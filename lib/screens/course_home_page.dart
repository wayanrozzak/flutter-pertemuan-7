
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/course.dart';
import '../providers/course_provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/course_summary_card.dart';

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

  // Mengambil profil pengguna dari Supabase
  late final Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
  }

  // Widget untuk menampilkan profil pengguna
  Widget _buildProfileCard() {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.error_outline,
                color: Colors.red,
              ),
              title: const Text('Gagal memuat profil'),
              subtitle: Text(
                snapshot.hasError
                    ? 'Terjadi kesalahan saat mengambil profil.'
                    : 'Data profil tidak ditemukan.',
              ),
            ),
          );
        }

        final profile = snapshot.data!;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    'Profil Pengguna',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: const Text('Nama'),
                  subtitle: Text(
                    profile.name.isEmpty
                        ? '-'
                        : profile.name,
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(profile.email),
                ),

                ListTile(
                  leading: const Icon(
                    Icons.admin_panel_settings_outlined,
                  ),
                  title: const Text('Role'),
                  subtitle: Text(
                    profile.role.toUpperCase(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Fungsi logout
  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await AuthService().signOut();

      // AuthGate akan otomatis mengarahkan pengguna
      // kembali ke LoginPage setelah session berakhir.
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout gagal: $e'),
          backgroundColor: Colors.red,
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

  // Dialog konfirmasi logout
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun?',
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    final pages = [
      _buildCoursePage(context, provider),
      const FavoritesPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
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
            label: 'Mata Kuliah',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }

  // Halaman utama Course Explorer
  Widget _buildCoursePage(
    BuildContext context,
    CourseProvider courseProvider,
  ) {
    final courses = courseProvider.courses;
    final favorites = courseProvider.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Explorer'),
        centerTitle: true,
        actions: [
          IconButton(
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
          IconButton(
            tooltip: 'Logout',
            icon: _isLoggingOut
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.logout),
            onPressed: _isLoggingOut ? null : _confirmLogout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<CourseProvider>().loadCourses(),
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
            const SizedBox(height: 8),

            const Text('Wayan Muizul Rozzak'),
            const Text('NIM: 2415051111'),

            const SizedBox(height: 12),

            // Profil pengguna: Nama, Email, dan Role
            _buildProfileCard(),

            const SizedBox(height: 8),

            const Text(
              'Tahap 12: Refactoring Struktur Folder',
              style: TextStyle(
                color: Colors.indigo,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 20),

            // Ringkasan mata kuliah dan favorit
            Row(
              children: [
                Expanded(
                  child: CourseSummaryCard(
                    title: 'Total Mata Kuliah',
                    value: '${courses.length}',
                    icon: Icons.school,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CourseSummaryCard(
                    title: 'Mata Kuliah Favorit',
                    value: '${favorites.length}',
                    icon: Icons.favorite,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Status data mata kuliah
            if (courseProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (courseProvider.error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Gagal memuat data mata kuliah',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(courseProvider.error!),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<CourseProvider>()
                              .loadCourses();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
            else if (courses.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'Belum ada data mata kuliah.',
                  ),
                ),
              )
            else ...[
              Text(
                'Daftar Mata Kuliah (${courses.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),

              ...courses.map(
                (course) => _buildCourseCard(
                  context,
                  course,
                  courseProvider,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget kartu mata kuliah
  Widget _buildCourseCard(
    BuildContext context,
    Course course,
    CourseProvider provider,
  ) {
    final isFavorite = provider.isFavorite(course.code);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(course.code),
        ),
        title: Text(
          course.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Kode: ${course.code}\n'
          'SKS: ${course.credits} • Status: ${course.status}',
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailPage(course: course),
            ),
          );
        },
        trailing: IconButton(
          tooltip: isFavorite
              ? 'Hapus dari favorit'
              : 'Tambahkan ke favorit',
          icon: Icon(
            isFavorite
                ? Icons.favorite
                : Icons.favorite_border,
            color: isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            provider.toggleFavorite(course.code);
          },
        ),
      ),
    );
  }
}
