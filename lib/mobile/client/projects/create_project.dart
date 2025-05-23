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

  final List<Widget> _pages = const [
    PageOne(),
    PageTwo(),
    PageThree(),
    PageFour(),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }else if(_currentPage == _pages.length - 1 ){
      Navigator.of(context).pop();
      // TODO: Create project
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  Widget build(BuildContext context) {
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
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) => _pages[index],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _prevPage,
                child: const Text('Back')
              ),
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(_currentPage == _pages.length - 1 ? 'Finish' : 'Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageOne extends StatelessWidget {
  const PageOne({super.key});

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
          const TextField(
            decoration: InputDecoration(
              labelText: 'Project Title',
              border: OutlineInputBorder(),
              focusColor: Colors.blue
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
  const PageTwo({super.key});

  @override
  State<PageTwo> createState() => _PageTwoState();
}

class _PageTwoState extends State<PageTwo> {
  final TextEditingController _searchController = TextEditingController();

  void _toggleSkill(Skill skill) {
    setState(() {
      skill.isSelected = !skill.isSelected;
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
  const PageThree({super.key});

  @override
  State<PageThree> createState() => _PageThreeState();
}

class _PageThreeState extends State<PageThree> {
  String? _selectedOption;

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
              controller: TextEditingController(),
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
              controller: TextEditingController(),
              labelText: 'Fixed Price (USD)',
              hint: 'Add a fixed price',
              textInputType: TextInputType.number,
              prefixIcon: Icon(Icons.attach_money),
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              controller: TextEditingController(),
              labelText: 'Description',
              hint: 'Describe the scope or deliverables',
              maxLines: 5,
              prefixIcon: null,
              suffixIcon: null,
            )
          ],
        ],
      ),
    );
  }
}


class PageFour extends StatelessWidget {
  const PageFour({super.key});

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
            controller: TextEditingController(),
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

