import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:vikrant/screens/video_stream_page.dart';

import 'live_location.dart';


class VikrantHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            _buildHeader(),

            // Main Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 3D Model Section
                      _buildBlock(
                        context,
                        content: _build3DModelContent(),
                        onTap: () {
                          // Navigation logic for 3D model
                        },
                        showArrow: false,
                      ),

                      SizedBox(height: 16),

                      // Data Section with Carousel
                      _buildBlock(
                        context,
                        content: _buildDataCarouselContent(),
                        onTap: () {
                          // Navigate to data analytics page
                        },
                        showArrow: false,
                      ),

                      SizedBox(height: 16),

                      _buildBlock(
                        context,
                        content: _buildControllerContent(),
                        onTap: () async {
                           await LaunchApp.openApp(
                            androidPackageName: 'com.electro_tex.bluetoothcar',
                          );
                        },
                      ),

                      SizedBox(height: 16),

                      // Live Feed and Location Blocks
                      Row(
                        children: [
                          Expanded(
                            child: _buildBlock(
                              context,
                              content: _buildLiveFeedContent(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const VideoStreamPage(),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildBlock(
                              context,
                              content: _buildLocationContent(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    RealTimeLocationMap(),
                                  ),
                                );
                                // Navigate to location tracking page
                              },
                            ),
                          ),
                        ],
                      ),
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

  // Header with logo and app name
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Circular Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue[100],
              image: DecorationImage(
                image: AssetImage('assets/images/logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16),
          // App Name
          Text(
            'VIKRANT',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  // Reusable block builder with optional arrow
  Widget _buildBlock(
    BuildContext context, {
    required Widget content,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(color: Colors.blue.withOpacity(0.3), width: 1),
        ),
        child: Stack(
          children: [
            // Centered content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(child: content),
            ),

            // Arrow in top right corner (optional)
            if (showArrow)
              Positioned(
                top: 12,
                right: 12,
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.blue[800],
                  size: 18,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 3D Model Block Content
  Widget _build3DModelContent() {
    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.blue[50],
      child: Stack(
        children: [
          // Placeholder for 3D Model
          Center(
            child: Container(
              color: Colors.blue[100],
            ),
          ),
          // Battery and pH Indicators at Bottom Center
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Battery Indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Battery: 87%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                // pH Indicator
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'pH: 7.2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  // Data Carousel Content
  Widget _buildDataCarouselContent() {
    final List<Map<String, String>> carouselItems = [
      {
        'title': 'Total Tourists',
        'value': '12,450',
        'icon': 'people',
      },
      {
        'title': 'Hotel Bookings',
        'value': '3,782',
        'icon': 'hotel',
      },
      {
        'title': 'Additional Stat',
        'value': '2,345',
        'icon': 'analytics',
      },
    ];

    return CarouselSlider(
      options: CarouselOptions(
        height: 150,
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
      ),
      items: carouselItems.map((item) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon on the left
                  Icon(
                    _getIconData(item['icon']!),
                    size: 30,
                    color: Colors.blue[800],
                  ),
                  SizedBox(width: 10),
                  // Data text content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        item['title']!,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        item['value']!,
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }).toList(),
    );
  }

  //
  // Controller Section Content
  Widget _buildControllerContent() {
    return Container(
      height: 100,
      width: double.infinity,
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon on the left
          Icon(
            Icons.settings,
            size: 30,
            color: Colors.blue[800],
          ),
          SizedBox(width: 10),
          // Boat control text
          Text(
            'Boat Controller',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Live Feed Block Content
  Widget _buildLiveFeedContent() {
    return Container(
      height: 130,
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Camera Icon on the left
          Icon(
            Icons.live_tv_rounded,
            size: 30,
            color: Colors.blue[800],
          ),
          SizedBox(width: 10),
          // Live Feed text
          Text(
            'Live Feed',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Location Block Content
  Widget _buildLocationContent() {
    return Container(
      height: 130,
      color: Colors.blue[50],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Location Icon on the left
          Icon(
            Icons.location_on,
            size: 30,
            color: Colors.blue[800],
          ),
          SizedBox(width: 10),
          // Location text
          Text(
            'Location',
            style: TextStyle(
              color: Colors.blue[800],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
