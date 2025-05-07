# note_app2

# 📓 Note App

A Flutter application for managing personal notes with secure authentication, built using the BLoC pattern and clean architecture. This app allows users to register or sign in via Firebase Authentication and perform full CRUD operations on their notes.

---

## 🔐 Features

### ✨ Authentication
- Firebase Email/Password login and signup
- Form validation with inline error messages
- Error handling and loading states

### 📝 Notes Management
- View a list of all your notes
- Create new notes with timestamps
- Edit existing notes
- Delete notes with confirmation
- Pull to refresh for updating the list

### ⚙️ Technical Stack
- **Flutter** & **Dart**
- **Firebase Authentication** & **Cloud Firestore**
- **BLoC** state management
- **Clean architecture** for separation of concerns
- **Dynamic theming** (Light/Dark mode toggle)

### 🖼️ UI Screens
- Login / Signup screen
- Notes listing screen
- Add / Edit note screen
- Theme toggle in UI

---

## 🎁 Bonus Features
- Swipe to delete with undo (via Snackbar)
- Optional offline support (with caching)

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Firebase project setup

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/UrvashiMandovker/note-app.git
   cd note-app
