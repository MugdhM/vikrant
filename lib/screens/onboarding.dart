import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  OnBoardingPageState createState() => OnBoardingPageState();
}

class OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onIntroEnd(context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => VikrantHomeScreen()),
    );
  }

  Widget _buildLottieAnimation(String assetName) {
    return Lottie.asset('assets/images/$assetName');
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    return Image.asset('assets/images/$assetName', width: width);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Skip button
          Padding(
            padding: const EdgeInsets.only(top: 50.0, right: 24.0),
            child: Align(
              alignment: Alignment.topRight,
              child: _currentPage != 2
                  ? GestureDetector(
                onTap: () => _onIntroEnd(context),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Colors.blue,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              physics: _currentPage == 2
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              children: [
                _buildOnboardingPage(
                  title: "Reclaiming Our Waterways",
                  body: "Invasive aquatic plant disrupting ecosystems and biodiversity.",
                  animation: _buildImage(
                      'page1.jpeg'), // Use an image instead of Lottie animation
                ),

                _buildOnboardingPage(
                  title: "Technology Meets Conservation",
                  body:
                  "Integrating solar technology and AI to restore and manage aquatic ecosystems.",
                  animation: _buildLottieAnimation('page2.json'),
                ),
                _buildOnboardingPage(
                  title: "Join Us in Making a Difference",
                  body:
                  "Revitalizing water bodies, boosting eco-tourism through VIKRANT.",
                  animation: _buildImage('page3.jpg'),
                  isLastPage: true,
                ),
              ],
            ),
          ),
          // Navigation buttons
          if (_currentPage != 2)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 25.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_currentPage == 2)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _onIntroEnd(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 17.0),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String body,
    required Widget animation,
    bool isLastPage = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Top-aligned animation or image
          Expanded(
            flex: 2, // Adjust to control height proportion
            child: Align(
              alignment: Alignment.topCenter,
              child: animation,
            ),
          ),
          // Center-aligned heading and subbody
          Expanded(
            flex: 2, // Adjust to control height proportion
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  // Ensures heading stays in one line
                  maxLines: 1, // Restricts to one line
                ),
                const SizedBox(height: 16),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 19.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}