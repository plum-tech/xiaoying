import 'package:sit/game/minesweeper/save.dart';

import '../entity/mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter/foundation.dart";
import 'package:logger/logger.dart';
import '../entity/board.dart';
import '../entity/cell.dart';
import '../entity/state.dart';
import 'package:sit/game/entity/game_state.dart';

// Debug Tool
final logger = Logger();

class GameLogic extends StateNotifier<GameStateMinesweeper> {
  GameLogic() : super(GameStateMinesweeper.byDefault());

  void initGame({required GameMode gameMode}) {
    final board = CellBoard.empty(rows: state.mode.gameRows, columns: state.mode.gameColumns);
    state = GameStateMinesweeper(mode: gameMode, board: board);
    if (kDebugMode) {
      logger.log(Level.info, "Game Init Finished");
    }
  }

  // TODO: finish this
  void fromSave(CellBoard save) {
    // state.mode = GameMode.easy;
    // state.board = save;
    // mineNum = save.mines;
    // if (kDebugMode) {
    //   logger.log(Level.info, "Game from save");
    // }
  }

  Duration get playTime => state.playTime;

  set playTime(Duration time) => state = state.copyWith(
        playTime: time,
      );

  Cell getCell({required row, required col}) {
    return state.board.getCell(row: row, column: col);
  }

  void _changeCell({required Cell cell, required CellState state}) {
    this.state = this.state.copyWith(
          board: this.state.board.changeCell(
                row: cell.row,
                column: cell.column,
                state: state,
              ),
        );
  }

  void dig({required Cell cell}) {
    // Generating mines on first dig
    if (state.state == GameState.idle) {
      final mode = state.mode;
      state = state.copyWith(
        state: GameState.running,
        board: CellBoard.withMines(
          rows: mode.gameRows,
          columns: mode.gameColumns,
          mines: mode.gameMines,
          rowExclude: cell.row,
          columnExclude: cell.column,
        ),
      );
    }
    if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.blank);
      // Check Game State
      if (cell.mine) {
        state = state.copyWith(
          state: GameState.gameOver,
        );
      } else {
        _digAroundIfSafe(cell: cell);
        if (checkWin()) {
          state = state.copyWith(
            state: GameState.victory,
          );
        }
      }
    } else {
      assert(false, "$cell");
    }
  }

  void _digAroundIfSafe({required Cell cell}) {
    if (cell.minesAround == 0) {
      for (final neighbor in state.board.iterateAround(row: cell.row, column: cell.column)) {
        if (neighbor.state == CellState.covered && neighbor.minesAround == 0) {
          _changeCell(cell: neighbor, state: CellState.blank);
          _digAroundIfSafe(cell: neighbor);
        } else if (!neighbor.mine && neighbor.state == CellState.covered && neighbor.minesAround != 0) {
          _changeCell(cell: neighbor, state: CellState.blank);
        }
      }
    }
  }

  bool digAroundBesidesFlagged({required Cell cell}) {
    bool digAny = false;
    if (state.board.countAroundByState(cell: cell, state: CellState.flag) >= cell.minesAround) {
      for (final neighbor in state.board.iterateAround(row: cell.row, column: cell.column)) {
        if (neighbor.state == CellState.covered) {
          dig(cell: neighbor);
          digAny = true;
        }
      }
    }
    return digAny;
  }

  bool flagRestCovered({required Cell cell}) {
    bool flagAny = false;
    final coveredCount = state.board.countAroundByState(cell: cell, state: CellState.covered);
    if (coveredCount == 0) return false;
    final flagCount = state.board.countAroundByState(cell: cell, state: CellState.flag);
    if (coveredCount + flagCount == cell.minesAround) {
      for (final neighbor in state.board.iterateAround(row: cell.row, column: cell.column)) {
        if (neighbor.state == CellState.covered) {
          flag(cell: neighbor);
          flagAny = true;
        }
      }
    }
    return flagAny;
  }

  bool checkWin() {
    var coveredCells = state.board.countAllByState(state: CellState.covered);
    var flagCells = state.board.countAllByState(state: CellState.flag);
    var mineCells = state.board.mines;
    if (kDebugMode) {
      logger.log(
        Level.debug,
        "mines: $mineCells, covers: $coveredCells, flags: $flagCells",
      );
    }
    if (coveredCells + flagCells == mineCells || flagCells >= mineCells) {
      return true;
    }
    return false;
  }

  void toggleFlag({required Cell cell}) {
    if (cell.state == CellState.flag) {
      _changeCell(cell: cell, state: CellState.covered);
    } else if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.flag);
    } else {
      assert(false, "$cell");
    }
  }

  void flag({required Cell cell}) {
    if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.flag);
    } else {
      assert(false, "$cell");
    }
  }

  void removeFlag({required Cell cell}) {
    if (cell.state == CellState.flag) {
      _changeCell(cell: cell, state: CellState.covered);
    } else {
      assert(false, "$cell");
    }
  }

  Future<void> save() async {
    if (state.state.shouldSave) {
      await SaveMinesweeper.storage.delete();
    } else {
      await SaveMinesweeper.storage.save(state.toSave());
    }
  }
}
