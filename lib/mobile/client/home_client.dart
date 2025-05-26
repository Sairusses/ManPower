import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//Pages
import '../components/user_list.dart';
import 'dashboard.dart';
import 'talents.dart';
import 'profile/profile.dart';
import 'package:manpower/mobile/client/projects/projects.dart';

class HomeClient extends StatefulWidget {
  const HomeClient({super.key});

  @override
  State<HomeClient> createState() => HomeClientState();
}

class HomeClientState extends State<HomeClient> {
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
            selectedIcon: Icon(Icons.home, color: Colors.blue,),
            icon: Icon(Icons.home_outlined),
            label: 'Dashboard',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.business_center, color: Colors.blue),
            icon: Icon(Icons.business_center_outlined),
            label: 'Principals',
          ),
          NavigationDestination(
            selectedIcon: Icon(CupertinoIcons.search_circle_fill, color: Colors.blue),
            icon: Icon(CupertinoIcons.search_circle),
            label: 'Talents',
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
          Dashboard(),
          Projects(),
          Talents(),
          UserList(),
          Profile(),
        ],
      ),
    );
  }
}