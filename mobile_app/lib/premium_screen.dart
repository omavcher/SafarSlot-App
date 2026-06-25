import 'package:flutter/material.dart';
import 'app_fonts.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // Plan options mapping matching mockup
  int _selectedPlanIndex = 0; // default 12 Months

  static const Color _saffron = Color(0xFFFF671F);
  static const Color _green = Color(0xFF046A38);
  static const Color _inactive = Color(0xFF94A3B8);

  final List<PlanModel> _plans = [
    PlanModel(
      months: 12,
      durationLabel: '12 Months',
      billingLabel: 'Billed annually',
      price: '₹699',
      saveLabel: 'Save 42%',
      isMostPopular: true,
    ),
    PlanModel(
      months: 3,
      durationLabel: '3 Months',
      billingLabel: 'Billed quarterly',
      price: '₹299',
      saveLabel: 'Save 25%',
      isMostPopular: false,
    ),
    PlanModel(
      months: 1,
      durationLabel: '1 Month',
      billingLabel: 'Billed monthly',
      price: '₹99',
      isMostPopular: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
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
                            'SafarSlot Premium',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Upgrade to Premium for an enhanced travel experience',
                            style: AppFonts.labelSmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Help Outlined Button
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Contacting Premium Helpdesk...')),
                      );
                    },
                    icon: const Icon(Icons.headset_mic_rounded, size: 14, color: Color(0xFF475569)),
                    label: const Text(
                      'Help',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Saffron Custom Train Banner
                      Container(
                        height: 140,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _saffron.withAlpha(20),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            children: [
                              // Background Train Illustration Image
                              Positioned.fill(
                                child: Image.asset(
                                  'assets/images/premium_train_banner.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              // Soft Saffron Gradient Overlay
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Colors.black.withAlpha(160),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // Content over image banner
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    // Golden Saffron Crown Icon Container
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFFEDD5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.workspace_premium_rounded,
                                          color: _saffron,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            'Go Premium. Travel Better.',
                                            style: TextStyle(
                                              fontSize: 16.5,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Unlock exclusive features and enjoy a seamless ad-free experience.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white70,
                                              fontFamily: 'Inter',
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
                      ),

                      const SizedBox(height: 16),

                      // Premium Benefits Section
                      Row(
                        children: const [
                          Icon(Icons.verified_user_rounded, color: _saffron, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Premium Benefits',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Benefit Grid (3x2)
                      GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: 1.7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildBenefitCard(
                            Icons.block_rounded,
                            'Ad-Free Experience',
                            'Enjoy the app without any ads',
                          ),
                          _buildBenefitCard(
                            Icons.my_location_rounded,
                            'Live Train Tracking',
                            'Real-time train location and status',
                          ),
                          _buildBenefitCard(
                            Icons.notifications_active_rounded,
                            'Advanced Alerts',
                            'Custom alerts for delays, arrivals & more',
                          ),
                          _buildBenefitCard(
                            Icons.airline_seat_recline_normal_rounded,
                            'Seat Availability',
                            'Check real-time seat availability',
                          ),
                          _buildBenefitCard(
                            Icons.calendar_month_rounded,
                            'Advance Booking',
                            'Book tickets in advance with ease',
                          ),
                          _buildBenefitCard(
                            Icons.headset_mic_rounded,
                            'Priority Support',
                            'Get faster support whenever you need',
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Choose Your Plan Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Choose Your Plan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(Icons.lock_outline_rounded, color: _saffron, size: 13),
                              SizedBox(width: 4),
                              Text(
                                'Secure & Safe Payments',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _saffron,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Plan Cards List
                      ListView.builder(
                        itemCount: _plans.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final plan = _plans[index];
                          final isSelected = index == _selectedPlanIndex;
                          return _buildPlanCard(plan, index, isSelected);
                        },
                      ),

                      // Secure footnotes badge
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.verified_rounded, color: Color(0xFF0284C7), size: 14),
                            SizedBox(width: 6),
                            Text(
                              '100% secure payments · Cancel anytime · No hidden charges',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Saffron Action CTA Button
                      ElevatedButton.icon(
                        onPressed: () {
                          final selectedPlan = _plans[_selectedPlanIndex];
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Processing purchase for ${selectedPlan.durationLabel}...'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.workspace_premium_rounded, size: 20),
                        label: const Text(
                          'Upgrade to Premium',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _saffron,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'By continuing, you agree to our Terms & Conditions and Privacy Policy.',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bottom Support Yellow Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFFEF3C7), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFEF3C7),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 20),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Support Better Travel',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF92400E),
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Your subscription helps us improve features and bring you the best travel experience.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFFB45309),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB45309), size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String desc) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _saffron.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: _saffron, size: 14),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 8.5,
              color: Color(0xFF64748B),
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

  Widget _buildPlanCard(PlanModel plan, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? _saffron : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _saffron.withAlpha(20),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Row(
                children: [
                  // Plan details left
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.durationLabel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.billingLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price middle
                  Row(
                    children: [
                      Text(
                        plan.price,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      if (plan.saveLabel != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2F6EC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            plan.saveLabel!,
                            style: const TextStyle(
                              color: Color(0xFF046A38),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Radio tick right
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _saffron : _inactive,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: _saffron,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            // Most Popular top floating tag
            if (plan.isMostPopular)
              Positioned(
                top: -10,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Most Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlanModel {
  final int months;
  final String durationLabel;
  final String billingLabel;
  final String price;
  final String? saveLabel;
  final bool isMostPopular;

  PlanModel({
    required this.months,
    required this.durationLabel,
    required this.billingLabel,
    required this.price,
    this.saveLabel,
    required this.isMostPopular,
  });
}
