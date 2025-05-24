import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:manpower/mobile/components/custom_text_form_field.dart';

import '../../components/skills.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hourlyRateController = TextEditingController();
  final TextEditingController fixedPriceController = TextEditingController();
  List<String> selectedSkills = [];
  String paymentType = '';

  Future<void> _nextPage() async {
    switch(_currentPage){
      case 0:
        if(titleController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a title')),
          );
          return;
        }else{
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
          break;
        }
      case 1:
        if(selectedSkills.isEmpty){
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select at least one skill')),
          );
          return;
        }else{
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
          break;
        }
      case 2:
        if (paymentType == 'fixed') {
          if (fixedPriceController.text.isEmpty ||
              double.tryParse(fixedPriceController.text) == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a valid fixed price')),
            );
            return;
          }
        } else if (paymentType == 'hourly') {
          if (hourlyRateController.text.isEmpty ||
              double.tryParse(hourlyRateController.text) == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a valid hourly rate')),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a payment type')),
          );
          return;
        }
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
        break;
      case 3:
        final uid = FirebaseAuth.instance.currentUser?.uid;

        if (uid == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
          return;
        }

        if (descriptionController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter a project description')),
          );
          return;
        }

        final projectData = {
          'client': uid,
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'skills': selectedSkills,
          'paymentType': paymentType,
          'hourlyRate': double.tryParse(hourlyRateController.text.trim()) ?? 0.0,
          'fixedPrice': double.tryParse(fixedPriceController.text.trim()) ?? 0.0,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('projects')
            .add(projectData);
        await FirebaseFirestore.instance
            .collection('jobs')
            .add(projectData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project created successfully')),
        );
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        break;
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      PageOne(titleController: titleController),
      PageTwo(
        selectedSkills: selectedSkills,
        onSkillsChanged: (List<String> value) {
          selectedSkills = value;
        }
      ),
      PageThree(
        onPaymentType: (String value) {
          paymentType = value;
        },
        hourlyRateController: hourlyRateController,
        fixedPriceController: fixedPriceController,
      ),
      PageFour(descriptionController: descriptionController,),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Project'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[300],
            height: 1.0,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) => pages[index],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _currentPage > 0 ? _prevPage : null, // Disable when on first page
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentPage > 0 ? Colors.blue : Colors.grey[300],
                foregroundColor: _currentPage > 0 ? Colors.white : Colors.grey[600],
              ),
              child: const Text('Back'),
            ),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentPage == pages.length - 1 ? 'Finish' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  final TextEditingController titleController;
  const PageOne({super.key, required this.titleController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("What's the title of your project?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("A clear title helps attract the right talent."),
          const SizedBox(height: 12),
          TextField(
            cursorColor: Colors.blue,
            controller: titleController,
            decoration: const InputDecoration(
              labelText: 'Project Title',
              labelStyle: TextStyle(color: Colors.black),
              border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54)),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Examples: Build a mobile app for my business, Redesign a website, Write SEO blog posts")
        ],
      ),
    );
  }
}

class PageTwo extends StatefulWidget {
  final List<String> selectedSkills;
  final ValueChanged<List<String>> onSkillsChanged;
  const PageTwo({super.key, required this.selectedSkills, required this.onSkillsChanged});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final TextEditingController _searchController = TextEditingController();

  void _toggleSkill(Skill skill) {
    setState(() {
      skill.isSelected = !skill.isSelected;
      widget.onSkillsChanged(skillList.where((skill) => skill.isSelected).map((skill) => skill.name).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredSkills = skillList
        .where((skill) =>
        skill.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
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
        ],
      ),
    );
  }
}

class PageThree extends StatefulWidget {
  final ValueChanged<String> onPaymentType;
  final TextEditingController hourlyRateController;
  final TextEditingController fixedPriceController;
  const PageThree({super.key, required this.hourlyRateController, required this.fixedPriceController, required this.onPaymentType});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  String? _selectedOption;

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
      widget.onPaymentType(_selectedOption = option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tell us about your budget", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Select how you'd like to pay for this project."),
          const SizedBox(height: 20),

          // Hourly Rate Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: _selectedOption == 'hourly' ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.access_time, color: _selectedOption == 'hourly' ? Colors.blue : null),
              title: const Text("Hourly Rate"),
              subtitle: const Text("Pay by the hour for flexible work"),
              trailing: Icon(
                _selectedOption == 'hourly' ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _selectedOption == 'hourly' ? Colors.blue : null,
              ),
              onTap: () => _selectOption('hourly'),
            ),
          ),

          const SizedBox(height: 10),

          // Fixed Price Card
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: _selectedOption == 'fixed' ? Colors.blue : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(Icons.price_change, color: _selectedOption == 'fixed' ? Colors.blue : null),
              title: const Text("Fixed Price"),
              subtitle: const Text("Agree on a price upfront"),
              trailing: Icon(
                _selectedOption == 'fixed' ? Icons.radio_button_checked : Icons.radio_button_off,
                color: _selectedOption == 'fixed' ? Colors.blue : null,
              ),
              onTap: () => _selectOption('fixed'),
            ),
          ),

          const SizedBox(height: 20),

          if (_selectedOption == 'hourly') ...[
            const Text("Set your hourly rate", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: widget.hourlyRateController,
              labelText: 'Hourly Rate (USD)',
              hint: 'Add a hourly rate',
              textInputType: TextInputType.number,
              prefixIcon: Icon(Icons.attach_money),
            ),
          ],

          if (_selectedOption == 'fixed') ...[
            const Text("Set a fixed price for the whole project", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: widget.fixedPriceController,
              labelText: 'Fixed Price (USD)',
              hint: 'Add a fixed price',
              textInputType: TextInputType.number,
              prefixIcon: Icon(Icons.attach_money),
            ),
          ],
        ],
      ),
    );
  }
}

class PageFour extends StatelessWidget {
  final TextEditingController descriptionController;
  const PageFour({super.key, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Describe what you need", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text("Tell us everything the freelancer needs to know to get started:"),
          const SizedBox(height: 12),
          const Text("• What is the purpose of this project?"),
          const Text("• What are the deliverables?"),
          const Text("• Are there any deadlines or specific milestones?"),
          const SizedBox(height: 16),
          CustomTextFormField(
            controller: descriptionController,
            labelText: 'Description',
            hint: 'Project description',
            maxLines: 5,
            prefixIcon: null,
            suffixIcon: null,
          ),
          const SizedBox(height: 16),

          // File Upload Placeholder Button
          Center(
            child: OutlinedButton.icon(
              onPressed: () {
                // Placeholder: Implement file picker logic later
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload document button pressed')),
                );
              },
              icon: const Icon(Icons.upload_file, color: Colors.black),
              label: const Text(
                "Upload Supporting Document",
                style: TextStyle(color: Colors.black),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black),
              ),
            ),
          )

        ],
      ),
    );
  }
}

