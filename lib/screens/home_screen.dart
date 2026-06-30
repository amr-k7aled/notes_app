import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import 'note_editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            _buildNotesList(context),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          final count = provider.notes.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Notes',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count ${count == 1 ? 'note' : 'notes'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: TextField(
        controller: _searchController,
        onChanged: (val) =>
            context.read<NotesProvider>().setSearch(val),
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondary, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textSecondary, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<NotesProvider>().setSearch('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildNotesList(BuildContext context) {
    return Expanded(
      child: Consumer<NotesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          final notes = provider.notes;

          if (notes.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return _NoteCard(
                note: notes[index],
                onTap: () => _openEditor(context, note: notes[index]),
                onDelete: () =>
                    context.read<NotesProvider>().deleteNote(notes[index].id),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.notes_rounded,
              color: AppColors.accent,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No notes yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tap + to create your first note',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _SmallFAB(
          icon: Icons.checklist_rounded,
          label: 'To-Do',
          onTap: () => _openEditor(context, type: NoteType.todo),
        ),
        const SizedBox(height: 10),
        _SmallFAB(
          icon: Icons.edit_note_rounded,
          label: 'Note',
          onTap: () => _openEditor(context, type: NoteType.note),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.extended(
          onPressed: () => _openEditor(context, type: NoteType.note),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New'),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context, {Note? note, NoteType? type}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteEditorScreen(
          note: note,
          initialType: type ?? NoteType.note,
        ),
      ),
    );
  }
}

class _SmallFAB extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallFAB({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: onTap,
          backgroundColor: AppColors.surfaceCard,
          child: Icon(icon, color: AppColors.accent, size: 20),
        ),
      ],
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NoteCard({
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = AppColors.noteColors[
        note.colorIndex.clamp(0, AppColors.noteColors.length - 1)];
    final accentColor = AppColors.noteAccents[
        note.colorIndex.clamp(0, AppColors.noteAccents.length - 1)];

    return Dismissible(
      key: Key(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppColors.danger),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(accentColor),
              if (note.type == NoteType.note && note.content.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
              if (note.type == NoteType.todo &&
                  note.todoItems.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildTodoPreview(),
              ],
              const SizedBox(height: 10),
              _buildCardFooter(accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(Color accentColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                note.type == NoteType.todo
                    ? Icons.checklist_rounded
                    : Icons.notes_rounded,
                size: 12,
                color: accentColor,
              ),
              const SizedBox(width: 4),
              Text(
                note.type == NoteType.todo ? 'To-Do' : 'Note',
                style: TextStyle(
                  fontSize: 10,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            note.title.isEmpty ? 'Untitled' : note.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        GestureDetector(
          onTap: onDelete,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.danger,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodoPreview() {
    final preview = note.todoItems.take(3).toList();
    final done = note.todoItems.where((t) => t.isDone).length;
    return Column(
      children: [
        ...preview.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(
                    item.isDone
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 14,
                    color: item.isDone
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.isDone
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        decoration: item.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        if (note.todoItems.length > 3)
          Text(
            '+${note.todoItems.length - 3} more',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        const SizedBox(height: 4),
        _buildProgressBar(done, note.todoItems.length),
      ],
    );
  }

  Widget _buildProgressBar(int done, int total) {
    final progress = total > 0 ? done / total : 0.0;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.divider,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.success),
              minHeight: 4,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$done/$total',
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(Color accentColor) {
    final formatter = DateFormat('MMM d, h:mm a');
    return Text(
      formatter.format(note.updatedAt),
      style: const TextStyle(
        fontSize: 11,
        color: AppColors.textSecondary,
      ),
    );
  }
}
