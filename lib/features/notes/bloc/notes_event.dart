import 'package:equatable/equatable.dart';
import '../models/note_model.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotesEvent extends NotesEvent {
  final String userId;

  const LoadNotesEvent(this.userId);

  @override
  List<Object> get props => [userId];
}

class AddNoteEvent extends NotesEvent {
  final NoteModel note;

  const AddNoteEvent(this.note);

  @override
  List<Object> get props => [note];
}

class UpdateNoteEvent extends NotesEvent {
  final NoteModel note;

  const UpdateNoteEvent(this.note);

  @override
  List<Object> get props => [note];
}

class DeleteNoteEvent extends NotesEvent {
  final String noteId;

  const DeleteNoteEvent(this.noteId);

  @override
  List<Object> get props => [noteId];
} 