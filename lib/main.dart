import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'models/attendance.dart';
import 'services/attendance_service.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/location_provider.dart';
import 'providers/auth_provider.dart';
import 'locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Setup service locator
  await setupLocator();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(AttendanceAdapter());
  
  // Initialize attendance service
  await AttendanceService.init();
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => getIt<ThemeProvider>(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => getIt<AuthProvider>(),
        ),
        ChangeNotifierProvider<AttendanceProvider>(
          create: (context) => getIt<AttendanceProvider>(),
        ),
        ChangeNotifierProvider<LocationProvider>(
          create: (context) => getIt<LocationProvider>(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Attendance App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
