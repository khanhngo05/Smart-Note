# 📝 Smart Note — Ứng dụng Ghi chú Thông minh

> **Sinh viên:** Ngô Xuân Khánh — MSSV: 2351060453  
> **Môn học:** Phát triển Ứng dụng Đa nền tảng (Flutter)  

---

## Giới thiệu

**Smart Note** là ứng dụng ghi chú đa nền tảng được xây dựng bằng **Flutter**. Ứng dụng cho phép người dùng tạo, chỉnh sửa, tìm kiếm và xóa ghi chú một cách nhanh chóng, với giao diện Material Design hiện đại. Toàn bộ dữ liệu được lưu trữ cục bộ ngay trên thiết bị, không cần kết nối internet.

---

## Tính năng chính

| Tính năng | Mô tả |
|---|---|
| ✅ Tạo ghi chú mới | Nhấn nút **+** để mở màn hình soạn thảo trắng |
| ✅ Chỉnh sửa ghi chú | Nhấn vào thẻ ghi chú để mở và chỉnh sửa |
| ✅ Auto-save | Tự động lưu khi người dùng nhấn nút Quay lại, không cần nhấn nút Lưu thủ công |
| ✅ Tìm kiếm | Lọc ghi chú theo tiêu đề ngay trên thanh tìm kiếm |
| ✅ Xóa ghi chú | Vuốt sang trái (swipe-to-delete) hoặc xác nhận qua dialog |
| ✅ Màu sắc ngẫu nhiên | Mỗi thẻ ghi chú có màu nền pastel riêng biệt |
| ✅ Hiển thị lưới Masonry | Danh sách dạng lưới 2 cột, chiều cao thẻ tự động theo nội dung |
| ✅ Trạng thái rỗng | Hiển thị hình minh họa và thông báo khi chưa có ghi chú |
| ✅ Lưu trữ cục bộ | Dữ liệu được mã hóa JSON và lưu xuống `SharedPreferences` |

---

## Giao diện ứng dụng

### Màn hình Trang chủ (`HomeScreen`)
- **AppBar** màu xanh dương (`#1E88E5`) hiển thị tên ứng dụng và tên sinh viên.
- **Thanh tìm kiếm** bo tròn nằm ngay bên dưới AppBar, hỗ trợ xóa văn bản nhanh.
- **Danh sách Masonry Grid** 2 cột: các thẻ ghi chú có chiều cao linh hoạt theo nội dung.
- Mỗi **thẻ ghi chú** hiển thị: tiêu đề (in đậm), nội dung tóm tắt (tối đa 3 dòng) và thời gian cập nhật.
- Thẻ có **màu nền pastel** khác nhau (vàng, xanh lá, xanh dương, hồng, tím, cam nhạt).
- **Vuốt trái** để xóa ghi chú kèm dialog xác nhận trước khi thực hiện.
- **FAB (Floating Action Button)** góc dưới phải để tạo ghi chú mới.

### Màn hình Soạn thảo (`EditScreen`)
- Thiết kế tối giản như **trang giấy trắng**.
- Ô **Tiêu đề** chữ to, in đậm, không hiển thị border.
- Ô **Nội dung** đa dòng, tự co giãn chiều cao, font dễ đọc.
- **Auto-save** khi nhấn nút Quay lại (mũi tên) hoặc nhấn phím Back vật lý.
- Nếu cả tiêu đề lẫn nội dung đều trống → **không lưu**, thoát ngay.
- Nếu chỉ có nội dung mà không có tiêu đề → tự động điền `"(Không có tiêu đề)"`.
- Hiển thị `"Đang lưu..."` với loading spinner trong khi ghi dữ liệu.
- Nhãn **Auto-save** ở góc phải AppBar nhắc nhở người dùng về cơ chế lưu tự động.

---

## Kiến trúc dự án

```
smart_note/
├── lib/
│   ├── main.dart                  # Điểm khởi chạy, cấu hình MaterialApp & Theme
│   ├── models/
│   │   └── note.dart              # Model Note (id, title, content, updatedAt)
│   ├── services/
│   │   └── storage_service.dart   # Dịch vụ đọc/ghi dữ liệu qua SharedPreferences
│   └── screens/
│       ├── home_screen.dart       # Màn hình trang chủ (danh sách, tìm kiếm, xóa)
│       └── edit_screen.dart       # Màn hình soạn thảo / chỉnh sửa ghi chú
├── assets/
│   └── images/
│       └── empty_notes.png        # Hình minh họa trạng thái rỗng
└── pubspec.yaml
```

### Mô tả các thành phần

#### `Note` (Model)
- Lưu trữ thông tin một ghi chú: `id` (UUID), `title`, `content`, `updatedAt`.
- Hỗ trợ serialization JSON: `toJson()`, `fromJson()`, `encodeList()`, `decodeList()`.
- Phương thức `copyWith()` để tạo bản sao có cập nhật một phần trường dữ liệu.

#### `StorageService` (Service)
- Sử dụng `SharedPreferences` để lưu trữ danh sách ghi chú dưới dạng chuỗi JSON.
- Các phương thức: `loadNotes()`, `saveNotes()`, `upsertNote()`, `deleteNote()`.
- Thao tác **upsert**: nếu `id` đã tồn tại thì cập nhật, nếu chưa thì thêm mới lên đầu danh sách.

#### `HomeScreen` (Widget)
- `StatefulWidget` quản lý danh sách `_allNotes` và `_filteredNotes`.
- Tự động tải dữ liệu khi khởi động (`initState`).
- Lọc theo tiêu đề realtime qua `TextEditingController.addListener`.
- Sau mỗi lần mở `EditScreen` → reload lại danh sách để cập nhật thay đổi.

#### `EditScreen` (Widget)
- `StatefulWidget` nhận tham số `existingNote` (nullable) để phân biệt tạo mới / chỉnh sửa.
- Sử dụng `PopScope` (Flutter 3.x) để chặn hành vi pop mặc định và thực hiện auto-save trước.
- UUID được tạo bởi thư viện `uuid` đảm bảo tính duy nhất của mỗi ghi chú.

---

## Mô tả chi tiết các chức năng theo code

### 1. Model `Note` — `lib/models/note.dart`

#### Cấu trúc dữ liệu

```dart
class Note {
  final String id;      // UUID duy nhất, không thay đổi sau khi tạo
  String title;         // Tiêu đề ghi chú
  String content;       // Nội dung ghi chú
  DateTime updatedAt;   // Thời điểm cập nhật cuối cùng
}
```

#### Serialization JSON — `toJson()` / `fromJson()`

Mỗi `Note` được chuyển đổi qua lại với `Map<String, dynamic>` để lưu/đọc từ `SharedPreferences`:

```dart
Map<String, dynamic> toJson() {
  return {
    'id': id,
    'title': title,
    'content': content,
    'updatedAt': updatedAt.toIso8601String(), // DateTime → chuỗi ISO 8601
  };
}

factory Note.fromJson(Map<String, dynamic> json) {
  return Note(
    id: json['id'] as String,
    title: json['title'] as String,
    content: json['content'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String), // chuỗi → DateTime
  );
}
```

#### Encode/Decode toàn bộ danh sách — `encodeList()` / `decodeList()`

Chuyển đổi `List<Note>` ↔ `String` JSON để lưu vào một key duy nhất trong `SharedPreferences`:

```dart
static String encodeList(List<Note> notes) {
  return jsonEncode(notes.map((n) => n.toJson()).toList());
}

static List<Note> decodeList(String jsonStr) {
  final List<dynamic> decoded = jsonDecode(jsonStr) as List<dynamic>;
  return decoded
      .map((item) => Note.fromJson(item as Map<String, dynamic>))
      .toList();
}
```

#### Bản sao bất biến — `copyWith()`

Tạo một `Note` mới từ bản hiện tại, chỉ thay thế các trường được truyền vào:

```dart
Note copyWith({String? title, String? content, DateTime? updatedAt}) {
  return Note(
    id: id,                           // id không bao giờ thay đổi
    title: title ?? this.title,
    content: content ?? this.content,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
```

---

### 2. Service `StorageService` — `lib/services/storage_service.dart`

Key lưu trữ cố định trong `SharedPreferences`:

```dart
static const _notesKey = 'smart_note_notes';
```

#### Đọc danh sách — `loadNotes()`

Lấy chuỗi JSON từ `SharedPreferences`, giải mã thành `List<Note>`. Trả về danh sách rỗng nếu chưa có dữ liệu hoặc lỗi parse:

```dart
Future<List<Note>> loadNotes() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString(_notesKey);
  if (jsonStr == null || jsonStr.isEmpty) return [];
  try {
    return Note.decodeList(jsonStr);
  } catch (_) {
    return []; // An toàn khi dữ liệu bị hỏng
  }
}
```

#### Ghi toàn bộ danh sách — `saveNotes()`

Mã hóa toàn bộ danh sách thành JSON và ghi đè vào `SharedPreferences`:

```dart
Future<void> saveNotes(List<Note> notes) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_notesKey, Note.encodeList(notes));
}
```

#### Thêm hoặc cập nhật — `upsertNote()`

Tìm kiếm ghi chú theo `id`. Nếu tồn tại thì cập nhật tại chỗ; nếu chưa thì chèn lên đầu danh sách (ghi chú mới nhất luôn ở trên cùng):

```dart
Future<List<Note>> upsertNote(Note note) async {
  final notes = await loadNotes();
  final index = notes.indexWhere((n) => n.id == note.id);
  if (index >= 0) {
    notes[index] = note;          // Cập nhật ghi chú cũ
  } else {
    notes.insert(0, note);        // Thêm ghi chú mới lên đầu
  }
  await saveNotes(notes);
  return notes;
}
```

#### Xóa ghi chú — `deleteNote()`

Lọc bỏ ghi chú có `id` tương ứng, sau đó ghi lại toàn bộ danh sách:

```dart
Future<List<Note>> deleteNote(String id) async {
  final notes = await loadNotes();
  notes.removeWhere((n) => n.id == id);
  await saveNotes(notes);
  return notes;
}
```

---

### 3. `HomeScreen` — `lib/screens/home_screen.dart`

#### State và khởi tạo

```dart
List<Note> _allNotes = [];       // Toàn bộ ghi chú gốc (không lọc)
List<Note> _filteredNotes = [];  // Danh sách đang hiển thị (đã lọc)
bool _isLoading = true;          // Hiển thị loading khi đang đọc dữ liệu

@override
void initState() {
  super.initState();
  _loadNotes();                                    // Đọc dữ liệu ngay khi khởi động
  _searchController.addListener(_onSearchChanged); // Lắng nghe thay đổi ô tìm kiếm
}
```

#### Tải dữ liệu — `_loadNotes()`

Gọi `StorageService`, cập nhật cả `_allNotes` lẫn `_filteredNotes` đồng thời tắt cờ loading. Kiểm tra `mounted` để tránh gọi `setState` sau khi widget đã bị hủy:

```dart
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
```

#### Tìm kiếm realtime — `_onSearchChanged()`

Lắng nghe mỗi ký tự nhập vào, lọc `_allNotes` theo tiêu đề (không phân biệt hoa/thường). Khi ô trống thì hiển thị lại toàn bộ danh sách:

```dart
void _onSearchChanged() {
  final query = _searchController.text.toLowerCase().trim();
  setState(() {
    _filteredNotes = query.isEmpty
        ? List.from(_allNotes)                                    // Hiển thị tất cả
        : _allNotes
            .where((n) => n.title.toLowerCase().contains(query))  // Lọc theo tiêu đề
            .toList();
  });
}
```

#### Mở màn hình soạn thảo — `_openNote()`

Truyền `note` vào `EditScreen` nếu là chỉnh sửa, để `null` nếu là tạo mới. Sau khi `EditScreen` đóng (`await` hoàn tất), reload lại danh sách và áp dụng lại bộ lọc tìm kiếm hiện tại:

```dart
Future<void> _openNote({Note? note}) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => EditScreen(existingNote: note), // null = tạo mới
    ),
  );
  await _loadNotes();    // Cập nhật danh sách sau khi quay về
  _onSearchChanged();    // Giữ nguyên bộ lọc đang áp dụng
}
```

#### Xóa ghi chú có xác nhận — `_confirmDelete()`

Hiển thị `AlertDialog` với hai lựa chọn. Chỉ thực hiện xóa khi người dùng xác nhận `true`. Kết quả xóa từ `StorageService` được dùng trực tiếp để cập nhật state, sau đó áp dụng lại bộ lọc:

```dart
Future<void> _confirmDelete(Note note) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(children: [
        Icon(Icons.warning_amber_rounded, color: Colors.red),
        Text('Xác nhận xóa'),
      ]),
      content: const Text('Bạn có chắc chắn muốn xóa ghi chú này không?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa')),
      ],
    ),
  );

  if (confirmed == true && mounted) {
    final updatedNotes = await _storage.deleteNote(note.id);
    setState(() { _allNotes = updatedNotes; });
    _onSearchChanged(); // Cập nhật _filteredNotes
  }
}
```

#### Màu nền thẻ ghi chú — `_noteColor()`

Bảng 6 màu pastel được cố định. Màu của mỗi thẻ được xác định bằng cách lấy tổng mã ASCII của các ký tự trong `id` rồi chia lấy dư — đảm bảo cùng một ghi chú luôn hiển thị cùng màu dù khởi động lại app:

```dart
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
```

#### Hiển thị lưới Masonry — `_buildGrid()`

Sử dụng `MasonryGridView.count` từ package `flutter_staggered_grid_view` để tạo lưới 2 cột, chiều cao mỗi thẻ tự động co giãn theo nội dung:

```dart
Widget _buildGrid() {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: MasonryGridView.count(
      crossAxisCount: 2,       // 2 cột
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      itemCount: _filteredNotes.length,
      itemBuilder: (context, index) => _buildNoteCard(_filteredNotes[index]),
    ),
  );
}
```

#### Thẻ ghi chú với Swipe-to-delete — `_buildNoteCard()`

Bọc thẻ bằng `Dismissible` để nhận cử chỉ vuốt trái. Tham số `confirmDismiss` luôn trả về `false` — nghĩa là `Dismissible` không tự xóa widget mà nhường quyền xử lý cho `_confirmDelete()`, đảm bảo luôn có dialog xác nhận trước khi xóa:

```dart
Widget _buildNoteCard(Note note) {
  return Dismissible(
    key: ValueKey(note.id),
    direction: DismissDirection.endToStart, // Chỉ vuốt từ phải sang trái
    background: Container(                  // Nền đỏ + icon thùng rác
      alignment: Alignment.centerRight,
      color: Colors.red.shade600,
      child: const Icon(Icons.delete_outline, color: Colors.white),
    ),
    confirmDismiss: (_) async {
      await _confirmDelete(note);
      return false; // Không để Dismissible tự xóa khỏi cây widget
    },
    child: GestureDetector(
      onTap: () => _openNote(note: note), // Nhấn để chỉnh sửa
      child: Container(
        decoration: BoxDecoration(
          color: _noteColor(note.id),     // Màu pastel theo id
          borderRadius: BorderRadius.circular(16),
        ),
        // ... hiển thị tiêu đề, nội dung tóm tắt, thời gian
      ),
    ),
  );
}
```

---

### 4. `EditScreen` — `lib/screens/edit_screen.dart`

#### Khởi tạo — `initState()`

Nếu là ghi chú cũ (`existingNote != null`): dùng `id` và nội dung có sẵn. Nếu là ghi chú mới: tự sinh UUID v4 mới và để trống các ô nhập liệu:

```dart
@override
void initState() {
  super.initState();
  _noteId = widget.existingNote?.id ?? const Uuid().v4(); // Giữ id cũ hoặc tạo mới
  _titleController = TextEditingController(text: widget.existingNote?.title ?? '');
  _contentController = TextEditingController(text: widget.existingNote?.content ?? '');
}
```

#### Auto-save khi quay lại — `_autoSaveAndPop()`

Hàm này được gọi tự động khi người dùng nhấn Back (vật lý hoặc mũi tên AppBar). Logic luồng:

1. Nếu cả tiêu đề và nội dung đều trống → thoát ngay, không lưu.
2. Hiển thị trạng thái `"Đang lưu..."`.
3. Xây dựng đối tượng `Note` mới với `updatedAt = DateTime.now()`.
4. Gọi `upsertNote()` để lưu xuống `SharedPreferences`.
5. Pop khỏi `EditScreen` để quay về `HomeScreen`.

```dart
Future<void> _autoSaveAndPop() async {
  final title = _titleController.text.trim();
  final content = _contentController.text.trim();

  // Trường hợp 1: Không lưu ghi chú rỗng
  if (title.isEmpty && content.isEmpty) {
    if (mounted) Navigator.pop(context);
    return;
  }

  setState(() => _isSaving = true); // Hiện "Đang lưu..."

  final note = Note(
    id: _noteId,
    title: title.isEmpty ? '(Không có tiêu đề)' : title, // Tiêu đề mặc định
    content: content,
    updatedAt: DateTime.now(),
  );

  await _storage.upsertNote(note); // Ghi xuống SharedPreferences

  if (mounted) {
    setState(() => _isSaving = false);
    Navigator.pop(context); // Quay về HomeScreen
  }
}
```

#### Chặn hành vi Back mặc định — `PopScope`

Flutter 3.x thay thế `WillPopScope` bằng `PopScope`. Tham số `canPop: false` ngăn hệ thống tự pop, buộc mọi thao tác Back đều đi qua `_autoSaveAndPop()`:

```dart
return PopScope(
  canPop: false,  // Tắt hành vi pop mặc định
  onPopInvokedWithResult: (didPop, _) async {
    if (!didPop) {
      await _autoSaveAndPop(); // Luôn lưu trước khi thoát
    }
  },
  child: Scaffold(...),
);
```

---

## Thư viện sử dụng

| Package | Phiên bản | Mục đích |
|---|---|---|
| `shared_preferences` | ^2.3.2 | Lưu trữ dữ liệu cục bộ dạng key-value |
| `flutter_staggered_grid_view` | ^0.7.0 | Hiển thị danh sách dạng Masonry Grid |
| `intl` | ^0.19.0 | Định dạng ngày giờ (`dd/MM/yyyy HH:mm`) |
| `uuid` | ^4.5.1 | Tạo ID duy nhất (UUID v4) cho mỗi ghi chú |
| `cupertino_icons` | ^1.0.8 | Bộ icon iOS cho Flutter |

---

## Yêu cầu môi trường

- **Flutter SDK:** `>=3.0.0 <4.0.0`
- **Dart SDK:** `>=3.0.0 <4.0.0`
- **Nền tảng hỗ trợ:** Android, iOS, Web, Windows, macOS, Linux

---

## Hướng dẫn cài đặt & chạy

### 1. Clone dự án

```bash
git clone <repository-url>
cd smart_note
```

### 2. Cài đặt dependencies

```bash
flutter pub get
```

### 3. Chạy ứng dụng

```bash
# Chạy trên thiết bị/giả lập mặc định
flutter run

# Chạy trên Android
flutter run -d android

# Chạy trên Web
flutter run -d chrome

# Chạy trên Windows
flutter run -d windows
```

### 4. Build release

```bash
# Android APK
flutter build apk --release

# Web
flutter build web --release

# Windows
flutter build windows --release
```

---

## Luồng hoạt động

```
Khởi động app
     │
     ▼
HomeScreen → loadNotes() từ SharedPreferences
     │
     ├─── [Danh sách rỗng] → Hiển thị Empty State
     │
     └─── [Có ghi chú] → Hiển thị Masonry Grid
                │
                ├── Tìm kiếm: lọc realtime theo tiêu đề
                │
                ├── Nhấn thẻ → EditScreen (chỉnh sửa)
                │                  └── Quay lại → Auto-save → upsertNote()
                │
                ├── Nhấn FAB (+) → EditScreen (tạo mới)
                │                  └── Quay lại → Auto-save → upsertNote()
                │
                └── Vuốt trái → Dialog xác nhận → deleteNote()
```

---

## Lưu ý kỹ thuật

- Dữ liệu được lưu trong `SharedPreferences` với key `smart_note_notes` dưới dạng chuỗi JSON được mã hóa từ danh sách `Note`.
- Ứng dụng **không yêu cầu quyền internet** hay bất kỳ permission đặc biệt nào.
- Khi xóa ghi chú bằng swipe, widget `Dismissible` luôn trả về `false` trong `confirmDismiss` để tự quản lý việc xóa và hiển thị dialog xác nhận trước.
- Màu nền của mỗi thẻ ghi chú được xác định dựa trên tổng mã ASCII của các ký tự trong `id`, đảm bảo cùng một ghi chú luôn hiển thị cùng màu.
