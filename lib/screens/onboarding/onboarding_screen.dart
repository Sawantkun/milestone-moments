import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      gradient: AppColors.onboardingPage1,
      icon: Icons.favorite_rounded,
      title: 'Track Every\nPrecious Moment',
      subtitle: 'Capture and celebrate each milestone in your child\'s journey — first steps, first words, and everything in between.',
    ),
    _OnboardingData(
      gradient: AppColors.onboardingPage2,
      icon: Icons.event_note_rounded,
      title: 'Never Miss\na Milestone',
      subtitle: 'Set reminders for vaccinations, doctor visits, and important developmental checkpoints. We\'ll keep you on track.',
    ),
    _OnboardingData(
      gradient: AppColors.onboardingPage3,
      icon: Icons.show_chart_rounded,
      title: 'Monitor Growth\n& Health',
      subtitle: 'Beautiful charts showing your child\'s height, weight, and head circumference growth over time.',
    ),
    _OnboardingData(
      gradient: AppColors.onboardingPage4,
      icon: Icons.family_restroom_rounded,
      title: 'Your Journey\nBegins',
      subtitle: 'Join thousands of parents documenting their children\'s most magical years. Start your story today.',
      isLast: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mm_onboarding_done', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: _pages.length,
            itemBuilder: (context, idx) {
              return _OnboardingPage(data: _pages[idx], isActive: _currentPage == idx);
            },
          ),
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 20,
            child: AnimatedOpacity(
              opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: TextButton(
                onPressed: _finish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          // Bottom controls
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _controller,
                  count: _pages.length,
                  effect: const WormEffect(
                    dotColor: Colors.white38,
                    activeDotColor: Colors.white,
                    dotHeight: 8,
                    dotWidth: 8,
                    spacing: 10,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Continue' : 'Get Started',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final bool isActive;

  const _OnboardingPage({required this.data, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: data.gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.4), width: 2),
                ),
                child: Icon(data.icon, size: 70, color: Colors.white),
              )
                  .animate(target: isActive ? 1 : 0)
                  .scale(
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1, 1),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 400.ms),
              const SizedBox(height: 48),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.25,
                ),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 20),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              )
                  .animate(target: isActive ? 1 : 0)
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .slideY(begin: 0.3, end: 0),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final LinearGradient gradient;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isLast;

  const _OnboardingData({
    required this.gradient,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
}
