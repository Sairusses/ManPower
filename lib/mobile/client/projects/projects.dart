import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'create_project.dart';

class Projects extends StatelessWidget {
  const Projects({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Principals"),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('projects').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.blue,));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Column(
                children: [
                  const SizedBox(height: 100),
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          "No projects yet.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            final projects = snapshot.data!.docs;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return ProjectCard(
                  title: project['title'] ?? 'Untitled',
                  description: project['description'] ?? 'No description.',
                  paymentType: project['paymentType'] ?? 'Unknown',
                  hourlyRate: project['hourlyRate']?.toDouble() ?? 0.0,
                  fixedPrice: project['fixedPrice']?.toDouble() ?? 0.0,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateProject()),
          );
        },
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final String paymentType;
  final double hourlyRate;
  final double fixedPrice;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.paymentType,
    required this.hourlyRate,
    required this.fixedPrice,
  });

  @override
  Widget build(BuildContext context) {
    String paymentInfo;
    if (paymentType.toLowerCase() == 'hourly') {
      paymentInfo = 'Hourly Rate -- Estimated Budget \$${hourlyRate.toStringAsFixed(0)} / hr';
    } else if (paymentType.toLowerCase() == 'fixed') {
      paymentInfo = 'Fixed Price -- Estimated Budget \$${fixedPrice.toStringAsFixed(0)}';
    } else {
      paymentInfo = 'Payment: Unknown';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: .5),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onPressed: () {
                    // TODO: Add options like edit/delete
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 12),

            // Payment info line
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  paymentInfo,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Footer Line (optional)
            Row(
              children: const [
                Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  "Created recently",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

