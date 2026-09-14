import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/unit_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../widgets/unit_card.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AuthService? _authService;
  List<UnitModel> _units = [];
  bool _isLoadingUnits = false;
  String? _unitsError;
  String _userName = 'there';
  int _currentNavIndex = 0;

  final double _profitAmount = 25000.0;

  @override
  void initState() {
    super.initState();
    _initAndFetchUnits();
  }

  Future<void> _initAndFetchUnits() async {
    try {
      setState(() {
        _isLoadingUnits = true;
        _unitsError = null;
      });

      _authService = await AuthService.create();
      await _authService!.init();
      final user = _authService!.currentUser;
      if (user != null && user.fullName.trim().isNotEmpty) {
        _userName = user.fullName.trim();
      }
      final response = await _authService!.getUnits();
      if (mounted) {
        setState(() {
          _units = response.units;
          _isLoadingUnits = false;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _unitsError = e.message;
          _isLoadingUnits = false;
        });
        _showSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _unitsError = 'Failed to load units';
          _isLoadingUnits = false;
        });
        _showSnackBar('Failed to load units. Please try again.');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: isError ? Colors.white : AppColors.successGreen,
            fontSize: 14,
          ),
        ),
        backgroundColor: isError ? AppColors.errorRed : AppColors.successGreen,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _refreshUnits() async {
    await _initAndFetchUnits();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 400;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(isWide),
      body: RefreshIndicator(
        onRefresh: _refreshUnits,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 20 : 16,
            vertical: 12,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 20),
              _buildSearchBar(isWide),
              const SizedBox(height: 20),
              _buildProfitsCard(),
              const SizedBox(height: 20),
              _buildSaleBanner(),
              const SizedBox(height: 20),
              _buildSectionHeader(),
              const SizedBox(height: 12),
              _buildUnitsSection(),
              const SizedBox(height: 20),
              _buildActionsSection(isWide),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isWide) {
    return AppBar(
      backgroundColor: AppColors.backgroundWhite,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: AppColors.textSecondary,
          size: 26,
        ),
        onPressed: () {
          _showSnackBar('Menu coming soon!', isError: false);
        },
      ),
      title: Row(
        children: [
          const Text(
            'Dealer',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.home,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Stack(
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.errorRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              _showSnackBar('Notifications coming soon!', isError: false);
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.tune,
              color: AppColors.textSecondary,
              size: 24,
            ),
            onPressed: () {
              _showSnackBar('Settings coming soon!', isError: false);
            },
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome $_userName!',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Discover the best properties near you',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isWide) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.inputBorder,
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(
              Icons.search,
              color: AppColors.textHint,
              size: 22,
            ),
          ),
          Text(
            'Search for properties, developers...',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1565C0),
            Color(0xFF1976D2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Profits',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Total earnings from deals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+12%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'EGP \$${_profitAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Last 30 days',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.store,
                      color: Colors.white70,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '12 deals',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSaleBanner() {
    return GestureDetector(
      onTap: () {
        _showSnackBar('Browse all properties!', isError: false);
      },
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFE3F2FD),
              const Color(0xFFBBDEFB),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: 10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'SALE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Find Your Dream Home',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Explore exclusive listings from top developers',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Property Listings',
          style: AppTextStyles.headline2.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton(
          onPressed: _refreshUnits,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.primaryBlue,
              ),
              SizedBox(width: 4),
              Text(
                'Refresh',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitsSection() {
    if (_isLoadingUnits) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryBlue,
          ),
        ),
      );
    }

    if (_unitsError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.errorRed.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorRed,
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(
              _unitsError!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.errorRed,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildPrimaryButtonWidget(
              text: 'Retry',
              onPressed: _refreshUnits,
              icon: Icons.refresh,
              backgroundColor: AppColors.errorRed,
            ),
          ],
        ),
      );
    }

    if (_units.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.home_work,
              size: 56,
              color: AppColors.textHint.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No properties found',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to list a property!',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: (_units.length * 200.0).clamp(200.0, 600.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75,
        ),
        itemCount: _units.length,
        itemBuilder: (context, index) {
          return UnitCard(
            unit: _units[index],
            onTap: () {
              _showSnackBar(
                'Viewing details for ${_units[index].name}',
                isError: false,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionsSection(bool isWide) {
    final actions = [
      {'icon': Icons.home, 'label': 'Real Estate\nDevelopers', 'color': AppColors.primaryBlue},
      {'icon': Icons.school, 'label': 'Apply for\nTraining', 'color': const Color(0xFF00897B)},
      {'icon': Icons.account_balance_wallet, 'label': 'Commissions', 'color': const Color(0xFF7B1FA2)},
      {'icon': Icons.person_search, 'label': 'Apply on\nLeads', 'color': const Color(0xFFE65100)},
      {'icon': Icons.analytics, 'label': 'Transaction\nData', 'color': const Color(0xFF00695C)},
      {'icon': Icons.radio, 'label': 'Dealer\nBroadcast', 'color': const Color(0xFFC62828)},
      {'icon': Icons.help_outline, 'label': 'How to use\nthe app', 'color': const Color(0xFF546E7A)},
      {'icon': Icons.settings, 'label': 'Settings', 'color': AppColors.textSecondary},
    ];

    final crossAxisCount = isWide ? 4 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Quick Actions',
          style: AppTextStyles.headline2.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              icon: action['icon'] as IconData,
              label: action['label'] as String,
              color: action['color'] as Color,
              index: index,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        _showSnackBar('Opening action...', isError: false);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.divider,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: AppColors.divider,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home'),
              _buildNavItem(1, Icons.explore_outlined, Icons.explore, 'Explore'),
              _buildNavItem(2, Icons.notifications_outlined, Icons.notifications, 'Alerts'),
              _buildNavItem(3, Icons.person_outline, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isActive = _currentNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
        _showSnackBar('$label screen coming soon!', isError: false);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              color: isActive ? AppColors.primaryBlue : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButtonWidget({
    required String text,
    required VoidCallback? onPressed,
    required IconData icon,
    required Color backgroundColor,
    double height = 50,
  }) {
    final isDisabled = onPressed == null;
    final txtColor = Colors.white;

    return SizedBox(
      height: height,
      child: Material(
        color: isDisabled
            ? backgroundColor.withValues(alpha: 0.5)
            : backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: txtColor,
                ),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: AppTextStyles.button.copyWith(
                    color: txtColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
