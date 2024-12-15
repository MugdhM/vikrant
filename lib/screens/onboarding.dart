import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:vikrant/screens/vikrantapp.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> onboardingData = [
    OnboardingData(
      title: "Reclaiming Our Waterways",
      description: "Invasive aquatic plant disrupting ecosystems and biodiversity.",
      imagePath: 'page1.jpeg',
      isLottie: false,
    ),
    OnboardingData(
      title: "Technology Meets Conservation",
      description: "Integrating solar technology and AI to restore and manage aquatic ecosystems.",
      imagePath: 'page2.json',
      isLottie: true,
    ),
    OnboardingData(
      title: "Join Us in Making a Difference",
      description: "Revitalizing water bodies, boosting eco-tourism through VIKRANT.",
      imagePath: 'page3.jpg',
      isLottie: false,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const VikrantScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF5F5F5)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildSkipButton(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) => setState(() => _currentPage = page),
                  physics: _currentPage == 2
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) => _buildPage(onboardingData[index]),
                ),
              ),
              _buildBottomNavigation(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: _currentPage != 2
            ? TextButton(
          onPressed: () => _onIntroEnd(context),
          child: const Text(
            'Skip',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16.0,
              color: Colors.blue,
            ),
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: data.isLottie
                    ? Lottie.asset('assets/images/${data.imagePath}')
                    : Image.asset(
                  'assets/images/${data.imagePath}',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3142),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 16.0,
              color: Color(0xFF9098B1),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
                  (index) => _buildDotIndicator(index),
            ),
          ),
          const SizedBox(height: 20),
          _currentPage == 2
              ? _buildGetStartedButton()
              : _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: _currentPage == index
            ? Colors.blue
            : Colors.blue.withOpacity(0.2),
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      style: ElevatedButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(16),
        backgroundColor: Colors.blue,
      ),
      child: const Icon(
        Icons.arrow_forward,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _onIntroEnd(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;
  final bool isLottie;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.isLottie,
  });
}