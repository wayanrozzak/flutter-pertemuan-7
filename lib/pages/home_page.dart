import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/kos.dart';
import '../services/auth_service.dart';
import '../services/kos_service.dart';
import '../services/notification_service.dart';
import '../services/profile_service.dart';
import '../widgets/role_guard.dart';
import 'kos_detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _kosService = KosService();
  late final Future<UserProfile?> _profileFuture;
  late Future<List<KosModel>> _kosListFuture;

  bool _isLoggingOut = false;
  int _tabIndex = 0; // 0: Semua Kos, 1: Kos Saya

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService().getMyProfile();
    _loadKosList();
    NotificationService.instance.requestPermission();
  }

  void _loadKosList() {
    setState(() {
      _kosListFuture = _tabIndex == 1
          ? _kosService.fetchMyKos()
          : _kosService.fetchAll();
    });
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
  }

  String _formatRupiah(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  void _showAddEditKosDialog({KosModel? kos}) {
    final nameC = TextEditingController(text: kos?.name ?? '');
    final addressC = TextEditingController(text: kos?.address ?? '');
    final priceC =
        TextEditingController(text: kos != null ? kos.price.toString() : '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        bool saving = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(kos == null ? 'Tambah Kos Baru' : 'Edit Data Kos'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameC,
                        decoration:
                            const InputDecoration(labelText: 'Nama Kos'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama kos wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: addressC,
                        decoration:
                            const InputDecoration(labelText: 'Alamat Kos'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Alamat wajib diisi'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: priceC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Harga / Bulan (Rp)',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Harga wajib diisi';
                          }
                          if (int.tryParse(v.trim()) == null) {
                            return 'Harga harus berupa angka';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.of(ctx).pop(),
                  child: const Text('Batal'),
                ),
                FilledButton(
                  onPressed: saving
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setDialogState(() => saving = true);

                          final name = nameC.text.trim();
                          final address = addressC.text.trim();
                          final price = int.parse(priceC.text.trim());

                          try {
                            if (kos == null) {
                              await _kosService.add(
                                name: name,
                                address: address,
                                price: price,
                              );
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Kos berhasil ditambahkan')),
                              );
                            } else {
                              final ok = await _kosService.update(kos.id, {
                                'name': name,
                                'address': address,
                                'price': price,
                              });
                              if (!ctx.mounted) return;
                              Navigator.of(ctx).pop();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(ok
                                      ? 'Kos berhasil diperbarui'
                                      : 'Gagal memperbarui (Akses ditolak RLS)'),
                                ),
                              );
                            }
                            _loadKosList();
                          } catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text('Terjadi error: $e')),
                              );
                            }
                          } finally {
                            if (ctx.mounted) {
                              setDialogState(() => saving = false);
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(kos == null ? 'Simpan' : 'Perbarui'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteKos(KosModel kos) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Kos'),
        content: Text('Yakin ingin menghapus "${kos.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ok = await _kosService.delete(kos.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? 'Kos berhasil dihapus'
            : 'Gagal menghapus (Ditolak oleh policy RLS)'),
      ),
    );
    _loadKosList();
  }

  @override
  Widget build(BuildContext context) {
    final myUid = Supabase.instance.client.auth.currentUser?.id ?? '';

    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final profile = snap.data;
        final role = profile?.role ?? 'seeker';

        return Scaffold(
          appBar: AppBar(
            title: Text('KosFinder (${role.toUpperCase()})'),
            actions: [
              IconButton(
                tooltip: 'Logout',
                icon: _isLoggingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                onPressed: _isLoggingOut ? null : _logout,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => _loadKosList(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Kartu Profil Pengguna
                Card(
                  elevation: 0,
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withAlpha(70),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha(50),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              child: const Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    profile?.name.isNotEmpty == true
                                        ? profile!.name
                                        : 'Pengguna KosFinder',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    profile?.email ?? '-',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(
                                role.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Navigasi Filter untuk Owner/Admin
                if (role == 'owner' || role == 'admin')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          icon: Icon(Icons.list),
                          label: Text('Semua Kos'),
                        ),
                        ButtonSegment(
                          value: 1,
                          icon: Icon(Icons.home_work),
                          label: Text('Kos Milik Saya'),
                        ),
                      ],
                      selected: {_tabIndex},
                      onSelectionChanged: (set) {
                        setState(() {
                          _tabIndex = set.first;
                          _loadKosList();
                        });
                      },
                    ),
                  ),

                // Header Daftar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _tabIndex == 1 ? 'Kos Milik Saya' : 'Daftar Kos Tersedia',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    IconButton(
                      tooltip: 'Muat ulang',
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadKosList,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // List Kos
                FutureBuilder<List<KosModel>>(
                  future: _kosListFuture,
                  builder: (context, kosSnap) {
                    if (kosSnap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (kosSnap.hasError) {
                      return Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 40),
                              const SizedBox(height: 8),
                              Text('Gagal memuat data kos: ${kosSnap.error}'),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: _loadKosList,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final items = kosSnap.data ?? [];

                    if (items.isEmpty) {
                      return Card(
                        elevation: 0,
                        color: Colors.grey.shade100,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                const Icon(Icons.home,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  _tabIndex == 1
                                      ? 'Anda belum memiliki kos terdaftar'
                                      : 'Belum ada data kos tersedia',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final kos = items[i];
                        final isMine = (kos.ownerId == myUid) || role == 'admin';

                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: const Icon(Icons.apartment),
                            ),
                            title: Text(
                              kos.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(kos.address),
                                const SizedBox(height: 4),
                                Text(
                                  _formatRupiah(kos.price),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: isMine
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit,
                                            color: Colors.indigo),
                                        tooltip: 'Edit Kos',
                                        onPressed: () =>
                                            _showAddEditKosDialog(kos: kos),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        tooltip: 'Hapus Kos',
                                        onPressed: () => _deleteKos(kos),
                                      ),
                                    ],
                                  )
                                : const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => KosDetailPage(
                                    kosId: kos.id,
                                    initialKos: kos,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          // Tombol Tambah Kos diproteksi RoleGuard (hanya owner & admin)
          floatingActionButton: RoleGuard(
            role: role,
            allowed: const ['owner', 'admin'],
            child: FloatingActionButton.extended(
              onPressed: () => _showAddEditKosDialog(),
              icon: const Icon(Icons.add_home_rounded),
              label: const Text('Tambah Kos'),
            ),
          ),
        );
      },
    );
  }
}
