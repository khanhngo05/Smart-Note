import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

/// B. Màn hình Soạn thảo / Xem & Sửa ghi chú
/// - Thiết kế tối giản như trang giấy trắng
/// - Không có nút Lưu — Auto-save khi Back
class EditScreen extends StatefulWidget {
  final Note? existingNote;

  const EditScreen({super.key, this.existingNote});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final StorageService _storage = StorageService();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final String _noteId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Nếu là ghi chú cũ thì load nội dung, nếu mới thì để trống
    _noteId = widget.existingNote?.id ?? const Uuid().v4();
    _titleController =
        TextEditingController(text: widget.existingNote?.title ?? '');
    _contentController =
        TextEditingController(text: widget.existingNote?.content ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Bước 4: Auto-save khi người dùng Back
  // - Không lưu nếu cả tiêu đề và nội dung đều trống
  // ──────────────────────────────────────────────
  Future<void> _autoSaveAndPop() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    // Bỏ qua nếu ghi chú rỗng hoàn toàn
    if (title.isEmpty && content.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    final note = Note(
      id: _noteId,
      title: title.isEmpty ? '(Không có tiêu đề)' : title,
      content: content,
      updatedAt: DateTime.now(),
    );

    // Mã hóa JSON và lưu xuống SharedPreferences
    await _storage.upsertNote(note);

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
    }
  }

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Chặn hành vi pop mặc định để thực hiện auto-save trước
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          await _autoSaveAndPop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E88E5)),
            onPressed: _autoSaveAndPop,
            tooltip: 'Quay lại (tự động lưu)',
          ),
          title: _isSaving
              ? const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đang lưu...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              : const Text(
                  'Ghi chú',
                  style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          // Hiển thị trạng thái Auto-save ở bên phải AppBar
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Tooltip(
                message: 'Tự động lưu khi quay lại',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_done_outlined,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Auto-save',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // B. Giao diện trang giấy trắng
        body: GestureDetector(
          // Tap vào vùng trống cũng focus ô nội dung
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ô tiêu đề — ẩn border, in đậm lớn
                TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Tiêu đề',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                ),
                const Divider(height: 24, thickness: 0.5, color: Colors.black12),
                // Ô nội dung — đa dòng, tự giãn chiều cao, ẩn border
                TextField(
                  controller: _contentController,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Bắt đầu viết ghi chú của bạn...',
                    hintStyle: TextStyle(
                      color: Colors.black26,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  // B. Multiline — tự giãn chiều cao theo nội dung
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
