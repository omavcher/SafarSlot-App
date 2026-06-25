import 'package:flutter/material.dart';
import 'app_fonts.dart';

class CoachPositionScreen extends StatefulWidget {
  const CoachPositionScreen({super.key});

  @override
  State<CoachPositionScreen> createState() => _CoachPositionScreenState();
}

class _CoachPositionScreenState extends State<CoachPositionScreen> {
  final List<String> _coaches = ['A\n1A', 'B\n2A', 'HA\n3A', 'B1\n3A', 'B2\n3A', 'B3\n3A', 'B4\n3A', 'B5\n3A'];
  int _selectedCoachIndex = 4; // B2

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTrainDetailsCard(),
            const SizedBox(height: 20),
            _buildCoachSelector(),
            const SizedBox(height: 24),
            _buildCoachLayoutSection(),
            const SizedBox(height: 24),
            _buildSelectedBerthsCard(),
            const SizedBox(height: 100), // Padding for bottom bar
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
          Text('Select Coach & Berth', style: AppFonts.appBarTitle.copyWith(fontSize: 18)),
          Text('Choose your preferred coach and seats', style: AppFonts.labelSmall.copyWith(fontSize: 11)),
        ],
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2F6EC)),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, size: 16, color: Color(0xFF046A38)),
                const SizedBox(width: 4),
                Text('Help', style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainDetailsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: Color(0xFFE2F6EC), shape: BoxShape.circle),
            child: const Icon(Icons.train_rounded, color: Color(0xFF046A38), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('12951 Mumbai Rajdhani Express', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                      child: Text('Superfast', style: AppFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF166534))),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('Mumbai CSMT (CSMT)', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward_rounded, size: 10, color: Color(0xFF94A3B8)),
                    ),
                    Text('New Delhi (NDLS)', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF475569))),
                  ],
                ),
                const SizedBox(height: 6),
                Text('21 May 2025   •   04:10 PM   →   08:35 AM (22 May)', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2F6EC)),
            ),
            child: Row(
              children: [
                Text('Train Details', style: AppFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 12, color: Color(0xFF046A38)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoachSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Coach', style: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
            Row(
              children: [
                Text('Coach Guide', style: AppFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF046A38)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Tap on a coach to view berth layout', style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
        const SizedBox(height: 12),
        Container(
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: _coaches.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _selectedCoachIndex;
                    final parts = _coaches[index].split('\n');
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCoachIndex = index),
                      child: Container(
                        width: 54,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF046A38) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? const Color(0xFF046A38) : const Color(0xFFE2E8F0)),
                          boxShadow: isSelected
                              ? [BoxShadow(color: const Color(0xFF046A38).withAlpha(60), blurRadius: 6, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              parts[0],
                              style: AppFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              parts[1],
                              style: AppFonts.inter(
                                fontSize: 10,
                                color: isSelected ? Colors.white.withAlpha(200) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 32,
                height: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
                child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B), size: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCoachLayoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coach B2 - 3A (AC Tier 3)', style: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
        const SizedBox(height: 16),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLegendItem(const Color(0xFF4ADE80), 'Available'),
            _buildLegendItem(const Color(0xFF60A5FA), 'Selected'),
            _buildLegendItem(const Color(0xFFCBD5E1), 'Booked'),
            _buildLegendItem(const Color(0xFFFDBA74), 'Ladies'),
            _buildLegendItem(const Color(0xFFF472B6), 'Senior Citizen'),
          ],
        ),
        const SizedBox(height: 16),
        // Seat Map Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
          child: Column(
            children: [
              // Header labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40), // Offset for left numbers
                  Expanded(
                    flex: 2,
                    child: Center(child: Text('Entry', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B)))),
                  ),
                  const SizedBox(width: 20), // Middle
                  Expanded(
                    flex: 2,
                    child: Center(child: Text('Exit', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B)))),
                  ),
                  const SizedBox(width: 40), // Offset for right numbers
                ],
              ),
              const SizedBox(height: 8),
              Center(
                child: Text('Emergency Window', style: AppFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
              ),
              const SizedBox(height: 16),
              
              // The Grid rows
              _buildSeatRow('24', '24', 'A', '25', 'A', '31', 'A', '12', 'B', '18', hasLadder: true),
              const SizedBox(height: 8),
              _buildSeatRow('23', '23', 'S', '26', 'A', '32', 'A', '11', 'B', '17', hasLadder: false),
              const SizedBox(height: 8),
              _buildSeatRow('22', '22', 'A', '27', 'B', '33', 'B', '10', 'A', '16', hasLadder: true),
              const SizedBox(height: 8),
              _buildSeatRow('21', '21', 'B', '28', 'A', '34', 'A', '9', 'A', '15', hasLadder: false),
              const SizedBox(height: 8),
              _buildSeatRow('20', '20', 'L', '29', 'A', '35', 'SC', '8', 'L', '14', hasLadder: true),
              const SizedBox(height: 8),
              _buildSeatRow('19', '19', 'B', '30', 'B', '36', 'B', '7', 'B', '13', hasLadder: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF475569))),
      ],
    );
  }

  // State Code map: A = Available, S = Selected, B = Booked, L = Ladies, SC = Senior Citizen
  Widget _buildSeatRow(
    String leftNum,
    String box1Num, String box1State,
    String box2Num, String box2State,
    String box3Num, String box3State,
    String box4Num, String box4State,
    String rightNum,
    {required bool hasLadder}
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left Column (Numbers)
        SizedBox(
          width: 24,
          child: Text(leftNum, style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)), textAlign: TextAlign.center),
        ),
        // Box 1
        _buildSeatBox(box1Num, box1State),
        const SizedBox(width: 8),
        // Box 2
        _buildSeatBox(box2Num, box2State),
        
        // Middle Aisle (Ladder)
        SizedBox(
          width: 32,
          child: hasLadder 
            ? const Icon(Icons.format_line_spacing_rounded, color: Color(0xFF94A3B8), size: 20) // Using a similar icon for ladder
            : const SizedBox(height: 20),
        ),
        
        // Box 3
        _buildSeatBox(box3Num, box3State),
        const SizedBox(width: 8),
        // Box 4
        _buildSeatBox(box4Num, box4State),
        
        // Right Column (Numbers)
        SizedBox(
          width: 24,
          child: Text(rightNum, style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF16A34A)), textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildSeatBox(String number, String stateCode) {
    Color bg;
    Color border;
    Color text;

    switch (stateCode) {
      case 'A': // Available
        bg = const Color(0xFFDCFCE7);
        border = const Color(0xFF86EFAC);
        text = const Color(0xFF166534);
        break;
      case 'S': // Selected
        bg = const Color(0xFFDBEAFE);
        border = const Color(0xFF93C5FD);
        text = const Color(0xFF1E40AF);
        break;
      case 'B': // Booked
        bg = const Color(0xFFF1F5F9);
        border = const Color(0xFFCBD5E1);
        text = const Color(0xFF64748B);
        break;
      case 'L': // Ladies
        bg = const Color(0xFFFFEDD5);
        border = const Color(0xFFFDBA74);
        text = const Color(0xFFC2410C);
        break;
      case 'SC': // Senior Citizen
        bg = const Color(0xFFFCE7F3);
        border = const Color(0xFFF9A8D4);
        text = const Color(0xFFBE185D);
        break;
      default:
        bg = Colors.white;
        border = Colors.grey;
        text = Colors.black;
    }

    return Container(
      width: 48,
      height: 36,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        number,
        style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: text),
      ),
    );
  }

  Widget _buildSelectedBerthsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Selected Berths (2)', style: AppFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text('Tap on berth to change', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
              ],
            ),
            Row(
              children: [
                Text('Clear All', style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626))),
                const SizedBox(width: 4),
                const Icon(Icons.delete_outline_rounded, size: 14, color: Color(0xFFDC2626)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildBerthItem('23', true, 'Berth 23', 'Middle', 'Passenger 1', 'Adult  •  Male'),
        const SizedBox(height: 12),
        _buildBerthItem('B2-11', false, 'Berth 11', 'Upper', 'Passenger 2', 'Adult  •  Female'),
      ],
    );
  }

  Widget _buildBerthItem(String boxLabel, bool isSelectedColor, String berthTitle, String berthSub, String passTitle, String passSub) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelectedColor ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelectedColor ? const Color(0xFF93C5FD) : const Color(0xFFCBD5E1), width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              boxLabel,
              style: AppFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelectedColor ? const Color(0xFF1E40AF) : const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(berthTitle, style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(berthSub, style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          Container(width: 1, height: 32, color: const Color(0xFFF1F5F9)),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(passTitle, style: AppFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                const SizedBox(height: 2),
                Text(passSub, style: AppFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF1F5F9), width: 1)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coach', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        Text('B2 - 3A', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 24, color: const Color(0xFFF1F5F9)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Berths', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        Text('23, 11', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 24, color: const Color(0xFFF1F5F9)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Fare', style: AppFonts.inter(fontSize: 10, color: const Color(0xFF64748B))),
                        Text('₹1,880', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF046A38),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Continue', style: AppFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Review & Pay', style: AppFonts.inter(fontSize: 9, color: Colors.white.withAlpha(200))),
                          ],
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4FBF7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.gpp_good_outlined, color: Color(0xFF046A38), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your data is safe and secure', style: AppFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF046A38))),
                          const SizedBox(height: 2),
                          Text('We use bank-level security to protect your information', style: AppFonts.inter(fontSize: 9, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF046A38), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
