import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final FirebaseFirestore _firestore;

  NotesBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(NotesInitial()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteNoteEvent>(_onDeleteNote);
  }

  Future<void> _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: event.userId)
          .get();

      if (snapshot.docs.isEmpty) {
        emit(NotesLoaded([]));
        return;
      }

      final notes = snapshot.docs
          .map((doc) {
            try {
              return NoteModel.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              return null;
            }
          })
          .where((note) => note != null)
          .cast<NoteModel>()
          .toList();

      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(NotesLoaded(notes));
    } catch (e, stackTrace) {
      emit(NotesError('Failed to load notes: ${e.toString()}'));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final isRestoring = event.note.id.isNotEmpty;
      final note = isRestoring
          ? event.note
          : event.note.copyWith(
              id: const Uuid().v4(),
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );


      await _firestore.collection('notes').doc(note.id).set(note.toJson()).then((_) {
      }).catchError((e) {
      });

      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: note.userId)
          .get();

      final notes = snapshot.docs
          .map((doc) {
            try {
              return NoteModel.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              return null;
            }
          })
          .where((note) => note != null)
          .cast<NoteModel>()
          .toList();

      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('Failed to add note: ${e.toString()}'));
    }
  }
  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      final note = event.note.copyWith(updatedAt: DateTime.now());

      await _firestore.collection('notes').doc(note.id).update(note.toJson());
      
      final snapshot = await _firestore
          .collection('notes')
          .where('userId', isEqualTo: note.userId)
          .get();

      final notes = snapshot.docs
          .map((doc) {
            try {
              return NoteModel.fromJson({...doc.data(), 'id': doc.id});
            } catch (e) {
              print('Error parsing document ${doc.id}: $e');
              return null;
            }
          })
          .where((note) => note != null)
          .cast<NoteModel>()
          .toList();

      notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('Failed to update note: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteNote(DeleteNoteEvent event, Emitter<NotesState> emit) async {
    try {
      emit(NotesLoading());
      
      final noteDoc = await _firestore.collection('notes').doc(event.noteId).get();
      final userId = noteDoc.data()?['userId'] as String?;
      
      await _firestore.collection('notes').doc(event.noteId).delete();
      
      if (userId != null) {
        final snapshot = await _firestore
            .collection('notes')
            .where('userId', isEqualTo: userId)
            .get();

        final notes = snapshot.docs
            .map((doc) {
              try {
                return NoteModel.fromJson({...doc.data(), 'id': doc.id});
              } catch (e) {
                print('Error parsing document ${doc.id}: $e');
                return null;
              }
            })
            .where((note) => note != null)
            .cast<NoteModel>()
            .toList();

        notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        emit(NotesLoaded(notes));
      } else {
        emit(NotesError('Failed to reload notes after deletion'));
      }
    } catch (e) {
      emit(NotesError('Failed to delete note: ${e.toString()}'));
    }
  }
} 