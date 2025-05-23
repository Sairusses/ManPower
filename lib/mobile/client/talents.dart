import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Talents extends StatefulWidget {
  const Talents({super.key});

  @override
  State<Talents> createState() => _TalentsState();
}

class _TalentsState extends State<Talents> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Find Freelancers'),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey[300], height: 1),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search freelancers by name, skill, or title',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.blue),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          // 👥 Freelancers List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'freelancer')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue));
                }

                final docs = snapshot.data?.docs ?? [];
                final filteredFreelancers = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['username'] ?? '').toString().toLowerCase();
                  final title = (data['title'] ?? '').toString().toLowerCase();
                  final description = (data['description'] ?? '').toString().toLowerCase();
                  return name.contains(searchQuery) ||
                      title.contains(searchQuery) ||
                      description.contains(searchQuery);
                }).toList();

                if (filteredFreelancers.isEmpty) {
                  return const Center(child: Text("No freelancers found."));
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filteredFreelancers.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final data = filteredFreelancers[index].data() as Map<String, dynamic>;

                    // ⛑ Use placeholders to prevent null errors
                    final name = data['username']?.toString().trim().isNotEmpty == true
                        ? data['username']
                        : 'Unnamed Freelancer';
                    final title = data['title'] ?? 'No Title';
                    final description = data['description'] ?? 'No description provided.';
                    final rate = data['rate'] != null ? '\$${data['rate']}/hr' : 'Rate not set';
                    final location = data['location'] ?? 'Unknown location';

                    return _buildFreelancerCard(
                      name: name,
                      title: title,
                      description: description,
                      rate: rate,
                      location: location,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Freelancer Card Widget
  Widget _buildFreelancerCard({
    required String name,
    required String title,
    required String description,
    required String rate,
    required String location,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 Avatar Placeholder
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),

          // 📋 Freelancer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),

                // 💰 Rate & 📍 Location
                Wrap(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.attach_money, size: 18, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(rate, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
