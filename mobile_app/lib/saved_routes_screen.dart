import 'package:flutter/material.dart';
import 'app_fonts.dart';
import 'search_trains_page.dart';
import 'nearby_stations_page.dart';

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> with SingleTickerProviderStateMixin {
  int _activeTab = 0; // 0: My Saved Routes, 1: Recently Viewed
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _sortBy = "Date"; // "Date", "Name", "Time"
  bool _isEditing = false;

  // Colors mapping matching the app identity
  static const Color _saffron = Color(0xFFFF671F);
  static const Color _green = Color(0xFF046A38);
  static const Color _inactive = Color(0xFF94A3B8);

  // Initial mock list of saved routes based on the provided screenshot
  late List<SavedRouteModel> _savedRoutes;
  late List<SavedRouteModel> _recentlyViewed;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _savedRoutes = [
      SavedRouteModel(
        id: "1",
        fromName: "Nagpur",
        fromCode: "NGP",
        toName: "Mumbai CSMT",
        toCode: "CSMT",
        date: "20 May, 2025",
        classes: "All Classes",
        badgeText: "Frequent Journey",
        badgeColor: const Color(0xFFE2F6EC),
        badgeTextColor: const Color(0xFF046A38),
        iconColor: const Color(0xFF046A38),
        iconBgColor: const Color(0xFFE2F6EC),
        time: "10:30 AM",
        relativeTime: "In 18 mins",
        relativeTimeColor: const Color(0xFF046A38),
        departureHour: 10,
        departureMinute: 30,
      ),
      SavedRouteModel(
        id: "2",
        fromName: "Pune Junction",
        fromCode: "PUNE",
        toName: "Nagpur",
        toCode: "NGP",
        date: "19 May, 2025",
        classes: "Sleeper",
        badgeText: "Weekend Trip",
        badgeColor: const Color(0xFFFFF7ED),
        badgeTextColor: const Color(0xFFFF671F),
        iconColor: const Color(0xFFFF671F),
        iconBgColor: const Color(0xFFFFF7ED),
        time: "09:15 AM",
        relativeTime: "In 1h 3m",
        relativeTimeColor: const Color(0xFF046A38),
        departureHour: 9,
        departureMinute: 15,
      ),
      SavedRouteModel(
        id: "3",
        fromName: "Mumbai CSMT",
        fromCode: "CSMT",
        toName: "Hyderabad",
        toCode: "HYB",
        date: "18 May, 2025",
        classes: "3A, 2A",
        badgeText: "Business Travel",
        badgeColor: const Color(0xFFE0F2FE),
        badgeTextColor: const Color(0xFF0284C7),
        iconColor: const Color(0xFF0284C7),
        iconBgColor: const Color(0xFFE0F2FE),
        time: "08:45 AM",
        relativeTime: "In 2h 33m",
        relativeTimeColor: const Color(0xFF046A38),
        departureHour: 8,
        departureMinute: 45,
      ),
      SavedRouteModel(
        id: "4",
        fromName: "Nagpur",
        fromCode: "NGP",
        toName: "Hyderabad Deccan",
        toCode: "HYB",
        date: "19 May, 2025",
        classes: "All Classes",
        badgeText: "Family Trip",
        badgeColor: const Color(0xFFFAF5FF),
        badgeTextColor: const Color(0xFF9333EA),
        iconColor: const Color(0xFF9333EA),
        iconBgColor: const Color(0xFFFAF5FF),
        time: "07:20 PM",
        relativeTime: "In 4h 8m",
        relativeTimeColor: const Color(0xFF046A38),
        departureHour: 19,
        departureMinute: 20,
      ),
      SavedRouteModel(
        id: "5",
        fromName: "New Delhi",
        fromCode: "NDLS",
        toName: "Lucknow",
        toCode: "LKO",
        date: "17 May, 2025",
        classes: "Chair Car",
        badgeText: "Short Trip",
        badgeColor: const Color(0xFFE2F6EC),
        badgeTextColor: const Color(0xFF046A38),
        iconColor: const Color(0xFF046A38),
        iconBgColor: const Color(0xFFE2F6EC),
        time: "06:10 PM",
        relativeTime: "In 3h 15m",
        relativeTimeColor: const Color(0xFF046A38),
        departureHour: 18,
        departureMinute: 10,
      ),
      SavedRouteModel(
        id: "6",
        fromName: "Bhopal",
        fromCode: "BPL",
        toName: "Indore Junction",
        toCode: "INDB",
        date: "15 May, 2025",
        classes: "General",
        badgeText: "Regular Journey",
        badgeColor: const Color(0xFFFFF7ED),
        badgeTextColor: const Color(0xFFFF671F),
        iconColor: const Color(0xFFFF671F),
        iconBgColor: const Color(0xFFFFF7ED),
        time: "05:30 PM",
        relativeTime: "In 1h 40m",
        relativeTimeColor: const Color(0xFF046A38),
        departureHour: 17,
        departureMinute: 30,
      ),
    ];

    // Mock data for recently viewed tab
    _recentlyViewed = [
      SavedRouteModel(
        id: "r1",
        fromName: "Mumbai CSMT",
        fromCode: "CSMT",
        toName: "Nagpur",
        toCode: "NGP",
        date: "23 May, 2025",
        classes: "All Classes",
        badgeText: "Recent Search",
        badgeColor: const Color(0xFFF1F5F9),
        badgeTextColor: const Color(0xFF64748B),
        iconColor: const Color(0xFF64748B),
        iconBgColor: const Color(0xFFF1F5F9),
        time: "11:30 PM",
        relativeTime: "Yesterday",
        relativeTimeColor: const Color(0xFF64748B),
        departureHour: 23,
        departureMinute: 30,
      ),
      SavedRouteModel(
        id: "r2",
        fromName: "Bengaluru",
        fromCode: "SBC",
        toName: "Chennai Central",
        toCode: "MAS",
        date: "21 May, 2025",
        classes: "3A, 2A, 1A",
        badgeText: "Recent Search",
        badgeColor: const Color(0xFFF1F5F9),
        badgeTextColor: const Color(0xFF64748B),
        iconColor: const Color(0xFF64748B),
        iconBgColor: const Color(0xFFF1F5F9),
        time: "06:00 AM",
        relativeTime: "2 days ago",
        relativeTimeColor: const Color(0xFF64748B),
        departureHour: 6,
        departureMinute: 0,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SavedRouteModel> _getFilteredAndSortedList() {
    List<SavedRouteModel> targetList = _activeTab == 0 ? _savedRoutes : _recentlyViewed;
    
    // 1. Search Filter
    if (_searchQuery.isNotEmpty) {
      targetList = targetList.where((route) {
        final query = _searchQuery.toLowerCase();
        return route.fromName.toLowerCase().contains(query) ||
               route.fromCode.toLowerCase().contains(query) ||
               route.toName.toLowerCase().contains(query) ||
               route.toCode.toLowerCase().contains(query);
      }).toList();
    }

    // 2. Sort Logic
    List<SavedRouteModel> sortedList = List.from(targetList);
    if (_sortBy == "Name") {
      sortedList.sort((a, b) => a.fromName.compareTo(b.fromName));
    } else if (_sortBy == "Time") {
      sortedList.sort((a, b) {
        final aTimeVal = a.departureHour * 60 + a.departureMinute;
        final bTimeVal = b.departureHour * 60 + b.departureMinute;
        return aTimeVal.compareTo(bTimeVal);
      });
    }
    // Default or "Date" keeps list in its default order or insertion order
    return sortedList;
  }

  void _showSortMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sort Saved Routes',
                      style: AppFonts.sectionHeading,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSortOption('Date', 'Sort by Saved Date'),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSortOption('Name', 'Sort by Station Name (A-Z)'),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                _buildSortOption('Time', 'Sort by Departure Time (Earliest First)'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String val, String description) {
    final isSelected = _sortBy == val;
    return InkWell(
      onTap: () {
        setState(() {
          _sortBy = val;
        });
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  val,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? _saffron : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: _saffron,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(SavedRouteModel route) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: route.iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.train_rounded, color: route.iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${route.fromName} → ${route.toName}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            "${route.date} · ${route.classes}",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.gps_fixed_rounded, color: Color(0xFF475569)),
                  title: const Text('Track Live Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Starting Live Tracking...')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share_rounded, color: Color(0xFF475569)),
                  title: const Text('Share Route', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route details copied to clipboard!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  title: const Text('Delete Route', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      if (_activeTab == 0) {
                        _savedRoutes.removeWhere((r) => r.id == route.id);
                      } else {
                        _recentlyViewed.removeWhere((r) => r.id == route.id);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Route deleted.')),
                    );
                  },
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
    final displayList = _getFilteredAndSortedList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                      // Back Button & Header Text
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
                                'Saved Routes',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Quick access to your favourite journeys',
                                style: AppFonts.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Edit Button
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                          });
                        },
                        icon: Icon(
                          _isEditing ? Icons.check_rounded : Icons.edit_rounded,
                          size: 14,
                          color: const Color(0xFF0F172A),
                        ),
                        label: Text(
                          _isEditing ? 'Done' : 'Edit',
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Main content area (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Promo Banner
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.asset(
                                'assets/images/saved_routes_banner.png',
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 3. Custom Tab Bar Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Tab 1: Saved Routes
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _activeTab = 0),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.bookmark_rounded,
                                                  color: _activeTab == 0 ? _saffron : _inactive,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'My Saved Routes (${_savedRoutes.length})',
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: _activeTab == 0 ? _saffron : _inactive,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 3,
                                            color: _activeTab == 0 ? _saffron : Colors.transparent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Tab 2: Recently Viewed
                                  Expanded(
                                    child: InkWell(
                                      onTap: () => setState(() => _activeTab = 1),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.access_time_filled_rounded,
                                                  color: _activeTab == 1 ? _saffron : _inactive,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Recently Viewed',
                                                  style: TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: _activeTab == 1 ? _saffron : _inactive,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            height: 3,
                                            color: _activeTab == 1 ? _saffron : Colors.transparent,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 1,
                                color: const Color(0xFFE2E8F0),
                              ),
                            ],
                          ),
                        ),

                        // 4. Search and Sort Filter Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                          child: Row(
                            children: [
                              // Search input field
                              Expanded(
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          style: AppFonts.bodyMedium,
                                          decoration: const InputDecoration(
                                            hintText: 'Search saved routes',
                                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                      if (_searchQuery.isNotEmpty)
                                        IconButton(
                                          icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B), size: 18),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Sort button
                              InkWell(
                                onTap: _showSortMenu,
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.tune_rounded, color: Color(0xFF475569), size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Sort By',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF475569), size: 16),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 5. Saved Route Cards List
                        if (displayList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded, size: 64, color: Colors.grey.shade300),
                                const SizedBox(height: 12),
                                const Text(
                                  'No routes found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayList.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final route = displayList[index];
                                return _buildRouteCard(route);
                              },
                            ),
                          ),

                        const SizedBox(height: 20),

                        // 6. Security Footer Banner
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
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2F6EC),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.gpp_good_rounded,
                                      color: _green,
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
                                        'All your data is safe',
                                        style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: _green,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Your saved routes are private and secure.',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Mini train illustration mockup
                                Image.asset(
                                  'assets/images/logo.jpg',
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ).clipToCircle(radius: 22),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 7. Quick Actions Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Quick Actions',
                              style: AppFonts.sectionHeading,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Quick Actions Grid (4 options)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuickActionItem(
                                label: 'Search Trains',
                                subLabel: 'Plan a new journey',
                                icon: Icons.directions_railway_filled_rounded,
                                bgColor: const Color(0xFFE2F6EC),
                                iconColor: const Color(0xFF046A38),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SearchTrainsPage(
                                        initialFrom: "Nagpur (NGP)",
                                        initialTo: "Mumbai CSMT (CSMT)",
                                      ),
                                    ),
                                  );
                                },
                              ),
                              _buildQuickActionItem(
                                label: 'Popular Routes',
                                subLabel: 'Explore top routes',
                                icon: Icons.stars_rounded,
                                bgColor: const Color(0xFFFFF7ED),
                                iconColor: const Color(0xFFFF671F),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Popular routes feature coming soon!')),
                                  );
                                },
                              ),
                              _buildQuickActionItem(
                                label: 'Recent Searches',
                                subLabel: 'View your history',
                                icon: Icons.access_time_filled_rounded,
                                bgColor: const Color(0xFFE0F2FE),
                                iconColor: const Color(0xFF0284C7),
                                onTap: () {
                                  setState(() {
                                    _activeTab = 1; // Swap to recently viewed
                                  });
                                },
                              ),
                              _buildQuickActionItem(
                                label: 'Nearby Stations',
                                subLabel: 'Find stations near you',
                                icon: Icons.location_on_rounded,
                                bgColor: const Color(0xFFFAF5FF),
                                iconColor: const Color(0xFF9333EA),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NearbyStationsPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Extra space at bottom to skip navigation bar overlay
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
            child: FloatingActionButton(
              onPressed: () => Navigator.pop(context),
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

  Widget _buildRouteCard(SavedRouteModel route) {
    return Container(
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
      padding: const EdgeInsets.all(14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon Left
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: route.iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.train_rounded,
                color: route.iconColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Central text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          children: [
                            TextSpan(text: '${route.fromName} '),
                            TextSpan(
                              text: '(${route.fromCode})',
                              style: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF64748B), fontSize: 13),
                            ),
                            const TextSpan(text: '  →  '),
                            TextSpan(text: '${route.toName} '),
                            TextSpan(
                              text: '(${route.toCode})',
                              style: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF64748B), fontSize: 13),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${route.date}   ·   ${route.classes}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: route.badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    route.badgeText,
                    style: TextStyle(
                      color: route.badgeTextColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Right texts & Menu button
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                route.time,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                route.relativeTime,
                style: TextStyle(
                  fontSize: 11.5,
                  color: route.relativeTimeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),

          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  if (_activeTab == 0) {
                    _savedRoutes.removeWhere((r) => r.id == route.id);
                  } else {
                    _recentlyViewed.removeWhere((r) => r.id == route.id);
                  }
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF94A3B8)),
              onPressed: () => _showActionMenu(route),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required String label,
    required String subLabel,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subLabel,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFF64748B),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SavedRouteModel {
  final String id;
  final String fromName;
  final String fromCode;
  final String toName;
  final String toCode;
  final String date;
  final String classes;
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color iconColor;
  final Color iconBgColor;
  final String time;
  final String relativeTime;
  final Color relativeTimeColor;
  final int departureHour;
  final int departureMinute;

  SavedRouteModel({
    required this.id,
    required this.fromName,
    required this.fromCode,
    required this.toName,
    required this.toCode,
    required this.date,
    required this.classes,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.iconColor,
    required this.iconBgColor,
    required this.time,
    required this.relativeTime,
    required this.relativeTimeColor,
    required this.departureHour,
    required this.departureMinute,
  });
}

extension CircleClipExtension on Widget {
  Widget clipToCircle({required double radius}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: this,
    );
  }
}
