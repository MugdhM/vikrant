import 'package:flutter/material.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:vikrant/screens/3d_model.dart';
import 'package:vikrant/screens/chatbot_screen.dart';
import 'package:vikrant/screens/detail_screen.dart';
import 'package:vikrant/screens/live_location.dart';
import 'package:vikrant/screens/notification_screen.dart';
import 'package:vikrant/screens/video_stream_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class VikrantScreen extends StatefulWidget {
  const VikrantScreen({Key? key}) : super(key: key);

  @override
  State<VikrantScreen> createState() => _VikrantScreenState();
}

class _VikrantScreenState extends State<VikrantScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  double tdsValue = 0.0;
  double batteryValue = 0.0;
  late BuildContext _context;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..forward();

    _setupRealtimeUpdates();
  }

  void _setupRealtimeUpdates() {
    _database
        .child('test/tds')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          tdsValue = double.parse(event.snapshot.value.toString());
        });
      }
    });

    _database
        .child('test/battery')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          batteryValue = double.parse(event.snapshot.value.toString());
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlertScreen()),
    );
  }


  void _onFabTapped(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetailScreen(),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMM, yyyy');
    _context = context;

    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      body: Stack(
        children: [
          // Animated Background Pattern
          ...List.generate(
            5,
                (index) =>
                Positioned(
                  top: index * 100.0,
                  right: -50 + (index * 20),
                  child: SlideTransition(
                    position:
                    Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                        .animate(CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        0.1 * index,
                        0.6 + (0.1 * index),
                        curve: Curves.easeOut,
                      ),
                    )),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(75),
                      ),
                    ),
                  ),
                ),
          ),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FadeTransition(
                            opacity: _controller,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                  begin: const Offset(-0.5, 0),
                                  end: Offset.zero)
                                  .animate(_controller),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Welcome',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const Text(
                                    'to Vikrant!',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      dateFormat.format(now),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Notification Button
                          ScaleTransition(
                            scale: _controller,
                            child: GestureDetector(
                              onTap: () => _navigateToNotifications(context),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    const Icon(
                                      Icons.notifications_none_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/Weather.png",
                            scale: 5,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "21",
                            style: TextStyle(fontSize: 25, color: Colors.white),
                          ),
                          const Text(
                            "°C",
                            style: TextStyle(fontSize: 30, color: Colors.white),
                          )
                        ],
                      )
                    ],
                  ),
                ),

                // Draggable Sheet
                Expanded(
                  child: DraggableScrollableSheet(
                    initialChildSize: 1.0,
                    minChildSize: 1.0,
                    maxChildSize: 1.0,
                    builder: (context, scrollController) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                          BorderRadius.vertical(top: Radius.circular(30)),
                        ),
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(20),
                          children: [
                            Center(
                              child: Container(
                                width: 40,
                                height: 4,
                                margin: const EdgeInsets.only(bottom: 20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            _buildStatusSection(),
                            const SizedBox(height: 25),
                            _buildMenuSection(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _controller,
        child: SizedBox(
          width: 70,
          height: 70,
          child: FloatingActionButton(
            onPressed: () {
              // Navigate to ChatBotApp() screen
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ChatbotScreen()));
            },
            backgroundColor: Colors.white,
            elevation: 4.0,
            child: ClipOval(
              // Ensures circular shape for the Lottie asset
              child: SizedBox(
                width: 70,
                height: 70,
                child: Lottie.asset(
                  'assets/images/Hello.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Status',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildGaugeCard(
              context: context,
              title: 'TDS Level (ppm)',
              value: tdsValue,
              maxValue: 400,
              gaugeBuilder: buildTDSGauge,
            ),
            buildGaugeCard(
              context: context,
              title: 'Battery Level %',
              value: batteryValue,
              maxValue: 100,
              gaugeBuilder: buildBatteryGauge,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildGaugeCard({
    required BuildContext context,
    required String title,
    required double value,
    required double maxValue,
    required Widget Function(double, double) gaugeBuilder,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
              height: 70,
              child: gaugeBuilder(value, maxValue)
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            '${value.toInt()}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _getColorForValue(value, maxValue),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForValue(double value, double maxValue) {
    // Automatically detect gauge type based on maxValue
    if (maxValue == 100) {
      // Battery logic
      if (value > (maxValue * 0.75)) {
        return Colors.green;
      } else if (value >= (maxValue * 0.5)) {
        return Colors.yellow;
      } else {
        return Colors.red;
      }
    } else if (maxValue <= 400) {
      // TDS logic (assuming TDS typically ranges up to 400 ppm)
      if (value < (maxValue * 0.3)) {
        return Colors.green; // Low TDS is good
      } else if (value < (maxValue * 0.7)) {
        return Colors.yellow; // Medium TDS
      } else {
        return Colors.red; // High TDS is problematic
      }
    } else {
      // Default color logic for other types of gauges
      return Colors.blue;
    }
  }

  Widget buildTDSGauge(double value, double maxValue) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: 2000,

      axes: [
        RadialAxis(
          minimum: 0,
maximumLabels: 0,
          labelOffset: 0,
          showFirstLabel: false,
          showAxisLine: false,
          maximum: maxValue,
          startAngle: 180,
          endAngle: 0,
          showLabels: false,
          showTicks: false,
          radiusFactor: 1.0,
          canScaleToFit: true,
          ranges: [
            GaugeRange(
              startValue: 0,
              endValue: maxValue,
              startWidth: 15,
              endWidth: 15,
              color: Colors.grey.shade200,
            ),
            GaugeRange(
              startValue: 0,
              endValue: value,
              startWidth: 15,
              endWidth: 15,
              gradient: const SweepGradient(
                colors: [Colors.green, Colors.yellow, Colors.red],
                stops: [0.5, 0.75, 1.0],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildBatteryGauge(double value, double maxValue) {
    return SfRadialGauge(
      enableLoadingAnimation: true,
      animationDuration: 2000,
      axes: [
        RadialAxis(
          minimum: 0,
          maximumLabels: 0,
          labelOffset: 0,
          showFirstLabel: false,
          showAxisLine: false,
          maximum: maxValue,
          startAngle: 180,
          endAngle: 0,
          showLabels: false,
          showTicks: false,
          radiusFactor: 1.0,
          canScaleToFit: true,
          ranges: [
            GaugeRange(
              startValue: 0,
              endValue: maxValue,
              startWidth: 15,
              endWidth: 15,
              color: Colors.grey.shade200,
            ),
            GaugeRange(
              startValue: 0,
              endValue: value,
              startWidth: 15,
              endWidth: 15,
              gradient: const SweepGradient(
                colors: [Colors.red, Colors.yellow, Colors.green],
                stops: [0.4, 0.8, 1.0],
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _buildMenuItem(
          'Controller',
          Icons.gamepad,
          Colors.orange,

          'Manages boat direction',
        ),
        const SizedBox(height: 15),
        _buildMenuItem(
          'Live Feed',
          Icons.videocam,
          Colors.red,
          'View real-time camera feed',
        ),
        const SizedBox(height: 15),
        _buildMenuItem(
          'Location',
          Icons.location_on,
          Colors.green,
          'Track current position',
        ),
        const SizedBox(height: 15),
        _buildMenuItem(
          '3-D Model',
          Icons.view_in_ar,
          Colors.blueAccent,
          'Model of the boat',
        ),
      ],
    );
  }

  Widget _buildMenuItem(String title,
      IconData icon,
      Color color,
      String subtitle,) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () async {
            // Add navigation logic based on menu item title
            if (title == 'Controller') {
              await LaunchApp.openApp(
                androidPackageName: 'com.electro_tex.bluetoothcar',
              );
            } else if (title == 'Live Feed') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VideoStreamPage(),
                ),
              );
            } else if (title == 'Location') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RealTimeLocationMap(),
                ),
              );
            }else if (title == '3-D Model') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Modelviewer(),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}