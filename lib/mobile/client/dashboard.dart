import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final User? user = FirebaseAuth.instance.currentUser;
    final DateTime now = DateTime.now();
    final weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    String date = "${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}";

    final List<Map<String, dynamic>> summaryCards = [
      {'title': 'Active Projects', 'value': '0', 'icon': Icons.work_outline},
      {'title': 'Employees', 'value': '0', 'icon': Icons.person_outline},
      {'title': 'Candidates', 'value': '0', 'icon': Icons.people_alt_outlined},
      {'title': 'Spent', 'value': r'0', 'icon': Icons.attach_money},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: 0, // hidden
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
        builder: (context, snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.blue,));
          }
          String username = snapshot.data!['username'] ?? 'User';
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 80,
                  child: Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[400],
                              ),
                            ),
                            Text(
                              'Hi, $username',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                    ),
                  ),
                ),
                // Summary Cards Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2,
                  children: summaryCards.map((card) {
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: .5, blurStyle: BlurStyle.normal)],
                      ),
                      child: Row(
                        children: [
                          Icon(card['icon'], size: 30, color: Colors.blue),
                          const SizedBox(width: 20),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(card['value'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              Text(card['title'], style: const TextStyle(fontSize: 12, color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Jobs Analytics',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              _buildLegendItem(color: Colors.blue, label: 'Applied'),
                              const SizedBox(width: 10),
                              _buildLegendItem(color: Colors.green, label: 'Qualified'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 200,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BarChart(
                            BarChartData(
                              barGroups: [
                                for (int i = 0; i < 12; i++)
                                  BarChartGroupData(x: i, barRods: [
                                    BarChartRodData(toY: (i + 1) * 2.0, color: Colors.blue, width: 8),
                                    BarChartRodData(toY: (i + 1) * 2.0, color: Colors.green, width: 8),
                                  ]),
                              ],
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
                                      return Text(months[value.toInt()], style: const TextStyle(fontSize: 10));
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              gridData: FlGridData(show: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Recent Applicant', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('See All', style: TextStyle(color: Colors.blue)),
                  ],
                ),

                SizedBox(
                  height: 60,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      ApplicantCard(name: 'Daisy Schoen', location: 'Florence, SC'),
                      SizedBox(width: 10),
                      ApplicantCard(name: 'Ronald Ross', location: 'Oxford, UK'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },

      ),
    );
  }
}

class ApplicantCard extends StatelessWidget {
  final String name;
  final String location;

  const ApplicantCard({super.key, required this.name, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.pinkAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(location, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}
