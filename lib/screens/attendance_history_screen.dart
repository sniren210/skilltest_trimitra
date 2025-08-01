import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/attendance.dart';
import '../theme/app_theme.dart';
import '../providers/theme_provider.dart';
import '../providers/attendance_provider.dart';
import '../widgets/animated_widgets.dart';
import 'settings_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showAttendanceDetails(Attendance attendance) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AttendanceDetailsModal(attendance: attendance),
    );
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
          child: Consumer<AttendanceProvider>(
            builder: (context, attendanceProvider, child) {
              final attendances = attendanceProvider.attendances;

              return CustomScrollView(
                slivers: [
                  // Modern App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    elevation: 0,
                    backgroundColor: isDark ? Colors.grey[900] : AppTheme.primaryColor,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: const Text(
                        'Attendance History',
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
                          color: Colors.white,
                        ),
                        onPressed: themeProvider.toggleTheme,
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

                  // Loading state
                  if (attendanceProvider.isLoading)
                    SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      ),
                    )
                  // Error state
                  else if (attendanceProvider.error != null)
                    SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading attendance data',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              attendanceProvider.error!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => attendanceProvider.loadAttendances(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  // Empty state
                  else if (attendances.isEmpty)
                    SliverFillRemaining(
                      child: _buildEmptyState(isDark),
                    )
                  // Content
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final attendance = attendances[index];
                            return _buildAttendanceCard(attendance, index, isDark).animate(delay: (index * 100).ms).fadeIn(duration: 600.ms, curve: Curves.easeOut).slideY(begin: 0.3, end: 0, duration: 600.ms);
                          },
                          childCount: attendances.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey[800] : Colors.grey[100],
            ),
            child: Icon(
              Icons.history,
              size: 64,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.5, 0.5),
                duration: 800.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 800.ms),
          const SizedBox(height: 24),
          Text(
            'No attendance records found',
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0, duration: 800.ms),
          const SizedBox(height: 8),
          Text(
            'Your attendance history will appear here',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 800.ms).slideY(begin: 0.3, end: 0, duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance, int index, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showAttendanceDetails(attendance),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Photo thumbnail
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: attendance.isLocationValid ? Colors.green : Colors.red,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: File(attendance.photoPath).existsSync()
                          ? Image.file(
                              File(attendance.photoPath),
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                              child: Icon(
                                Icons.image_not_supported,
                                color: isDark ? Colors.grey[600] : Colors.grey[400],
                                size: 24,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Date and time info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          attendance.formattedDate,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              attendance.formattedTime,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: attendance.isLocationValid ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${attendance.distanceFromOffice.toStringAsFixed(0)}m from office',
                              style: TextStyle(
                                fontSize: 12,
                                color: attendance.isLocationValid ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  StatusChip(
                    label: attendance.isLocationValid ? 'Valid' : 'Invalid',
                    isValid: attendance.isLocationValid,
                    icon: attendance.isLocationValid ? Icons.check_circle : Icons.cancel,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),

              // Address preview
              Row(
                children: [
                  Icon(
                    Icons.place,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      attendance.address.length > 50 ? '${attendance.address.substring(0, 50)}...' : attendance.address,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttendanceDetailsModal extends StatelessWidget {
  final Attendance attendance;

  const _AttendanceDetailsModal({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Attendance Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    StatusChip(
                      label: attendance.isLocationValid ? 'Valid' : 'Invalid',
                      isValid: attendance.isLocationValid,
                      icon: attendance.isLocationValid ? Icons.check_circle : Icons.cancel,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Photo
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: attendance.isLocationValid ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: File(attendance.photoPath).existsSync()
                        ? Image.file(
                            File(attendance.photoPath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: isDark ? Colors.grey[800] : Colors.grey[200],
                            child: Icon(
                              Icons.image_not_supported,
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                              size: 48,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // Details
                _buildDetailRow(
                  Icons.calendar_today,
                  'Date',
                  attendance.formattedDate,
                  isDark,
                ),
                _buildDetailRow(
                  Icons.access_time,
                  'Time',
                  attendance.formattedTime,
                  isDark,
                ),
                _buildDetailRow(
                  Icons.location_on,
                  'Distance',
                  '${attendance.distanceFromOffice.toStringAsFixed(0)}m from office',
                  isDark,
                ),
                _buildDetailRow(
                  Icons.place,
                  'Address',
                  attendance.address,
                  isDark,
                  isMultiline: true,
                ),
                _buildDetailRow(
                  Icons.pin_drop,
                  'Coordinates',
                  '${attendance.latitude.toStringAsFixed(6)}, ${attendance.longitude.toStringAsFixed(6)}',
                  isDark,
                ),

                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOut).fadeIn(duration: 400.ms);
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isDark, {
    bool isMultiline = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
