import 'package:flutter/material.dart';
import 'app_fonts.dart';

class StationDetailsScreen extends StatefulWidget {
  final String stationName;
  final String stationCode;

  const StationDetailsScreen({
    super.key,
    required this.stationName,
    required this.stationCode,
  });

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  bool _isFavorited = false;

  // Colors mapping matching the app identity
  static const Color _saffron = Color(0xFFFF671F);
  static const Color _green = Color(0xFF046A38);
  static const Color _inactive = Color(0xFF94A3B8);

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFavorited
            ? '${widget.stationName} added to favorites!'
            : '${widget.stationName} removed from favorites.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
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
                              Text(
                                '${widget.stationName} (${widget.stationCode})',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Major Junction  ·  Central Railway',
                                style: AppFonts.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isFavorited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                              color: _isFavorited ? Colors.red : const Color(0xFF0F172A),
                              size: 22,
                            ),
                            onPressed: _toggleFavorite,
                          ),
                          IconButton(
                            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0F172A), size: 22),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Station options opened.')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main Image Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Hero image
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(8),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/images/nagpur_station.png',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              // Floating station summary card
                              Positioned(
                                left: 16,
                                bottom: -20,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE2F6EC),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          widget.stationCode,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: _green,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            widget.stationName,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: const [
                                              Text(
                                                'नागपुर जंक्शन',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.play_arrow_rounded, color: _saffron, size: 10),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Stats Card (Platforms, Trains, Location)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                _buildDetailStatBox(Icons.train_rounded, '6', 'Platforms'),
                                _buildDivider(),
                                _buildDetailStatBox(Icons.directions_railway_filled_rounded, '312', 'Trains/Day'),
                                _buildDivider(),
                                _buildDetailStatBox(Icons.location_on_rounded, 'Ramdaspeth,', 'Nagpur, MH'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Quick Actions Grid (5 Items)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuickActionBtn(Icons.train_rounded, 'Live Trains', const Color(0xFFE2F6EC), const Color(0xFF046A38)),
                              _buildQuickActionBtn(Icons.map_rounded, 'Station Map', const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                              _buildQuickActionBtn(Icons.search_rounded, 'Search Trains', const Color(0xFFFFF7ED), const Color(0xFFFF671F)),
                              _buildQuickActionBtn(Icons.alt_route_rounded, 'Plan Route', const Color(0xFFFAF5FF), const Color(0xFF9333EA)),
                              _buildQuickActionBtn(Icons.navigation_rounded, 'Directions', const Color(0xFFF0FDF4), const Color(0xFF16A34A)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Upcoming Departures Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Upcoming Departures',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Departures list expanded.')),
                                      );
                                    },
                                    child: const Text(
                                      'View All',
                                      style: TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Departures Container Card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                ),
                                child: Column(
                                  children: [
                                    _buildDepartureItem(
                                      trainNo: '12139',
                                      trainName: 'Vidarbha Express',
                                      toStation: 'Itwari (ITW)',
                                      platform: 'Platform 4',
                                      time: '09:30 AM',
                                      timeToGo: 'In 15 min',
                                      color: _green,
                                    ),
                                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    _buildDepartureItem(
                                      trainNo: '22105',
                                      trainName: 'Mumbai LTT Express',
                                      toStation: 'Ajni (AJNI)',
                                      platform: 'Platform 2',
                                      time: '10:15 AM',
                                      timeToGo: 'In 1h 00m',
                                      color: const Color(0xFF0284C7),
                                    ),
                                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                    _buildDepartureItem(
                                      trainNo: '12615',
                                      trainName: 'Grand Trunk Express',
                                      toStation: 'Itwari (ITW)',
                                      platform: 'Platform 3',
                                      time: '11:05 AM',
                                      timeToGo: 'In 1h 50m',
                                      color: const Color(0xFF9333EA),
                                    ),
                                    // See all departures footer
                                    InkWell(
                                      onTap: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('See all departures opened.')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF4FAF7),
                                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text(
                                              'See all departures',
                                              style: TextStyle(
                                                color: _green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Icon(Icons.chevron_right_rounded, color: _green, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Dual Row (Facilities & Station Information)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Facilities Card
                              Expanded(
                                child: Container(
                                  height: 310,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Station Facilities',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 14),
                                      // Facility Grid Mock
                                      Expanded(
                                        child: GridView.count(
                                          crossAxisCount: 3,
                                          mainAxisSpacing: 10,
                                          crossAxisSpacing: 8,
                                          physics: const NeverScrollableScrollPhysics(),
                                          children: [
                                            _buildFacilityIconItem(Icons.airline_seat_recline_normal_rounded, 'Waiting Room'),
                                            _buildFacilityIconItem(Icons.hotel_rounded, 'Retiring Room'),
                                            _buildFacilityIconItem(Icons.restaurant_rounded, 'Food Plaza'),
                                            _buildFacilityIconItem(Icons.local_parking_rounded, 'Parking'),
                                            _buildFacilityIconItem(Icons.battery_charging_full_rounded, 'Charging'),
                                            _buildFacilityIconItem(Icons.wifi_rounded, 'Wi-Fi'),
                                            _buildFacilityIconItem(Icons.local_drink_rounded, 'Drinking Water'),
                                            _buildFacilityIconItem(Icons.wc_rounded, 'Toilet'),
                                            _buildFacilityIconItem(Icons.medical_services_rounded, 'Medical Help'),
                                          ],
                                        ),
                                      ),
                                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Station facilities sheet opened.')),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('View all facilities', style: TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.bold)),
                                            Icon(Icons.chevron_right_rounded, color: _green, size: 16),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Right: Station Information Card
                              Expanded(
                                child: Container(
                                  height: 310,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Station Information',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                      ),
                                      const SizedBox(height: 14),
                                      // Information list items
                                      _buildInfoListItem(Icons.qr_code_2_rounded, 'Station Code', 'NGP'),
                                      const Divider(height: 12, color: Color(0xFFF1F5F9)),
                                      _buildInfoListItem(Icons.corporate_fare_rounded, 'Zone', 'Central Railway'),
                                      const Divider(height: 12, color: Color(0xFFF1F5F9)),
                                      _buildInfoListItem(Icons.account_tree_rounded, 'Division', 'Nagpur'),
                                      const Divider(height: 12, color: Color(0xFFF1F5F9)),
                                      _buildInfoListItem(Icons.landscape_rounded, 'Elevation', '310 m'),
                                      const Divider(height: 12, color: Color(0xFFF1F5F9)),
                                      _buildInfoListItem(Icons.calendar_month_rounded, 'Opened', '1867'),
                                      const Spacer(),
                                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                                      const SizedBox(height: 10),
                                      InkWell(
                                        onTap: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Detailed Station Info opened.')),
                                          );
                                        },
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text('More information', style: TextStyle(fontSize: 12, color: _green, fontWeight: FontWeight.bold)),
                                            Icon(Icons.chevron_right_rounded, color: _green, size: 16),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Station Map Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Station Map',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Platform layout map expanded.')),
                                      );
                                    },
                                    icon: const Icon(Icons.map_outlined, color: _green, size: 14),
                                    label: const Text('View full map', style: TextStyle(fontSize: 13, color: _green, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Render Schematic Map of Platforms
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildTrackSchematicRow('Platform 1', const Color(0xFFE2F6EC), _green),
                                    _buildTrackSchematicRow('Platform 2', const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                                    _buildTrackSchematicRow('Platform 3', const Color(0xFFFFF7ED), _saffron),
                                    // Booking Office Label Box at bottom
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildStationAreaLabel('Main Entrance', Icons.login_rounded),
                                        Row(
                                          children: [
                                            _buildStationAreaLabel('Toilet', Icons.wc_rounded),
                                            const SizedBox(width: 8),
                                            _buildStationAreaLabel('Booking Office', Icons.storefront_rounded),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Feedback Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4FAF7),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: const Color(0xFFE2F6EC), width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        'Loved the station info?',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _green),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Help us improve by sharing your feedback.',
                                        style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Feedback form opened. Thank you!')),
                                    );
                                  },
                                  icon: const Icon(Icons.share_rounded, size: 12, color: _green),
                                  label: const Text('Share Feedback', style: TextStyle(fontSize: 11.5, color: _green, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: _green),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

          // Replicated Bottom Navigation Bar (matches main.dart design)
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
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      // Search
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.search_rounded,
                          label: 'Explore',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      // FAB Gap
                      const SizedBox(width: 80),
                      // Alerts
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.notifications_none_rounded,
                          label: 'Alerts',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      // Profile
                      Expanded(
                        child: _buildBottomBarNavItem(
                          icon: Icons.person_outline_rounded,
                          label: 'Profile',
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Floating Action Button Center
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
                    color: _green.withAlpha(80),
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
            color: _inactive,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: _inactive,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatBox(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: _green, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: const Color(0xFFE2E8F0));
  }

  Widget _buildQuickActionBtn(IconData icon, String label, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildDepartureItem({
    required String trainNo,
    required String trainName,
    required String toStation,
    required String platform,
    required String time,
    required String timeToGo,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14.0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_railway_filled_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(trainNo, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        trainName,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(toStation, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(platform, style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 2),
              Text(timeToGo, style: const TextStyle(fontSize: 11, color: _green, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 16),
        ],
      ),
    );
  }

  Widget _buildFacilityIconItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _green, size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Color(0xFF475569), height: 1.1),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoListItem(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  Widget _buildTrackSchematicRow(String label, Color trackBg, Color trackColor) {
    return Row(
      children: [
        // Platform index indicator capsule
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: trackBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: trackColor),
          ),
        ),
        const SizedBox(width: 12),
        // Schematic track line
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: trackBg,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: trackColor.withAlpha(40), width: 1),
            ),
            alignment: Alignment.centerLeft,
            child: Container(
              width: 60,
              height: 6,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationAreaLabel(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF475569), size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }
}
