import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_fonts.dart';
import 'premium_screen.dart';
import 'coach_position_screen.dart';

class PnrStatusScreen extends StatefulWidget {
  const PnrStatusScreen({super.key});

  @override
  State<PnrStatusScreen> createState() => _PnrStatusScreenState();
}

class _PnrStatusScreenState extends State<PnrStatusScreen> {
  final TextEditingController _pnrController = TextEditingController();
  final FocusNode _pnrFocusNode = FocusNode();
  bool _hasSearched = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _pnrController.dispose();
    _pnrFocusNode.dispose();
    super.dispose();
  }

  void _searchPnr() {
    FocusScope.of(context).unfocus(); // Ensure keyboard closes on search
    if (_pnrController.text.length == 10) {
      setState(() {
        _hasSearched = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 10-digit PNR.', style: AppFonts.inter(color: Colors.white)),
          backgroundColor: const Color(0xFF0F172A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      resizeToAvoidBottomInset: false, // Prevent keyboard animation from causing layout rebuilds
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PNR Status', style: AppFonts.appBarTitle),
            Text('Check your PNR current status', style: AppFonts.labelSmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_hasSearched) ...[
              _buildInputCardLarge(),
              const SizedBox(height: 24),
              _buildHowItWorks(),
              const SizedBox(height: 24),
              _buildPopularSearches(),
              const SizedBox(height: 24),
            ] else ...[
              _buildInputCardCompact(),
              const SizedBox(height: 16),
              _buildTicketDetailsCard(),
              const SizedBox(height: 24),
              Text('Passenger Details', style: AppFonts.sectionHeading),
              const SizedBox(height: 12),
              _buildPassengerList(),
              const SizedBox(height: 16),
              
              // View Coach Position Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CoachPositionScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF046A38), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFF4FBF7),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.airline_seat_recline_normal_rounded, color: Color(0xFF046A38), size: 20),
                      const SizedBox(width: 8),
                      Text('View Coach Position', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              _buildRouteTimeline(),
              const SizedBox(height: 24),
            ],
            
            // Common Footer
            _buildTipBox(),
            const SizedBox(height: 16),
            _buildGoPremiumCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCardLarge() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE2F6EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_activity_outlined, color: Color(0xFF046A38), size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Check your PNR Status',
            style: AppFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your 10-digit PNR number to get\nthe latest booking and journey status.',
            textAlign: TextAlign.center,
            style: AppFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.4),
          ),
          const SizedBox(height: 24),
          // TextField
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.local_activity_outlined, color: Color(0xFF046A38)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _pnrController,
                    focusNode: _pnrFocusNode,
                    keyboardType: TextInputType.number,
                    onTapOutside: (event) {}, // Disable auto-unfocus to debug Android 14 keyboard cancellation
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                    style: AppFonts.pnrNumber,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter 10-digit PNR Number',
                      hintStyle: AppFonts.inter(fontSize: 15, color: const Color(0xFF94A3B8)),
                    ),
                    onChanged: (val) => setState((){}),
                  ),
                ),
                if (_pnrController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _pnrController.clear();
                      setState((){});
                    },
                    child: const Icon(Icons.cancel, color: Color(0xFFCBD5E1), size: 20),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Search Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _searchPnr,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF046A38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Search Status', style: AppFonts.buttonText),
                  const SizedBox(width: 8),
                  const Icon(Icons.search, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Features Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFeatureItem(Icons.verified_user_outlined, 'Secure & Safe', 'Your data is protected\nand encrypted'),
              _buildFeatureItem(Icons.flash_on_rounded, 'Instant Results', 'Get real-time PNR\nstatus instantly'),
              _buildFeatureItem(Icons.bookmark_border_rounded, 'Save PNR', 'Save your PNR for\nquick access'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF046A38), size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF046A38)), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: AppFonts.inter(fontSize: 9.5, color: const Color(0xFF64748B)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF4FBF7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2F6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How PNR Status Works', style: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _buildStepNode('1', Icons.local_activity_outlined, 'Enter PNR Number', 'Enter your 10-digit\nPNR number above')),
              Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(top: 14), child: _buildDashedLine())),
              Expanded(flex: 3, child: _buildStepNode('2', Icons.search_rounded, 'Search Status', 'Tap on search to\nfetch latest status')),
              Expanded(flex: 2, child: Padding(padding: const EdgeInsets.only(top: 14), child: _buildDashedLine())),
              Expanded(flex: 3, child: _buildStepNode('3', Icons.fact_check_outlined, 'View Results', 'Get booking status,\nchart status & more')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: List.generate(
          (constraints.maxWidth / 6).floor(),
          (index) => Expanded(
            child: Container(color: index % 2 == 0 ? const Color(0xFFCBD5E1) : Colors.transparent, height: 1.5),
          ),
        ),
      );
    });
  }

  Widget _buildStepNode(String step, IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: Color(0xFFE2F6EC),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(step, style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF046A38)))),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE2F6EC), width: 1.5),
          ),
          child: Icon(icon, color: const Color(0xFF046A38), size: 24),
        ),
        const SizedBox(height: 12),
        Text(title, style: AppFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(subtitle, style: AppFonts.inter(fontSize: 9, color: const Color(0xFF64748B)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPopularSearches() {
    final searches = ['6123456789', '4632157890', '8254796310', '2154987653'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Popular Searches', style: AppFonts.sectionHeading),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: searches.map((pnr) => GestureDetector(
            onTap: () {
              _pnrController.text = pnr;
              _searchPnr();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.history, size: 14, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(pnr, style: AppFonts.inter(fontSize: 13, color: const Color(0xFF475569))),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildInputCardCompact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter PNR Number', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.local_activity_outlined, color: Color(0xFF046A38), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_pnrController.text, style: AppFonts.pnrNumber.copyWith(fontSize: 16)),
              ),
              GestureDetector(
                onTap: () {
                  setState(() { _hasSearched = false; });
                },
                child: const Icon(Icons.cancel, color: Color(0xFFCBD5E1), size: 20),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _searchPnr,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF046A38),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text('Check Status', style: AppFonts.buttonText.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.verified_user_outlined, size: 14, color: Color(0xFF94A3B8)),
            const SizedBox(width: 6),
            Text('Your data is safe and secure with us', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF046A38), size: 14),
                    const SizedBox(width: 4),
                    Text('Confirmed', style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                  ],
                ),
              ),
              Row(
                children: [
                  Text('Last updated: Just now', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                  const SizedBox(width: 4),
                  const Icon(Icons.refresh, size: 14, color: Color(0xFF94A3B8)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('12615 Grand Trunk Express', style: AppFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Text('Itwari (ITW)   →   Nagpur (NGP)', style: AppFonts.inter(fontSize: 13, color: const Color(0xFF475569))),
                    const SizedBox(height: 6),
                    Text('21 May 2025   •   Sleeper (SL)   •   PNR: ${_pnrController.text}', style: AppFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F6EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.train_rounded, color: Color(0xFF046A38), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTicketStat('Total Passengers', '4', const Color(0xFF0F172A))),
              Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
              Expanded(child: _buildTicketStat('Chart Status', 'Chart Prepared', const Color(0xFF046A38))),
              Container(width: 1, height: 30, color: const Color(0xFFF1F5F9)),
              Expanded(child: _buildTicketStat('Booking Status', 'Confirmed', const Color(0xFF046A38))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
        const SizedBox(height: 4),
        Text(value, style: AppFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: valueColor), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildPassengerList() {
    final passengers = [
      {'name': 'RAHUL SHARMA', 'gender': 'Male', 'age': '32 yrs', 'berth': 'Lower', 'berthNo': 'S5 - 32', 'status': 'Confirmed'},
      {'name': 'PRIYA SHARMA', 'gender': 'Female', 'age': '29 yrs', 'berth': 'Middle', 'berthNo': 'S5 - 33', 'status': 'Confirmed'},
      {'name': 'AARAV SHARMA', 'gender': 'Male', 'age': '8 yrs', 'berth': 'Upper', 'berthNo': 'S5 - 34', 'status': 'Confirmed'},
      {'name': 'ANITA SHARMA', 'gender': 'Female', 'age': '55 yrs', 'berth': 'Side Lower', 'berthNo': 'S5 - 35', 'status': 'Confirmed'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        children: passengers.asMap().entries.map((entry) {
          final i = entry.key;
          final p = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Number Circle
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _getPassengerColor(i),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text('${i + 1}', style: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: _getPassengerTextColor(i))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['name']!, style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text('${p['gender']}   •   ${p['age']}   •   ${p['berth']}', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Berth No.', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(p['berthNo']!, style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Status', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(p['status']!, style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < passengers.length - 1)
                const Divider(color: Color(0xFFF1F5F9), height: 1, indent: 64),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getPassengerColor(int index) {
    const colors = [Color(0xFFE2F6EC), Color(0xFFE0F2FE), Color(0xFFFFF7ED), Color(0xFFFAF5FF)];
    return colors[index % colors.length];
  }

  Color _getPassengerTextColor(int index) {
    const colors = [Color(0xFF046A38), Color(0xFF0284C7), Color(0xFFEA580C), Color(0xFF9333EA)];
    return colors[index % colors.length];
  }

  Widget _buildRouteTimeline() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Boarding Station', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
              Text('Destination Station', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Itwari Junction (ITW)', style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
              Text('Nagpur Junction (NGP)', style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 12),
          // Timeline Row
          Row(
            children: [
              Text('07:20 PM', style: AppFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          children: List.generate(
                            (constraints.maxWidth / 6).floor(),
                            (index) => Expanded(
                              child: Container(color: index % 2 == 0 ? const Color(0xFFCBD5E1) : Colors.transparent, height: 1.5),
                            ),
                          ),
                        );
                      }),
                    ),
                    Column(
                      children: [
                        const Icon(Icons.directions_railway, color: Color(0xFF046A38), size: 20),
                        const SizedBox(height: 2),
                        Text('2h 10m', style: AppFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                      ],
                    ),
                    Expanded(
                      child: LayoutBuilder(builder: (context, constraints) {
                        return Row(
                          children: List.generate(
                            (constraints.maxWidth / 6).floor(),
                            (index) => Expanded(
                              child: Container(color: index % 2 == 0 ? const Color(0xFFCBD5E1) : Colors.transparent, height: 1.5),
                            ),
                          ),
                        );
                      }),
                    ),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text('09:30 PM', style: AppFonts.poppins(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('21 May 2025', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              Text('21 May 2025', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTipBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _hasSearched ? const Color(0xFFF4FBF7) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _hasSearched ? const Color(0xFFE2F6EC) : const Color(0xFFFFEDD5)),
      ),
      child: Row(
        children: [
          Icon(
            _hasSearched ? Icons.lightbulb_outline : Icons.lightbulb_rounded,
            color: _hasSearched ? const Color(0xFF046A38) : const Color(0xFFEA580C),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _hasSearched ? 'Tip: Save this PNR for quick access' : 'Tip: PNR number is usually mentioned on your ticket.',
              style: AppFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _hasSearched ? const Color(0xFF046A38) : const Color(0xFF9A3412),
              ),
            ),
          ),
          if (_hasSearched)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF046A38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFF046A38)),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 32),
              ),
              child: Text('Save PNR', style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildGoPremiumCard() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xFFFF671F).withAlpha(30), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.workspace_premium, color: Color(0xFFFF671F), size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Go Premium', style: AppFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF9A3412))),
                  const SizedBox(height: 4),
                  Text(
                    'Get real-time updates, alerts, seat availability,\nrefund status and many more.',
                    style: AppFonts.inter(fontSize: 10.5, color: const Color(0xFFC2410C), height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF671F),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: const Color(0xFFFF671F).withAlpha(60), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Text('Upgrade Now', style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFEA580C)),
          ],
        ),
      ),
    );
  }
}
