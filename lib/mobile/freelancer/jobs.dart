import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manpower/mobile/freelancer/profile/pick_skills.dart';

class Jobs extends StatefulWidget {
  const Jobs({super.key});

  @override
  State<Jobs> createState() => _JobsState();
}

class _JobsState extends State<Jobs> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  String _searchQuery = '';

  List<String> userSkills = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchUserSkills();
  }

  Future<void> fetchUserSkills() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final data = doc.data();
    if (data != null && data.containsKey('skills')) {
      setState(() {
        userSkills = List<String>.from(data['skills']);
      });
    }
  }

  Stream<QuerySnapshot> fetchJobs({bool bestMatches = false}) {
    final collection = FirebaseFirestore.instance.collection('jobs');
    if (bestMatches) {
      return collection
          .where('skills', arrayContainsAny: userSkills.isNotEmpty ? userSkills : [''])
          .snapshots();
    } else {
      return collection.orderBy('createdAt', descending: true).snapshots();
    }
  }

  List<QueryDocumentSnapshot> _applySearchFilter(List<QueryDocumentSnapshot> jobs) {
    if (_searchQuery.isEmpty) return jobs;
    return jobs.where((doc) {
      final title = doc['title']?.toString().toLowerCase() ?? '';
      final description = doc['description']?.toString().toLowerCase() ?? '';
      return title.contains(_searchQuery.toLowerCase()) ||
          description.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('Jobs', style: TextStyle(color: Colors.black)),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(radius: 16, backgroundColor: Colors.blue, child: Icon(Icons.person, color: Colors.white,),),
          )
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    cursorColor: Colors.blue,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Search for jobs',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      suffixIcon: Icon(Icons.search, color: Colors.white),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey)
                  ),
                  padding: const EdgeInsets.all(12),
                  child: const Icon(Icons.favorite_border, color: Colors.blue),
                ),
              ],
            ),
          ),
          Divider(thickness: .3, color: Colors.grey[800],),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.blue,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Best Matches"),
              Tab(text: "Most Recent"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJobList(bestMatches: true),
                _buildJobList(bestMatches: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList({required bool bestMatches}) {
    if (bestMatches && userSkills.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 100),
          Center(
            child: Column(
              children: [
                Icon(Icons.engineering, size: 60, color: Colors.grey[400]), // Example skill icon
                const SizedBox(height: 16),
                const Text(
                  "No skills added yet.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => PickSkills())
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Add Skills?"),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: fetchJobs(bestMatches: bestMatches),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.work_outline, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text("No jobs available", style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        final filteredJobs = _applySearchFilter(snapshot.data!.docs);

        return ListView.builder(
          itemCount: filteredJobs.length,
          padding: const EdgeInsets.all(12),
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            return _buildJobCard(job);
          },
        );
      },
    );
  }


  Widget _buildJobCard(QueryDocumentSnapshot job) {
    final data = job.data() as Map<String, dynamic>?;

    final String title = data?['title']?.toString().trim() ?? 'Untitled Job';
    final String description = data?['description']?.toString().trim() ?? 'No description available.';
    final List<dynamic> skills = data?['skills'] ?? [];
    final String location = data?['location']?.toString().trim() ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black87),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: skills.isNotEmpty
                  ? skills.map((skill) {
                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: Chip(
                    label: Text(skill.toString()),
                    backgroundColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }).toList()
                  : [
                Chip(
                  label: const Text('No skills listed'),
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              const Text("Payment verified", style: TextStyle(fontSize: 12)),
              const Spacer(),
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

}
