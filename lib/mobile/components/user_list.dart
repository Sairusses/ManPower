import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messages.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Select User to Chat"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (val) {
                setState(() {
                  _searchTerm = val.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.blue,));
                }

                // Filter users excluding current user and by search term
                final users = snapshot.data!.docs.where((doc) {
                  if (doc.id == currentUser.uid) return false;
                  final username = (doc.data() as Map<String, dynamic>)['username'] ?? '';
                  return username.toLowerCase().contains(_searchTerm);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users found."));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final doc = users[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String peerId = doc.id;
                    final String username = data['username'] ?? 'Unknown';

                    return FutureBuilder<QuerySnapshot>(
                      future: _getLastMessage(currentUser.uid, peerId),
                      builder: (context, messageSnapshot) {
                        String subtitle = 'Say hi to $username';
                        if (messageSnapshot.hasData && messageSnapshot.data!.docs.isNotEmpty) {
                          final lastMsg = messageSnapshot.data!.docs.first;
                          subtitle = lastMsg['text'] ?? '';
                        }

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey, width: .5),
                          ),
                          child: ListTile(
                            title: Text(username),
                            subtitle: Text(
                              subtitle,
                              style: TextStyle(color: Colors.grey[600]),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            trailing: const Icon(Icons.chat),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Messages(peerId: peerId),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        );
                      },
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

  Future<QuerySnapshot> _getLastMessage(String uid1, String uid2) {
    final chatId = [uid1, uid2]..sort();
    return FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId.join('_'))
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
  }
}
