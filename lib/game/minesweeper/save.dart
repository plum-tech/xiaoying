import 'package:json_annotation/json_annotation.dart';
import 'package:sit/game/storage/storage.dart';
import 'package:version/version.dart';

import 'entity/mode.dart';
import 'entity/cell.dart';

part "save.g.dart";

List<Cell4Save> _defaultCells() {
  return List.generate(
    GameMode.defaultRows * GameMode.defaultColumns,
    (index) => const Cell4Save(mine: false, state: CellState.covered),
  );
}

@JsonSerializable()
class Cell4Save {
  @JsonKey(defaultValue: false)
  final bool mine;
  @JsonKey(defaultValue: CellState.covered)
  final CellState state;

  const Cell4Save({
    required this.mine,
    required this.state,
  });

  Map<String, dynamic> toJson() => _$Cell4SaveToJson(this);

  factory Cell4Save.fromJson(Map<String, dynamic> json) => _$Cell4SaveFromJson(json);
}

@JsonSerializable()
class SaveMinesweeper {
  final int rows;
  final int columns;
  @JsonKey(defaultValue: _defaultCells)
  final List<Cell4Save> cells;
  final Duration duration;

  const SaveMinesweeper({
    this.rows = GameMode.defaultRows,
    this.columns = GameMode.defaultColumns,
    required this.cells,
    this.duration = Duration.zero,
  });

  Map<String, dynamic> toJson() => _$SaveMinesweeperToJson(this);

  factory SaveMinesweeper.fromJson(Map<String, dynamic> json) => _$SaveMinesweeperFromJson(json);

  static final storage = GameStorageBox<SaveMinesweeper>(
    name: "minesweeper",
    version: Version(1, 0, 0),
    serialize: (save) => save.toJson(),
    deserialize: SaveMinesweeper.fromJson,
  );
}
