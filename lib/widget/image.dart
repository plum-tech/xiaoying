import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mimir/l10n/common.dart';
import 'package:rettulf/rettulf.dart';
import 'package:mimir/widget/modal_image_view.dart';

const _i18n = CommonI18n();

enum _ImageMode {
  url,
  base64,
  error,
}

class CachedNetworkImageView extends StatelessWidget {
  final String imageUrl;

  const CachedNetworkImageView({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const CircularProgressIndicator.adaptive(),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image_rounded),
      fit: BoxFit.fitHeight,
    );
  }
}

class ImageView extends StatefulWidget {
  /// It could be a url of image, or a base64 string.
  final String? data;

  const ImageView(
    this.data, {
    super.key,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  var mode = _ImageMode.url;
  Uint8List? imageData;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void didUpdateWidget(covariant ImageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      refresh();
    }
  }

  void refresh() {
    final data = widget.data;
    setState(() {
      imageData = null;
    });
    if (data == null) {
      setState(() {
        mode = _ImageMode.error;
      });
    } else if (data.startsWith("data")) {
      setState(() {
        mode = _ImageMode.base64;
      });
      try {
        final parts = data.split(",");
        final bytes = const Base64Decoder().convert(parts[1]);
        setState(() {
          imageData = bytes;
        });
      } catch (error) {
        setState(() {
          mode = _ImageMode.error;
        });
      }
    } else {
      setState(() {
        mode = _ImageMode.url;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? provider;
    final data = widget.data;
    final imageData = this.imageData;
    if (mode == _ImageMode.url && data != null) {
      provider = CachedNetworkImageProvider(data);
    } else if (mode == _ImageMode.base64 && imageData != null) {
      provider = MemoryImage(imageData);
    } else {
      provider = null;
    }
    return ModalImageViewer(
      child: provider == null ? buildBrokenImage() : buildImage(provider),
    );
  }

  Widget buildImage(ImageProvider provider) {
    return Image(
      image: provider,
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          final current = loadingProgress.cumulativeBytesLoaded;
          final total = loadingProgress.expectedTotalBytes;
          if (total == null || total == 0) {
            return const CircularProgressIndicator.adaptive();
          } else {
            return CircularProgressIndicator(value: current / total);
          }
        }
      },
      errorBuilder: (ctx, error, stacktrace) {
        return buildBrokenImage();
      },
    );
  }

  Widget buildBrokenImage() {
    return const FittedBox(
      fit: BoxFit.fill,
      child: Icon(Icons.broken_image_rounded),
    );
  }
}

class ImageViewPage extends StatelessWidget {
  final String? data;
  final String? title;

  const ImageViewPage(
    this.data, {
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Save the image.
    return Scaffold(
      appBar: AppBar(
        title: (title ?? _i18n.untitled).text(),
      ),
      body: ImageView(data).center(),
    );
  }
}
