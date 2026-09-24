import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  Map<String, dynamic>? _user;
  int _examCount = 0;
  int _userCount = 0;
  int _submissionCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _user = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final exams = await ApiService.get('/exams');
      final users = await ApiService.get('/users');
      final submissions = await ApiService.get('/submissions');
      if (mounted) {
        setState(() {
          _examCount = (exams['data'] as List?)?.length ?? 0;
          _userCount = (users['data'] as List?)?.length ?? 0;
          _submissionCount = (submissions['data'] as List?)?.length ?? 0;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${_user?['name'] ?? 'Admin'}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Admin Panel',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Statistics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Total Exams', count: _examCount, icon: Icons.quiz, color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Total Users', count: _userCount, icon: Icons.people, color: Colors.green)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Submissions', count: _submissionCount, icon: Icons.assignment_turned_in, color: Colors.orange)),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _ActionCard(
                    title: 'Manage Exams',
                    icon: Icons.library_books,
                    color: const Color(0xFF6C63FF),
                    onTap: () => Navigator.pushNamed(context, '/exam-list', arguments: _user),
                  ),
                  _ActionCard(
                    title: 'Add New Exam',
                    icon: Icons.add_circle,
                    color: Colors.green,
                    onTap: () => Navigator.pushNamed(context, '/add-exam', arguments: _user).then((_) => _loadStats()),
                  ),
                  _ActionCard(
                    title: 'Analytics',
                    icon: Icons.bar_chart,
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/analytics'),
                  ),
                  _ActionCard(
                    title: 'All Results',
                    icon: Icons.leaderboard,
                    color: Colors.purple,
                    onTap: () => Navigator.pushNamed(context, '/my-results', arguments: {'isAdmin': true}),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.count, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            Text(title, style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
