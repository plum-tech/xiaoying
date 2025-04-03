/*
Original author: https://github.com/juliansteenbakker/duration_picker

MIT License

Copyright (c) 2018 Chris Harris

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 */

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

const Duration _kDialAnimateDuration = Duration(milliseconds: 200);

const double _kDurationPickerWidthPortrait = 328.0;
const double _kDurationPickerWidthLandscape = 512.0;

const double _kDurationPickerHeightPortrait = 380.0;
const double _kDurationPickerHeightLandscape = 304.0;

const double _kTwoPi = 2 * math.pi;
const double _kPiByTwo = math.pi / 2;

const double _kCircleTop = _kPiByTwo;

/// Use [DialPainter] to style the durationPicker to your style.
class DialPainter extends CustomPainter {
  const DialPainter({
    required this.context,
    required this.labels,
    required this.backgroundColor,
    required this.accentColor,
    required this.theta,
    required this.textDirection,
    required this.selectedValue,
    required this.pct,
    required this.baseUnitMultiplier,
    required this.baseUnitHand,
    required this.baseUnit,
  });

  final List<TextPainter> labels;
  final Color? backgroundColor;
  final Color accentColor;
  final double theta;
  final TextDirection textDirection;
  final int? selectedValue;
  final BuildContext context;

  final double pct;
  final int baseUnitMultiplier;
  final int baseUnitHand;
  final BaseUnit baseUnit;

  @override
  void paint(Canvas canvas, Size size) {
    const epsilon = .001;
    const sweep = _kTwoPi - epsilon;
    const startAngle = -math.pi / 2.0;

    final radius = size.shortestSide / 2.0;
    final center = Offset(size.width / 2.0, size.height / 2.0);
    final centerPoint = center;

    final pctTheta = (0.25 - (theta % _kTwoPi) / _kTwoPi) % 1.0;

    // Draw the background outer ring
    canvas.drawCircle(centerPoint, radius, Paint()..color = backgroundColor!);

    // Draw a translucent circle for every secondary unit
    for (var i = 0; i < baseUnitMultiplier; i = i + 1) {
      canvas.drawCircle(
        centerPoint,
        radius,
        Paint()..color = accentColor.withOpacity((i == 0) ? 0.3 : 0.1),
      );
    }

    // Draw the inner background circle
    canvas.drawCircle(
      centerPoint,
      radius * 0.88,
      Paint()..color = Theme.of(context).canvasColor,
    );

    // Get the offset point for an angle value of theta, and a distance of _radius
    Offset getOffsetForTheta(double theta, double radius) {
      return center + Offset(radius * math.cos(theta), -radius * math.sin(theta));
    }

    // Draw the handle that is used to drag and to indicate the position around the circle
    final handlePaint = Paint()..color = accentColor;
    final handlePoint = getOffsetForTheta(theta, radius - 10.0);
    canvas.drawCircle(handlePoint, 20.0, handlePaint);

    // Get the appropriate base unit string
    String getBaseUnitString() {
      switch (baseUnit) {
        case BaseUnit.millisecond:
          return 'ms.';
        case BaseUnit.second:
          return 'sec.';
        case BaseUnit.minute:
          return 'min.';
        case BaseUnit.hour:
          return 'hr.';
      }
    }

    // Get the appropriate secondary unit string
    String getSecondaryUnitString() {
      switch (baseUnit) {
        case BaseUnit.millisecond:
          return 's ';
        case BaseUnit.second:
          return 'm ';
        case BaseUnit.minute:
          return 'h ';
        case BaseUnit.hour:
          return 'd ';
      }
    }

    // Draw the Text in the center of the circle which displays the duration string
    final secondaryUnits = (baseUnitMultiplier == 0) ? '' : '$baseUnitMultiplier${getSecondaryUnitString()} ';
    final baseUnits = '$baseUnitHand';

    final textDurationValuePainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: '$secondaryUnits$baseUnits',
        style: Theme.of(context).textTheme.displayMedium!.copyWith(fontSize: size.shortestSide * 0.15),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final middleForValueText = Offset(
      centerPoint.dx - (textDurationValuePainter.width / 2),
      centerPoint.dy - textDurationValuePainter.height / 2,
    );
    textDurationValuePainter.paint(canvas, middleForValueText);

    final textMinPainter = TextPainter(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: getBaseUnitString(), //th: ${theta}',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textMinPainter.paint(
      canvas,
      Offset(
        centerPoint.dx - (textMinPainter.width / 2),
        centerPoint.dy + (textDurationValuePainter.height / 2) - textMinPainter.height / 2,
      ),
    );

    // Draw an arc around the circle for the amount of the circle that has elapsed.
    final elapsedPainter = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withOpacity(0.3)
      ..isAntiAlias = true
      ..strokeWidth = radius * 0.12;

    canvas.drawArc(
      Rect.fromCircle(
        center: centerPoint,
        radius: radius - radius * 0.12 / 2,
      ),
      startAngle,
      sweep * pctTheta,
      false,
      elapsedPainter,
    );

    // Paint the labels (the minute strings)
    void paintLabels(List<TextPainter> labels) {
      final labelThetaIncrement = -_kTwoPi / labels.length;
      var labelTheta = _kPiByTwo;

      for (final label in labels) {
        final labelOffset = Offset(-label.width / 2.0, -label.height / 2.0);

        label.paint(
          canvas,
          getOffsetForTheta(labelTheta, radius - 40.0) + labelOffset,
        );

        labelTheta += labelThetaIncrement;
      }
    }

    paintLabels(labels);
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) {
    return oldDelegate.labels != labels ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.theta != theta;
  }
}

class _Dial extends StatefulWidget {
  const _Dial({
    required this.duration,
    required this.onChanged,
    this.baseUnit = BaseUnit.minute,
    this.snapToMins = 1.0,
  });

  final Duration duration;
  final ValueChanged<Duration> onChanged;
  final BaseUnit baseUnit;

  /// The resolution of mins of the dial, i.e. if snapToMins = 5.0, only durations of 5min intervals will be selectable.
  final double? snapToMins;

  @override
  _DialState createState() => _DialState();
}

class _DialState extends State<_Dial> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _thetaController = AnimationController(
      duration: _kDialAnimateDuration,
      vsync: this,
    );
    _thetaTween = Tween<double>(
      begin: _getThetaForDuration(widget.duration, widget.baseUnit),
    );
    _theta = _thetaTween.animate(
      CurvedAnimation(parent: _thetaController, curve: Curves.fastOutSlowIn),
    )..addListener(() => setState(() {}));
    _thetaController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _secondaryUnitValue = _secondaryUnitHand();
        _baseUnitValue = _baseUnitHand();
        setState(() {});
      }
    });

    _turningAngle = _kPiByTwo - _turningAngleFactor() * _kTwoPi;
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();
  }

  late ThemeData themeData;
  MaterialLocalizations? localizations;
  MediaQueryData? media;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    assert(debugCheckHasMediaQuery(context));
    themeData = Theme.of(context);
    localizations = MaterialLocalizations.of(context);
    media = MediaQuery.of(context);
  }

  @override
  void dispose() {
    _thetaController.dispose();
    super.dispose();
  }

  late Tween<double> _thetaTween;
  late Animation<double> _theta;
  late AnimationController _thetaController;

  final double _pct = 0.0;
  int _secondaryUnitValue = 0;
  bool _dragging = false;
  int _baseUnitValue = 0;
  double _turningAngle = 0.0;

  static double _nearest(double target, double a, double b) {
    return ((target - a).abs() < (target - b).abs()) ? a : b;
  }

  void _animateTo(double targetTheta) {
    final currentTheta = _theta.value;
    var beginTheta = _nearest(targetTheta, currentTheta, currentTheta + _kTwoPi);
    beginTheta = _nearest(targetTheta, beginTheta, currentTheta - _kTwoPi);
    _thetaTween
      ..begin = beginTheta
      ..end = targetTheta;
    _thetaController
      ..value = 0.0
      ..forward();
  }

  // Converts the duration to the chosen base unit. For example, for base unit minutes, this gets the number of minutes
  // in the duration
  int _getDurationInBaseUnits(Duration duration, BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds;
      case BaseUnit.second:
        return duration.inSeconds;
      case BaseUnit.minute:
        return duration.inMinutes;
      case BaseUnit.hour:
        return duration.inHours;
    }
  }

  // Converts the duration to the chosen secondary unit. For example, for base unit minutes, this gets the number
  // of hours in the duration
  int _getDurationInSecondaryUnits(Duration duration, BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return duration.inSeconds;
      case BaseUnit.second:
        return duration.inMinutes;
      case BaseUnit.minute:
        return duration.inHours;
      case BaseUnit.hour:
        return duration.inDays;
    }
  }

  // Gets the relation between the base unit and the secondary unit, which is the unit just greater than the base unit.
  // For example if the base unit is second, it will get the number of seconds in a minute
  int _getBaseUnitToSecondaryUnitFactor(BaseUnit baseUnit) {
    switch (baseUnit) {
      case BaseUnit.millisecond:
        return Duration.millisecondsPerSecond;
      case BaseUnit.second:
        return Duration.secondsPerMinute;
      case BaseUnit.minute:
        return Duration.minutesPerHour;
      case BaseUnit.hour:
        return Duration.hoursPerDay;
    }
  }

  double _getThetaForDuration(Duration duration, BaseUnit baseUnit) {
    final int baseUnits = _getDurationInBaseUnits(duration, baseUnit);
    final int baseToSecondaryFactor = _getBaseUnitToSecondaryUnitFactor(baseUnit);

    return (_kPiByTwo - (baseUnits % baseToSecondaryFactor) / baseToSecondaryFactor.toDouble() * _kTwoPi) % _kTwoPi;
  }

  double _turningAngleFactor() {
    return _getDurationInBaseUnits(widget.duration, widget.baseUnit) /
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  // TODO: Fix snap to mins
  Duration _getTimeForTheta(double theta) {
    return _angleToDuration(_turningAngle);
    // var fractionalRotation = (0.25 - (theta / _kTwoPi));
    // fractionalRotation = fractionalRotation < 0
    //    ? 1 - fractionalRotation.abs()
    //    : fractionalRotation;
    // var mins = (fractionalRotation * 60).round();
    // debugPrint('Mins0: ${widget.snapToMins }');
    // if (widget.snapToMins != null) {
    //   debugPrint('Mins1: $mins');
    //  mins = ((mins / widget.snapToMins!).round() * widget.snapToMins!).round();
    //   debugPrint('Mins2: $mins');
    // }
    // if (mins == 60) {
    //  // _snappedHours = _hours + 1;
    //  // mins = 0;
    //  return new Duration(hours: 1, minutes: mins);
    // } else {
    //  // _snappedHours = _hours;
    //  return new Duration(hours: _hours, minutes: mins);
    // }
  }

  Duration _notifyOnChangedIfNeeded() {
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();
    final d = _angleToDuration(_turningAngle);
    widget.onChanged(d);

    return d;
  }

  void _updateThetaForPan() {
    setState(() {
      final offset = _position! - _center!;
      final angle = (math.atan2(offset.dx, offset.dy) - _kPiByTwo) % _kTwoPi;

      // Stop accidental abrupt pans from making the dial seem like it starts from 1h.
      // (happens when wanting to pan from 0 clockwise, but when doing so quickly, one actually pans from before 0 (e.g. setting the duration to 59mins, and then crossing 0, which would then mean 1h 1min).
      if (angle >= _kCircleTop &&
          _theta.value <= _kCircleTop &&
          _theta.value >= 0.1 && // to allow the radians sign change at 15mins.
          _secondaryUnitValue == 0) return;

      _thetaTween
        ..begin = angle
        ..end = angle;
    });
  }

  Offset? _position;
  Offset? _center;

  void _handlePanStart(DragStartDetails details) {
    assert(!_dragging);
    _dragging = true;
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);

    _notifyOnChangedIfNeeded();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final oldTheta = _theta.value;
    _position = _position! + details.delta;
    // _position! += details.delta;
    _updateThetaForPan();
    final newTheta = _theta.value;

    _updateTurningAngle(oldTheta, newTheta);
    _notifyOnChangedIfNeeded();
  }

  int _secondaryUnitHand() {
    return _getDurationInSecondaryUnits(widget.duration, widget.baseUnit);
  }

  int _baseUnitHand() {
    // Result is in [0; num base units in secondary unit - 1], even if overall time is >= 1 secondary unit
    return _getDurationInBaseUnits(widget.duration, widget.baseUnit) %
        _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  Duration _angleToDuration(double angle) {
    return _baseUnitToDuration(_angleToBaseUnit(angle));
  }

  Duration _baseUnitToDuration(double baseUnitValue) {
    final int unitFactor = _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);

    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return Duration(
          seconds: baseUnitValue ~/ unitFactor,
          milliseconds: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.second:
        return Duration(
          minutes: baseUnitValue ~/ unitFactor,
          seconds: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.minute:
        return Duration(
          hours: baseUnitValue ~/ unitFactor,
          minutes: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
      case BaseUnit.hour:
        return Duration(
          days: baseUnitValue ~/ unitFactor,
          hours: (baseUnitValue % unitFactor.toDouble()).toInt(),
        );
    }
  }

  String _durationToBaseUnitString(Duration duration) {
    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        return duration.inMilliseconds.toString();
      case BaseUnit.second:
        return duration.inSeconds.toString();
      case BaseUnit.minute:
        return duration.inMinutes.toString();
      case BaseUnit.hour:
        return duration.inHours.toString();
    }
  }

  double _angleToBaseUnit(double angle) {
    // Coordinate transformation from mathematical COS to dial COS
    final dialAngle = _kPiByTwo - angle;

    // Turn dial angle into minutes, may go beyond 60 minutes (multiple turns)
    return dialAngle / _kTwoPi * _getBaseUnitToSecondaryUnitFactor(widget.baseUnit);
  }

  void _updateTurningAngle(double oldTheta, double newTheta) {
    // Register any angle by which the user has turned the dial.
    //
    // The resulting turning angle fully captures the state of the dial,
    // including multiple turns (= full hours). The [_turningAngle] is in
    // mathematical coordinate system, i.e. 3-o-clock position being zero, and
    // increasing counter clock wise.

    // From positive to negative (in mathematical COS)
    if (newTheta > 1.5 * math.pi && oldTheta < 0.5 * math.pi) {
      _turningAngle = _turningAngle - ((_kTwoPi - newTheta) + oldTheta);
    }
    // From negative to positive (in mathematical COS)
    else if (newTheta < 0.5 * math.pi && oldTheta > 1.5 * math.pi) {
      _turningAngle = _turningAngle + ((_kTwoPi - oldTheta) + newTheta);
    } else {
      _turningAngle = _turningAngle + (newTheta - oldTheta);
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    assert(_dragging);
    _dragging = false;
    _position = null;
    _center = null;
    _animateTo(_getThetaForDuration(widget.duration, widget.baseUnit));
  }

  void _handleTapUp(TapUpDetails details) {
    final box = context.findRenderObject() as RenderBox?;
    _position = box?.globalToLocal(details.globalPosition);
    _center = box?.size.center(Offset.zero);
    _updateThetaForPan();
    _notifyOnChangedIfNeeded();

    _animateTo(
      _getThetaForDuration(_getTimeForTheta(_theta.value), widget.baseUnit),
    );
    _dragging = false;
    _position = null;
    _center = null;
  }

  List<TextPainter> _buildBaseUnitLabels(TextTheme textTheme) {
    final style = textTheme.titleMedium;

    var baseUnitMarkerValues = <Duration>[];

    switch (widget.baseUnit) {
      case BaseUnit.millisecond:
        const int interval = 100;
        const int factor = Duration.millisecondsPerSecond;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(milliseconds: index * interval),
        );
        break;
      case BaseUnit.second:
        const int interval = 5;
        const int factor = Duration.secondsPerMinute;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(seconds: index * interval),
        );
        break;
      case BaseUnit.minute:
        const int interval = 5;
        const int factor = Duration.minutesPerHour;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(
          length,
          (index) => Duration(minutes: index * interval),
        );
        break;
      case BaseUnit.hour:
        const int interval = 3;
        const int factor = Duration.hoursPerDay;
        const int length = factor ~/ interval;
        baseUnitMarkerValues = List.generate(length, (index) => Duration(hours: index * interval));
        break;
    }

    final labels = <TextPainter>[];
    for (final duration in baseUnitMarkerValues) {
      final painter = TextPainter(
        text: TextSpan(style: style, text: _durationToBaseUnitString(duration)),
        textDirection: TextDirection.ltr,
      )..layout();
      labels.add(painter);
    }
    return labels;
  }

  @override
  Widget build(BuildContext context) {
    Color? backgroundColor;
    switch (themeData.brightness) {
      case Brightness.light:
        backgroundColor = Colors.grey[200];
        break;
      case Brightness.dark:
        backgroundColor = themeData.colorScheme.surface;
        break;
    }

    final theme = Theme.of(context);

    int? selectedDialValue;
    _secondaryUnitValue = _secondaryUnitHand();
    _baseUnitValue = _baseUnitHand();

    return GestureDetector(
      excludeFromSemantics: true,
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      onTapUp: _handleTapUp,
      child: CustomPaint(
        painter: DialPainter(
          pct: _pct,
          baseUnitMultiplier: _secondaryUnitValue,
          baseUnitHand: _baseUnitValue,
          baseUnit: widget.baseUnit,
          context: context,
          selectedValue: selectedDialValue,
          labels: _buildBaseUnitLabels(theme.textTheme),
          backgroundColor: backgroundColor,
          accentColor: themeData.colorScheme.secondary,
          theta: _theta.value,
          textDirection: Directionality.of(context),
        ),
      ),
    );
  }
}

/// A duration picker designed to appear inside a popup dialog.
///
/// Pass this widget to [showDialog]. The value returned by [showDialog] is the
/// selected [Duration] if the user taps the "OK" button, or null if the user
/// taps the "CANCEL" button. The selected time is reported by calling
/// [Navigator.pop].
class DurationPickerDialog extends StatefulWidget {
  /// Creates a duration picker.
  ///
  /// [initialTime] must not be null.
  const DurationPickerDialog({
    super.key,
    required this.initialTime,
    this.baseUnit = BaseUnit.minute,
    this.snapToMins = 1.0,
    this.decoration,
  });

  /// The duration initially selected when the dialog is shown.
  final Duration initialTime;
  final BaseUnit baseUnit;
  final double snapToMins;
  final BoxDecoration? decoration;

  @override
  DurationPickerDialogState createState() => DurationPickerDialogState();
}

class DurationPickerDialogState extends State<DurationPickerDialog> {
  @override
  void initState() {
    super.initState();
    _selectedDuration = widget.initialTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    localizations = MaterialLocalizations.of(context);
  }

  Duration? get selectedDuration => _selectedDuration;
  Duration? _selectedDuration;

  late MaterialLocalizations localizations;

  void _handleTimeChanged(Duration value) {
    setState(() {
      _selectedDuration = value;
    });
  }

  void _handleCancel() {
    Navigator.pop(context);
  }

  void _handleOk() {
    Navigator.pop(context, _selectedDuration);
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMediaQuery(context));
    final theme = Theme.of(context);
    final boxDecoration = widget.decoration ?? BoxDecoration(color: theme.dialogBackgroundColor);
    final Widget picker = Padding(
      padding: const EdgeInsets.all(16.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: _Dial(
          duration: _selectedDuration!,
          onChanged: _handleTimeChanged,
          baseUnit: widget.baseUnit,
          snapToMins: widget.snapToMins,
        ),
      ),
    );

    final Widget actions = ButtonBarTheme(
      data: ButtonBarTheme.of(context),
      child: OverflowBar(
        children: <Widget>[
          TextButton(
            onPressed: _handleCancel,
            child: Text(localizations.cancelButtonLabel),
          ),
          TextButton(
            onPressed: _handleOk,
            child: Text(localizations.okButtonLabel),
          ),
        ],
      ),
    );

    final dialog = Dialog(
      child: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final Widget pickerAndActions = DecoratedBox(
            decoration: boxDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: picker,
                ), // picker grows and shrinks with the available space
                actions,
              ],
            ),
          );

          switch (orientation) {
            case Orientation.portrait:
              return SizedBox(
                width: _kDurationPickerWidthPortrait,
                height: _kDurationPickerHeightPortrait,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Expanded(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
            case Orientation.landscape:
              return SizedBox(
                width: _kDurationPickerWidthLandscape,
                height: _kDurationPickerHeightLandscape,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Flexible(
                      child: pickerAndActions,
                    ),
                  ],
                ),
              );
          }
        },
      ),
    );

    return Theme(
      data: theme.copyWith(
        dialogBackgroundColor: Colors.transparent,
      ),
      child: dialog,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Shows a dialog containing the duration picker.
///
/// The returned Future resolves to the duration selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// To show a dialog with [initialTime] equal to the current time:
///
/// ```dart
/// showDurationPicker(
///   initialTime: new Duration.now(),
///   context: context,
/// );
/// ```
Future<Duration?> showDurationPicker({
  required BuildContext context,
  required Duration initialTime,
  BaseUnit baseUnit = BaseUnit.minute,
  double snapToMins = 1.0,
  BoxDecoration? decoration,
}) async {
  return showAdaptiveDialog<Duration>(
    context: context,
    builder: (BuildContext context) => DurationPickerDialog(
      initialTime: initialTime,
      baseUnit: baseUnit,
      snapToMins: snapToMins,
      decoration: decoration,
    ),
  );
}

/// The [DurationPicker] widget.
class DurationPicker extends StatelessWidget {
  final Duration duration;
  final ValueChanged<Duration> onChange;
  final BaseUnit baseUnit;
  final double? snapToMins;

  final double? width;
  final double? height;

  const DurationPicker({
    super.key,
    this.duration = Duration.zero,
    required this.onChange,
    this.baseUnit = BaseUnit.minute,
    this.snapToMins,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? _kDurationPickerWidthPortrait / 1.5,
      height: height ?? _kDurationPickerHeightPortrait / 1.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _Dial(
              duration: duration,
              onChanged: onChange,
              baseUnit: baseUnit,
              snapToMins: snapToMins,
            ),
          ),
        ],
      ),
    );
  }
}

/// This enum contains the possible units for the [DurationPicker]
enum BaseUnit {
  millisecond,
  second,
  minute,
  hour,
}
