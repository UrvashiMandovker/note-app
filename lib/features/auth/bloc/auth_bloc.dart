import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;

  AuthBloc({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<SignupEvent>(_onSignup);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
        );
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
    } catch (e) {
      emit(const AuthError('Something went wrong'));
    }
  }

  Future<void> _onSignup(SignupEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (userCredential.user != null) {
        if (event.displayName != null) {
          await userCredential.user!.updateDisplayName(event.displayName);
        }
        final user = UserModel(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
        );
        emit(Authenticated(user));
      } else {
        emit(const AuthError('Signup failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Signup failed'));
    } catch (e) {
      emit(const AuthError('Something went wrong'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await _auth.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(const AuthError('Logout failed'));
    }
  }

  Future<void> _onCheckAuthStatus(
      CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final user = _auth.currentUser;
      if (user != null) {
        final userModel = UserModel(
          id: user.uid,
          email: user.email!,
          displayName: user.displayName,
          photoURL: user.photoURL,
        );
        emit(Authenticated(userModel));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(const AuthError('Failed to check authentication status'));
    }
  }
} 