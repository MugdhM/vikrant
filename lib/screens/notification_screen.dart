import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Notifications',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AlertScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AlertData {
  final String title;
  final String message;
  final IconData icon;
  final String time;
  final String severity;

  AlertData({
    required this.title,
    required this.message,
    required this.icon,
    required this.time,
    required this.severity,
  });
}

class AlertScreen extends StatefulWidget {
  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> with TickerProviderStateMixin {
  final List<AlertData> alerts = [
    AlertData(
      title: "Obstacle Ahead",
      message: "Lookout obstacle ahead",
      icon: Icons.warning_amber_rounded,
      time: "Just Now",
      severity: "High",
    ),
    AlertData(
      title: "Battery Full",
      message: "Your device battery is 100%",
      icon: Icons.battery_alert,
      time: "Just Now",
      severity: "Low",
    ),
    AlertData(
      title: "Carriage Full",
      message: "The Carriage is Full Please Unload",
      icon: Icons.check_box,
      time: "Just Now",
      severity: "Medium",
    ),
  ];

  final List<AlertData> activeNotifications = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  int currentIndex = 0;

  void _showNextNotification() {
    if (currentIndex < alerts.length) {
      _showNotification(alerts[currentIndex]);
      currentIndex++;
    }
  }

  void _showNotification(AlertData alert) {
    setState(() {
      activeNotifications.insert(0, alert);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
    });

    Timer(const Duration(seconds: 10), () {
      _dismissNotification(0);
    });
  }

  void _dismissNotification(int index) {
    if (index < activeNotifications.length) {
      final removedItem = activeNotifications[index];
      setState(() {
        activeNotifications.removeAt(index);
        _listKey.currentState?.removeItem(
          index,
              (context, animation) => _buildNotificationItem(removedItem, animation),
          duration: const Duration(milliseconds: 300),
        );
      });
    }
  }

  Widget _buildNotificationItem(AlertData alert, Animation<double> animation) {
    return SlideTransition(
      position: animation.drive(
        Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: NotificationCard(alert: alert),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: activeNotifications.length,
              shrinkWrap: true,
              itemBuilder: (context, index, animation) {
                return _buildNotificationItem(activeNotifications[index], animation);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 25.0, // Reduced button width
        height: 25.0, // Reduced button height
        child: FloatingActionButton(
          onPressed: _showNextNotification,
          backgroundColor: Colors.white, // Set the button color to white
          elevation: 2.0, // Optional: Adjust the shadow effect
        ),
      ),

    );
  }
}

class NotificationCard extends StatelessWidget {
  final AlertData alert;

  const NotificationCard({Key? key, required this.alert}) : super(key: key);

  Color _getSeverityColor() {
    switch (alert.severity.toLowerCase()) {
      case 'high':
        return Colors.red.shade100;
      case 'medium':
        return Colors.orange.shade100;
      case 'low':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getSeverityTextColor() {
    switch (alert.severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(alert.icon, color: _getSeverityTextColor()),
          ),
          title: Text(
            alert.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(alert.message),
              const SizedBox(height: 4),
              Text(
                alert.time,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getSeverityColor(),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              alert.severity,
              style: TextStyle(
                color: _getSeverityTextColor(),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
