import 'package:flutter/material.dart';
import '../models/kos.dart';
import '../services/kos_service.dart';

class KosDetailPage extends StatefulWidget {
  const KosDetailPage({
    super.key,
    required this.kosId,
    this.initialKos,
  });

  final String kosId;
  final KosModel? initialKos;

  @override
  State<KosDetailPage> createState() => _KosDetailPageState();
}

class _KosDetailPageState extends State<KosDetailPage> {
  KosModel? _kos;
  bool _loading = false;
  int _activePhotoIndex = 0; // 0: Halaman, 1: Dalam Kamar

  @override
  void initState() {
    super.initState();
    _kos = widget.initialKos;
    if (_kos == null) {
      _loadKos();
    }
  }

  Future<void> _loadKos() async {
    setState(() => _loading = true);
    try {
      final list = await KosService().fetchAll();
      final found = list.firstWhere(
        (k) => k.id == widget.kosId,
        orElse: () => throw Exception('Kos tidak ditemukan'),
      );
      if (mounted) setState(() => _kos = found);
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _loading = false);
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

  Widget _buildPhotoView(String? url, String label, IconData fallbackIcon) {
    final hasUrl = url != null && url.trim().isNotEmpty;

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasUrl)
            Image.network(
              url.trim(),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  _buildPlaceholder(label, fallbackIcon),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
            )
          else
            _buildPlaceholder(label, fallbackIcon),
          Positioned(
            bottom: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(160),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label, IconData icon) {
    return Container(
      color: Colors.indigo.shade50,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 50, color: Colors.indigo.shade300),
            const SizedBox(height: 6),
            Text(
              'Foto $label Belum Diunggah',
              style: TextStyle(color: Colors.indigo.shade400, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Kos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_kos == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Kos')),
        body: const Center(child: Text('Data kos tidak ditemukan')),
      );
    }

    final kos = _kos!;
    final isKmDalam = kos.isBathroomInside;
    final facilitiesList = kos.facilities
        .split(RegExp(r'[,;\n]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(kos.name),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Galeri Foto Kos (Halaman vs Kamar)
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                icon: Icon(Icons.deck_outlined),
                label: Text('Foto Halaman'),
              ),
              ButtonSegment(
                value: 1,
                icon: Icon(Icons.bed_outlined),
                label: Text('Foto Dalam Kamar'),
              ),
            ],
            selected: {_activePhotoIndex},
            onSelectionChanged: (set) {
              setState(() => _activePhotoIndex = set.first);
            },
          ),
          const SizedBox(height: 12),

          // Tampilan Foto Aktif
          if (_activePhotoIndex == 0)
            _buildPhotoView(
              kos.yardImageUrl,
              'Halaman / Luar Kos',
              Icons.home_work_outlined,
            )
          else
            _buildPhotoView(
              kos.roomImageUrl,
              'Dalam Kamar Kos',
              Icons.bedroom_parent_outlined,
            ),

          const SizedBox(height: 16),

          // Kartu Informasi Utama & Harga
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              kos.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_formatRupiah(kos.price)} / bulan',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Badge Tipe Kamar Mandi
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isKmDalam
                              ? Colors.teal.shade50
                              : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isKmDalam
                                ? Colors.teal.shade300
                                : Colors.orange.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isKmDalam
                                  ? Icons.shower_rounded
                                  : Icons.bathtub_outlined,
                              size: 16,
                              color: isKmDalam
                                  ? Colors.teal.shade800
                                  : Colors.orange.shade800,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              kos.bathroomLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isKmDalam
                                    ? Colors.teal.shade800
                                    : Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Alamat
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.redAccent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          kos.address.isNotEmpty
                              ? kos.address
                              : 'Alamat belum dicantumkan',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Kartu Fasilitas Lengkap
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.stars_rounded, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text(
                        'Fasilitas Kos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (facilitiesList.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: facilitiesList.map((f) {
                        return Chip(
                          avatar: const Icon(Icons.check_circle_outline,
                              size: 16, color: Colors.indigo),
                          label: Text(f, style: const TextStyle(fontSize: 13)),
                          backgroundColor: Colors.indigo.shade50,
                          side: BorderSide(color: Colors.indigo.shade100),
                        );
                      }).toList(),
                    )
                  else
                    Text(
                      kos.facilities.isNotEmpty
                          ? kos.facilities
                          : 'Belum ada rincian fasilitas yang ditambahkan.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ID Pemilik
          Card(
            elevation: 0,
            color: Colors.grey.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined,
                      size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  const Text('Owner ID: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12)),
                  Expanded(
                    child: SelectableText(
                      kos.ownerId,
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
