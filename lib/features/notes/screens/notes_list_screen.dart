import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:note_app2/features/auth/bloc/auth_bloc.dart';
import 'package:note_app2/features/auth/bloc/auth_state.dart';
import 'package:note_app2/features/notes/bloc/notes_bloc.dart';
import 'package:note_app2/features/notes/bloc/notes_event.dart';
import 'package:note_app2/features/notes/bloc/notes_state.dart';
import 'package:note_app2/features/notes/models/note_model.dart';
import 'package:note_app2/features/notes/screens/add_edit_note_screen.dart';
import 'package:note_app2/core/theme/theme_bloc.dart';

import '../../auth/bloc/auth_event.dart';

class NotesListScreen extends StatelessWidget {
  const NotesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notesBloc = context.read<NotesBloc>();
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Authenticated) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              title: Row(
                children: [
                  const Icon(Icons.sticky_note_2, color: Colors.white, size: 32),
                  const SizedBox(width: 8),
                  Text(
                    'My Notes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const Spacer(),
                ],
              ),
              actions: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    return IconButton(
                      icon: Icon(
                        themeState.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      },
                      tooltip: 'Toggle Theme',
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Logout',
                  onPressed: () {
                    context.read<AuthBloc>().add(LogoutEvent());
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditNoteScreen(),
                      ),
                    );
                    if (result == true) {
                      if (!context.mounted) return;
                      context.read<NotesBloc>().add(LoadNotesEvent(authState.user.id));
                    }
                  },
                ),
              ],
            ),
            body: BlocConsumer<NotesBloc, NotesState>(
              listener: (context, state) {
                if (state is NotesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is NotesInitial) {
                  context.read<NotesBloc>().add(LoadNotesEvent(authState.user.id));
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is NotesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (state is NotesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<NotesBloc>().add(LoadNotesEvent(authState.user.id));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is NotesLoaded) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotesBloc>().add(LoadNotesEvent(authState.user.id));
                    },
                    child: state.notes.isEmpty
                        ? const Center(child: Text('No notes yet. Add your first note!'))
                        : ListView.builder(
                            itemCount: state.notes.length,
                            itemBuilder: (context, index) {
                              final note = state.notes[index];
                              return Dismissible(
                                key: ValueKey(note.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                confirmDismiss: (direction) async {
                                  return true;
                                },
                                onDismissed: (direction) {
                                  final deletedNote = note;
                                  notesBloc.add(DeleteNoteEvent(note.id));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text('Note deleted'),
                                      action: SnackBarAction(
                                        label: 'Undo',
                                        onPressed: () {
                                          notesBloc.add(AddNoteEvent(deletedNote));
                                        },
                                      ),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                },
                                child: NoteCard(note: note),
                              );
                            },
                          ),
                  );
                }
                
                return const Center(child: Text('No notes found'));
              },
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Please login to view notes')),
        );
      },
    );
  }
}

class NoteCard extends StatelessWidget {
  final NoteModel note;

  const NoteCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM dd, yyyy HH:mm').format(note.updatedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditNoteScreen(note: note),
                ),
              );
            } else if (value == 'delete') {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Note'),
                  content: const Text('Are you sure you want to delete this note?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<NotesBloc>().add(DeleteNoteEvent(note.id));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Deleting note...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditNoteScreen(note: note),
            ),
          );
        },
      ),
    );
  }
} 