import 'package:flutter/material.dart';

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

// Alert Screen
class AlertScreen extends StatefulWidget {
  @override
  _AlertScreenState createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  final List<AlertData> alerts = [
    AlertData(
      title: "System Update Available",
      message: "A new system update is ready to install",
      icon: Icons.system_update,
      time: "2 mins ago",
      severity: "High",
    ),
    AlertData(
      title: "Battery Low",
      message: "Your device battery is below 15%",
      icon: Icons.battery_alert,
      time: "5 mins ago",
      severity: "Medium",
    ),
    AlertData(
      title: "New Message",
      message: "You have received a new message",
      icon: Icons.message,
      time: "10 mins ago",
      severity: "Low",
    ),
    AlertData(
      title: "Security Alert",
      message: "Unusual login attempt detected",
      icon: Icons.security,
      time: "15 mins ago",
      severity: "High",
    ),
    AlertData(
      title: "Storage Full",
      message: "Device storage is almost full",
      icon: Icons.storage,
      time: "20 mins ago",
      severity: "Medium",
    ),
    AlertData(
      title: "WiFi Disconnected",
      message: "Your device lost WiFi connection",
      icon: Icons.wifi_off,
      time: "25 mins ago",
      severity: "Low",
    ),
    AlertData(
      title: "Calendar Event",
      message: "Upcoming meeting in 30 minutes",
      icon: Icons.event,
      time: "30 mins ago",
      severity: "Medium",
    ),
  ];

  void _handleAlertTap(AlertData alert) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(alert.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(alert.message),
              SizedBox(height: 12),
              Text(
                'Severity: ${alert.severity}',
                style: TextStyle(
                  color: _getSeverityTextColor(alert.severity),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Time: ${alert.time}',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Dismiss'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  Color _getSeverityTextColor(String severity) {
    switch (severity.toLowerCase()) {
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _handleAlertTap(alerts[index]),
              child: AlertBox(alert: alerts[index]),
            );
          },
        ),
      ),
    );
  }
}

// Alert Box Widget
class AlertBox extends StatelessWidget {
  final AlertData alert;

  const AlertBox({Key? key, required this.alert}) : super(key: key);

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
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getSeverityColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                alert.icon,
                size: 24,
                color: _getSeverityTextColor(),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          alert.severity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getSeverityTextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    alert.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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
}
