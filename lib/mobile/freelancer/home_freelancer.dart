import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Pages
import '../components/messages.dart';
import 'jobs.dart';
import 'contracts.dart';
import 'profile/profile.dart';
import 'proposals.dart';

class HomeFreelancer extends StatefulWidget {
  const HomeFreelancer({super.key});

  @override
  State<HomeFreelancer> createState() => HomeFreelancerState();
}

class HomeFreelancerState extends State<HomeFreelancer> {
  int currentPageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  void onDestinationSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        indicatorColor: Colors.transparent,
        backgroundColor: Colors.grey[50],
        animationDuration: const Duration(milliseconds: 700),
        onDestinationSelected: onDestinationSelected,
        height: MediaQuery.of(context).size.height * 0.1,
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.search_circle_fill, color: Colors.blue),
            icon: Icon(CupertinoIcons.search_circle),
            label: 'Jobs',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.edit_document, color: Colors.blue),
            icon: Icon(Icons.edit_document),
            label: 'Proposals',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.doc_append, color: Colors.blue),
            icon: Icon(CupertinoIcons.doc_append),
            label: 'Contracts',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.chat_bubble_fill, color: Colors.blue),
            icon: Icon(CupertinoIcons.chat_bubble),
            label: 'Messages',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person, color: Colors.blue),
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: onPageChanged,
        children: const [
          Jobs(),
          Proposals(),
          Contracts(),
          Messages(),
          Profile(),
        ],
      ),
    );
  }
}