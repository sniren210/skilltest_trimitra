import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../services/attendance_service.dart';
import '../locator.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = getIt<AttendanceService>();
  
  List<Attendance> _attendances = [];
  bool _isLoading = false;
  String? _error;
  Attendance? _todayAttendance;

  List<Attendance> get attendances => _attendances;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Attendance? get todayAttendance => _todayAttendance;
  bool get hasAttendedToday => _todayAttendance != null;

  AttendanceProvider() {
    loadAttendances();
  }

  Future<void> loadAttendances() async {
    _setLoading(true);
    try {
      _attendances = _attendanceService.getAllAttendances();
      _attendances.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      _checkTodayAttendance();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveAttendance(Attendance attendance) async {
    _setLoading(true);
    try {
      await _attendanceService.saveAttendance(attendance);
      await loadAttendances(); // Reload to get updated list
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearAllAttendances() async {
    _setLoading(true);
    try {
      await _attendanceService.clearAllAttendances();
      _attendances = [];
      _todayAttendance = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  List<Attendance> getAttendancesByDate(DateTime date) {
    return _attendances.where((attendance) {
      return attendance.dateTime.year == date.year &&
             attendance.dateTime.month == date.month &&
             attendance.dateTime.day == date.day;
    }).toList();
  }

  void _checkTodayAttendance() {
    final today = DateTime.now();
    _todayAttendance = _attendances.firstWhereOrNull((attendance) {
      return attendance.dateTime.year == today.year &&
             attendance.dateTime.month == today.month &&
             attendance.dateTime.day == today.day;
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
