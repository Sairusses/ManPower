import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manpower/mobile/auth/auth_service.dart';

class ProfileClient extends StatefulWidget {
  const ProfileClient({super.key});

  @override
  State<ProfileClient> createState() => _ProfileClientState();
}

class _ProfileClientState extends State<ProfileClient> with AutomaticKeepAliveClientMixin{
  final User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Company Profile"),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue,));
          }
          String username = snapshot.data!['username'] ?? 'User';
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Info',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'This is a client account',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                _buildAccountCard(
                  name: username,
                  email: user!.email!,
                  onEdit: () {
                    // TODO: Handle edit button press
                  },
                ),
                const SizedBox(height: 8),
                _buildCompanyCard(),
                const SizedBox(height: 8),
                _buildPayments(),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Expanded(
                    child: ElevatedButton(
                      onPressed: (){
                        AuthService().logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                      ),
                      child: Text('Log Out'),
                    ),
                  ),
                ),

              ],
            ),
          );
        },

      ),
    );
  }

  Widget _buildAccountCard ({
    required String name,
    required String email,
    required VoidCallback onEdit,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: Colors.grey,
              width: .5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Account', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal)),
                    Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(CupertinoIcons.pencil_circle, color: Colors.blue, size: 30,),
                  onPressed: onEdit
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: .5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              children: const [
                Text('Company', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Icon(Icons.business, size: 40, color: Colors.blue),
                SizedBox(height: 12),
                Text('Company Name: Not set'),
                Text('Location: Not set'),
              ],
            ),
          ),
          const Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(CupertinoIcons.pencil_circle, color: Colors.blue, size: 30),
              onPressed: null, // TODO: Implement editing
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayments() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: .5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text('Billings & Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Icon(Icons.payment, size: 40, color: Colors.blue),
          SizedBox(height: 12),
          Text('Payment Method: Not added'),
          Text('Billing History: No recent activity'),
        ],
      ),
    );
  }

}
