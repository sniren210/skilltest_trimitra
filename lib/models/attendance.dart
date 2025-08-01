import 'package:hive/hive.dart';

part 'attendance.g.dart';

@HiveType(typeId: 0)
class Attendance extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  double latitude;

  @HiveField(3)
  double longitude;

  @HiveField(4)
  String address;

  @HiveField(5)
  String photoPath;

  @HiveField(6)
  bool isLocationValid;

  @HiveField(7)
  double distanceFromOffice;

  Attendance({
    required this.id,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.photoPath,
    required this.isLocationValid,
    required this.distanceFromOffice,
  });

  String get formattedDate {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String get formattedTime {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
