import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'note_viewmodel.dart'; // было: '../viewmodel/note_viewmodel.dart'

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<NoteViewModel>();
    // Восстанавливаем черновик (переживает поворот экрана)
    _titleCtrl = TextEditingController(text: vm.draftTitle);
    _contentCtrl = TextEditingController(text: vm.draftContent);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoteViewModel>();

    return AlertDialog(
      title: const Text('Новая заметка'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Заголовок',
                errorText: null,
              ),
              onChanged: vm.updateDraftTitle,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Содержание',
              ),
              onChanged: vm.updateDraftContent,
            ),
            if (vm.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                vm.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
            vm.clearDraft();
            Navigator.of(context).pop(false);
          },
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          // Кнопка блокируется, если ввод пуст (Задание А)
          onPressed: (!vm.isDraftValid || _saving)
              ? null
              : () async {
            setState(() => _saving = true);
            final ok = await vm.saveDraft();
            if (!mounted) return;
            setState(() => _saving = false);
            if (ok) Navigator.of(context).pop(true);
          },
          child: _saving
              ? const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}