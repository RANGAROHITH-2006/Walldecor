import 'package:flutter/material.dart';

class Notificationpage extends StatefulWidget {
  const Notificationpage({super.key});

  @override
  State<Notificationpage> createState() => _NotificationpageState();
}

class _NotificationpageState extends State<Notificationpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF25272F),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          }, 
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        backgroundColor: const Color(0xFF25272F),
        titleSpacing: 0,
        title: const Text('Notification', style: TextStyle(color: Colors.white,fontSize: 18)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
              Text(
                'You have 2 Notifications today',
                style: TextStyle(
                  color: Color(0xFF868EAE),
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF868EAE),
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      'You received a payment of \$20.00',
                      style: TextStyle(color: Colors.white,fontSize: 
                      16),
                    ),
                    subtitle: Text(
                      '2 hours ago',
                      style: TextStyle(color: Color(0xFF868EAE)),
                    ),
                  );
                },),
              )
          ],
        ),
      ),
    );
  }
}