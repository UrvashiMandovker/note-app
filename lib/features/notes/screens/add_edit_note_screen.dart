import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app2/core/constants/app_constants.dart';
import 'package:note_app2/features/auth/bloc/auth_bloc.dart';
import 'package:note_app2/features/auth/bloc/auth_state.dart';
import 'package:note_app2/features/notes/bloc/notes_bloc.dart';
import 'package:note_app2/features/notes/bloc/notes_event.dart';
import 'package:note_app2/features/notes/models/note_model.dart';

class AddEditNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! Authenticated) {
            return const Center(child: Text('Please login to continue'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return AppConstants.titleRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppConstants.contentRequired;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final note = NoteModel(
                          id: widget.note?.id ?? '',
                          title: _titleController.text,
                          content: _contentController.text,
                          createdAt: widget.note?.createdAt ?? DateTime.now(),
                          updatedAt: DateTime.now(),
                          userId: authState.user.id,
                        );

                        if (widget.note == null) {
                          context.read<NotesBloc>().add(AddNoteEvent(note));
                        } else {
                          context.read<NotesBloc>().add(UpdateNoteEvent(note));
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              widget.note == null 
                                ? 'Adding note...' 
                                : 'Updating note...'
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );

                        Navigator.pop(context, true);
                      }
                    },
                    child: Text(widget.note == null ? 'Add Note' : 'Update Note'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 