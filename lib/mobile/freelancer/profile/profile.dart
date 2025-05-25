import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manpower/mobile/auth/auth_service.dart';
import 'package:manpower/mobile/freelancer/profile/edit_name.dart';
import 'package:manpower/mobile/freelancer/profile/edit_overview.dart';
import 'package:manpower/mobile/freelancer/profile/pick_skills.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Company Profile"),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No profile data found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String username = data['username'] ?? 'User';
          final String email = data['email'] ?? 'email';
          final String overview = data['overview'] ?? 'No overview provided.';
          final String resumeName = data['resume_name'] ?? '';
          final String resumeUrl = data['resume_url'] ?? '';
          final String fileKey = data['resume_fileKey'] ?? '';
          final List<dynamic> skills = data['skills'] ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My Info', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text('This is a freelancer account', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                const SizedBox(height: 16),
                _buildAccountCard(name: username, email: email),
                const SizedBox(height: 16),
                _buildOverviewSection(overview, resumeName, resumeUrl, fileKey),
                const SizedBox(height: 16),
                _buildSkillsSection(skills),
                const SizedBox(height: 16),
                _buildPayments(),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      AuthService().logout(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountCard({required String name, required String email}) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const CircleAvatar(radius: 20, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white)),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 18)),
                Text(email, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => EditName(name: name, email: email)));
                  setState(() {});
                },
                icon: Icon(CupertinoIcons.pencil_circle, color: Colors.blue, size: 30),
              )
          )
        ]
      ),
    );
  }

  Widget _buildOverviewSection(String overview, String resumeName, String resumeUrl, String fileKey) {
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
              children: [
                Text(
                  'Profile Overview',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(overview),
                SizedBox(height: 8),
                if (resumeName.isNotEmpty && resumeUrl.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final Uint8List fileBytes = await sb.Supabase.instance.client.storage.from('files').download(fileKey);
                          final tempDir = await getTemporaryDirectory();
                          final filePath = '${tempDir.path}/$resumeName';
                          final file = io.File(filePath);
                          await file.writeAsBytes(fileBytes);
                          final result = await OpenFilex.open(filePath);
                          debugPrint('File open result: ${result.message}');
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(MediaQuery.of(context).size.width * .7, 40),
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        label: Text(resumeName),
                        icon: Icon(Icons.file_download, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: () async{
                          await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                            'resume_name': '',
                            'resume_url': '',
                            'resume_fileKey': '',
                          });
                          await sb.Supabase.instance.client.storage.from('files').remove([fileKey, resumeName]);
                          if(context.mounted){
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('File successfully deleted'))
                            );
                          }
                        },
                        icon: Icon(Icons.close, color: Colors.grey)
                      )
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      final filePickerResult = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['pdf', 'doc'],
                        withData: true, // Required for web
                      );

                      if (filePickerResult != null) {
                        final fileName = filePickerResult.files.single.name;
                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        final fileKey = '$uid/$fileName';

                        final storage = sb.Supabase.instance.client.storage.from('files');

                        try {
                          if (kIsWeb) {
                            // Web upload using bytes
                            final Uint8List fileBytes = filePickerResult.files.single.bytes!;
                            await storage.uploadBinary(fileKey, fileBytes);
                          } else {
                            // Mobile upload using File
                            final String filePath = filePickerResult.files.single.path!;
                            final io.File file = io.File(filePath);
                            await storage.upload(fileKey, file);
                          }

                          final publicUrl = storage.getPublicUrl(fileKey);

                          await FirebaseFirestore.instance.collection('users').doc(uid).update({
                            'resume_name': fileName,
                            'resume_url': publicUrl,
                            'resume_fileKey': fileKey,
                          });

                          print('Upload successful. File key: $fileKey');
                        } catch (e) {
                          print('Upload failed: $e');
                        }
                      }
                    }
                    ,
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(MediaQuery.of(context).size.width * .75, 40),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Upload Resume'),
                  ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(CupertinoIcons.pencil_circle, size: 30, color: Colors.blue,),
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => EditOverview(overview: overview,)));
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(List<dynamic> skills) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Skills', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: skills.map((skill) => Chip(backgroundColor: Colors. white, label: Text(skill)),).toList(),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () async {
                await Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => PickSkills())
                );
                setState(() {});
              }, 
              icon: Icon(CupertinoIcons.pencil_circle, color: Colors.blue, size: 30,)
            ),
          )
        ]
        
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
