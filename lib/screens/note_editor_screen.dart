import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final NoteType initialType;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.initialType = NoteType.note,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late NoteType _type;
  late List<TodoItem> _todoItems;
  late int _colorIndex;
  final TextEditingController _newTodoController = TextEditingController();
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _type = note?.type ?? widget.initialType;
    _todoItems = note?.todoItems.map((e) => TodoItem(
              id: e.id,
              text: e.text,
              isDone: e.isDone,
            )).toList() ??
        [];
    _colorIndex = note?.colorIndex ?? 0;

    _titleController.addListener(() => setState(() => _hasChanges = true));
    _contentController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _newTodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.noteAccents[
        _colorIndex.clamp(0, AppColors.noteAccents.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(accentColor),
      body: Column(
        children: [
          _buildTypeSelector(accentColor),
          _buildColorPicker(),
          const Divider(color: AppColors.divider, height: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  AppBar _buildAppBar(Color accentColor) {
    return AppBar(
      backgroundColor: AppColors.background,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        onPressed: _onBack,
      ),
      title: Text(
        widget.note == null ? 'New' : 'Edit',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      actions: [
        if (widget.note != null)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.danger),
            onPressed: _deleteNote,
          ),
        TextButton(
          onPressed: _save,
          child: Text(
            'Save',
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildTypeSelector(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _TypeChip(
            icon: Icons.notes_rounded,
            label: 'Note',
            selected: _type == NoteType.note,
            accentColor: accentColor,
            onTap: () => setState(() {
              _type = NoteType.note;
              _hasChanges = true;
            }),
          ),
          const SizedBox(width: 10),
          _TypeChip(
            icon: Icons.checklist_rounded,
            label: 'To-Do',
            selected: _type == NoteType.todo,
            accentColor: accentColor,
            onTap: () => setState(() {
              _type = NoteType.todo;
              _hasChanges = true;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        itemCount: AppColors.noteColors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = _colorIndex == i;
          return GestureDetector(
            onTap: () => setState(() {
              _colorIndex = i;
              _hasChanges = true;
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.noteAccents[i],
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? Colors.white : Colors.transparent,
                  width: 2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: AppColors.noteAccents[i].withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    : [],
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.white)
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_type == NoteType.note) _buildNoteContent(),
          if (_type == NoteType.todo) _buildTodoList(),
        ],
      ),
    );
  }

  Widget _buildNoteContent() {
    return TextField(
      controller: _contentController,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textPrimary,
        height: 1.6,
      ),
      decoration: const InputDecoration(
        hintText: 'Start writing...',
        border: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
        hintStyle: TextStyle(
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    final accentColor = AppColors.noteAccents[
        _colorIndex.clamp(0, AppColors.noteAccents.length - 1)];

    final activeItems =
        _todoItems.where((t) => !t.isDone).toList();
    final doneItems =
        _todoItems.where((t) => t.isDone).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Active items ──
        if (activeItems.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Active  •  ${activeItems.length}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: accentColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ...activeItems.map((item) {
            final realIndex = _todoItems.indexOf(item);
            return _TodoItemTile(
              key: Key(item.id),
              item: item,
              index: realIndex,
              accentColor: accentColor,
              onToggle: () {
                setState(() {
                  _todoItems[realIndex] =
                      item.copyWith(isDone: true);
                  _hasChanges = true;
                });
              },
              onDelete: () {
                setState(() {
                  _todoItems.removeAt(realIndex);
                  _hasChanges = true;
                });
              },
              onEdit: (text) {
                setState(() {
                  _todoItems[realIndex] =
                      item.copyWith(text: text);
                  _hasChanges = true;
                });
              },
            );
          }),
          const SizedBox(height: 12),
        ],

        // ── Progress bar ──
        if (_todoItems.isNotEmpty) ...[
          _buildTodoProgress(accentColor),
          const SizedBox(height: 16),
        ],

        // ── Add new item ──
        _buildAddTodoField(accentColor),

        // ── Completed items ──
        if (doneItems.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Completed  •  ${doneItems.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          ...doneItems.map((item) {
            final realIndex = _todoItems.indexOf(item);
            return _TodoItemTile(
              key: Key(item.id),
              item: item,
              index: realIndex,
              accentColor: accentColor,
              onToggle: () {
                setState(() {
                  _todoItems[realIndex] =
                      item.copyWith(isDone: false);
                  _hasChanges = true;
                });
              },
              onDelete: () {
                setState(() {
                  _todoItems.removeAt(realIndex);
                  _hasChanges = true;
                });
              },
              onEdit: (text) {
                setState(() {
                  _todoItems[realIndex] =
                      item.copyWith(text: text);
                  _hasChanges = true;
                });
              },
            );
          }),
        ],
      ],
    );
  }

  Widget _buildTodoProgress(Color accentColor) {
    final done = _todoItems.where((t) => t.isDone).length;
    final total = _todoItems.length;
    final progress = total > 0 ? done / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$done of $total completed',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildAddTodoField(Color accentColor) {
    return Row(
      children: [
        Icon(Icons.add_circle_outline_rounded, color: accentColor, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _newTodoController,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText: 'Add item...',
              border: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
              hintStyle: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            onSubmitted: _addTodoItem,
          ),
        ),
      ],
    );
  }

  void _addTodoItem(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _todoItems.add(TodoItem(
        id: const Uuid().v4(),
        text: text.trim(),
      ));
      _hasChanges = true;
    });
    _newTodoController.clear();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final provider = context.read<NotesProvider>();

    if (title.isEmpty && content.isEmpty && _todoItems.isEmpty) {
      Navigator.pop(context);
      return;
    }

    if (widget.note == null) {
      final newNote = Note(
        id: const Uuid().v4(),
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        type: _type,
        todoItems: _todoItems,
        colorIndex: _colorIndex,
      );
      await provider.addNote(newNote);
    } else {
      final updated = widget.note!.copyWith(
        title: title.isEmpty ? 'Untitled' : title,
        content: content,
        type: _type,
        todoItems: _todoItems,
        colorIndex: _colorIndex,
        updatedAt: DateTime.now(),
      );
      await provider.updateNote(updated);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteNote() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Note',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to delete this note?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<NotesProvider>().deleteNote(widget.note!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  void _onBack() {
    if (_hasChanges) {
      _save();
    } else {
      Navigator.pop(context);
    }
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.15) : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? accentColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? accentColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: selected ? accentColor : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodoItemTile extends StatelessWidget {
  final TodoItem item;
  final int index;
  final Color accentColor;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final void Function(String) onEdit;

  const _TodoItemTile({
    super.key,
    required this.item,
    required this.index,
    required this.accentColor,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isDone
                    ? AppColors.success
                    : Colors.transparent,
                border: Border.all(
                  color: item.isDone
                      ? AppColors.success
                      : AppColors.textSecondary,
                  width: 1.5,
                ),
              ),
              child: item.isDone
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.text,
              style: TextStyle(
                fontSize: 14,
                color: item.isDone
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                decoration:
                    item.isDone ? TextDecoration.lineThrough : null,
                decorationColor: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(5),
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
      ),
    );
  }
}
