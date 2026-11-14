
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/course_summary_card.dart';
import '../widgets/role_guard.dart';

import 'course_detail_page.dart';
import 'course_form_page.dart';
import 'favorites_page.dart';

class CourseHomePage extends StatefulWidget {
  const CourseHomePage({super.key});

  @override
  State<CourseHomePage> createState() => _CourseHomePageState();
}

class _CourseHomePageState extends State<CourseHomePage> {
  int _selectedIndex = 0;
  bool _isLoggingOut = false;

  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthService().signOut();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal logout: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _logout();
    }
  }

  Widget _profileInfo(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value.isEmpty ? '-' : value,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Gagal memuat profil: ${snapshot.error}',
              ),
            ),
          );
        }

        final profile = snapshot.data;

        if (profile == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text('Data profil tidak ditemukan.'),
            ),
          );
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Profil Pengguna',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _profileInfo(
                  Icons.person,
                  'Nama',
                  profile.name,
                ),
                const SizedBox(height: 8),
                _profileInfo(
                  Icons.email,
                  'Email',
                  profile.email,
                ),
                const SizedBox(height: 8),
                _profileInfo(
                  Icons.admin_panel_settings,
                  'Role',
                  profile.role.toUpperCase(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildCoursePage(context, provider),
          const FavoritesPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePage(
    BuildContext context,
    CourseProvider provider,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Course Explorer'),
        actions: [
          // Tombol tambah hanya untuk owner dan admin.
          FutureBuilder<UserProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.hasError) {
                return const SizedBox.shrink();
              }

              final profile = snapshot.data!;

              return RoleGuard(
                role: profile.role,
                allowed: const ['owner', 'admin'],
                child: IconButton(
                  tooltip: 'Tambah Course',
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CourseFormPage(),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          IconButton(
            tooltip: 'Logout',
            onPressed: _isLoggingOut ? null : _confirmLogout,
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: provider.loadCourses,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Flutter UI Fundamentals',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Jelajahi materi pembelajaran Flutter.',
            ),
            const SizedBox(height: 16),

            _buildProfileCard(),

            const SizedBox(height: 16),

            const Text(
              'Course Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: CourseSummaryCard(
                    title: 'Total Courses',
                    value: provider.courses.length.toString(),
                    icon: Icons.menu_book,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CourseSummaryCard(
                    title: 'Favorites',
                    value: provider.favoriteCourses.length.toString(),
                    icon: Icons.favorite,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'Daftar Course',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (provider.error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              )
            else if (provider.courses.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Belum ada course yang tersedia.',
                  ),
                ),
              )
            else
              ...provider.courses.map(
                (course) => _buildCourseCard(
                  context,
                  provider,
                  course,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    CourseProvider provider,
    Course course,
  ) {
    final isFavorite = provider.isFavorite(course.code);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            course.code.isNotEmpty
                ? course.code[0].toUpperCase()
                : 'C',
          ),
        ),
        title: Text(course.title),
        subtitle: Text(
          '${course.code} • ${course.credits} SKS • ${course.status}',
        ),
        trailing: IconButton(
          tooltip: isFavorite
              ? 'Hapus dari favorit'
              : 'Tambah ke favorit',
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            provider.toggleFavorite(course.code);
          },
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(course: course),
            ),
          );
        },
      ),
    );
  }
}
