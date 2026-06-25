import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_fonts.dart';
import 'station_details_screen.dart';

class LiveTrainTrackingScreen extends StatefulWidget {
  const LiveTrainTrackingScreen({super.key});

  @override
  State<LiveTrainTrackingScreen> createState() => _LiveTrainTrackingScreenState();
}

class _LiveTrainTrackingScreenState extends State<LiveTrainTrackingScreen> {
  bool _isAudioAnnouncementActive = true;
  bool _isAlertEnabled = false;
  bool _isFullRouteExpanded = true;

  // Colors mapping matching the app identity
  static const Color _saffron = Color(0xFFFF671F);
  static const Color _green = Color(0xFF046A38);
  static const Color _inactive = Color(0xFF94A3B8);

  late List<TimelineStationModel> _stations;

  @override
  void initState() {
    super.initState();
    _loadAlertPref();

    _stations = [
      TimelineStationModel(
        stationName: "Mumbai CSMT",
        stationCode: "CSMT",
        platform: "Platform 18",
        scheduledTime: "04:10 PM",
        actualTime: "04:10 PM",
        statusText: "Departure",
        dateText: "20 May",
        isPassed: true,
        isActive: false,
      ),
      TimelineStationModel(
        stationName: "Kalyan Junction",
        stationCode: "KYN",
        platform: "Platform 4",
        scheduledTime: "04:55 PM",
        actualTime: "04:54 PM",
        statusText: "",
        dateText: "20 May",
        isPassed: true,
        isActive: false,
      ),
      TimelineStationModel(
        stationName: "Igatpuri",
        stationCode: "IGP",
        platform: "Platform 2",
        scheduledTime: "06:24 PM",
        actualTime: "06:23 PM",
        statusText: "",
        dateText: "20 May",
        isPassed: true,
        isActive: false,
      ),
      TimelineStationModel(
        stationName: "Bhopal Junction",
        stationCode: "BPL",
        platform: "Platform 2",
        scheduledTime: "12:15 AM",
        actualTime: "12:15 AM",
        statusText: "",
        dateText: "21 May",
        isPassed: false,
        isActive: true,
        timeToGoText: "In 1h 45m",
      ),
      TimelineStationModel(
        stationName: "Jhansi Junction",
        stationCode: "JHS",
        platform: "Platform 1",
        scheduledTime: "02:35 AM",
        actualTime: "02:35 AM",
        statusText: "",
        dateText: "21 May",
        isPassed: false,
        isActive: false,
        timeToGoText: "In 4h 5m",
      ),
      TimelineStationModel(
        stationName: "Gwalior",
        stationCode: "GWL",
        platform: "Platform 2",
        scheduledTime: "04:25 AM",
        actualTime: "04:25 AM",
        statusText: "",
        dateText: "21 May",
        isPassed: false,
        isActive: false,
        timeToGoText: "In 5h 55m",
      ),
      TimelineStationModel(
        stationName: "New Delhi",
        stationCode: "NDLS",
        platform: "Platform 3",
        scheduledTime: "08:35 AM",
        actualTime: "08:35 AM",
        statusText: "Arrival",
        dateText: "21 May",
        isPassed: false,
        isActive: false,
        isDestination: true,
        timeToGoText: "In 10h 25m",
      ),
    ];
  }

  Future<void> _loadAlertPref() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isAlertEnabled = prefs.getBool('train_alert_enabled_12951') ?? false;
    });
  }

  Future<void> _toggleAlert() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = !_isAlertEnabled;
    await prefs.setBool('train_alert_enabled_12951', newState);
    setState(() {
      _isAlertEnabled = newState;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newState ? 'Alerts activated for this train!' : 'Alerts disabled.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 1. App Bar Header Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Live Train Tracking',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Stay updated with real-time train location',
                                style: AppFonts.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.ios_share_rounded, color: Color(0xFF0F172A), size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sharing train location link...')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A), size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Train settings options opened.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Scrollable Body Contents
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Train Info Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Train Circle Icon Green
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2F6EC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.directions_railway_filled_rounded,
                                      color: _green,
                                      size: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Train Names & Routes
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        '12951 Mumbai Rajdhani Express',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Mumbai CSMT (CSMT)  →  New Delhi (NDLS)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Announcement & Running Status Info
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE2F6EC),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'Running On Time',
                                        style: TextStyle(
                                          color: _green,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Text(
                                          'Last updated just now',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isAudioAnnouncementActive = !_isAudioAnnouncementActive;
                                            });
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(_isAudioAnnouncementActive
                                                    ? 'Audio Announcements Enabled'
                                                    : 'Audio Announcements Muted'),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            _isAudioAnnouncementActive
                                                ? Icons.volume_up_rounded
                                                : Icons.volume_off_rounded,
                                            color: _isAudioAnnouncementActive ? _green : _inactive,
                                            size: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 3. Map Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  // Map Background Image
                                  Positioned.fill(
                                    child: Image.asset(
                                      'assets/images/live_train_map.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),

                                  // Source Station Info Box (Bottom Left)
                                  Positioned(
                                    left: 14,
                                    bottom: 14,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(240),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'Mumbai CSMT',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Departure',
                                            style: TextStyle(fontSize: 9.5, color: _green, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '04:10 PM',
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Destination Station Info Box (Top Right)
                                  Positioned(
                                    right: 14,
                                    top: 14,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(240),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Text(
                                            'New Delhi',
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Arrival',
                                            style: TextStyle(fontSize: 9.5, color: _saffron, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            '08:35 AM (21 May)',
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Float Controls Right Side
                                  Positioned(
                                    right: 14,
                                    bottom: 14,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildMapControlBtn(Icons.my_location_rounded, 'locate'),
                                        const SizedBox(height: 8),
                                        _buildMapControlBtn(Icons.layers_rounded, 'layers'),
                                        const SizedBox(height: 8),
                                        _buildMapControlBtn(Icons.fullscreen_rounded, 'expand'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 4. Key Stats Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                            child: Row(
                              children: [
                                _buildKeyStatBox('Next Stop', 'Bhopal Junction (BPL)', subtitle: '12:15 AM'),
                                _buildDivider(),
                                _buildKeyStatBox('Platform', '2'),
                                _buildDivider(),
                                _buildKeyStatBox('Speed', '82 km/h'),
                                _buildDivider(),
                                _buildKeyStatBox('Distance to Go', '702 km'),
                                _buildDivider(),
                                _buildKeyStatBox('ETA', '08:35 AM', subtitle: '21 May'),
                              ],
                            ),
                          ),
                        ),

                        // 5. Journey Progress Timeline
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Journey Progress',
                                    style: TextStyle(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _isFullRouteExpanded = !_isFullRouteExpanded;
                                      });
                                    },
                                    child: Text(
                                      _isFullRouteExpanded ? 'Collapse Route' : 'View Full Route',
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: _saffron,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    'Day 1  ·  20 May, 2025',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Total 1389 km  ·  16h 25m',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Timeline build
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _isFullRouteExpanded ? _stations.length : 3, // COLLAPSED: shows only passed-last, active, next-upcoming
                                  itemBuilder: (context, index) {
                                    int targetIndex = index;
                                    if (!_isFullRouteExpanded) {
                                      // COLLAPSED: map index to showing index 2 (Igatpuri), 3 (Bhopal/Active), 4 (Jhansi)
                                      targetIndex = index + 2;
                                    }
                                    final station = _stations[targetIndex];
                                    return _buildTimelineRow(station, targetIndex);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Get Alerts Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFFFEDD5), width: 1),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFEDD5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.notifications_active_rounded,
                                      color: _saffron,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Get alerts for this train',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF7C2D12),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Never miss your stop. Enable notifications.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF9A3412),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: _toggleAlert,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _saffron,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    _isAlertEnabled ? 'Alerts Active' : 'Enable Alerts',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Replicated Bottom Navigation Bar (with Live active)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 30,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 80,
                  child: Row(
                    children: [
                      // Home
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.home_outlined,
                          label: 'Home',
                          isActive: false,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      // Search
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.search_rounded,
                          label: 'Explore',
                          isActive: false,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      // FAB Gap
                      const SizedBox(width: 80),
                      // Alerts
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Alerts',
                          isActive: false,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      // Profile
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          isActive: false,
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Highlighting the LIVE center FAB button as active
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 36,
            bottom: 24,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 6),
                boxShadow: [
                  BoxShadow(
                    color: _green.withAlpha(120),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.train_rounded, color: Colors.white, size: 22),
                  SizedBox(height: 1),
                  Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? _saffron : _inactive,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _saffron : _inactive,
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControlBtn(IconData icon, String action) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Map $action triggered.'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Icon(icon, color: const Color(0xFF475569), size: 18),
      ),
    );
  }

  Widget _buildKeyStatBox(String label, String value, {String? subtitle}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 45,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildTimelineRow(TimelineStationModel station, int index) {
    final showDashedTop = index > 0;
    final showDashedBottom = index < _stations.length - 1;

    Color connectorColor = _inactive;
    if (station.isPassed) {
      connectorColor = _green;
    } else if (station.isActive) {
      connectorColor = const Color(0xFF1E40AF);
    }

    return InkWell(
      onTap: () => _showStationBottomSheet(context, station),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        color: station.isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. Indicator Circle and Lines
            SizedBox(
              width: 32,
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (showDashedTop)
                    Positioned(
                      top: 0,
                      bottom: 36,
                      child: Container(
                        width: 2.5,
                        color: station.isPassed ? _green : connectorColor,
                      ),
                    ),
                  if (showDashedBottom)
                    Positioned(
                      top: 36,
                      bottom: 0,
                      child: Container(
                        width: 2.5,
                        color: station.isPassed || station.isActive ? _green : _inactive,
                      ),
                    ),
                  _buildTimelineIcon(station),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 2. Station Name & Platform info
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      children: [
                        TextSpan(
                          text: station.stationName,
                          style: TextStyle(
                            color: station.isActive ? const Color(0xFF1D4ED8) : const Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' (${station.stationCode})',
                          style: TextStyle(
                            color: station.isActive ? const Color(0xFF1D4ED8).withAlpha(180) : const Color(0xFF64748B),
                            fontWeight: FontWeight.normal,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    station.isDestination!
                        ? '${station.dateText}  ·  ${station.platform}  ·  ${station.statusText}'
                        : (index == 0 
                            ? '${station.platform}  ·  ${station.statusText}'
                            : '${station.dateText}  ·  ${station.platform}'),
                    style: TextStyle(
                      fontSize: 11.5,
                      color: station.isActive ? const Color(0xFF1D4ED8).withAlpha(180) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Scheduled Time Column
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  station.scheduledTime,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF475569),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // 4. Actual / Estimated Time Column
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (station.timeToGoText != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: station.isActive ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        station.timeToGoText!,
                        style: TextStyle(
                          fontSize: 10,
                          color: station.isActive ? const Color(0xFF1E40AF) : const Color(0xFF475569),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    station.actualTime,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: station.isActive
                          ? const Color(0xFF1D4ED8)
                          : (station.isPassed
                              ? _green
                              : (station.isDestination! ? Colors.red : const Color(0xFF0F172A))),
                    ),
                  ),
                  if (station.isActive || station.isDestination!)
                    const SizedBox(height: 2),
                  if (station.isActive || station.isDestination!)
                    Text(
                      station.dateText,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: station.isActive
                            ? const Color(0xFF1D4ED8)
                            : (station.isDestination! ? Colors.red : const Color(0xFF64748B)),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),

            // 5. Chevron arrow for intermediate passed stations
            if (station.isPassed && index > 0)
              const Padding(
                padding: EdgeInsets.only(left: 6.0, right: 2.0),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              )
            else
              const SizedBox(width: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineIcon(TimelineStationModel station) {
    if (station.isPassed) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: _green,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.check, color: Colors.white, size: 14),
        ),
      );
    } else if (station.isActive) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF1D4ED8), // Deep blue active train indicator outer ring
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.train_rounded, color: Colors.white, size: 14),
        ),
      );
    } else if (station.isDestination!) {
      return Container(
        width: 22,
        height: 22,
        decoration: const BoxDecoration(
          color: Color(0xFFEF4444), // Red pin circle
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(Icons.location_on_rounded, color: Colors.white, size: 12),
        ),
      );
    } else {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _inactive, width: 2),
        ),
      );
    }
  }

  void _showStationBottomSheet(BuildContext context, TimelineStationModel station) {
    String platformsCount = "6";
    String trainsPerDay = "312";
    String elevationVal = "310 m";
    String zoneDivision = "Central Railway";
    String shortZone = "CR";
    String divisionText = "Nagpur";
    String imagePath = "assets/images/nagpur_station.png";
    String rating = "4.4";
    String nextDepartureName = "Vidarbha Express";
    String nextDepartureTimeVal = "09:30 AM";
    String nextDeparturePlat = "4";
    bool isFavorited = false;

    switch (station.stationCode) {
      case 'CSMT':
        platformsCount = "18";
        trainsPerDay = "450";
        elevationVal = "14 m";
        zoneDivision = "Central Railway";
        shortZone = "CR";
        divisionText = "Mumbai";
        imagePath = "assets/images/splash_screen_bg.png";
        rating = "4.7";
        nextDepartureName = "Rajdhani Express";
        nextDepartureTimeVal = "04:10 PM";
        nextDeparturePlat = "18";
        break;
      case 'KYN':
        platformsCount = "8";
        trainsPerDay = "380";
        elevationVal = "9 m";
        zoneDivision = "Central Railway";
        shortZone = "CR";
        divisionText = "Mumbai";
        imagePath = "assets/images/homepage_banner1.png";
        rating = "4.1";
        nextDepartureName = "Deccan Queen";
        nextDepartureTimeVal = "05:15 PM";
        nextDeparturePlat = "4";
        break;
      case 'IGP':
        platformsCount = "4";
        trainsPerDay = "120";
        elevationVal = "599 m";
        zoneDivision = "Central Railway";
        shortZone = "CR";
        divisionText = "Mumbai";
        imagePath = "assets/images/saved_routes_banner.png";
        rating = "4.0";
        nextDepartureName = "Panchavati Exp";
        nextDepartureTimeVal = "06:24 PM";
        nextDeparturePlat = "2";
        break;
      case 'BPL':
        platformsCount = "6";
        trainsPerDay = "280";
        elevationVal = "505 m";
        zoneDivision = "West Central Railway";
        shortZone = "WCR";
        divisionText = "Bhopal";
        imagePath = "assets/images/homepage_banner1.png";
        rating = "4.3";
        nextDepartureName = "Shatabdi Express";
        nextDepartureTimeVal = "12:15 AM";
        nextDeparturePlat = "2";
        break;
      case 'JHS':
        platformsCount = "8";
        trainsPerDay = "220";
        elevationVal = "268 m";
        zoneDivision = "North Central Railway";
        shortZone = "NCR";
        divisionText = "Jhansi";
        imagePath = "assets/images/saved_routes_banner.png";
        rating = "4.2";
        nextDepartureName = "Jabalpur Express";
        nextDepartureTimeVal = "02:35 AM";
        nextDeparturePlat = "1";
        break;
      case 'GWL':
        platformsCount = "4";
        trainsPerDay = "180";
        elevationVal = "212 m";
        zoneDivision = "North Central Railway";
        shortZone = "NCR";
        divisionText = "Jhansi";
        imagePath = "assets/images/homepage_banner1.png";
        rating = "4.1";
        nextDepartureName = "Bundelkhand Exp";
        nextDepartureTimeVal = "04:25 AM";
        nextDeparturePlat = "2";
        break;
      case 'NDLS':
        platformsCount = "16";
        trainsPerDay = "400";
        elevationVal = "216 m";
        zoneDivision = "Northern Railway";
        shortZone = "NR";
        divisionText = "Delhi";
        imagePath = "assets/images/splash_screen_bg.png";
        rating = "4.6";
        nextDepartureName = "Taj Express";
        nextDepartureTimeVal = "08:35 AM";
        nextDeparturePlat = "3";
        break;
      default:
        platformsCount = "6";
        trainsPerDay = "312";
        elevationVal = "310 m";
        zoneDivision = "Central Railway";
        shortZone = "CR";
        divisionText = "Nagpur";
        imagePath = "assets/images/nagpur_station.png";
        rating = "4.4";
        nextDepartureName = "Vidarbha Express";
        nextDepartureTimeVal = "09:30 AM";
        nextDeparturePlat = "4";
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Image Banner
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    child: Stack(
                      children: [
                        Image.asset(
                          imagePath,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        // Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withAlpha(90),
                                  Colors.transparent,
                                  Colors.black.withAlpha(140),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Drag Handle
                        Positioned(
                          top: 10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(180),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                            ),
                          ),
                        ),
                        // Code Badge on top left
                        Positioned(
                          left: 16,
                          top: 22,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F6EC),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Text(
                              station.stationCode,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _green,
                              ),
                            ),
                          ),
                        ),
                        // Rating badge on top right
                        Positioned(
                          right: 16,
                          top: 22,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(130),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withAlpha(80), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFFB000), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '$rating Rating',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Overlay tags at bottom left
                        Positioned(
                          left: 16,
                          bottom: 12,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _saffron,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      'Operational',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(210),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.wifi_rounded, color: Color(0xFF0284C7), size: 10),
                                    SizedBox(width: 4),
                                    Text(
                                      'Free Wi-Fi',
                                      style: TextStyle(
                                        color: Color(0xFF0284C7),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content Area
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Title & Division
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    station.stationName,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Junction Station · $zoneDivision · Div: $divisionText',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 16),

                        // Stats Dashboard
                        Row(
                          children: [
                            _buildBottomSheetStatBox(Icons.train_rounded, platformsCount, 'Platforms'),
                            _buildBottomSheetDivider(),
                            _buildBottomSheetStatBox(Icons.directions_railway_filled_rounded, trainsPerDay, 'Trains/Day'),
                            _buildBottomSheetDivider(),
                            _buildBottomSheetStatBox(Icons.landscape_rounded, elevationVal, 'Elevation'),
                            _buildBottomSheetDivider(),
                            _buildBottomSheetStatBox(Icons.location_city_rounded, shortZone, 'Zone'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 16),

                        // Amenities Section
                        const Text(
                          'Available Amenities',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildAmenityBadge(Icons.wifi_rounded, 'Wi-Fi'),
                            const SizedBox(width: 12),
                            _buildAmenityBadge(Icons.restaurant_rounded, 'Food Plaza'),
                            const SizedBox(width: 12),
                            _buildAmenityBadge(Icons.hotel_rounded, 'Retiring Rooms'),
                            const SizedBox(width: 12),
                            _buildAmenityBadge(Icons.airline_seat_recline_normal_rounded, 'Waiting Area'),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 16),

                        // Next Departure Card
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.alarm_on_rounded,
                                    color: _green,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'NEXT DEPARTURE',
                                      style: TextStyle(
                                        color: _green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF0F172A),
                                          fontFamily: 'Inter',
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '$nextDepartureName ',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const TextSpan(text: 'at '),
                                          TextSpan(
                                            text: nextDepartureTimeVal,
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: _saffron),
                                          ),
                                          const TextSpan(text: ' · '),
                                          TextSpan(
                                            text: 'Plat $nextDeparturePlat',
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Action Buttons Row
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StationDetailsScreen(
                                        stationName: station.stationName,
                                        stationCode: station.stationCode,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _saffron,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'View Full Station Profile & Map',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Interactive Favorite Heart
                            GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  isFavorited = !isFavorited;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(isFavorited
                                        ? '${station.stationName} added to Favorites!'
                                        : '${station.stationName} removed from Favorites.'),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: isFavorited ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isFavorited ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    isFavorited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                    color: isFavorited ? Colors.red : const Color(0xFF475569),
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAmenityBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _green, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheetDivider() {
    return Container(
      width: 1,
      height: 36,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class TimelineStationModel {
  final String stationName;
  final String stationCode;
  final String platform;
  final String scheduledTime;
  final String actualTime;
  final String statusText;
  final String dateText;
  final bool isPassed;
  final bool isActive;
  final bool? isDestination;
  final String? timeToGoText;

  TimelineStationModel({
    required this.stationName,
    required this.stationCode,
    required this.platform,
    required this.scheduledTime,
    required this.actualTime,
    required this.statusText,
    required this.dateText,
    required this.isPassed,
    required this.isActive,
    this.isDestination = false,
    this.timeToGoText,
  });
}
