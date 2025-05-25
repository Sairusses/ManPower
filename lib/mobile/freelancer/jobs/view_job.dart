import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:manpower/mobile/freelancer/jobs/apply_proposal.dart';

class ViewJob extends StatelessWidget {
  final String jobId;
  const ViewJob({super.key, required this.jobId});

  Future<String> _fetchClientUsername(String clientId) async {
    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(clientId).get();
    final userData = userDoc.data();
    return userData?['username'] ?? 'Unknown Client';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Details"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey[300], height: 1.0),
        ),
      ),
      backgroundColor: Colors.grey[50],
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Job not found"));
          }

          final job = snapshot.data!.data() as Map<String, dynamic>;

          final title = job['title'] ?? 'Untitled Job';
          final description = job['description'] ?? 'No description available.';
          final location = job['location'] ?? 'Unknown';
          final clientId = job['client'] ?? '';
          final skills = job['skills'] as List<dynamic>? ?? [];
          final timestamp = job['createdAt'] != null
              ? (job['createdAt'] as Timestamp).toDate()
              : DateTime.now();

          return FutureBuilder<String>(
            future: _fetchClientUsername(clientId),
            builder: (context, clientSnapshot) {
              final postedBy = clientSnapshot.data ?? 'Unknown Client';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text("Posted by $postedBy", style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(location, style: const TextStyle(fontSize: 14)),
                          const Spacer(),
                          const Icon(Icons.access_time, size: 18, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            "${timestamp.day}/${timestamp.month}/${timestamp.year}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Job Description",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(description, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 20),
                      const Text(
                        "Required Skills",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: skills.isNotEmpty
                            ? skills.map((skill) {
                          return Chip(
                            label: Text(skill.toString()),
                            backgroundColor: Colors.blue[50],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.blue),
                            ),
                          );
                        }).toList()
                            : [
                          const Chip(
                            label: Text("No skills listed"),
                            backgroundColor: Colors.grey,
                          )
                        ],
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send, color: Colors.white,),
                          label: const Text("Apply with Proposal"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ApplyProposal(jobId: jobId)));
                          },
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
