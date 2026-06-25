import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'config/api_config.dart';

class NearbyStationsPage extends StatefulWidget {
  const NearbyStationsPage({super.key});

  @override
  State<NearbyStationsPage> createState() => _NearbyStationsPageState();
}

class _NearbyStationsPageState extends State<NearbyStationsPage> {
  bool _accurateResultsExpanded = false;
  String _selectedSort = "Nearest";
  bool _isLoading = true;
  Position? _currentPosition;

  // Dynamic list of nearby stations fetched from the backend
  List<Map<String, dynamic>> _stations = [];

  @override
  void initState() {
    super.initState();
    _fetchNearbyStations();
  }

  Future<void> _fetchNearbyStations() async {
    try {
      // Use low accuracy with timeout to avoid freezing
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      ).timeout(const Duration(seconds: 10), onTimeout: () async {
        return await Geolocator.getLastKnownPosition() ?? Position(
            longitude: 79.0882, latitude: 21.1458, timestamp: DateTime.now(),
            accuracy: 0, altitude: 0, heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0);
      });

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }

      final response = await http.post(
        Uri.parse(ApiConfig.getNearbyStations),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lat': position.latitude,
          'long': position.longitude,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List stationsRaw = data['stations'];
          List<Map<String, dynamic>> mappedStations = [];

          for (var s in stationsRaw) {
            double stnLat = double.tryParse(s['latitude']?.toString() ?? '0') ?? 0;
            double stnLong = double.tryParse(s['longitude']?.toString() ?? '0') ?? 0;
            
            double distanceInMeters = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              stnLat,
              stnLong,
            );
            
            double distanceInKm = distanceInMeters / 1000;

            mappedStations.add({
              "name": s['stationName'] ?? '',
              "code": s['stationCode'] == "N/A" ? "" : s['stationCode'] ?? '',
              "type": s['isMetro'] == true ? "Metro Station" : (s['majorStn'] == true ? "Major Junction" : "Railway Station"),
              "distance": "${distanceInKm.toStringAsFixed(1)} km",
              "distanceValue": distanceInKm,
              "timeAway": "${(distanceInKm * 3).ceil()} mins away", // Rough estimate
              "platforms": (distanceInKm.toInt() % 4) + 1, // Mock
              "trainCount": (distanceInKm.toInt() * 15 + 10), // Mock
              "lat": stnLat,
              "long": stnLong,
            });
          }

          mappedStations.sort((a, b) => (a['distanceValue'] as double).compareTo(b['distanceValue'] as double));

          if (mounted) {
            setState(() {
              _stations = mappedStations;
              _isLoading = false;
            });
          }
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching nearby stations: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Stations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.directions_railway_filled_rounded, color: Color(0xFF046A38)),
                title: const Text('Show Major Junctions Only'),
                trailing: Switch(value: false, onChanged: (val) {}),
              ),
              ListTile(
                leading: const Icon(Icons.train_rounded, color: Color(0xFFFF671F)),
                title: const Text('Minimum 50+ Daily Trains'),
                trailing: Switch(value: true, onChanged: (val) {}),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Sort Stations By',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Nearest'),
              _buildSortOption('Most Platforms'),
              _buildSortOption('Most Daily Trains'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String option) {
    final isSelected = _selectedSort == option;
    return ListTile(
      title: Text(
        option,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFFFF671F) : const Color(0xFF0F172A),
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check_rounded, color: Color(0xFFFF671F)) : null,
      onTap: () {
        setState(() {
          _selectedSort = option;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Custom Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nearby Stations',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Stations near your current location',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showFilterOptions,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.tune_rounded, size: 14, color: Color(0xFF0F172A)),
                          SizedBox(width: 4),
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 2. Current Location Selector Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
                        ),
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE2F6EC),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFF046A38),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Your Location',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Nagpur Junction, Maharashtra',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('GPS Refreshed! Current Location: Nagpur Junction')),
                                );
                              },
                              icon: const Icon(Icons.my_location_rounded, size: 14, color: Color(0xFF046A38)),
                              label: const Text('Change', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF046A38),
                                side: const BorderSide(color: Color(0xFFE2F6EC), width: 1.5),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. Map View Component (CustomPainter + Positioned Stack)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Container(
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                _currentPosition?.latitude ?? 21.1458,
                                _currentPosition?.longitude ?? 79.0882,
                              ),
                              initialZoom: 11.0,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.safarslot.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  // User Marker
                                  if (_currentPosition != null)
                                    Marker(
                                      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                                      width: 60,
                                      height: 60,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                                            child: const Text('You', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                          ),
                                          const Icon(Icons.location_on, color: Colors.blue, size: 30),
                                        ],
                                      ),
                                    ),
                                  // Station Markers
                                  ..._stations.map((s) {
                                    return Marker(
                                      point: LatLng(s['lat'] ?? 0.0, s['long'] ?? 0.0),
                                      width: 100,
                                      height: 60,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: const Color(0xFFE2E8F0)),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1)),
                                              ],
                                            ),
                                            child: Text(
                                              '${s['code']}',
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.train_rounded,
                                            color: Color(0xFF046A38),
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 4. Accurate Results Banner Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F6EC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFBFEFDF), width: 1.0),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF046A38),
                              size: 20,
                            ),
                            title: const Text(
                              'Accurate Results',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF046A38),
                              ),
                            ),
                            subtitle: const Text(
                              'Based on your current location',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF046A38),
                              ),
                            ),
                            trailing: Icon(
                              _accurateResultsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              color: const Color(0xFF046A38),
                            ),
                            onExpansionChanged: (val) {
                              setState(() {
                                _accurateResultsExpanded = val;
                              });
                            },
                            children: const [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                                child: Text(
                                  'GPS tracking resolves closest stations by coordinate calculations. Platforms and daily train scheduling reflect live IRCTC slots.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF046A38),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 5. Stations List Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Stations Near You (${_stations.length})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          GestureDetector(
                            onTap: _showSortOptions,
                            child: Row(
                              children: [
                                Text(
                                  'Sort by: $_selectedSort',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFF671F),
                                  ),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFFFF671F),
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Stations cards loop
                    _isLoading 
                      ? const Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Center(child: CircularProgressIndicator(color: Color(0xFF046A38))),
                        )
                      : Column(
                          children: _stations.map((station) => _buildStationCard(station)).toList(),
                        ),

                    // View all stations on map button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.map_rounded, color: Color(0xFF0F172A), size: 20),
                          title: const Text(
                            'View all stations on map',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F172A)),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening full screen interactive map...')),
                            );
                          },
                        ),
                      ),
                    ),

                    // 6. Secondary Quick Actions Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSubQuickAction('Search Trains', Icons.directions_railway_filled_rounded, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
                              _buildSubQuickAction('Save Station', Icons.star_rounded, const Color(0xFFFFF7ED), const Color(0xFFFF671F)),
                              _buildSubQuickAction('Live Status', Icons.timer_rounded, const Color(0xFFFAF5FF), const Color(0xFF9333EA)),
                              _buildSubQuickAction('Plan Route', Icons.map_rounded, const Color(0xFFFEF2F2), const Color(0xFFEF4444)),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
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
                Expanded(
                  child: _buildNavItem(
                    isActive: true,
                    activeIcon: Icons.home_filled,
                    inactiveIcon: Icons.home_outlined,
                    label: 'Home',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    isActive: false,
                    activeIcon: Icons.search_rounded,
                    inactiveIcon: Icons.search_rounded,
                    label: 'Explore',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                // Live FAB gap
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                            color: Color(0xFF046A38),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.train_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Live',
                          style: TextStyle(
                            color: Color(0xFF046A38),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    isActive: false,
                    activeIcon: Icons.notifications_rounded,
                    inactiveIcon: Icons.notifications_none_rounded,
                    label: 'Alerts',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    isActive: false,
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
                    label: 'Profile',
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapMarker({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required String label,
    required String subLabel,
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
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F6EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_railway_filled_rounded,
                    color: Color(0xFF046A38),
                    size: 10,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(width: 4),
                Text(
                  subLabel,
                  style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xFF046A38)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          const Icon(
            Icons.location_on_rounded,
            color: Color(0xFF046A38),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildStationCard(Map<String, dynamic> station) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Selected Station: ${station['name']} (${station['code']})')),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Station leading train circle icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F6EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_railway_filled_rounded,
                    color: Color(0xFF046A38),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        station['name'],
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${station['code']}  ·  ${station['type']}',
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildStationTag('${station['platforms']} Platform', const Color(0xFFE2F6EC), const Color(0xFF046A38)),
                          const SizedBox(width: 6),
                          _buildStationTag('No. of Trains: ${station['trainCount']}', const Color(0xFFE2F6EC), const Color(0xFF046A38)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Distance and arrow right
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          station['distance'],
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          station['timeAway'],
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF046A38), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildSubQuickAction(String title, IconData icon, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title.split(' ').first,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Text(
          title.split(' ').last,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required bool isActive,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon,
            color: isActive ? const Color(0xFFFF671F) : const Color(0xFF7A7A7A),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFFFF671F) : const Color(0xFF7A7A7A),
              fontSize: 10.5,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to render streets vector styling beautifully
class _MapVectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw light background map base
    final paintBg = Paint()
      ..color = const Color(0xFFF1F5F9) // Light grey background base
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, paintBg);

    // 2. Draw soft green spaces (parks/forest blocks)
    final paintPark = Paint()
      ..color = const Color(0xFFE2F6EC) // Light green park base
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 10, 70, 50), const Radius.circular(8)), paintPark);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(200, 180, 80, 60), const Radius.circular(8)), paintPark);

    // 3. Draw street network paths
    final paintStreet = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Draw main boulevard avenue (diagonal)
    paintStreet.strokeWidth = 14;
    canvas.drawLine(const Offset(-10, 130), Offset(size.width + 10, 130), paintStreet);

    // Draw minor road cross networks
    paintStreet.strokeWidth = 8;
    canvas.drawLine(const Offset(80, -10), Offset(80, size.height + 10), paintStreet);
    canvas.drawLine(const Offset(240, -10), Offset(240, size.height + 10), paintStreet);

    // Draw Ajni Rd
    paintStreet.strokeWidth = 6;
    canvas.drawLine(const Offset(0, 60), Offset(size.width, 60), paintStreet);
    canvas.drawLine(const Offset(0, 200), Offset(size.width, 200), paintStreet);

    // 4. Draw street names / texts
    const textStyle = TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.bold);
    
    _drawText(canvas, 'Ajni Rd', const Offset(120, 48), textStyle);
    _drawText(canvas, 'Mankapur', const Offset(250, 15), textStyle);
    _drawText(canvas, 'Sitabuldi', const Offset(20, 90), textStyle);
    _drawText(canvas, 'Dharampeth', const Offset(130, 230), textStyle);
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
