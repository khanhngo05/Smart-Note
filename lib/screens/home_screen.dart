import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import 'edit_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  final TextEditingController _searchController = TextEditingController();

  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────
  // Bước 1 & 2: Đọc dữ liệu khi khởi động
  // ──────────────────────────────────────────────
  Future<void> _loadNotes() async {
    final notes = await _storage.loadNotes();
    if (mounted) {
      setState(() {
        _allNotes = notes;
        _filteredNotes = notes;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredNotes = query.isEmpty
          ? List.from(_allNotes)
          : _allNotes
              .where((n) => n.title.toLowerCase().contains(query))
              .toList();
    });
  }

  // ──────────────────────────────────────────────
  // Bước 3 & 5: Mở màn hình soạn thảo, sau đó
  //             làm mới danh sách khi quay về
  // ──────────────────────────────────────────────
  Future<void> _openNote({Note? note}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditScreen(existingNote: note),
      ),
    );
    // Bước 5: Sau khi pop từ EditScreen, reload danh sách
    await _loadNotes();
    // Giữ nguyên từ khóa tìm kiếm nếu đang lọc
    _onSearchChanged();
  }

  // ──────────────────────────────────────────────
  // C. Xóa ghi chú với dialog xác nhận
  // ──────────────────────────────────────────────
  Future<void> _confirmDelete(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: const Text(
          'Bạn có chắc chắn muốn xóa ghi chú này không?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child:
                const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final updatedNotes = await _storage.deleteNote(note.id);
      setState(() {
        _allNotes = updatedNotes;
        _onSearchChanged();
      });
      _onSearchChanged();
    }
  }

  // ──────────────────────────────────────────────
  // Helpers
  // ──────────────────────────────────────────────
  String _formatDate(DateTime dt) =>
      DateFormat('dd/MM/yyyy HH:mm').format(dt);

  // ──────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E88E5),
        title: const Text(
          'Smart Note - Ngô Xuân Khánh - 2351060453',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // ─── Bước 3: Thanh tìm kiếm + danh sách ───
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _isLoading ? _buildLoading() : _buildBody()),
        ],
      ),
      // ─── FAB Thêm mới ───
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(),
        backgroundColor: const Color(0xFF1E88E5),
        tooltip: 'Thêm ghi chú',
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  // A. Thanh tìm kiếm bo góc
  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF1E88E5),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tiêu đề...',
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: const Icon(Icons.search, color: Colors.black45),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.white, width: 2),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.black45),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBody() {
    if (_filteredNotes.isEmpty) return _buildEmptyState();
    return _buildGrid();
  }

  // A. Trạng thái rỗng (Empty State)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/empty_notes.png',
              width: 180,
              height: 180,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.note_alt_outlined,
                size: 120,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bạn chưa có ghi chú nào,\nhãy tạo mới nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // A. Danh sách dạng lưới 2 cột với Masonry (Staggered Grid)
  Widget _buildGrid() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: _filteredNotes.length,
        itemBuilder: (context, index) {
          final note = _filteredNotes[index];
          return _buildNoteCard(note);
        },
      ),
    );
  }

  // A. Thẻ ghi chú với Swipe-to-delete
  Widget _buildNoteCard(Note note) {
    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      // C. Nền đỏ + icon thùng rác khi vuốt
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text('Xóa', style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      // C. Ràng buộc: hiển thị dialog trước khi xóa
      confirmDismiss: (_) async {
        await _confirmDelete(note);
        return false; // tự quản lý việc xóa trong _confirmDelete
      },
      child: GestureDetector(
        onTap: () => _openNote(note: note),
        child: Container(
          decoration: BoxDecoration(
            color: _noteColor(note.id),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tiêu đề: in đậm, 1 dòng, overflow ellipsis
              Text(
                note.title.isEmpty ? '(Không có tiêu đề)' : note.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (note.content.isNotEmpty) ...[
                const SizedBox(height: 6),
                // Nội dung tóm tắt: chữ nhạt, tối đa 3 dòng
                Text(
                  note.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              // Thời gian ở góc dưới thẻ
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 12, color: Color(0xFF9CA3AF)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDate(note.updatedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mỗi ghi chú có màu nền khác nhau (pastel palette)
  static const List<Color> _palette = [
    Color(0xFFFFF9C4), // vàng nhạt
    Color(0xFFE8F5E9), // xanh lá nhạt
    Color(0xFFE3F2FD), // xanh dương nhạt
    Color(0xFFFCE4EC), // hồng nhạt
    Color(0xFFEDE7F6), // tím nhạt
    Color(0xFFFFF3E0), // cam nhạt
  ];

  Color _noteColor(String id) {
    final idx = id.codeUnits.reduce((a, b) => a + b) % _palette.length;
    return _palette[idx];
  }
}
