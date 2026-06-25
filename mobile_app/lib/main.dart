import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'config/api_config.dart';
import 'splash_screen.dart';
import 'search_trains_page.dart';
import 'nearby_stations_page.dart';
import 'upcoming_trains_page.dart';
import 'app_fonts.dart';
import 'saved_routes_screen.dart';
import 'live_train_tracking_screen.dart';
import 'language_screen.dart';
import 'premium_screen.dart';
import 'pnr_status_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safar Slot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF671F), // Saffron orange
          primary: const Color(0xFFFF671F),
          secondary: const Color(0xFF046A38), // India green
          tertiary: const Color(0xFF06038D), // Ashoka Chakra blue
          brightness: Brightness.light,
        ),
        // Combined Poppins (headings) + Inter (body) text theme (light theme)
        textTheme: AppFonts.combinedTextTheme(ThemeData.light().textTheme),
        // Also apply to primaryTextTheme (AppBar etc.)
        primaryTextTheme: AppFonts.combinedTextTheme(ThemeData.light().primaryTextTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF671F),
          brightness: Brightness.dark,
        ),
        // Combined Poppins (headings) + Inter (body) text theme (dark theme)
        textTheme: AppFonts.combinedTextTheme(ThemeData.dark().textTheme),
        primaryTextTheme: AppFonts.combinedTextTheme(ThemeData.dark().primaryTextTheme),
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}

class SafarSlotHome extends StatefulWidget {
  const SafarSlotHome({super.key});

  @override
  State<SafarSlotHome> createState() => _SafarSlotHomeState();
}

class _SafarSlotHomeState extends State<SafarSlotHome> with TickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  // Bottom nav animation controllers (one per tab: Home, Explore, Alerts, Profile)
  late final List<AnimationController> _navAnimControllers;
  late final List<Animation<double>> _navScaleAnims;

  // Search Train values
  String _fromLocation = "Nagpur (NGP)";
  String _toLocation = "Mumbai CSMT (CSMT)";
  final String _travelDate = "20 May, 2025";

  // Notification banner
  bool _notificationsEnabled = true; // default true until prefs load (avoids flicker)

  String? _cachedCity; // Add cached city for instant load

  Map<String, dynamic>? _userProfile;
  bool _isLoadingProfile = false;

  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoadingProfile = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null && token.isNotEmpty) {
        final response = await http.get(
          Uri.parse(ApiConfig.getProfile),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            setState(() {
              _userProfile = data['userProfileDetils'];
            });
            if (_userProfile!['city'] != null && _userProfile!['city'].toString().isNotEmpty) {
               prefs.setString('cached_city', _userProfile!['city']);
            }
            _checkAndUpdateLocation();
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _checkAndUpdateLocation() async {
    if (!mounted) return;
    try {
      debugPrint("Checking location service...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
         debugPrint("Location service disabled");
         return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      debugPrint("Permission status: $permission");
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          debugPrint("Permission denied");
          return;
        }
      } else if (permission == LocationPermission.deniedForever) {
        debugPrint("Permission denied forever");
        return;
      }

      debugPrint("Getting position...");
      Position? position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        debugPrint("Last known position null, getting current...");
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.low,
            timeLimit: const Duration(seconds: 10),
          );
        } catch (e) {
          debugPrint("Failed to get current position: $e");
        }
      }
      
      double? lat;
      double? long;
      
      if (position != null) {
        lat = position.latitude;
        long = position.longitude;
      } else {
        // Fallback to saved DB location if GPS fails
        final savedLocation = _userProfile?['location'];
        if (savedLocation != null && savedLocation['lat'] != null && savedLocation['long'] != null) {
           lat = double.tryParse(savedLocation['lat'].toString());
           long = double.tryParse(savedLocation['long'].toString());
        }
      }

      if (lat == null || long == null) {
        debugPrint("No valid coordinates available to update city");
        return;
      }

      debugPrint("Position obtained: $lat, $long");
      bool shouldUpdate = false;
      final city = _userProfile?['city']?.toString();
      
      if (city == null || city.isEmpty) {
        debugPrint("City is empty, should update");
        shouldUpdate = true;
      } else {
        final savedLocation = _userProfile?['location'];
        if (savedLocation != null && savedLocation['lat'] != null && savedLocation['long'] != null) {
           double savedLat = double.tryParse(savedLocation['lat'].toString()) ?? 0;
           double savedLong = double.tryParse(savedLocation['long'].toString()) ?? 0;
           double distance = Geolocator.distanceBetween(lat, long, savedLat, savedLong);
           debugPrint("Distance from saved location: $distance meters");
           
           if (distance > 2000) { // 2 kilometers
              debugPrint("Distance > 2000m, should update");
              shouldUpdate = true;
           }
        } else {
           debugPrint("No saved location coords but city exists, should update");
           shouldUpdate = true; 
        }
      }

      if (shouldUpdate) {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');
        if (token != null) {
          debugPrint("Calling updateLocation API...");
          final response = await http.put(
            Uri.parse(ApiConfig.updateLocation),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'location': {
                'lat': lat,
                'long': long,
              }
            }),
          );

          debugPrint("updateLocation API Response: ${response.statusCode} - ${response.body}");
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true) {
              setState(() {
                if (_userProfile != null) {
                  _userProfile!['city'] = data['city'];
                  _userProfile!['location'] = data['location'];
                }
              });
              if (data['city'] != null && data['city'].toString().isNotEmpty) {
                 prefs.setString('cached_city', data['city']);
              }
              debugPrint("UI state updated with new city: ${data['city']}");
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking location: $e");
    }
  }

  @override
  void initState() {
    super.initState(); // Must be first — initializes TickerProviderStateMixin before vsync: this
    _loadCachedCity();
    // Create 4 animation controllers for Home(0), Explore(1), Alerts(3), Profile(4)
    _navAnimControllers = List.generate(
      4,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        lowerBound: 0.85,
        upperBound: 1.0,
        value: i == 0 ? 1.0 : 0.85, // Home starts active
      ),
    );
    _navScaleAnims = _navAnimControllers
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _startBannerTimer();
    _loadNotifPref();
    _fetchUserProfile();
  }

  Future<void> _loadCachedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final city = prefs.getString('cached_city');
    if (city != null && mounted) {
      setState(() => _cachedCity = city);
    }
  }

  Future<void> _loadNotifPref() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? false;
    if (mounted) setState(() => _notificationsEnabled = enabled);
  }

  Future<void> _enableNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', true);
    if (mounted) setState(() => _notificationsEnabled = true);
  }

  void _startBannerTimer() {
    _bannerTimer?.cancel();
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
      if (isCurrentRoute && _currentIndex == 0) {
        _bannerIndex = (_bannerIndex + 1) % 3;
        _bannerController.animateToPage(
          _bannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    for (final c in _navAnimControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _swapLocations() {
    setState(() {
      final temp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = temp;
    });
  }

  // Display SnackBar
  void _showFeatureComingSoon(String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _userProfile != null && _userProfile!['city'] != null && _userProfile!['city'].toString().isNotEmpty
                              ? _userProfile!['city']
                              : (_cachedCity != null && _cachedCity!.isNotEmpty ? _cachedCity! : 'Fetching location...'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right Notification Bell with badge 3
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        color: Color(0xFF0F172A),
                        size: 26,
                      ),
                      onPressed: () {
                        setState(() {
                          _currentIndex = 3; // Switch to Alerts tab
                        });
                      },
                    ),
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF671F), // Orange badge
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Banner Slideshow Carousel (4:1 Aspect Ratio)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 3.8, // Premium 4:1 style aspect ratio
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(8),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: PageView.builder(
                        controller: _bannerController,
                        onPageChanged: (index) {
                          setState(() {
                            _bannerIndex = index;
                          });
                        },
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            'assets/images/homepage_banner1.png',
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Page Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 6,
                      width: _bannerIndex == index ? 16 : 6,
                      decoration: BoxDecoration(
                        color: _bannerIndex == index
                            ? const Color(0xFFFF671F)
                            : const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 3. Search Trains Card Layout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Search Trains',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Row with From, Swap, To fields
                  Row(
                    children: [
                      // From Field
                      Expanded(
                        child: InkWell(
                          onTap: () => _showFeatureComingSoon('From Station Selector'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF046A38), // Green dot
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'From',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _fromLocation,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      // Swap Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: InkWell(
                          onTap: _swapLocations,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.swap_horiz_rounded,
                              color: Color(0xFF0F172A),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      
                      // To Field
                      Expanded(
                        child: InkWell(
                          onTap: () => _showFeatureComingSoon('To Station Selector'),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFF671F), // Orange dot
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'To',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _toLocation,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Row for Date Picker & Action Button
                  Row(
                    children: [
                      // Date Selector Field
                      Expanded(
                        child: InkWell(
                          onTap: () => _showFeatureComingSoon('Date Selector'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today_rounded,
                                  color: Color(0xFF64748B),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Travel Date',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        _travelDate,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Search Trains Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchTrainsPage(
                                  initialFrom: _fromLocation,
                                  initialTo: _toLocation,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF671F), // Saffron Orange
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Search Trains',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showFeatureComingSoon('Quick Actions'),
                      child: const Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF671F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 5 items row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickActionItem(
                      label: 'Nearby\nStations',
                      icon: Icons.location_on_rounded,
                      bgColor: const Color(0xFFE2F6EC),
                      iconColor: const Color(0xFF046A38),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NearbyStationsPage()),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      label: 'Live Train\nStatus',
                      icon: Icons.directions_railway_filled_rounded,
                      bgColor: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LiveTrainTrackingScreen()),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      label: 'Book\nTickets',
                      icon: Icons.confirmation_number_rounded,
                      bgColor: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFFF671F),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchTrainsPage(
                              initialFrom: _fromLocation,
                              initialTo: _toLocation,
                            ),
                          ),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      label: 'Upcoming\nTrains',
                      icon: Icons.watch_later_rounded,
                      bgColor: const Color(0xFFFAF5FF),
                      iconColor: const Color(0xFF9333EA),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UpcomingTrainsPage()),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      label: 'Saved\nRoutes',
                      icon: Icons.stars_rounded,
                      bgColor: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFEF4444),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SavedRoutesScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 5. Upcoming Trains Near You
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Upcoming Trains Near You',
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F6EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Live',
                            style: TextStyle(
                              color: Color(0xFF046A38),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => _showFeatureComingSoon('All Upcoming Trains'),
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF671F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Train list container card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildUpcomingTrainItem(
                        trainNo: '22105',
                        trainName: 'Mumbai LTT Express',
                        stationPlatform: 'Ajni (AJNI)  ·  Platform 2',
                        time: '10:30 AM',
                        timeDiff: 'In 18 mins',
                        themeColor: const Color(0xFFFF671F),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildUpcomingTrainItem(
                        trainNo: '12721',
                        trainName: 'Hyderabad SF Express',
                        stationPlatform: 'Nagpur (NGP)  ·  Platform 1',
                        time: '11:15 AM',
                        timeDiff: 'In 1h 3m',
                        themeColor: const Color(0xFF0284C7),
                      ),
                      const Divider(height: 1, color: Color(0xFFF1F5F9)),
                      _buildUpcomingTrainItem(
                        trainNo: '12615',
                        trainName: 'Grand Trunk Express',
                        stationPlatform: 'Itwari (ITW)  ·  Platform 3',
                        time: '12:05 PM',
                        timeDiff: 'In 1h 53m',
                        themeColor: const Color(0xFF046A38),
                      ),
                      
                      // Find more trains around you bar at bottom
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NearbyStationsPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF4FAF7),
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_railway_filled_rounded,
                                    color: Color(0xFF046A38),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Find more trains around you',
                                    style: TextStyle(
                                      color: Color(0xFF046A38),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF046A38),
                                size: 20,
                              ),
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

          // 6. Horizontal Cards Row (PNR, Running Status, Coach Position)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _buildHorizontalUtilityCard(
                    title: 'PNR Status',
                    subtitle: 'Check your PNR\nstatus instantly',
                    icon: Icons.check_circle_rounded,
                    themeColor: const Color(0xFF046A38),
                    bgColor: const Color(0xFFE2F6EC),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PnrStatusScreen()),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  _buildHorizontalUtilityCard(
                    title: 'Train Running\nStatus',
                    subtitle: 'Check live status\nof any train',
                    icon: Icons.directions_railway_rounded,
                    themeColor: const Color(0xFF0284C7),
                    bgColor: const Color(0xFFE0F2FE),
                  ),
                  const SizedBox(width: 12),
                  _buildHorizontalUtilityCard(
                    title: 'Coach Position',
                    subtitle: 'Find your coach\nposition on platform',
                    icon: Icons.grid_view_rounded,
                    themeColor: const Color(0xFF9333EA),
                    bgColor: const Color(0xFFFAF5FF),
                  ),
                ],
              ),
            ),
          ),

          // 7. Stay Updated Notification Card (only when notifications are OFF)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: _notificationsEnabled
                ? const SizedBox.shrink(key: ValueKey('hidden'))
                : Padding(
                    key: const ValueKey('shown'),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFED7AA), width: 1.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            color: Color(0xFFFF671F),
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Stay Updated',
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7C2D12),
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Enable notifications to get real-time updates, alerts and platform changes.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF9A3412),
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton(
                            onPressed: _enableNotifications,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFF671F),
                              side: const BorderSide(color: Color(0xFFFF671F), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: const Text(
                              'Enable Alerts',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          
          const SizedBox(height: 80), // Padding at the bottom for scroll clearance
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap ?? () => _showFeatureComingSoon(label.replaceAll('\n', ' ')),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
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
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTrainItem({
    required String trainNo,
    required String trainName,
    required String stationPlatform,
    required String time,
    required String timeDiff,
    required Color themeColor,
  }) {
    return InkWell(
      onTap: () => _showFeatureComingSoon('Train $trainNo Detail'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        child: Row(
          children: [
            // Left Train logo icon circular background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: themeColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_railway_filled_rounded,
                color: themeColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            
            // Train Number and Name details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        trainNo,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trainName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stationPlatform,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            
            // Right Train time schedules details
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  timeDiff,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF046A38),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalUtilityCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color themeColor,
    required Color bgColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 145,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with tint rounded bg
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: themeColor,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.5,
              color: Color(0xFF64748B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          // Action button
          InkWell(
            onTap: () => _showFeatureComingSoon(title.replaceAll('\n', ' ')),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Check Now',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: themeColor,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildExploreTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.search_rounded, size: 64, color: Color(0xFFFF671F)),
          const SizedBox(height: 16),
          const Text(
            'Explore Routes & Trains',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Search, discover, and trace Indian railway networks directly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            decoration: InputDecoration(
              hintText: 'Enter train name or number...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFF671F)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFF671F), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          Icon(Icons.directions_railway_filled_rounded, size: 72, color: Color(0xFF046A38)),
          SizedBox(height: 20),
          Text(
            'Live GPS Tracking Active',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Locate train position, platform allocations, and status updates on-the-go.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Alerts Tab State ────────────────────────────────────────────────────────
  int _alertsTabIndex = 0;  // 0=All, 1=Active, 2=History

  static const List<Map<String, dynamic>> _alertsData = [
    {
      'type': 'Delay Alert',
      'typeColor': Color(0xFFFF671F),
      'typeBg': Color(0xFFFFF0EB),
      'icon': Icons.access_time_rounded,
      'iconBg': Color(0xFFFFF0EB),
      'iconColor': Color(0xFFFF671F),
      'borderColor': Color(0xFFFF671F),
      'trainNo': '12615',
      'trainName': 'Grand Trunk Express',
      'from': 'Itwari (ITW)',
      'to': 'Nagpur (NGP)',
      'desc': 'Delayed by 45 minutes due to heavy fog',
      'time': '10 mins ago',
      'priority': 'High Priority',
      'priorityBg': Color(0xFFFEE2E2),
      'priorityColor': Color(0xFFDC2626),
      'isActive': true,
    },
    {
      'type': 'Platform Change Alert',
      'typeColor': Color(0xFFF59E0B),
      'typeBg': Color(0xFFFFFBEB),
      'icon': Icons.swap_horiz_rounded,
      'iconBg': Color(0xFFFFFBEB),
      'iconColor': Color(0xFFF59E0B),
      'borderColor': Color(0xFFF59E0B),
      'trainNo': '22105',
      'trainName': 'Mumbai LTT Express',
      'from': 'Ajni (AJNI)',
      'to': 'Mumbai CSMT (CSMT)',
      'desc': 'Platform changed from 2 to 5',
      'time': '25 mins ago',
      'priority': 'Medium Priority',
      'priorityBg': Color(0xFFFEF3C7),
      'priorityColor': Color(0xFFD97706),
      'isActive': true,
    },
    {
      'type': 'Arrival Alert',
      'typeColor': Color(0xFF046A38),
      'typeBg': Color(0xFFE2F6EC),
      'icon': Icons.notifications_rounded,
      'iconBg': Color(0xFFE2F6EC),
      'iconColor': Color(0xFF046A38),
      'borderColor': Color(0xFF046A38),
      'trainNo': '12951',
      'trainName': 'Mumbai Rajdhani Express',
      'from': '',
      'to': 'Nagpur (NGP)',
      'desc': 'Arriving at Nagpur (NGP)\nExpected arrival at 10:30 AM',
      'time': '30 mins ago',
      'priority': 'Low Priority',
      'priorityBg': Color(0xFFDCFCE7),
      'priorityColor': Color(0xFF16A34A),
      'isActive': true,
    },
    {
      'type': 'Departure Alert',
      'typeColor': Color(0xFF0284C7),
      'typeBg': Color(0xFFE0F2FE),
      'icon': Icons.send_rounded,
      'iconBg': Color(0xFFE0F2FE),
      'iconColor': Color(0xFF0284C7),
      'borderColor': Color(0xFF0284C7),
      'trainNo': '12721',
      'trainName': 'Hyderabad SF Express',
      'from': 'Nagpur (NGP)',
      'to': 'Hyderabad (HYB)',
      'desc': 'Departing from Platform 1',
      'time': '1 hr ago',
      'priority': 'Low Priority',
      'priorityBg': Color(0xFFDCFCE7),
      'priorityColor': Color(0xFF16A34A),
      'isActive': false,
    },
    {
      'type': 'Delay Alert',
      'typeColor': Color(0xFFFF671F),
      'typeBg': Color(0xFFFFF0EB),
      'icon': Icons.access_time_rounded,
      'iconBg': Color(0xFFFFF0EB),
      'iconColor': Color(0xFFFF671F),
      'borderColor': Color(0xFFFF671F),
      'trainNo': '12139',
      'trainName': 'Vidarbha Express',
      'from': 'Nagpur (NGP)',
      'to': 'Itwari (ITW)',
      'desc': 'Delayed by 20 minutes',
      'time': '2 hrs ago',
      'priority': 'Medium Priority',
      'priorityBg': Color(0xFFFEF3C7),
      'priorityColor': Color(0xFFD97706),
      'isActive': false,
    },
    {
      'type': 'Platform Change Alert',
      'typeColor': Color(0xFFF59E0B),
      'typeBg': Color(0xFFFFFBEB),
      'icon': Icons.swap_horiz_rounded,
      'iconBg': Color(0xFFFFFBEB),
      'iconColor': Color(0xFFF59E0B),
      'borderColor': Color(0xFFF59E0B),
      'trainNo': '12615',
      'trainName': 'Grand Trunk Express',
      'from': 'Itwari (ITW)',
      'to': 'Nagpur (NGP)',
      'desc': 'Platform changed from 3 to 1',
      'time': '3 hrs ago',
      'priority': 'Low Priority',
      'priorityBg': Color(0xFFDCFCE7),
      'priorityColor': Color(0xFF16A34A),
      'isActive': false,
    },
  ];

  Widget _buildAlertsTab() {
    final filteredAlerts = _alertsTabIndex == 1
        ? _alertsData.where((a) => a['isActive'] == true).toList()
        : _alertsTabIndex == 2
            ? _alertsData.where((a) => a['isActive'] == false).toList()
            : _alertsData;

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // ── Header ──────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Alerts Center',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A))),
                    SizedBox(height: 2),
                    Text('Stay informed. Travel smarter.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Icon(Icons.settings_rounded, size: 20, color: Color(0xFF0F172A)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Stats row (horizontally scrollable) ──────────────────────────
        SizedBox(
          height: 108,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAlertStatCard(
                icon: Icons.access_time_rounded,
                iconColor: const Color(0xFFFF671F),
                iconBg: const Color(0xFFFFF0EB),
                count: '05',
                label: 'Delay Alerts',
                sub: 'Trains delayed',
              ),
              _buildAlertStatCard(
                icon: Icons.swap_horiz_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFFFBEB),
                count: '02',
                label: 'Platform Change',
                sub: 'Check platform',
              ),
              _buildAlertStatCard(
                icon: Icons.notifications_rounded,
                iconColor: const Color(0xFF046A38),
                iconBg: const Color(0xFFE2F6EC),
                count: '03',
                label: 'Arrival Alerts',
                sub: 'Upcoming arrivals',
              ),
              _buildAlertStatCard(
                icon: Icons.send_rounded,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                count: '02',
                label: 'Departure Alerts',
                sub: 'Upcoming departures',
                isLast: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // ── Tab row: All Alerts | Active | History ───────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildAlertsTabItem(0, Icons.notifications_rounded, 'All Alerts'),
                _buildAlertsTabItem(1, Icons.circle_rounded, 'Active'),
                _buildAlertsTabItem(2, Icons.history_rounded, 'History'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Filter + Sort row ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildDropdownChip(Icons.filter_list_rounded, 'All Types'),
              const Spacer(),
              _buildDropdownChip(Icons.swap_vert_rounded, 'Sort: Latest'),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // ── Alert cards ───────────────────────────────────────────────────
        ...filteredAlerts.map((alert) => _buildAlertCard(alert)),

        // ── Push notification enable banner ────────────────────────────────
        if (!_notificationsEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF046A38), Color(0xFF078A4A)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Never miss an important update!',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        SizedBox(height: 2),
                        Text('Enable push notifications for real-time alerts',
                            style: TextStyle(fontSize: 11, color: Color(0xFFB9F0D5))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enableNotifications,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.notifications_active_rounded,
                              size: 14, color: Color(0xFF046A38)),
                          SizedBox(width: 4),
                          Text('Enable Alerts',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF046A38))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Quick Actions ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Quick Actions',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildAlertQuickAction(
                      Icons.directions_railway_filled_rounded,
                      'Live Tracking',
                      'Track your train',
                      const Color(0xFFE2F6EC),
                      const Color(0xFF046A38)),
                  _buildAlertQuickAction(
                      Icons.search_rounded,
                      'Search Trains',
                      'Find your train',
                      const Color(0xFFE0F2FE),
                      const Color(0xFF0284C7)),
                  _buildAlertQuickAction(
                      Icons.location_on_rounded,
                      'Nearby Stations',
                      'Find stations',
                      const Color(0xFFFFF7ED),
                      const Color(0xFFFF671F)),
                  _buildAlertQuickAction(
                      Icons.star_rounded,
                      'Saved Routes',
                      'View your routes',
                      const Color(0xFFFEF3C7),
                      const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildAlertStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String count,
    required String label,
    required String sub,
    bool isLast = false,
  }) {
    return Container(
      width: 130,
      margin: EdgeInsets.only(right: isLast ? 0 : 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFCBD5E1)),
            ],
          ),
          const SizedBox(height: 8),
          Text(count,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: iconColor)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          Text(sub,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildAlertsTabItem(int index, IconData icon, String label) {
    final isActive = _alertsTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _alertsTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFFF671F) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 13,
                  color: isActive ? Colors.white : const Color(0xFF64748B)),
              const SizedBox(width: 4),
              Text(label,
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : const Color(0xFF64748B))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F172A)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
              color: (alert['borderColor'] as Color).withAlpha(14),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left colour accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: alert['borderColor'] as Color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: icon + type badge + time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: alert['iconBg'] as Color,
                              shape: BoxShape.circle),
                          child: Icon(alert['icon'] as IconData,
                              size: 18, color: alert['iconColor'] as Color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: alert['typeBg'] as Color,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      alert['type'] as String,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: alert['typeColor'] as Color),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${alert['trainNo']} ${alert['trainName']}',
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((alert['from'] as String).isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(alert['from'] as String,
                                        style: const TextStyle(
                                            fontSize: 11, color: Color(0xFF64748B))),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4),
                                      child: Icon(Icons.arrow_forward_rounded,
                                          size: 11, color: Color(0xFF94A3B8)),
                                    ),
                                    Text(alert['to'] as String,
                                        style: const TextStyle(
                                            fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ] else ...[
                                const SizedBox(height: 2),
                                Text(alert['to'] as String,
                                    style: const TextStyle(
                                        fontSize: 11, color: Color(0xFF64748B))),
                              ],
                            ],
                          ),
                        ),
                        // Time + Priority column
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(alert['time'] as String,
                                style: const TextStyle(
                                    fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: alert['priorityBg'] as Color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                alert['priority'] as String,
                                style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: alert['priorityColor'] as Color),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded,
                            size: 18, color: Color(0xFFCBD5E1)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Description text
                    Text(
                      alert['desc'] as String,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertQuickAction(
      IconData icon, String label, String sub, Color bg, Color fg) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Icon(icon, color: fg, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text(sub,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8))),
          ],
        ),
      ),
    );
  }


  Widget _buildProfileTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header (Title, Subtitle on left, notifications & settings on right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your account and preferences',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF0F172A),
                          size: 24,
                        ),
                        onPressed: () {
                          setState(() {
                            _currentIndex = 3; // Switch to Alerts tab
                          });
                        },
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: _saffron,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF0F172A),
                      size: 24,
                    ),
                    onPressed: () {
                      _showFeatureComingSoon('Settings');
                    },
                  ),
                ],
              ),
            ],
          ),

          // 2. User Info Card with Stats Grid inside
          Container(
            margin: const EdgeInsets.only(top: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: _saffron.withAlpha(20),
                          child: Text(
                            _userProfile != null && _userProfile!['name'] != null && _userProfile!['name'].toString().trim().isNotEmpty
                                ? _userProfile!['name'].toString().trim().substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: _saffron,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: () {
                              _showFeatureComingSoon('Edit Profile Photo');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                              child: const Icon(
                                Icons.edit_outlined,
                                size: 13,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _userProfile?['name'] ?? 'User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE2F6EC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFDCFCE7), width: 1),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(
                                      Icons.verified_user_rounded,
                                      color: Color(0xFF16A34A),
                                      size: 11,
                                    ),
                                    SizedBox(width: 3),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: Color(0xFF16A34A),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userProfile?['email'] ?? 'Not logged in',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                              fontFamily: 'Inter',
                            ),
                          ),
                          // Mobile number removed as per backend data
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildProfileStatBox(Icons.bookmark_added_rounded, _userProfile?['savedRoutes']?.toString() ?? '0', 'Saved Routes'),
                    _buildVerticalDivider(),
                    _buildProfileStatBox(Icons.access_time_filled_rounded, '0', 'Recent Searches'),
                    _buildVerticalDivider(),
                    _buildProfileStatBox(Icons.directions_railway_filled_rounded, '0', 'Upcoming Trips'),
                    _buildVerticalDivider(),
                    _buildProfileStatBox(Icons.favorite_rounded, _userProfile?['favoriteStations']?.toString() ?? '0', 'Favourite Stations'),
                  ],
                ),
              ],
            ),
          ),

          // 3. Go Premium Banner
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
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
                  child: Center(
                    child: Icon(
                      Icons.workspace_premium,
                      color: _saffron,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Go Premium',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7C2D12),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Unlock exclusive features and seamless travel',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9A3412),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _saffron,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Upgrade Now',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF9A3412),
                  size: 16,
                ),
              ],
            ),
          ),

          // 4. My Bookings Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Bookings',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showFeatureComingSoon('All Bookings'),
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: _saffron,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF7ED),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.directions_railway_filled_rounded,
                          color: _saffron,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '12951 Mumbai Rajdhani Express',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Mumbai CSMT  →  New Delhi (NDLS)',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontFamily: 'Inter',
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '21 May 2025  ·  2A  ·  PNR: 1234567890',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF94A3B8),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F6EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Confirmed',
                            style: TextStyle(
                              color: Color(0xFF046A38),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E1),
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 5. Preferences Card Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Preferences',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildCustomSettingItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Alert Preferences',
                      subtitle: 'Manage your alerts and notifications',
                      onTap: () => _showFeatureComingSoon('Alert Preferences'),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildCustomSettingItem(
                      icon: Icons.language_rounded,
                      title: 'Language',
                      trailingValue: _userProfile?['language'] == 'hi' ? 'Hindi' : 
                                     _userProfile?['language'] == 'ma' ? 'Marathi' :
                                     _userProfile?['language'] == 'ta' ? 'Tamil' :
                                     _userProfile?['language'] == 'tel' ? 'Telugu' :
                                     _userProfile?['language'] == 'ka' ? 'Kannada' :
                                     _userProfile?['language'] == 'mal' ? 'Malayalam' :
                                     _userProfile?['language'] == 'bengali' ? 'Bengali' :
                                     _userProfile?['language'] == 'panj' ? 'Punjabi' :
                                     _userProfile?['language'] == 'odia' ? 'Odia' : 'English',
                      onTap: () async {
                        final newLang = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LanguageSelectionScreen(isFromProfile: true)),
                        );
                        if (newLang != null && newLang is String) {
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('token');
                            if (token != null && token.isNotEmpty) {
                              await http.put(
                                Uri.parse(ApiConfig.updateLanguage),
                                headers: {
                                  'Content-Type': 'application/json',
                                  'Authorization': 'Bearer $token',
                                },
                                body: jsonEncode({'language': newLang}),
                              );
                            }
                            
                            setState(() {
                              if (_userProfile == null) {
                                _userProfile = {'language': newLang};
                              } else {
                                _userProfile!['language'] = newLang;
                              }
                            });
                          } catch (e) {
                            debugPrint("Error updating language: $e");
                          }
                        }
                      },
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildCustomSettingItem(
                      icon: Icons.location_on_outlined,
                      title: 'Preferred Stations',
                      subtitle: 'Manage your preferred stations',
                      onTap: () => _showFeatureComingSoon('Preferred Stations'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 6. Support & Information Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Text(
                'Support & Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: Column(
                  children: [
                    _buildCustomSettingItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'Get help and contact support',
                      onTap: () => _showFeatureComingSoon('Help & Support'),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildCustomSettingItem(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      subtitle: 'Read our terms and conditions',
                      onTap: () => _showFeatureComingSoon('Terms & Conditions'),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildCustomSettingItem(
                      icon: Icons.security_rounded,
                      title: 'Privacy Policy',
                      subtitle: 'Read our privacy policy',
                      onTap: () => _showFeatureComingSoon('Privacy Policy'),
                    ),
                    const Divider(height: 1, color: Color(0xFFF1F5F9)),
                    _buildCustomSettingItem(
                      icon: Icons.info_outline_rounded,
                      title: 'About SafarSlot',
                      trailingValue: 'App version 2.3.1',
                      onTap: () => _showFeatureComingSoon('About SafarSlot'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 7. Outlined Log Out Button
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Logged out successfully!'),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatBox(IconData icon, String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _saffron.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                icon,
                color: _saffron,
                size: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFF1F5F9),
    );
  }

  Widget _buildCustomSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingValue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Color(0xFFF1F5F9),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            icon,
            color: const Color(0xFF475569),
            size: 18,
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF0F172A),
          fontFamily: 'Poppins',
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF64748B),
                fontFamily: 'Inter',
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingValue != null)
            Text(
              trailingValue,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          const SizedBox(width: 4),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCBD5E1),
            size: 18,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  // ─── Theme colours ───────────────────────────────────────────────────────
  static const _saffron  = Color(0xFFFF671F);
  static const _green    = Color(0xFF046A38);
  static const _inactive = Color(0xFF7A7A7A);

  // Maps tab-bar index (0,1,3,4) → animation list index (0,1,2,3)
  int _animIndex(int tabIndex) {
    const map = {0: 0, 1: 1, 3: 2, 4: 3};
    return map[tabIndex] ?? 0;
  }

  void _onNavTap(int tabIndex) {
    if (tabIndex == _currentIndex) return;
    final prevAnimIdx = _animIndex(_currentIndex);
    final nextAnimIdx = _animIndex(tabIndex);
    _navAnimControllers[prevAnimIdx].reverse();
    _navAnimControllers[nextAnimIdx].forward();
    setState(() => _currentIndex = tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // ─── Content ────────────────────────────────────────────────────────────
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeTab(),
            _buildExploreTab(),
            _buildLiveTab(),
            _buildAlertsTab(),
            _buildProfileTab(),
          ],
        ),
      ),

      // ─── Live centre button ─────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_currentIndex != 2) {
            _navAnimControllers[_animIndex(_currentIndex)].reverse();
            setState(() => _currentIndex = 2);
          }
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        highlightElevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        splashColor: Colors.transparent,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: _green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 6),
            boxShadow: [
              BoxShadow(
                color: _green.withValues(alpha: 0.30),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ─── Premium bottom bar ────────────────────────────────────────────────
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
            height: 88,
            child: Row(
              children: [
                // Home  (tab 0, anim 0)
                Expanded(
                  child: _buildNavItem(
                    tabIndex: 0, animIdx: 0,
                    activeIcon: Icons.home_filled,
                    inactiveIcon: Icons.home_outlined,
                    label: 'Home',
                  ),
                ),
                // Search  (tab 1, anim 1)
                Expanded(
                  child: _buildNavItem(
                    tabIndex: 1, animIdx: 1,
                    activeIcon: Icons.search_rounded,
                    inactiveIcon: Icons.search_rounded,
                    label: 'Search',
                  ),
                ),
                // Gap for FAB
                const SizedBox(width: 80),
                // Alerts  (tab 3, anim 2)
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      _buildNavItem(
                        tabIndex: 3, animIdx: 2,
                        activeIcon: Icons.notifications_rounded,
                        inactiveIcon: Icons.notifications_none_rounded,
                        label: 'Alerts',
                      ),
                      Positioned(
                        right: 22,
                        top: 10,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            color: _saffron,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile  (tab 4, anim 3)
                Expanded(
                  child: _buildNavItem(
                    tabIndex: 4, animIdx: 3,
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
                    label: 'Profile',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Animated nav item: scale bounce + saffron pill highlight when active
  Widget _buildNavItem({
    required int tabIndex,
    required int animIdx,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
  }) {
    final isActive = _currentIndex == tabIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onNavTap(tabIndex),
      child: ScaleTransition(
        scale: _navScaleAnims[animIdx],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Soft pill glow when active
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: isActive ? 44 : 0,
                  height: isActive ? 28 : 0,
                  decoration: BoxDecoration(
                    color: _saffron.withValues(alpha: isActive ? 0.12 : 0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                Icon(
                  isActive ? activeIcon : inactiveIcon,
                  color: isActive ? _saffron : _inactive,
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isActive ? _saffron : _inactive,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.1,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

