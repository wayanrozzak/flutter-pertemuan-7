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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Kos'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _kos == null
              ? const Center(child: Text('Data kos tidak ditemukan'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  child: const Icon(
                                    Icons.home_work_rounded,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _kos!.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${_formatRupiah(_kos!.price)} / bulan',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            const Text(
                              'Alamat Lengkap',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _kos!.address.isNotEmpty
                                        ? _kos!.address
                                        : 'Alamat belum dicantumkan',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'ID Pemilik',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              _kos!.ownerId,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
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
