import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/photo_codec.dart';
import '../../core/widgets/photo_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/journal_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';

/// Tambah (entryId == null) atau edit catatan jurnal.
/// Foto dikompres lalu disimpan sebagai Base64 di Firestore (bukan Firebase Storage).
class JournalFormScreen extends ConsumerStatefulWidget {
  const JournalFormScreen({super.key, this.entryId});
  final String? entryId;
  @override
  ConsumerState<JournalFormScreen> createState() => _JournalFormScreenState();
}

class _JournalFormScreenState extends ConsumerState<JournalFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'rumah';
  Uint8List? _newPhoto;
  bool _removePhoto = false;
  bool _processing = false;
  bool _saving = false;
  bool _filled = false;
  JournalModel? _existing;

  bool get _editing => widget.entryId != null;

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  void _snack(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  void _fill(List<JournalModel> list) {
    if (_filled || !_editing) return;
    final i = list.indexWhere((e) => e.id == widget.entryId);
    if (i < 0) return;
    _filled = true;
    _existing = list[i];
    _title.text = _existing!.title;
    _desc.text = _existing!.description;
    _category = _existing!.category;
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final x = await ImagePicker().pickImage(source: source, imageQuality: 80, maxWidth: 1200);
      if (x == null) return;
      setState(() => _processing = true);
      final bytes = await PhotoCodec.compress(await x.readAsBytes());
      if (mounted) {
        setState(() {
          _newPhoto = bytes;
          _removePhoto = false;
        });
      }
    } on PhotoTooLargeException catch (e) {
      _snack(e.toString());
    } catch (_) {
      _snack('Foto tidak bisa diproses. Periksa izin galeri/kamera atau coba foto lain.');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _choose() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: AppColors.terracotta),
              title: const Text('Pilih dari galeri', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.terracotta),
              title: const Text('Ambil dengan kamera', style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(ctx);
                _pick(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      String? photo = _existing?.imageBase64;
      if (_newPhoto != null) {
        photo = PhotoCodec.encode(_newPhoto!);
      } else if (_removePhoto) {
        photo = null;
      }
      final svc = ref.read(journalServiceProvider);
      if (_editing) {
        await svc.update(
          id: _existing!.id,
          title: _title.text.trim(),
          category: _category,
          description: _desc.text.trim(),
          imageBase64: photo,
        );
      } else {
        await svc.create(
          id: svc.newId(),
          uid: user.uid,
          title: _title.text.trim(),
          category: _category,
          description: _desc.text.trim(),
          imageBase64: photo,
        );
      }
      if (mounted) {
        _snack(_editing ? 'Catatan diperbarui.' : 'Catatan tersimpan.');
        context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Gagal menyimpan. Periksa koneksi lalu coba lagi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(journalProvider).valueOrNull;
    if (list != null) _fill(list);
    final remote = !_removePhoto && _newPhoto == null ? _existing?.imageBase64 : null;
    final hasPhoto = _newPhoto != null || remote != null;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Catatan' : 'Catatan Baru')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          GestureDetector(
            onTap: (_saving || _processing) ? null : _choose,
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: _processing
                    ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                    : _newPhoto != null
                        ? Image.memory(_newPhoto!, fit: BoxFit.cover)
                        : remote != null
                            ? Base64Image(remote)
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.add_photo_alternate_rounded,
                                      size: 44, color: AppColors.terracotta),
                                  const SizedBox(height: 8),
                                  Text('Ketuk untuk menambah foto',
                                      style: AppTheme.heading(15, color: AppColors.brownSoft)),
                                  const Text('Galeri atau kamera (opsional)',
                                      style: TextStyle(fontSize: 12, color: AppColors.brownSoft)),
                                ],
                              ),
              ),
            ),
          ),
          if (hasPhoto)
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: _saving ? null : _choose,
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Ganti foto'),
                  ),
                  TextButton.icon(
                    onPressed: _saving
                        ? null
                        : () => setState(() {
                              _newPhoto = null;
                              _removePhoto = true;
                            }),
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    label: const Text('Hapus foto', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(top: 2, bottom: 10),
            child: Text(
              'Foto dikompres lalu disimpan sebagai Base64 di Firestore (bukan Firebase Storage).',
              style: TextStyle(fontSize: 11, color: AppColors.brownSoft),
            ),
          ),
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 60,
                  enabled: !_saving,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Judul wajib diisi';
                    if (t.length < 3) return 'Judul minimal 3 karakter';
                    return null;
                  },
                  decoration: const InputDecoration(
                      labelText: 'Judul', prefixIcon: Icon(Icons.title_rounded)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                      labelText: 'Kategori', prefixIcon: Icon(Icons.category_outlined)),
                  items: [
                    for (final c in JournalCategory.all)
                      DropdownMenuItem(value: c.id, child: Text(c.label)),
                  ],
                  onChanged: _saving ? null : (v) => setState(() => _category = v ?? 'lainnya'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _desc,
                  minLines: 4,
                  maxLines: 8,
                  maxLength: 600,
                  enabled: !_saving,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Deskripsi wajib diisi';
                    if (t.length < 10) return 'Deskripsi minimal 10 karakter';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi / ceritamu',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(
            label: _editing ? 'Simpan Perubahan' : 'Simpan Catatan',
            icon: Icons.check_rounded,
            loading: _saving,
            onPressed: _processing ? null : _save,
          ),
        ],
      ),
    );
  }
}
