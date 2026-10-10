import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/models/note_model.dart';
import '../../core/providers/note_provider.dart';
import '../../utils/app_theme.dart';

class AddEditNoteScreen extends StatefulWidget {
  final bool isEditMode;

  const AddEditNoteScreen({super.key, this.isEditMode = false});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  String _selectedCategory = 'General';
  int _selectedColorHex = AppColors.noteColors.first;
  NoteModel? _existingNote;

  @override
  void initState() {
    super.initState();
    // Retrieve argument passed via GetX routing
    if (widget.isEditMode && Get.arguments is NoteModel) {
      _existingNote = Get.arguments as NoteModel;
      _titleController.text = _existingNote!.title;
      _contentController.text = _existingNote!.content;
      _selectedCategory = _existingNote!.category;
      _selectedColorHex = _existingNote!.colorHex;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      Get.snackbar(
        'Missing Title',
        'Please enter a title for your note',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    final provider = Provider.of<NoteProvider>(context, listen: false);

    if (widget.isEditMode && _existingNote != null) {
      final updatedNote = _existingNote!.copyWith(
        title: title,
        content: content,
        category: _selectedCategory,
        colorHex: _selectedColorHex,
      );
      provider.updateNote(updatedNote);
      Get.snackbar(
        'Updated',
        'Note updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } else {
      final newNote = NoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        category: _selectedCategory,
        colorHex: _selectedColorHex,
        createdAt: DateTime.now(),
      );
      provider.addNote(newNote);
      Get.snackbar(
        'Created',
        'Note created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }

    // Navigate back using GetX Routing
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NoteProvider>(context, listen: false);
    final categories = provider.categories.where((c) => c != 'All').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditMode ? 'Edit Note' : 'New Note'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(), // GetX navigation
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 28),
            onPressed: _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Input
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                hintText: 'Note Title',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 24),
              ),
            ),
            const Divider(),

            const SizedBox(height: 12),

            // Category selector
            Row(
              children: [
                const Text(
                  'Category: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: isSelected ? AppColors.primary : Colors.black87,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Color accent selector
            Row(
              children: [
                const Text(
                  'Color Badge: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(width: 8),
                Row(
                  children: AppColors.noteColors.map((colorHex) {
                    final isSelected = _selectedColorHex == colorHex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorHex = colorHex;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(colorHex),
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.black87, width: 2.5)
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Content Input
            TextField(
              controller: _contentController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 16, height: 1.5),
              decoration: const InputDecoration(
                hintText: 'Start writing your note here...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
