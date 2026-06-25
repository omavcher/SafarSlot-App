import 'package:flutter/material.dart';

class TrainResultsPage extends StatefulWidget {
  final String fromCode;
  final String fromName;
  final String toCode;
  final String toName;
  final DateTime date;
  final String travelClass;
  final String? searchFilter;

  const TrainResultsPage({
    super.key,
    required this.fromCode,
    required this.fromName,
    required this.toCode,
    required this.toName,
    required this.date,
    required this.travelClass,
    this.searchFilter,
  });

  @override
  State<TrainResultsPage> createState() => _TrainResultsPageState();
}

class _TrainResultsPageState extends State<TrainResultsPage> {
  String _activeSort = "Fastest"; // Sorters: "Fastest", "Cheapest", "Earliest", "Available First"
  bool _acOnly = false;

  // Mock Train Data
  late List<Map<String, dynamic>> _trains;

  @override
  void initState() {
    super.initState();
    _initMockTrains();
    if (widget.searchFilter != null) {
      // Filter trains by search filter (number or name)
      final query = widget.searchFilter!.toLowerCase();
      _trains = _trains.where((t) {
        return t['number'].toString().contains(query) ||
            t['name'].toString().toLowerCase().contains(query);
      }).toList();
    }
  }

  void _initMockTrains() {
    _trains = [
      {
        "number": "22105",
        "name": "Mumbai LTT SF Express",
        "type": "Superfast",
        "from": widget.fromCode,
        "to": widget.toCode,
        "depTime": "10:30",
        "arrTime": "18:45",
        "duration": "8h 15m",
        "runsOn": [true, false, true, false, true, false, true], // M W F Su
        "classes": [
          {"code": "SL", "status": "AVBL 42", "price": 445, "avail": true},
          {"code": "3A", "status": "AVBL 12", "price": 1200, "avail": true},
          {"code": "2A", "status": "RAC 3", "price": 1750, "avail": true},
          {"code": "1A", "status": "WL 2", "price": 2980, "avail": false},
        ],
        "selectedClassIndex": 0,
      },
      {
        "number": "12137",
        "name": "Punjab Mail",
        "type": "Express",
        "from": widget.fromCode,
        "to": widget.toCode,
        "depTime": "11:15",
        "arrTime": "20:30",
        "duration": "9h 15m",
        "runsOn": [true, true, true, true, true, true, true], // Daily
        "classes": [
          {"code": "SL", "status": "AVBL 8", "price": 420, "avail": true},
          {"code": "3A", "status": "WL 4", "price": 1150, "avail": false},
          {"code": "2A", "status": "AVBL 2", "price": 1690, "avail": true},
          {"code": "1A", "status": "AVBL 1", "price": 2880, "avail": true},
        ],
        "selectedClassIndex": 0,
      },
      {
        "number": "12809",
        "name": "Mumbai Mail Express",
        "type": "Express",
        "from": widget.fromCode,
        "to": widget.toCode,
        "depTime": "15:00",
        "arrTime": "23:55",
        "duration": "8h 55m",
        "runsOn": [true, true, false, true, true, false, true], // M T Th F Su
        "classes": [
          {"code": "SL", "status": "AVBL 19", "price": 435, "avail": true},
          {"code": "3A", "status": "RAC 1", "price": 1180, "avail": true},
          {"code": "2A", "status": "WL 8", "price": 1720, "avail": false},
          {"code": "1A", "status": "AVBL 3", "price": 2920, "avail": true},
        ],
        "selectedClassIndex": 0,
      },
      {
        "number": "01028",
        "name": "Vidarbha Vande Bharat",
        "type": "Vande Bharat",
        "from": widget.fromCode,
        "to": widget.toCode,
        "depTime": "06:00",
        "arrTime": "13:30",
        "duration": "7h 30m",
        "runsOn": [true, true, true, true, true, true, false], // Mon-Sat
        "classes": [
          {"code": "CC", "status": "AVBL 64", "price": 1420, "avail": true},
          {"code": "EC", "status": "AVBL 18", "price": 2680, "avail": true},
        ],
        "selectedClassIndex": 0,
      },
      {
        "number": "12290",
        "name": "Duronto Express",
        "type": "Duronto",
        "from": widget.fromCode,
        "to": widget.toCode,
        "depTime": "20:40",
        "arrTime": "05:10",
        "duration": "8h 30m",
        "runsOn": [false, true, false, true, false, true, false], // T Th S
        "classes": [
          {"code": "3A", "status": "AVBL 24", "price": 1380, "avail": true},
          {"code": "2A", "status": "AVBL 9", "price": 1950, "avail": true},
          {"code": "1A", "status": "RAC 2", "price": 3120, "avail": true},
        ],
        "selectedClassIndex": 0,
      }
    ];
  }

  // Filter and Sort trains
  List<Map<String, dynamic>> _getProcessedTrains() {
    List<Map<String, dynamic>> list = List.from(_trains);

    // Apply AC Only filter
    if (_acOnly) {
      list = list.where((train) {
        final classes = train['classes'] as List;
        return classes.any((c) => c['code'] != 'SL' && c['code'] != '2S');
      }).toList();
    }

    // Apply Sorting
    if (_activeSort == "Fastest") {
      list.sort((a, b) {
        final durA = _parseDuration(a['duration']);
        final durB = _parseDuration(b['duration']);
        return durA.compareTo(durB);
      });
    } else if (_activeSort == "Cheapest") {
      list.sort((a, b) {
        final priceA = (a['classes'] as List).first['price'] as int;
        final priceB = (b['classes'] as List).first['price'] as int;
        return priceA.compareTo(priceB);
      });
    } else if (_activeSort == "Earliest") {
      list.sort((a, b) => (a['depTime'] as String).compareTo(b['depTime'] as String));
    } else if (_activeSort == "Available First") {
      list.sort((a, b) {
        final availA = (a['classes'] as List).any((c) => c['avail'] == true) ? 0 : 1;
        final availB = (b['classes'] as List).any((c) => c['avail'] == true) ? 0 : 1;
        return availA.compareTo(availB);
      });
    }

    return list;
  }

  int _parseDuration(String durationStr) {
    // e.g. "8h 15m" -> 8 * 60 + 15 = 495
    try {
      final parts = durationStr.split(' ');
      int hours = 0;
      int mins = 0;
      for (var part in parts) {
        if (part.contains('h')) {
          hours = int.parse(part.replaceAll('h', ''));
        } else if (part.contains('m')) {
          mins = int.parse(part.replaceAll('m', ''));
        }
      }
      return hours * 60 + mins;
    } catch (_) {
      return 9999;
    }
  }

  void _bookSlot(Map<String, dynamic> train, Map<String, dynamic> selectedClass) {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    String selectedGender = "Male";
    String selectedBerth = "No Preference";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Confirm Slot Booking',
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
                    // Train short details card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${train['number']} · ${train['name']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF671F).withAlpha(30),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  selectedClass['code'],
                                  style: const TextStyle(
                                    color: Color(0xFFFF671F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Route: ${train['from']} ➔ ${train['to']} | Date: ${_formatLongDate(widget.date)}',
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Fare: ₹${selectedClass['price']}',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF046A38)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Passenger Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Passenger Name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: const Icon(Icons.person_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: ageController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              prefixIcon: const Icon(Icons.cake_rounded),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedGender,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: const [
                              DropdownMenuItem(value: "Male", child: Text("Male")),
                              DropdownMenuItem(value: "Female", child: Text("Female")),
                              DropdownMenuItem(value: "Other", child: Text("Other")),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedGender = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBerth,
                      decoration: InputDecoration(
                        labelText: 'Berth Preference',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      items: const [
                        DropdownMenuItem(value: "No Preference", child: Text("No Preference")),
                        DropdownMenuItem(value: "Lower Berth", child: Text("Lower Berth")),
                        DropdownMenuItem(value: "Middle Berth", child: Text("Middle Berth")),
                        DropdownMenuItem(value: "Upper Berth", child: Text("Upper Berth")),
                        DropdownMenuItem(value: "Side Lower", child: Text("Side Lower")),
                        DropdownMenuItem(value: "Side Upper", child: Text("Side Upper")),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedBerth = val);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF671F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final age = ageController.text.trim();
                        if (name.isEmpty || age.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please fill passenger name and age')),
                          );
                          return;
                        }
                        Navigator.pop(context); // Close bottom sheet
                        _showSuccessDialog(train, selectedClass, name);
                      },
                      child: const Text('Confirm & Book Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSuccessDialog(Map<String, dynamic> train, Map<String, dynamic> selectedClass, String passengerName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE2F6EC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF046A38),
                    size: 54,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Slot Booked Successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Your slot for $passengerName in Train ${train['number']} (${selectedClass['code']}) has been successfully blocked.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('PNR STATUS', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('4820194819', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('SEAT NO', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text('${selectedClass['code']} - 18 (Lower)', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF046A38))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF671F),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Pop TrainResultsPage
                    Navigator.pop(context); // Pop SearchTrainsPage (return to Home)
                  },
                  child: const Text('Back to Home', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatLongDate(DateTime date) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }

  String _formatShortDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]}, ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final processedTrains = _getProcessedTrains();
    final formattedDate = _formatShortDate(widget.date);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header summary
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFF671F), Color(0xFFFF8A48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.fromCode} ➔ ${widget.toCode}',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$formattedDate · ${widget.travelClass}',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withAlpha(220),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.tune_rounded, color: Colors.white),
                        onPressed: () {
                          // Toggle filter AC/Non-AC
                          setState(() {
                            _acOnly = !_acOnly;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_acOnly ? 'Showing AC Trains Only' : 'Showing All Trains'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. Filters Sorter Bar
            Container(
              height: 54,
              color: Colors.white,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                children: [
                  _buildSorterChip("Fastest"),
                  _buildSorterChip("Cheapest"),
                  _buildSorterChip("Earliest"),
                  _buildSorterChip("Available First"),
                  const SizedBox(width: 8),
                  VerticalDivider(color: Colors.grey.shade300, width: 1),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('AC Only', style: TextStyle(fontSize: 12.5)),
                    selected: _acOnly,
                    onSelected: (val) {
                      setState(() {
                        _acOnly = val;
                      });
                    },
                    selectedColor: const Color(0xFFFF671F).withAlpha(40),
                    checkmarkColor: const Color(0xFFFF671F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
            ),

            // 3. Train Results List
            Expanded(
              child: processedTrains.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_railway_filled_rounded, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text(
                            'No trains found!',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try altering your search or filters.',
                            style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: processedTrains.length,
                      itemBuilder: (context, index) {
                        final train = processedTrains[index];
                        return _buildTrainCard(train);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSorterChip(String sortLabel) {
    final isActive = _activeSort == sortLabel;
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeSort = sortLabel;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFF671F) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFFFF671F) : const Color(0xFFE2E8F0),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          sortLabel,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF475569),
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTrainCard(Map<String, dynamic> train) {
    final classes = train['classes'] as List;
    final selectedClassIdx = train['selectedClassIndex'] as int;
    final selectedClass = classes[selectedClassIdx];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      color: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Train Code, Name & Runs On
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        train['number'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF671F),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          train['name'],
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
                _buildRunsOnRow(train['runsOn']),
              ],
            ),
            const SizedBox(height: 14),

            // Time and Duration schedule row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      train['depTime'],
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      train['from'],
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        train['duration'],
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(Icons.circle, size: 6, color: Color(0xFFFF671F)),
                          ),
                          Expanded(child: Container(height: 1.5, color: const Color(0xFFE2E8F0))),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      train['arrTime'],
                      style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      train['to'],
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Class Cards Selectable Grid
            SizedBox(
              height: 74,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: classes.length,
                itemBuilder: (context, cIdx) {
                  final classInfo = classes[cIdx];
                  final isSelected = selectedClassIdx == cIdx;

                  Color statusColor = const Color(0xFFEF4444); // default red (WL)
                  if (classInfo['status'].toString().contains('AVBL')) {
                    statusColor = const Color(0xFF046A38); // green
                  } else if (classInfo['status'].toString().contains('RAC')) {
                    statusColor = const Color(0xFFEAB308); // yellow/orange
                  }

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        train['selectedClassIndex'] = cIdx;
                      });
                    },
                    child: Container(
                      width: 94,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF671F).withAlpha(12) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFFF671F) : const Color(0xFFE2E8F0),
                          width: isSelected ? 1.8 : 1.2,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            classInfo['code'],
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            classInfo['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${classInfo['price']}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Book Slot Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF046A38), // Green button for slot booking
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(44),
                elevation: 0,
              ),
              onPressed: () => _bookSlot(train, selectedClass),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Book Slot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(
                    '(${selectedClass['code']} - ₹${selectedClass['price']})',
                    style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(220)),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRunsOnRow(List<dynamic> runsOn) {
    final days = ["M", "T", "W", "T", "F", "S", "S"];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(7, (i) {
        final active = runsOn[i] as bool;
        return Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF046A38).withAlpha(30) : Colors.transparent,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            days[i],
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: active ? const Color(0xFF046A38) : const Color(0xFF94A3B8),
            ),
          ),
        );
      }),
    );
  }
}
