import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:daily_habits/config/constants.dart';
import 'package:daily_habits/config/routes.dart';
import 'package:daily_habits/config/theme.dart';
import 'package:daily_habits/core/providers/app_state_provider.dart';
import 'package:daily_habits/shared/widgets/custom_button.dart';

/// Onboarding screen with tutorial slides
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'skip'.tr(),
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildOnboardingPage(
                    title: 'onboardingTitle1'.tr(),
                    description: 'onboardingDesc1'.tr(),
                    image: 'assets/images/onboarding_1.png',
                    context: context,
                  ),
                  _buildOnboardingPage(
                    title: 'onboardingTitle2'.tr(),
                    description: 'onboardingDesc2'.tr(),
                    image: 'assets/images/onboarding_2.png',
                    context: context,
                  ),
                  _buildOnboardingPage(
                    title: 'onboardingTitle3'.tr(),
                    description: 'onboardingDesc3'.tr(),
                    image: 'assets/images/onboarding_3.png',
                    context: context,
                  ),
                ],
              ),
            ),

            // Page indicator and buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppTheme.primaryColor,
                      dotColor:
                          AppTheme.primaryColor.withAlpha(76), // 0.3 * 255 = 76
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      expansionFactor: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Next or Get Started button
                  CustomButton(
                    text: _currentPage == 2 ? 'getStarted'.tr() : 'next'.tr(),
                    onPressed: _currentPage == 2 ? _goToLogin : _nextPage,
                    type: ButtonType.primary,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build onboarding page
  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required String image,
    required BuildContext context,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image placeholder with primary gradient
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                _getIconForPage(_currentPage),
                size: 100,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Title with primary color
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDarkColor,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[700],
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Get icon for page
  IconData _getIconForPage(int page) {
    switch (page) {
      case 0:
        return Icons.track_changes; // Habit tracking
      case 1:
        return Icons.analytics; // Progress tracking
      case 2:
        return Icons.emoji_events; // Achievements
      default:
        return Icons.help_outline;
    }
  }

  // Go to next page
  void _nextPage() {
    _pageController.nextPage(
      duration: AppConstants.animationDurationMedium,
      curve: Curves.easeInOut,
    );
  }

  // Complete onboarding and navigate to login
  void _goToLogin() {
    // Mark onboarding as complete
    Provider.of<AppStateProvider>(context, listen: false).completeOnboarding();
    
    // Navigate to login screen and clear all previous routes
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }
}
