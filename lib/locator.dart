import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/attendance_service.dart';
import 'services/location_service.dart';
import 'services/camera_service.dart';
import 'providers/theme_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/location_provider.dart';
import 'providers/auth_provider.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Register Services
  getIt.registerLazySingleton<AttendanceService>(() => AttendanceService());
  getIt.registerLazySingleton<LocationService>(() => LocationService());
  getIt.registerLazySingleton<CameraService>(() => CameraService());

  // Register Providers
  getIt.registerLazySingleton<ThemeProvider>(() => ThemeProvider());
  getIt.registerLazySingleton<AttendanceProvider>(() => AttendanceProvider());
  getIt.registerLazySingleton<LocationProvider>(() => LocationProvider());
  getIt.registerLazySingleton<AuthProvider>(() => AuthProvider());
}