import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'chatscreen.dart';

class Messages extends StatelessWidget {
  const Messages({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUser?.uid)
            .orderBy('lastUpdated', descending: true)
            .snapshots(),
        builder: (context, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue));
          }

          final chatDocs = chatSnapshot.data?.docs ?? [];

          if (chatDocs.isEmpty) {
            return Container(
              color: Colors.grey[50],
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.message, color: Colors.grey, size: 80,),
                    SizedBox(height: 12,),
                    Text('No conversations yet.'),
                ],
              )),
            );
          }

          return ListView.builder(
            itemCount: chatDocs.length,
            itemBuilder: (context, index) {
              final chatData = chatDocs[index].data() as Map<String, dynamic>;
              final chatId = chatDocs[index].id;
              final otherUserId = (chatData['participants'] as List)
                  .firstWhere((id) => id != currentUser?.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text('Loading user...'));
                  }

                  final userData =
                  userSnapshot.data?.data() as Map<String, dynamic>;

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .limit(1)
                        .snapshots(),
                    builder: (context, messageSnapshot) {
                      String lastMessage = 'No messages yet';
                      String time = '';

                      if (messageSnapshot.hasData &&
                          messageSnapshot.data!.docs.isNotEmpty) {
                        final messageData = messageSnapshot.data!.docs.first
                            .data() as Map<String, dynamic>;
                        lastMessage = messageData['text'] ?? '';
                        final timestamp = messageData['timestamp'] as Timestamp;
                        time = DateFormat('hh:mm a').format(timestamp.toDate());
                      }

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(userData['profilePic']),
                        ),
                        title: Text(userData['name']),
                        subtitle: Text(lastMessage, maxLines: 1),
                        trailing: Text(time),
                        onTap: () {
                          // Navigate to chat screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatId: chatId,
                                otherUserId: otherUserId,
                                otherUserName: userData['name'],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
