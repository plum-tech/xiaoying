export "package:hive/hive.dart";

/// Basic 0-19
class CoreHiveType {
  static const size = 0;
  static const themeMode = 1;
  static const version = 2;
  static const campus = 3;
  static const credentials = 4;
  static const oaLoginStatus = 5;
  static const oaUserType = 6;
}

class CacheHiveType {
  // School 20
  static const _school = 0;
  static const semester = _school + 0;
  static const semesterInfo = _school + 1;
  static const courseCat = _school + 2;

  // Exam result 10
  static const _examResult = _school + 20;
  static const examResultUg = _examResult + 0;
  static const examResultUgItem = _examResult + 1;
  static const examResultUgExamType = _examResult + 2;
  static const examResultPg = _examResult + 3;

  // Second class 20
  static const _class2nd = _examResult + 10;
  static const activity = _class2nd + 0;
  static const activityDetails = _class2nd + 1;
  static const activityCat = _class2nd + 2;
  static const class2ndPointsSummary = _class2nd + 3;
  static const class2ndActivityApplication = _class2nd + 4;
  static const class2ndActivityApplicationStatus = _class2nd + 5;
  static const class2ndPointItem = _class2nd + 6;
  static const class2ndScoreType = _class2nd + 7;

  // Expense 10
  static const _expense = _class2nd + 20;
  static const expenseTransactionType = _expense + 0;
  static const expenseTransaction = _expense + 1;

  // Electricity 10
  static const _electricity = _expense + 10;
  static const electricityBalance = _electricity + 0;

  // Ywb 20
  static const _ywb = _electricity + 10;
  static const ywbServiceDetails = _ywb + 0;
  static const ywbServiceDetailSection = _ywb + 1;
  static const ywbService = _ywb + 2;
  static const ywbApplication = _ywb + 3;
  static const ywbApplicationTrack = _ywb + 4;

  // OaAnnounce 10
  static const _oaAnnounce = _ywb + 20;
  static const oaAnnounceDetails = _oaAnnounce + 0;
  static const oaAnnounceAttachment = _oaAnnounce + 1;
  static const oaAnnounceRecord = _oaAnnounce + 2;

  // School yellow pages 5
  static const _yellowPages = _oaAnnounce + 10;
  // static const schoolContact = _yellowPages + 0;

  // Library 20
  static const _library = _yellowPages + 5;
  static const libraryBook = _library + 0;
  static const libraryBookImage = _library + 1;
  static const libraryBookDetails = _library + 2;
  static const libraryBorrowedBook = _library + 3;
  static const libraryBorrowingHistory = _library + 4;
  static const libraryBorrowingHistoryOp = _library + 5;
}
