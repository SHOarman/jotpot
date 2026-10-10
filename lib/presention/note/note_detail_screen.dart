import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/models/note_model.dart';
import '../../core/providers/note_provider.dart';
import '../../core/route/app_routes.dart';
import '../../utils/app_theme.dart';

class NoteDetailScreen extends StatelessWidget {
  const NoteDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve argument from GetX Routing
    final NoteModel? note = Get.arguments as NoteModel?;

    if (note == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Note not found')),
      );
    }

    return Consumer<NoteProvider>(
      builder: (context, provider, _) {
        // Get updated copy of note from provider if available
        final currentNote = provider.notes.firstWhere(
          (n) => n.id == note.id,
          orElse: () => note,
        );

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(), // GetX Routing back navigation
            ),
            actions: [
              IconButton(
                icon: Icon(
                  currentNote.isPinned
                      ? Icons.push_pin_rounded
                      : Icons.push_pin_outlined,
                  color: currentNote.isPinned ? AppColors.primary : Colors.grey,
                ),
                onPressed: () => provider.togglePinNote(currentNote),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                onPressed: () {
                  // Navigate to Edit screen using GetX Routing
                  Get.toNamed(AppRoutes.EDIT_NOTE, arguments: currentNote);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Delete Note'),
                      content:
                          const Text('Are you sure you want to delete this note?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            provider.deleteNote(currentNote.id);
                            Get.back(); // Close dialog
                            Get.back(); // Go back to Home screen
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category & Date Row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentNote.cardColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: currentNote.cardColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        currentNote.category,
                        style: TextStyle(
                          color: currentNote.cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      '${currentNote.createdAt.day}/${currentNote.createdAt.month}/${currentNote.createdAt.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Note Title
                Text(
                  currentNote.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                // Note Content Body
                Text(
                  currentNote.content.isEmpty
                      ? 'No content written...'
                      : currentNote.content,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
