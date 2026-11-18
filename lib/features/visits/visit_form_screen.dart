import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/format.dart';
import '../../core/utils/photo_codec.dart';
import '../../core/widgets/photo_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/journal_model.dart';
import '../../models/visit_model.dart';
import '../../providers/planner_providers.dart';
import '../../providers/providers.dart';

/// Tambah (visitId == null) atau edit rencana kunjungan.
class VisitFormScreen extends ConsumerStatefulWidget {
  const VisitFormScreen({super.key, this.visitId});
  final String? visitId;
  @override
  ConsumerState<VisitFormScreen> createState() => _VisitFormScreenState();
}

class _VisitFormScreenState extends ConsumerState<VisitFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  String _category = 'rumah';
  DateTime? _date;
  bool _dateError = false;
  bool _reminderOn = true;
  Uint8List? _newPhoto;
  bool _removePhoto = false;
  bool _processing = false;
  bool _saving = false;
  bool _filled = false;
  VisitModel? _existing;

  bool get _editing => widget.visitId != null;

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  void _fill(List<VisitModel> list) {
    if (_filled || !_editing) return;
    final i = list.indexWhere((v) => v.id == widget.visitId);
    if (i < 0) return;
    _filled = true;
    _existing = list[i];
    _title.text = _existing!.title;
    _note.text = _existing!.note;
    _category = _existing!.category;
    _date = _existing!.date;
    _reminderOn = _existing!.reminderOn;
  }

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date != null && !_date!.isBefore(start) ? _date! : start,
      firstDate: _editing ? DateTime(2020) : start,
      lastDate: DateTime(today.year + 3, 12, 31),
      helpText: 'Pilih tanggal kunjungan',
    );
    if (picked != null) setState(() {
          _date = picked;
          _dateError = false;
        });
  }

  Future<void> _pickPhoto(ImageSource source) async {
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
      _snack('Foto tidak bisa diproses. Coba foto lain.');
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  void _snack(String m) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  void _choosePhoto() {
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
              title: const Text('Pilih dari galeri'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded, color: AppColors.terracotta),
              title: const Text('Ambil dengan kamera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    final ok = _form.currentState!.validate();
    if (_date == null) setState(() => _dateError = true);
    if (!ok || _date == null) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      String? photo = _existing?.photoBase64;
      if (_newPhoto != null) {
        photo = PhotoCodec.encode(_newPhoto!);
      } else if (_removePhoto) {
        photo = null;
      }
      final svc = ref.read(plannerServiceProvider);
      await svc.saveVisit(
        id: _existing?.id ?? svc.newVisitId(),
        uid: user.uid,
        isNew: !_editing,
        title: _title.text.trim(),
        category: _category,
        date: _date!,
        note: _note.text.trim(),
        reminderOn: _reminderOn,
        visited: _existing?.visited ?? false,
        photoBase64: photo,
      );
      if (mounted) {
        _snack(_editing ? 'Rencana diperbarui.' : 'Rencana tersimpan.');
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
    final list = ref.watch(visitsProvider).valueOrNull;
    if (list != null) _fill(list);
    final remote = !_removePhoto && _newPhoto == null ? _existing?.photoBase64 : null;
    final hasPhoto = _newPhoto != null || remote != null;

    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit Rencana' : 'Rencana Baru')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _title,
                  enabled: !_saving,
                  maxLength: 80,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Nama tempat atau tujuan wajib diisi';
                    if (t.length < 3) return 'Minimal 3 karakter';
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nama tempat / tujuan',
                    hintText: 'Isi sesuai tempat yang ingin kamu kunjungi',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(
                      labelText: 'Kategori budaya', prefixIcon: Icon(Icons.category_outlined)),
                  items: [
                    for (final c in JournalCategory.all)
                      DropdownMenuItem(value: c.id, child: Text(c.label)),
                  ],
                  onChanged: _saving ? null : (v) => setState(() => _category = v ?? 'lainnya'),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _saving ? null : _pickDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Tanggal kunjungan',
                      prefixIcon: const Icon(Icons.event_outlined),
                      errorText: _dateError ? 'Tanggal wajib dipilih' : null,
                    ),
                    child: Text(
                      _date == null ? 'Ketuk untuk memilih tanggal' : formatDay(_date!),
                      style: TextStyle(
                          color: _date == null ? AppColors.brownSoft : AppColors.brown,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _note,
                  enabled: !_saving,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 300,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Catatan / tujuan kunjungan (opsional)',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('Foto referensi (opsional)', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: (_saving || _processing) ? null : _choosePhoto,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.sand, width: 1.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: _processing
                    ? const Center(child: CircularProgressIndicator(color: AppColors.terracotta))
                    : _newPhoto != null
                        ? Image.memory(_newPhoto!, fit: BoxFit.cover)
                        : remote != null
                            ? Base64Image(remote)
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 38, color: AppColors.terracotta),
                                  SizedBox(height: 6),
                                  Text('Tambah foto dari galeri atau kamera',
                                      style: TextStyle(color: AppColors.brownSoft)),
                                ],
                              ),
              ),
            ),
          ),
          if (hasPhoto)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _saving
                    ? null
                    : () => setState(() {
                          _newPhoto = null;
                          _removePhoto = true;
                        }),
                icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                label: const Text('Hapus foto', style: TextStyle(color: AppColors.error)),
              ),
            ),
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Foto dikompres lalu disimpan sebagai Base64 di Firestore (bukan Firebase Storage).',
              style: TextStyle(fontSize: 11, color: AppColors.brownSoft),
            ),
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _reminderOn,
            activeColor: AppColors.terracotta,
            title: const Text('Ingatkan saya', style: TextStyle(fontWeight: FontWeight.w800)),
            subtitle: const Text('Sehari sebelumnya pukul 18.00 dan pada hari H pukul 07.00 WIB.'),
            onChanged: _saving ? null : (v) => setState(() => _reminderOn = v),
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: _editing ? 'Simpan Perubahan' : 'Simpan Rencana',
            icon: Icons.check_rounded,
            loading: _saving,
            onPressed: _processing ? null : _save,
          ),
        ],
      ),
    );
  }
}
