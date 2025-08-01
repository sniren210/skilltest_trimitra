import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:skilltest_trimitra/locator.dart';
import '../models/attendance.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import '../services/attendance_service.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/location_map_widget.dart';
import 'attendance_history_screen.dart';
import 'settings_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  Position? _currentPosition;
  String _locationStatus = 'Checking location...';
  String _detailedAddress = '';
  String? _photoPath;
  bool _isLocationValid = false;
  bool _isLoading = false;
  bool _hasAttendedToday = false;
  bool _isGettingLocation = true;
  Attendance? _todayAttendance;

  late AnimationController _pulseController;
  late AnimationController _cardController;

  late ScrollController _scrollController;

  final AttendanceService _attendanceService = getIt<AttendanceService>();
  final LocationService _locationService = getIt<LocationService>();

  bool get _isAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > (200 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkTodayAttendance();
    _getCurrentLocation();
    _cardController.forward();

    _scrollController = ScrollController()
      ..addListener(
        () {
          setState(() => _isAppBarExpanded);
        },
      );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _checkTodayAttendance() {
    _hasAttendedToday = _attendanceService.hasAttendanceToday();
    _todayAttendance = _attendanceService.getTodayAttendance();
    setState(() {});
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _locationStatus = 'Getting location...';
      _isGettingLocation = true;
    });

    try {
      Position position = await _locationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
        _isLocationValid = _locationService.isLocationValid(
          position.latitude,
          position.longitude,
        );
      });

      double distance = await _locationService.getDistanceFromOffice(position);

      String address = await _locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _detailedAddress = address;
        _locationStatus = _isLocationValid ? 'Location valid (${distance.toStringAsFixed(0)}m from office)' : 'Location invalid (${distance.toStringAsFixed(0)}m from office - must be within ${_locationService.validRadius.toStringAsFixed(0)}m)';
        _isGettingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationStatus = '$e';
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _takeSelfie() async {
    String? photoPath = await CameraService.takeSelfie();
    if (photoPath != null) {
      setState(() {
        _photoPath = photoPath;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Photo taken successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to take photo'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  Future<void> _submitAttendance() async {
    if (_currentPosition == null || _photoPath == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      double distance = await _locationService.getDistanceFromOffice(_currentPosition!);

      Attendance attendance = Attendance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: DateTime.now(),
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: _detailedAddress,
        photoPath: _photoPath!,
        isLocationValid: _isLocationValid,
        distanceFromOffice: distance,
      );

      await _attendanceService.saveAttendance(attendance);

      setState(() {
        _hasAttendedToday = true;
        _todayAttendance = attendance;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Attendance recorded successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error recording attendance: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[900]!,
                    Colors.grey[800]!,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    Colors.white,
                  ],
                ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                elevation: 0,
                backgroundColor: isDark ? Colors.grey[900] : AppTheme.primaryColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Attendance',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? LinearGradient(
                              colors: [Colors.grey[800]!, Colors.grey[900]!],
                            )
                          : AppTheme.primaryGradient,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.light_mode : Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.white,
                    ),
                    onPressed: themeProvider.toggleTheme,
                  ),
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const AttendanceHistoryScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return SlideTransition(
                              position: animation.drive(
                                Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut)),
                              ),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // User Info Card
                    AnimatedCard(
                      delay: 200.ms,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, User',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.grey[800] : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                StreamBuilder(
                                  stream: Stream.periodic(const Duration(seconds: 1)),
                                  builder: (context, snapshot) {
                                    return Text(
                                      DateFormat('HH:mm:ss').format(DateTime.now()),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Attendance Status Card
                    AnimatedCard(
                      delay: 400.ms,
                      color: _hasAttendedToday ? (isDark ? Colors.green[900]?.withOpacity(0.3) : Colors.green[50]) : (isDark ? Colors.orange[900]?.withOpacity(0.3) : Colors.orange[50]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _hasAttendedToday ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _hasAttendedToday ? Icons.check_circle : Icons.pending,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _hasAttendedToday ? 'Already Attended Today' : 'Not Attended Yet',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          if (_hasAttendedToday && _todayAttendance != null) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                                      const SizedBox(width: 8),
                                      Text('Time: ${_todayAttendance!.formattedTime}'),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        _todayAttendance!.isLocationValid ? Icons.location_on : Icons.location_off,
                                        size: 16,
                                        color: _todayAttendance!.isLocationValid ? Colors.green : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Location: ${_todayAttendance!.isLocationValid ? "Valid" : "Invalid"}',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Location Card
                    AnimatedCard(
                      delay: 600.ms,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _isLocationValid ? Colors.green : Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _isLocationValid ? Icons.location_on : Icons.location_off,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Location Status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_isGettingLocation)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          StatusChip(
                            label: _locationStatus,
                            isValid: _isLocationValid,
                            icon: _isLocationValid ? Icons.check : Icons.close,
                            delay: 800.ms,
                          ),
                          if (_detailedAddress.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.place, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _detailedAddress,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isGettingLocation ? null : _getCurrentLocation,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh Location'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Map Card
                    if (_currentPosition != null)
                      AnimatedCard(
                        delay: 800.ms,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.map,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Location Map',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LocationMapWidget(
                              userLatitude: _currentPosition?.latitude,
                              userLongitude: _currentPosition?.longitude,
                              height: 200,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Camera Section
                    AnimatedCard(
                      delay: 1000.ms,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.successGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Selfie Photo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_photoPath != null) ...[
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  File(_photoPath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _hasAttendedToday ? null : _takeSelfie,
                              icon: const Icon(Icons.camera_alt),
                              label: Text(_photoPath != null ? 'Retake Photo' : 'Take Selfie'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                backgroundColor: AppTheme.successColor,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    GradientButton(
                      onPressed: (_hasAttendedToday || !_isLocationValid || _photoPath == null || _isLoading) ? null : _submitAttendance,
                      text: _hasAttendedToday ? 'Already Attended Today' : 'Submit Attendance',
                      gradient: _hasAttendedToday ? LinearGradient(colors: [Colors.grey, Colors.grey.shade400]) : AppTheme.primaryGradient,
                      isLoading: _isLoading,
                      delay: 1200.ms,
                      height: 56,
                    ),

                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
