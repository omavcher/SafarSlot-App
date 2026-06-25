import 'dart:async';
import 'package:flutter/material.dart';

class UpcomingTrainsPage extends StatefulWidget {
  const UpcomingTrainsPage({super.key});

  @override
  State<UpcomingTrainsPage> createState() => _UpcomingTrainsPageState();
}

class _UpcomingTrainsPageState extends State<UpcomingTrainsPage>
    with SingleTickerProviderStateMixin {
  // ─── Colours ────────────────────────────────────────────────────────────────
  static const _orange = Color(0xFFFF671F);
  static const _green = Color(0xFF046A38);
  static const _navy = Color(0xFF0F172A);
  static const _slate = Color(0xFF64748B);
  static const _bg = Color(0xFFF8FAFC);

  // ─── Tab Bar ────────────────────────────────────────────────────────────────
  late final TabController _tabController;
  int _activeTab = 0;

  // ─── Refresh ticker ─────────────────────────────────────────────────────────
  int _refreshCountdown = 30;
  Timer? _refreshTimer;
  String _lastUpdated = 'just now';

  // ─── Filter state ───────────────────────────────────────────────────────────
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'AC Only', 'Non-AC', 'Express', 'Passenger'];

  // ─── Train data ─────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _allTrains = [
    {
      'trainNo': '22105',
      'name': 'Mumbai LTT Express',
      'station': 'Ajni Junction',
      'stationCode': 'AJNI',
      'platform': '2',
      'time': '08:45 AM',
      'inMins': 18,
      'distance': '650 m',
      'walkTime': '~8 min walk',
      'status': 'On Time',
      'statusOk': true,
      'type': 'Express',
      'class': 'AC',
      'color': _green,
    },
    {
      'trainNo': '12721',
      'name': 'Hyderabad SF Express',
      'station': 'Nagpur Junction',
      'stationCode': 'NGP',
      'platform': '5',
      'time': '07:20 PM',
      'inMins': 248,
      'distance': '1.2 km',
      'walkTime': '~15 min walk',
      'status': 'On Time',
      'statusOk': true,
      'type': 'Superfast',
      'class': 'AC',
      'color': Color(0xFF0284C7),
    },
    {
      'trainNo': '12615',
      'name': 'Grand Trunk Express',
      'station': 'Itwari Junction',
      'stationCode': 'ITW',
      'platform': '1',
      'time': '06:10 PM',
      'inMins': 195,
      'distance': '1.6 km',
      'walkTime': '~20 min walk',
      'status': 'On Time',
      'statusOk': true,
      'type': 'Express',
      'class': 'Non-AC',
      'color': Color(0xFF9333EA),
    },
    {
      'trainNo': '12139',
      'name': 'Vidarbha Express',
      'station': 'Ajni Junction',
      'stationCode': 'AJNI',
      'platform': '3',
      'time': '09:30 AM',
      'inMins': 63,
      'distance': '2.1 km',
      'walkTime': '~26 min walk',
      'status': 'Delayed 10m',
      'statusOk': false,
      'type': 'Express',
      'class': 'Non-AC',
      'color': _orange,
    },
    {
      'trainNo': '11401',
      'name': 'Nandigram Express',
      'station': 'Nagpur Junction',
      'stationCode': 'NGP',
      'platform': '4',
      'time': '11:15 AM',
      'inMins': 105,
      'distance': '1.2 km',
      'walkTime': '~15 min walk',
      'status': 'On Time',
      'statusOk': true,
      'type': 'Express',
      'class': 'Non-AC',
      'color': _green,
    },
    {
      'trainNo': '58101',
      'name': 'Nagpur–Gondia Passenger',
      'station': 'Nagpur Junction',
      'stationCode': 'NGP',
      'platform': '6',
      'time': '01:00 PM',
      'inMins': 170,
      'distance': '1.2 km',
      'walkTime': '~15 min walk',
      'status': 'On Time',
      'statusOk': true,
      'type': 'Passenger',
      'class': 'Non-AC',
      'color': _slate,
    },
  ];

  List<Map<String, dynamic>> get _filteredTrains {
    if (_activeTab == 1) {
      // Sort by distance (smallest inMins = closest based on distance string)
      final sorted = [..._allTrains];
      sorted.sort((a, b) {
        final da = double.tryParse((a['distance'] as String).replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        final db = double.tryParse((b['distance'] as String).replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
        return da.compareTo(db);
      });
      return sorted;
    } else if (_activeTab == 2) {
      // Sort by soonest departure
      final sorted = [..._allTrains];
      sorted.sort((a, b) => (a['inMins'] as int).compareTo(b['inMins'] as int));
      return sorted;
    }
    return _allTrains;
  }

  String _formatEta(int mins) {
    if (mins < 60) return 'in $mins min';
    final h = mins ~/ 60;
    final m = mins % 60;
    return m == 0 ? 'in ${h}h' : 'in ${h}h ${m}m';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _activeTab = _tabController.index);
      }
    });
    _startRefreshTimer();
  }

  void _startRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshCountdown = 30;
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() {
        _refreshCountdown--;
        if (_refreshCountdown <= 0) {
          _refreshCountdown = 30;
          _lastUpdated = 'just now';
        }
      });
    });
  }

  void _manualRefresh() {
    setState(() => _lastUpdated = 'just now');
    _startRefreshTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Live data refreshed'),
        backgroundColor: _green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  // ─── Filter bottom sheet ────────────────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setBS) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Filter Trains',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _navy)),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _filterOptions.map((opt) {
                    final sel = _selectedFilter == opt;
                    return GestureDetector(
                      onTap: () {
                        setBS(() => _selectedFilter = opt);
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? _orange : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          opt,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: sel ? Colors.white : _slate,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Apply Filter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. AppBar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: _navy, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Upcoming Trains Near You',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _navy,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Live departures from nearby stations',
                          style: TextStyle(fontSize: 11.5, color: _slate),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterSheet,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.tune_rounded, size: 14, color: _navy),
                          SizedBox(width: 4),
                          Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _navy)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // ── Scrollable content ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── 2. Location Card ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2F6EC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.location_on_rounded, color: _green, size: 20),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Location',
                                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                                  SizedBox(height: 2),
                                  Text('Nagpur Junction, Maharashtra',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _navy)),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('GPS refreshed! Location: Nagpur Junction')),
                                );
                              },
                              icon: const Icon(Icons.my_location_rounded, size: 14, color: _green),
                              label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _green,
                                side: const BorderSide(color: Color(0xFFBFEFDF), width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── 3. Vector Map ────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Container(
                        height: 230,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              // Painted streets background
                              Positioned.fill(
                                child: CustomPaint(painter: _UpcomingMapPainter()),
                              ),
                              // Compass
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
                                  ),
                                  child: Transform.rotate(
                                    angle: -0.15,
                                    child: const Icon(Icons.explore_rounded, color: _orange, size: 22),
                                  ),
                                ),
                              ),
                              // Station markers
                              _buildMapMarker(top: 30, left: 50, label: 'AJNI', subLabel: '650m', color: _green),
                              _buildMapMarker(top: 30, right: 50, label: 'NGP', subLabel: '1.2km', color: Color(0xFF0284C7)),
                              _buildMapMarker(bottom: 55, left: 30, label: 'ITW', subLabel: '1.6km', color: Color(0xFF9333EA)),
                              // "You are here" center
                              Positioned(
                                top: 105,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                                        ),
                                        child: const Text('You are here',
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: _navy)),
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: _orange, width: 2.5),
                                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                        ),
                                        alignment: Alignment.center,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(color: Color(0xFF0284C7), shape: BoxShape.circle),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text('Nagpur Junction',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _slate)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ── 4. "3 Stations nearby" green summary bar ─────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFF046A38), Color(0xFF078A4A)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.train_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('3 Stations nearby',
                                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                  SizedBox(height: 2),
                                  Text('Showing next trains from nearby stations',
                                      style: TextStyle(fontSize: 11, color: Color(0xFFB9F0D5))),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: Colors.white70),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── 5. Tabs: All / By Distance / By Time ──────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: _orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: Colors.transparent,
                          labelColor: Colors.white,
                          unselectedLabelColor: _slate,
                          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(text: 'All (${_allTrains.length})'),
                            const Tab(text: 'By Distance'),
                            const Tab(text: 'By Time'),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── 6. Train cards ────────────────────────────────────────
                    ..._filteredTrains.map((t) => _buildTrainCard(t)),

                    // ── 7. "View all trains" footer button ────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.directions_railway_filled_rounded, color: _navy, size: 20),
                          title: const Text('View all trains from nearby stations',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: _navy)),
                          trailing: const Icon(Icons.chevron_right_rounded, color: _navy),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Showing all trains from 3 nearby stations...')),
                            );
                          },
                        ),
                      ),
                    ),

                    // ── 8. Last updated row ───────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: _slate),
                          const SizedBox(width: 5),
                          Text('Last updated $_lastUpdated',
                              style: const TextStyle(fontSize: 11.5, color: _slate)),
                          const Spacer(),
                          GestureDetector(
                            onTap: _manualRefresh,
                            child: Row(
                              children: [
                                const Icon(Icons.refresh_rounded, size: 14, color: _orange),
                                const SizedBox(width: 4),
                                Text('Auto refresh in ${_refreshCountdown}s',
                                    style: const TextStyle(fontSize: 11.5, color: _orange, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30, offset: Offset(0, -5))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 80,
            child: Row(
              children: [
                Expanded(child: _buildNavItem(isActive: true, activeIcon: Icons.home_filled, inactiveIcon: Icons.home_outlined, label: 'Home', onTap: () => Navigator.pop(context))),
                Expanded(child: _buildNavItem(isActive: false, activeIcon: Icons.search_rounded, inactiveIcon: Icons.search_rounded, label: 'Explore', onTap: () => Navigator.pop(context))),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
                          child: const Icon(Icons.train_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text('Live', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                Expanded(child: _buildNavItem(isActive: false, activeIcon: Icons.notifications_rounded, inactiveIcon: Icons.notifications_none_rounded, label: 'Alerts', onTap: () => Navigator.pop(context))),
                Expanded(child: _buildNavItem(isActive: false, activeIcon: Icons.person_rounded, inactiveIcon: Icons.person_outline_rounded, label: 'Profile', onTap: () => Navigator.pop(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Map marker widget ───────────────────────────────────────────────────────
  Widget _buildMapMarker({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String label,
    required String subLabel,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withAlpha(80)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
                  child: Icon(Icons.directions_railway_filled_rounded, color: color, size: 10),
                ),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: _navy)),
                const SizedBox(width: 4),
                Text(subLabel, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Icon(Icons.location_on_rounded, color: color, size: 18),
        ],
      ),
    );
  }

  // ── Train card widget ───────────────────────────────────────────────────────
  Widget _buildTrainCard(Map<String, dynamic> t) {
    final Color themeColor = t['color'] as Color;
    final bool statusOk = t['statusOk'] as bool;
    final int mins = t['inMins'] as int;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Train ${t['trainNo']}: ${t['name']}')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    // Train icon
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: themeColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.directions_railway_filled_rounded, color: themeColor, size: 22),
                    ),
                    const SizedBox(width: 12),

                    // Train name + number
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t['trainNo']} · ${t['name']}',
                            style: const TextStyle(
                                fontSize: 13.5, fontWeight: FontWeight.bold, color: _navy),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(Icons.train_rounded, size: 11, color: _slate),
                              const SizedBox(width: 3),
                              Text('${t['station']} · Pf ${t['platform']}',
                                  style: const TextStyle(fontSize: 11, color: _slate)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusOk ? const Color(0xFFDCFCE7) : const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t['status'] as String,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: statusOk ? _green : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                // Departure time row
                Row(
                  children: [
                    // Departure clock
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 14, color: _slate),
                        const SizedBox(width: 4),
                        Text(t['time'] as String,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold, color: _navy)),
                      ],
                    ),
                    const SizedBox(width: 10),

                    // ETA chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: mins < 60 ? const Color(0xFFDCFCE7) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatEta(mins),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: mins < 60 ? _green : const Color(0xFF0284C7),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Distance
                    Row(
                      children: [
                        const Icon(Icons.directions_walk_rounded, size: 14, color: _slate),
                        const SizedBox(width: 3),
                        Text('${t['distance']} · ${t['walkTime']}',
                            style: const TextStyle(fontSize: 11, color: _slate)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Class + type tags
                Row(
                  children: [
                    _buildTag(t['type'] as String, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                    const SizedBox(width: 6),
                    _buildTag(t['class'] as String,
                        (t['class'] == 'AC') ? const Color(0xFFE2F6EC) : const Color(0xFFFFF7ED),
                        (t['class'] == 'AC') ? _green : _orange),
                    const Spacer(),
                    Text(
                      'Track Train →',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  // ── Bottom nav item ──────────────────────────────────────────────────────────
  Widget _buildNavItem({
    required bool isActive,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? _orange : _slate,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? _orange : _slate,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Map Vector Painter ────────────────────────────────────────────────────────
class _UpcomingMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background sky-grey
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFF0F4F8));

    // Block groups (building outlines)
    final blockPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    final blockStroke = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final blocks = [
      Rect.fromLTWH(10, 10, 80, 55),
      Rect.fromLTWH(20, 80, 60, 40),
      Rect.fromLTWH(w - 100, 12, 80, 50),
      Rect.fromLTWH(w - 90, 75, 70, 45),
      Rect.fromLTWH(15, h - 80, 70, 50),
      Rect.fromLTWH(w - 100, h - 90, 80, 55),
      Rect.fromLTWH(w * 0.35, h - 70, 60, 45),
    ];
    for (final b in blocks) {
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(4)), blockPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(b, const Radius.circular(4)), blockStroke);
    }

    // Roads
    final roadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    final roadMarkPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    // Horizontal roads
    for (final y in [h * 0.33, h * 0.67]) {
      canvas.drawLine(Offset(0, y), Offset(w, y), roadPaint);
      canvas.drawLine(Offset(0, y), Offset(w, y), roadMarkPaint);
    }
    // Vertical roads
    for (final x in [w * 0.33, w * 0.67]) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), roadPaint);
      canvas.drawLine(Offset(x, 0), Offset(x, h), roadMarkPaint);
    }

    // Green park area in centre
    final parkPaint = Paint()..color = const Color(0xFFDCFCE7);
    final parkRect = Rect.fromCenter(center: Offset(w / 2, h / 2), width: 55, height: 55);
    canvas.drawRRect(RRect.fromRectAndRadius(parkRect, const Radius.circular(8)), parkPaint);

    // Walking path arcs (dashed look via segments)
    final dashedPaint = Paint()
      ..color = const Color(0xFF046A38).withAlpha(100)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final cx = w / 2;
    final cy = h / 2;
    // Circles indicating walking radii
    canvas.drawCircle(Offset(cx, cy), 45, dashedPaint);
    canvas.drawCircle(Offset(cx, cy), 80, dashedPaint..color = const Color(0xFF0284C7).withAlpha(80));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
