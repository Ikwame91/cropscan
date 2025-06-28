import 'package:flutter/material.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Alert Screen'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            ListTile(
              title: const Text('Alert 1'),
              subtitle: const Text('This is the first alert'),
              onTap: () {
                // Handle alert tap
              },
            ),
            ListTile(
              title: const Text('Alert 2'),
              subtitle: const Text('This is the second alert'),
              onTap: () {
                // Handle alert tap
              },
            ),
            ListTile(
              title: const Text('Alert 3'),
              subtitle: const Text('This is the third alert'),
              onTap: () {
                // Handle alert tap
              },
            ),
          ],
        ));
  }
}
