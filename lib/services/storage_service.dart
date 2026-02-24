import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// Service quản lý đọc/ghi ghi chú xuống bộ nhớ cục bộ qua SharedPreferences.
/// Dữ liệu được mã hóa/giải mã bằng JSON trước mọi thao tác đọc-ghi.
class StorageService {
  static const _notesKey = 'smart_note_notes';

  /// Đọc toàn bộ danh sách ghi chú từ SharedPreferences
  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_notesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return Note.decodeList(jsonStr);
    } catch (_) {
      return [];
    }
  }

  /// Ghi toàn bộ danh sách ghi chú xuống SharedPreferences dưới dạng JSON
  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_notesKey, Note.encodeList(notes));
  }

  /// Thêm hoặc cập nhật một ghi chú (upsert theo id)
  Future<List<Note>> upsertNote(Note note) async {
    final notes = await loadNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.insert(0, note); // ghi chú mới lên đầu danh sách
    }
    await saveNotes(notes);
    return notes;
  }

  /// Xóa ghi chú theo id
  Future<List<Note>> deleteNote(String id) async {
    final notes = await loadNotes();
    notes.removeWhere((n) => n.id == id);
    await saveNotes(notes);
    return notes;
  }
}
