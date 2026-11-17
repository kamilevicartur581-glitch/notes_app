import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'note.dart';           // было: '../../data/local/entity/note.dart'
import 'note_viewmodel.dart'; // было: '../viewmodel/note_viewmodel.dart'
import 'add_note_dialog.dart';
import 'add_note_dialog.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  bool _searching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NoteViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Поиск...',
            border: InputBorder.none,
          ),
          onChanged: (v) => vm.setSearchQuery(v),
        )
            : const Text('Заметки'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                _searchController.clear();
                vm.setSearchQuery('');
              }
            },
          ),
        ],
      ),
      body: vm.notes.isEmpty
          ? const Center(child: Text('Нет заметок'))
          : ListView.separated(
        itemCount: vm.notes.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final note = vm.notes[i];
          return Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => vm.deleteNote(note),
            child: ListTile(
              title: Text(note.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(
                      DateTime.fromMillisecondsSinceEpoch(note.timestamp),
                    ),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showDialog<bool>(
            context: context,
            builder: (_) => ChangeNotifierProvider.value(
              value: vm,
              child: const AddNoteDialog(),
            ),
          );
          if (saved == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Заметка сохранена')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}