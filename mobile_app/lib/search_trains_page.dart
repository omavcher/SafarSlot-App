import 'package:flutter/material.dart';
import 'train_results_page.dart';
import 'nearby_stations_page.dart';

class SearchTrainsPage extends StatefulWidget {
  final String initialFrom;
  final String initialTo;

  const SearchTrainsPage({
    super.key,
    this.initialFrom = "Nagpur (NGP)",
    this.initialTo = "Mumbai CSMT (CSMT)",
  });

  @override
  State<SearchTrainsPage> createState() => _SearchTrainsPageState();
}

class _SearchTrainsPageState extends State<SearchTrainsPage> with SingleTickerProviderStateMixin {
  late String _fromStationCode;
  late String _fromStationName;
  late String _toStationCode;
  late String _toStationName;

  DateTime _selectedDate = DateTime(2025, 5, 20);
  String _selectedClass = "All Classes";
  String _selectedClassDetail = "All class types";

  late AnimationController _swapRotationController;

  final List<Map<String, String>> _stations = [
    {"code": "NGP", "name": "Nagpur Junction, Maharashtra"},
    {"code": "CSMT", "name": "Chhatrapati Shivaji Maharaj Terminus, Maharashtra"},
    {"code": "PUNE", "name": "Pune Junction, Maharashtra"},
    {"code": "NDLS", "name": "New Delhi Railway Station, Delhi"},
    {"code": "HYB", "name": "Hyderabad Deccan, Telangana"},
    {"code": "LKO", "name": "Lucknow NR, Uttar Pradesh"},
    {"code": "BPL", "name": "Bhopal Junction, Madhya Pradesh"},
    {"code": "INDB", "name": "Indore Junction, Madhya Pradesh"},
    {"code": "SBC", "name": "KSR Bengaluru City, Karnataka"},
    {"code": "MAS", "name": "Chennai Central, Tamil Nadu"},
  ];

  final List<Map<String, String>> _classes = [
    {"title": "All Classes", "subtitle": "All class types"},
    {"title": "Sleeper Class (SL)", "subtitle": "Non-AC budget class"},
    {"title": "AC 3 Tier (3A)", "subtitle": "Third AC sleeper class"},
    {"title": "AC 2 Tier (2A)", "subtitle": "Second AC luxury sleeper"},
    {"title": "AC 1 Class (1A)", "subtitle": "First AC premium sleeper"},
    {"title": "Second Seating (2S)", "subtitle": "Reserved non-AC sitting"},
    {"title": "AC Chair Car (CC)", "subtitle": "AC sitting class"},
  ];

  @override
  void initState() {
    super.initState();
    _parseInitialStations();
    _swapRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _parseInitialStations() {
    _fromStationCode = _extractCode(widget.initialFrom);
    _fromStationName = _extractName(widget.initialFrom);
    _toStationCode = _extractCode(widget.initialTo);
    _toStationName = _extractName(widget.initialTo);
  }

  String _extractCode(String fullText) {
    final regExp = RegExp(r'\((.*?)\)');
    final match = regExp.firstMatch(fullText);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return fullText.split(' ').first;
  }

  String _extractName(String fullText) {
    if (fullText.contains("Nagpur")) return "Nagpur Junction, Maharashtra";
    if (fullText.contains("Mumbai")) return "Chhatrapati Shivaji Maharaj Terminus, Maharashtra";
    if (fullText.contains("Pune")) return "Pune Junction, Maharashtra";
    if (fullText.contains("New Delhi")) return "New Delhi Railway Station, Delhi";
    if (fullText.contains("Hyderabad")) return "Hyderabad Deccan, Telangana";
    return "Railway Station, India";
  }

  @override
  void dispose() {
    _swapRotationController.dispose();
    super.dispose();
  }

  void _swapStations() {
    _swapRotationController.forward(from: 0.0);
    setState(() {
      final tempCode = _fromStationCode;
      final tempName = _fromStationName;
      _fromStationCode = _toStationCode;
      _fromStationName = _toStationName;
      _toStationCode = tempCode;
      _toStationName = tempName;
    });
  }

  void _selectStation(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isFrom ? 'Select Source Station' : 'Select Destination Station',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search station name or code...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF671F)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'POPULAR STATIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _stations.length,
                  itemBuilder: (context, index) {
                    final station = _stations[index];
                    final isAlreadySelected = isFrom
                        ? station['code'] == _toStationCode
                        : station['code'] == _fromStationCode;
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.directions_railway_filled_rounded,
                            color: Color(0xFF64748B), size: 20),
                      ),
                      title: Text(
                        '${station['code']} - ${_stations[index]['name']!.split(',').first}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isAlreadySelected ? Colors.grey : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        station['name']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                      onTap: isAlreadySelected
                          ? null
                          : () {
                              setState(() {
                                if (isFrom) {
                                  _fromStationCode = station['code']!;
                                  _fromStationName = station['name']!;
                                } else {
                                  _toStationCode = station['code']!;
                                  _toStationName = station['name']!;
                                }
                              });
                              Navigator.pop(context);
                            },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF671F),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectClass() {
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
                    'Select Travel Class',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                children: _classes.map((c) {
                  final isSelected = _selectedClass == c['title'] ||
                      (_selectedClass == "All Classes" && c['title'] == "All Classes");
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                      color: isSelected ? const Color(0xFFFF671F) : const Color(0xFF94A3B8),
                    ),
                    title: Text(
                      c['title']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    subtitle: Text(c['subtitle']!),
                    onTap: () {
                      setState(() {
                        _selectedClass = c['title']!;
                        _selectedClassDetail = c['subtitle']!;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _searchTrains() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainResultsPage(
          fromCode: _fromStationCode,
          fromName: _fromStationName,
          toCode: _toStationCode,
          toName: _toStationName,
          date: _selectedDate,
          travelClass: _selectedClass,
        ),
      ),
    );
  }

  void _loadPopularRoute(String fromCode, String fromName, String toCode, String toName) {
    setState(() {
      _fromStationCode = fromCode;
      _fromStationName = fromName;
      _toStationCode = toCode;
      _toStationName = toName;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded Route: $fromCode to $toCode'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showRecentSearches() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RecentSearchesSheet(
          onSelect: (fromCode, fromName, toCode, toName, date, travelClass) {
            setState(() {
              _fromStationCode = fromCode;
              _fromStationName = fromName;
              _toStationCode = toCode;
              _toStationName = toName;
              _selectedDate = date;
              _selectedClass = travelClass;
              
              _selectedClassDetail = _classes.firstWhere(
                (c) => c['title'] == travelClass || c['title']!.startsWith(travelClass),
                orElse: () => {"subtitle": "All class types"}
              )['subtitle']!;
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showSearchByDialog(String title, String placeholder) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Find by $title'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter the $title to look up details quickly.',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: placeholder,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFF671F), width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF671F),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final query = textController.text.trim();
                Navigator.pop(context);
                if (query.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Searching for $title: "$query"...')),
                  );
                  // Open train results filtered
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrainResultsPage(
                        fromCode: "NGP",
                        fromName: "Nagpur Junction",
                        toCode: "CSMT",
                        toName: "Mumbai CSMT",
                        date: _selectedDate,
                        travelClass: _selectedClass,
                        searchFilter: query,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }


  void _showRouteMap() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Route Map'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Interactive route map between stations.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              const SizedBox(height: 16),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildRouteNode(_fromStationCode, true),
                          Container(
                            width: 80,
                            height: 4,
                            color: const Color(0xFFFF671F),
                          ),
                          _buildRouteNode(_toStationCode, false),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Total Distance: ~830 km\nEstimated Duration: 8h 15m',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Color(0xFFFF671F))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRouteNode(String code, bool isStart) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isStart ? const Color(0xFF046A38) : const Color(0xFFFF671F),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.train, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
        ),
      ],
    );
  }

  String _formatShortDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    return weekdays[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatShortDate(_selectedDate);
    final weekdayName = _getWeekdayName(_selectedDate);

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
                          'Search Trains',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Find trains between stations',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _showRecentSearches,
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
                          Icon(Icons.history_rounded, size: 15, color: Color(0xFF0F172A)),
                          SizedBox(width: 4),
                          Text(
                            'Recent Searches',
                            style: TextStyle(
                              fontSize: 11,
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
                    // 2. Banner Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: AspectRatio(
                        aspectRatio: 3.8,
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
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/images/homepage_banner1.png',
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withAlpha(120),
                                        Colors.transparent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Live Tracking • Real Updates',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(220),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Text(
                                            'Travel Smart,\nArrive ',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                          ),
                                          const Text(
                                            'Happy',
                                            style: TextStyle(
                                              color: Color(0xFFFF671F),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Text(
                                            '🇮🇳',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 3. Search inputs card matching the mockup
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                Column(
                                  children: [
                                    // From station selector
                                    GestureDetector(
                                      onTap: () => _selectStation(true),
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            // Left green indicator
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF046A38),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'From',
                                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Nagpur ($_fromStationCode)',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _fromStationName,
                                                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 48), // space for swap button
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Dotted divider lines between From and To
                                    Row(
                                      children: [
                                        const SizedBox(width: 4),
                                        Column(
                                          children: List.generate(4, (index) {
                                            return Container(
                                              width: 2,
                                              height: 4,
                                              margin: const EdgeInsets.symmetric(vertical: 2),
                                              color: const Color(0xFFCBD5E1),
                                            );
                                          }),
                                        ),
                                        const Expanded(child: SizedBox()),
                                      ],
                                    ),
                                    // To station selector
                                    GestureDetector(
                                      onTap: () => _selectStation(false),
                                      behavior: HitTestBehavior.opaque,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                                        child: Row(
                                          children: [
                                            // Left orange indicator
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFF671F),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'To',
                                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Mumbai CSMT ($_toStationCode)',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _toStationName,
                                                    style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 48), // space for swap button
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                // Swap button in between From and To
                                Positioned(
                                  right: 0,
                                  child: RotationTransition(
                                    turns: Tween(begin: 0.0, end: 0.5).animate(_swapRotationController),
                                    child: GestureDetector(
                                      onTap: _swapStations,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withAlpha(5),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.swap_vert_rounded,
                                          color: Color(0xFF0F172A),
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Divider(color: Color(0xFFF1F5F9), height: 1),
                            ),

                            // Date & Class Section
                            Row(
                              children: [
                                // Journey Date
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _selectDate,
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.calendar_today_rounded,
                                          color: Color(0xFF0F172A),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Journey Date',
                                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                weekdayName,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF046A38), // Green weekday
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Vertical Divider line
                                Container(
                                  width: 1,
                                  height: 48,
                                  color: const Color(0xFFE2E8F0),
                                  margin: const EdgeInsets.symmetric(horizontal: 8),
                                ),

                                // Class selection
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _selectClass,
                                    behavior: HitTestBehavior.opaque,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.tune_rounded,
                                          color: Color(0xFF0F172A),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Class',
                                                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _selectedClass.split(' ').first,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF0F172A),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    color: Color(0xFF94A3B8),
                                                    size: 18,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _selectedClassDetail,
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
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
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Saffron Search Trains button
                            ElevatedButton.icon(
                              onPressed: _searchTrains,
                              icon: const Icon(Icons.search_rounded, size: 20),
                              label: const Text(
                                'Search Trains',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF671F),
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                                shadowColor: const Color(0xFFFF671F).withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. Popular Routes Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Popular Routes',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              GestureDetector(
                                onTap: _showRecentSearches,
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
                          const SizedBox(height: 12),
                          _buildPopularRouteCard(
                            from: "Mumbai CSMT",
                            fromCode: "CSMT",
                            to: "Pune Junction",
                            toCode: "PUNE",
                            icon: Icons.domain_rounded,
                            bgColor: const Color(0xFFE0F2FE),
                            iconColor: const Color(0xFF0284C7),
                          ),
                          _buildPopularRouteCard(
                            from: "Nagpur",
                            fromCode: "NGP",
                            to: "Hyderabad Deccan",
                            toCode: "HYB",
                            icon: Icons.castle_rounded,
                            bgColor: const Color(0xFFFFF7ED),
                            iconColor: const Color(0xFFFF671F),
                          ),
                          _buildPopularRouteCard(
                            from: "New Delhi",
                            fromCode: "NDLS",
                            to: "Lucknow NR",
                            toCode: "LKO",
                            icon: Icons.account_balance_rounded,
                            bgColor: const Color(0xFFE2F6EC),
                            iconColor: const Color(0xFF046A38),
                          ),
                          _buildPopularRouteCard(
                            from: "Bhopal",
                            fromCode: "BPL",
                            to: "Indore Junction",
                            toCode: "INDB",
                            icon: Icons.temple_hindu_rounded,
                            bgColor: const Color(0xFFFAF5FF),
                            iconColor: const Color(0xFF9333EA),
                          ),
                        ],
                      ),
                    ),

                    // 5. Search By Grid Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Search by',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridItem(
                                  title: 'Train Number',
                                  subtitle: 'Find by train no.',
                                  icon: Icons.train_rounded,
                                  color: const Color(0xFF046A38),
                                  onTap: () => _showSearchByDialog('Train Number', 'e.g. 22105'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildGridItem(
                                  title: 'Station Code',
                                  subtitle: 'Find by station code',
                                  icon: Icons.pin_drop_rounded,
                                  color: const Color(0xFF0284C7),
                                  onTap: () => _showSearchByDialog('Station Code', 'e.g. NGP'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10, height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridItem(
                                  title: 'Nearby Stations',
                                  subtitle: 'Find stations near you',
                                  icon: Icons.my_location_rounded,
                                  color: const Color(0xFF9333EA),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const NearbyStationsPage()),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildGridItem(
                                  title: 'Route Map',
                                  subtitle: 'Explore train route',
                                  icon: Icons.map_rounded,
                                  color: const Color(0xFFFF671F),
                                  onTap: _showRouteMap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 6. BOTTOM NAVIGATION BAR - EXACT MATCH TO THE SCREENSHOT
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
                    onTap: () {
                      Navigator.pop(context); // Go back to Home
                    },
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    isActive: false,
                    activeIcon: Icons.search_rounded,
                    inactiveIcon: Icons.search_rounded,
                    label: 'Explore',
                    onTap: () {
                      Navigator.pop(context);
                      // Set state in main.dart if possible
                    },
                  ),
                ),
                // Gap for Live green button
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
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    isActive: false,
                    activeIcon: Icons.person_rounded,
                    inactiveIcon: Icons.person_outline_rounded,
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
    );
  }

  Widget _buildPopularRouteCard({
    required String from,
    required String fromCode,
    required String to,
    required String toCode,
    required IconData icon,
    required Color bgColor,
    required Color iconColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            '$from ➔ $to',
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          subtitle: const Text(
            'Popular Route',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF046A38), // Green "Popular Route"
            ),
          ),
          trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
          onTap: () => _loadPopularRoute(
            fromCode,
            '$from Junction, India',
            toCode,
            '$to Terminus, India',
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
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

class _RecentSearchesSheet extends StatefulWidget {
  final Function(
    String fromCode,
    String fromName,
    String toCode,
    String toName,
    DateTime date,
    String travelClass,
  ) onSelect;

  const _RecentSearchesSheet({required this.onSelect});

  @override
  State<_RecentSearchesSheet> createState() => _RecentSearchesSheetState();
}

class _RecentSearchesSheetState extends State<_RecentSearchesSheet> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Drag indicator handle
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            
            // TabBar row
            TabBar(
              labelColor: const Color(0xFFFF671F),
              unselectedLabelColor: const Color(0xFF7A7A7A),
              indicatorColor: const Color(0xFFFF671F),
              indicatorWeight: 3.0,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: const Color(0xFFE2E8F0),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(
                  icon: Icon(Icons.directions_railway_filled_rounded),
                  text: 'Train Searches',
                ),
                Tab(
                  icon: Icon(Icons.domain_rounded),
                  text: 'Station Searches',
                ),
              ],
            ),
            
            // TabBarView content
            Expanded(
              child: TabBarView(
                children: [
                  _buildTrainSearchesTab(),
                  _buildStationSearchesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainSearchesTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        // TODAY
        _buildSectionHeader('Today', const Color(0xFFE2F6EC), const Color(0xFF046A38)),
        const SizedBox(height: 8),
        _buildTrainSearchCard(
          from: 'Nagpur',
          fromCode: 'NGP',
          to: 'Mumbai CSMT',
          toCode: 'CSMT',
          date: DateTime(2025, 5, 20),
          travelClass: 'All Classes',
          time: '10:30 AM',
          iconColor: const Color(0xFF046A38), // Green
        ),
        _buildTrainSearchCard(
          from: 'Pune Junction',
          fromCode: 'PUNE',
          to: 'Nagpur',
          toCode: 'NGP',
          date: DateTime(2025, 5, 19),
          travelClass: 'Sleeper Class (SL)',
          time: '09:15 AM',
          iconColor: const Color(0xFFFF671F), // Orange
        ),
        _buildTrainSearchCard(
          from: 'Mumbai CSMT',
          fromCode: 'CSMT',
          to: 'Hyderabad',
          toCode: 'HYB',
          date: DateTime(2025, 5, 18),
          travelClass: 'AC 3 Tier (3A)',
          time: '08:45 AM',
          iconColor: const Color(0xFF046A38), // Green
        ),
        
        const SizedBox(height: 16),
        // YESTERDAY
        _buildSectionHeader('Yesterday', const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
        const SizedBox(height: 8),
        _buildTrainSearchCard(
          from: 'Nagpur',
          fromCode: 'NGP',
          to: 'Hyderabad Deccan',
          toCode: 'HYB',
          date: DateTime(2025, 5, 19),
          travelClass: 'All Classes',
          time: '07:20 PM',
          iconColor: const Color(0xFF0284C7), // Blue
        ),

        const SizedBox(height: 16),
        // EARLIER
        _buildSectionHeader('Earlier', const Color(0xFFF1F5F9), const Color(0xFF64748B)),
        const SizedBox(height: 8),
        _buildTrainSearchCard(
          from: 'New Delhi',
          fromCode: 'NDLS',
          to: 'Lucknow',
          toCode: 'LKO',
          date: DateTime(2025, 5, 17),
          travelClass: 'AC Chair Car (CC)',
          time: '06:10 PM',
          iconColor: const Color(0xFF9333EA), // Purple
        ),
        _buildTrainSearchCard(
          from: 'Bhopal',
          fromCode: 'BPL',
          to: 'Indore Junction',
          toCode: 'INDB',
          date: DateTime(2025, 5, 15),
          travelClass: 'Second Seating (2S)',
          time: '05:30 PM',
          iconColor: const Color(0xFFFF671F), // Orange
        ),
      ],
    );
  }

  Widget _buildStationSearchesTab() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionHeader('Today', const Color(0xFFE2F6EC), const Color(0xFF046A38)),
        const SizedBox(height: 8),
        _buildStationSearchCard('Nagpur Junction', 'NGP', '10:45 AM', const Color(0xFF046A38)),
        _buildStationSearchCard('Mumbai CSMT', 'CSMT', '09:30 AM', const Color(0xFF0284C7)),
        const SizedBox(height: 16),
        _buildSectionHeader('Yesterday', const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
        const SizedBox(height: 8),
        _buildStationSearchCard('Pune Junction', 'PUNE', '06:15 PM', const Color(0xFFFF671F)),
        _buildStationSearchCard('New Delhi', 'NDLS', '04:20 PM', const Color(0xFF9333EA)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color bgColor, Color textColor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTrainSearchCard({
    required String from,
    required String fromCode,
    required String to,
    required String toCode,
    required DateTime date,
    required String travelClass,
    required String time,
    required Color iconColor,
  }) {
    final dateStr = "${date.day} ${_getMonthName(date.month)}, ${date.year}";
    final displayClass = travelClass.contains('(') ? travelClass.split('(').first.trim() : travelClass;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            widget.onSelect(
              fromCode,
              "$from Junction, India",
              toCode,
              "$to Terminus, India",
              date,
              travelClass,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // Train leading circular icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_railway_filled_rounded,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Route texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$from ($fromCode) → $to ($toCode)',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 11, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(width: 6),
                          const Text('•', style: TextStyle(fontSize: 11, color: Color(0xFFCBD5E1))),
                          const SizedBox(width: 6),
                          const Icon(Icons.tune_rounded, size: 11, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            displayClass,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Time & chevron right
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStationSearchCard(String name, String code, String time, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            // Load station selection
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.pin_drop_rounded,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name ($code)',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Recent Station Search',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}

