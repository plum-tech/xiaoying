import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:flutter/foundation.dart";
import 'package:logger/logger.dart';
import 'mineboard.dart';

// Debug Tool
final logger = Logger();

// Board Size
const cellWidth = 40.0;
const cellRadius = 2.0;

const boardRows = 15;
const boardCols = 8;
const borderWidth = 5.0;

const boardWidth = cellWidth * boardCols + borderWidth * 2;
const boardHeight = cellWidth * boardRows + borderWidth * 2;

class GameLogic extends StateNotifier<GameStates> {
  GameLogic(this.ref) : super(GameStates());
  final StateNotifierProviderRef ref;

  // Generating Mines When First Click
  bool firstClick = true;
  int mineNum = (boardRows * boardCols * 0.15).floor();

  void initGame() {
    state.gameOver = false;
    state.goodGame = false;
    state.board = MineBoard(rows: boardRows, cols: boardCols);
    firstClick = true;
    if (kDebugMode) {
      logger.log(Level.info, "Game init finished");
    }
  }

  Cell getCell({required row, required col}) {
    return state.board.getCell(row: row, col: col);
  }

  void _changeCell({required Cell cell, required CellState state}) {
    this.state.board.changeCell(row: cell.row, col: cell.col, state: state);
  }

  void dig({required Cell cell}) {
    if (cell.state == CellState.covered) {
      _changeCell(cell: cell, state: CellState.blank);
      _digAround(checkCell: cell);
      // Check Game State
      if (cell.mine) {
        state.gameOver = true;
      } else if (checkWin()) {
        state.goodGame = true;
      }
    } else {
      assert(false, "$cell");
    }
  }

  void _digAround({required Cell checkCell}) {
    if (firstClick) {
      state.board.randomMines(number: mineNum, clickRow: checkCell.row, clickCol: checkCell.col);
      firstClick = false;
    }
    if (checkCell.around == 0) {
      var dx = [1, 0, -1, 0];
      var dy = [0, 1, 0, -1];
      for (int i = 0; i < 4; i++) {
        var nextRow = checkCell.row + dy[i];
        nextRow = nextRow < 0 ? 0 : nextRow;
        nextRow = nextRow >= boardRows ? boardRows - 1 : nextRow;
        var nextCol = checkCell.col + dx[i];
        nextCol = nextCol < 0 ? 0 : nextCol;
        nextCol = nextCol >= boardCols ? boardCols - 1 : nextCol;
        // Get the next pose cell state
        Cell nextCell = getCell(row: nextRow, col: nextCol);
        // Check the next cell
        if (nextCell.state == CellState.covered && nextCell.around == 0) {
          _changeCell(cell: nextCell, state: CellState.blank);
          _digAround(checkCell: nextCell);
        } else if (!nextCell.mine && nextCell.state == CellState.covered && nextCell.around != 0) {
          _changeCell(cell: nextCell, state: CellState.blank);
        }
      }
    }
  }

  bool checkWin() {
    var coveredCells = state.board.countState(state: CellState.covered);
    var flagCells = state.board.countState(state: CellState.flag);
    var mineCells = state.board.countMines();
    if (kDebugMode) {
      logger.log(
        Level.debug,
        "mines: $mineCells, covers: $coveredCells, flags: $flagCells",
      );
    }
    if (coveredCells + flagCells == mineCells) {
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
}

class GameStates {
  late bool gameOver;
  late bool goodGame;
  late MineBoard board;
}

final boardManager = StateNotifierProvider<GameLogic, GameStates>((ref) {
  return GameLogic(ref);
});
