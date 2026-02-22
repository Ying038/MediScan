import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    const Color primaryPurple = Color(0xFF8A94FF);
    const Color textDark = Color(0xFF2D3142);
    const Color bgColor = Color(0xFFF8F9FE);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Account Settings", style: TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 50, 
                backgroundColor: primaryPurple.withOpacity(0.2), 
                child: const Icon(Icons.person, size: 50, color: primaryPurple)
              ),
            ),
            const SizedBox(height: 15),
            Text(user?.email ?? "User Email", 
              style: const TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Member since 2026", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            _profileMenuItem(Icons.edit, "Edit Profile", primaryPurple, textDark),
            _profileMenuItem(Icons.notifications, "Notifications", primaryPurple, textDark),
            _profileMenuItem(Icons.language, "Language (BM/English)", primaryPurple, textDark),
            _profileMenuItem(Icons.lock, "Privacy Policy", primaryPurple, textDark),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(color: Colors.grey, thickness: 0.2),
            ),
            
            _profileMenuItem(Icons.help_center, "Help & Support", primaryPurple, textDark),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem(IconData icon, String title, Color primary, Color text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: primary),
        title: Text(title, style: TextStyle(color: text, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: () {},
      ),
    );
  }
}