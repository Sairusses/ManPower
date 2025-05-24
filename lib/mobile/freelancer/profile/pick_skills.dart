import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../components/skills.dart';

class PickSkills extends StatefulWidget {
  const PickSkills({super.key});

  @override
  State<PickSkills> createState() => _PickSkillsState();
}

class _PickSkillsState extends State<PickSkills> {
  final TextEditingController _searchController = TextEditingController();

  void _toggleSkill(Skill skill) {
    setState(() {
      skill.isSelected = !skill.isSelected;
    });
  }

  Future<void> _saveSelectedSkills() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final selectedSkills = skillList
        .where((skill) => skill.isSelected)
        .map((skill) => skill.name)
        .toList();

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'skills': selectedSkills},
        SetOptions(merge: true),
      );
      if(context.mounted){
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Skills saved successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving skills: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final filteredSkills = skillList
        .where((skill) =>
        skill.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What are the main skills for your work?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search or type skills (e.g. Flutter, Firebase)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Add 3–5 relevant skills:"),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: SingleChildScrollView(
                controller: ScrollController(),
                child: Wrap(
                  spacing: 2,
                  children: filteredSkills.map((skill) {
                    return ChoiceChip(
                      backgroundColor: Colors.white,
                      label: Text(skill.name),
                      selected: skill.isSelected,
                      selectedColor: Colors.blue.shade50,
                      onSelected: (_) => _toggleSkill(skill),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveSelectedSkills,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save Skills'),
            ),
          ],
        ),
      ),
    );
  }
}