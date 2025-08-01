import 'package:hive/hive.dart';
import '../models/attendance.dart';

class AttendanceService {
  static const String boxName = 'attendance_box';
  static Box<Attendance>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<Attendance>(boxName);
  }

  Future<void> saveAttendance(Attendance attendance) async {
    await _box?.put(attendance.id, attendance);
  }

  List<Attendance> getAllAttendances() {
    return _box?.values.toList() ?? [];
  }

  List<Attendance> getAttendancesByDate(DateTime date) {
    final attendances = getAllAttendances();
    return attendances.where((attendance) {
      return attendance.dateTime.year == date.year &&
             attendance.dateTime.month == date.month &&
             attendance.dateTime.day == date.day;
    }).toList();
  }

  bool hasAttendanceToday() {
    final today = DateTime.now();
    final todayAttendances = getAttendancesByDate(today);
    return todayAttendances.isNotEmpty;
  }

  Attendance? getTodayAttendance() {
    final today = DateTime.now();
    final todayAttendances = getAttendancesByDate(today);
    return todayAttendances.isNotEmpty ? todayAttendances.first : null;
  }

  Future<void> deleteAttendance(String id) async {
    await _box?.delete(id);
  }

  Future<void> clearAllAttendances() async {
    await _box?.clear();
  }
}
