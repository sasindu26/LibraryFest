# 📚 LibraryFest - Your Library Management System

<div align="center">
  
  ### Your Complete Library Management Solution
  
  ![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
  ![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)
  ![License](https://img.shields.io/badge/License-MIT-green.svg)
</div>

## Description

**LibraryFest** is a comprehensive library management mobile application designed to streamline the book borrowing and management process for educational institutions. This full-stack mobile application offers a complete suite of library management functionalities with both frontend and backend integration. The key features of the application include:

### 🎓 For Students & Members

- **User Authentication & Profiles**: Secure user registration and login with Google Sign-In support, personalized profile management with photo upload, and complete borrowing history.

- **Book Catalog & Search**: Extensive book browsing with multiple categories, advanced filters, and powerful search functionality to help users find exactly what they need.

- **Favorites & Wishlist**: Save favorite books for quick access and future reference.

- **Borrow Request System**: Submit book borrow requests with officer approval workflow, real-time status updates (Pending/Approved/Rejected), and due date tracking.

- **Borrowing History**: Complete history of borrowed, returned, and rejected books with detailed information and status badges.

- **Real-time Updates**: Instant notifications when borrow requests are approved or rejected by library officers.

### 👨‍💼 For Library Officers & Admins

- **Admin Dashboard**: Comprehensive statistics including total books, borrowed books, returned books, and categories.

- **Borrow Request Management**: Real-time view of pending borrow requests with approve/reject capabilities and borrower contact information.

- **Book Management**: Add, edit, and delete books with support for multiple categories, cover image uploads, and inventory tracking.

- **Track Borrowers**: Search any book to see who has borrowed it, view complete borrower information (name, student index, email, phone, address), and identify overdue books.

- **User Management**: View and manage student/member profiles with university index number verification.

### ✨ Key Features

- **Multi-Category Support**: Books can belong to multiple categories (e.g., Fiction, Fantasy, Adventure) and appear in each category separately.

- **Profile Completion Enforcement**: New users are required to provide contact information and university index number before accessing the app.

- **Real-time Synchronization**: All changes (approvals, rejections, returns) are reflected instantly across all devices using Firebase Firestore streams.

- **Secure Authentication**: Support for both email/password and Google Sign-In with proper session management and logout functionality.

- **Forgot Password**: Password reset functionality via email for users who forget their credentials.

- **Beautiful UI**: Modern, intuitive interface with iOS-style design elements and smooth animations.

The front-end of LibraryFest is developed using **Flutter**, providing a beautiful, responsive cross-platform experience that works seamlessly on both Android and iOS devices with a single codebase.

The back-end is powered by **Firebase**, offering robust cloud infrastructure including:

- **Firebase Authentication** for secure user management (Email/Password & Google Sign-In)
- **Cloud Firestore** for real-time database operations and instant synchronization
- **Firebase Storage** for book cover images and user profile photos
- **Real-time Listeners** for live updates of borrow requests and book availability

## Technical Stack

| Frontend | Backend | State Management | Authentication | Storage |
|----------|---------|------------------|----------------|---------|
| Flutter 3.0+ | Firebase | Provider | Firebase Auth | Firebase Storage |
| Dart | Cloud Firestore | - | Google Sign-In | Cloud Storage |
| Material Design | - | - | Email/Password | - |

### Key Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.15.2
  firebase_auth: ^5.7.0
  cloud_firestore: ^5.6.12
  firebase_storage: ^12.4.10
  google_sign_in: ^6.3.0
  provider: ^6.1.2
  image_picker: ^1.1.2
  google_fonts: ^6.2.1
  intl: ^0.19.0
```

### Student Interface
- Login & Registration
- Home Dashboard with Quick Stats
- Book Catalog with Categories
- Book Details & Borrow Request
- My Books (Pending & Borrowed)
- Borrowing History
- Favorites
- User Profile with Photo Upload

### Admin Interface
- Admin Dashboard
- Borrow Requests Management
- Book Management (Add/Edit/Delete)
- Track Borrowers
- User Management

## License

LibraryFest is licensed under the **MIT License**. Feel free to modify and distribute the code, subject to the terms and conditions of this license.

See the [LICENSE](LICENSE) file for more details.

## Installation

To install and run LibraryFest on your device, follow these steps:

### Prerequisites

Make sure you have the following installed and properly configured in your development environment before proceeding:

1. **Flutter SDK** (version 3.0 or higher)
2. **Android Studio** or **Xcode** (for iOS development)
3. **Firebase Project** set up with the following services enabled:
   - Authentication (Email/Password & Google Sign-In)
   - Cloud Firestore
   - Firebase Storage

For detailed instructions on setting up Flutter, refer to the official documentation: [Getting Started with Flutter](https://docs.flutter.dev/get-started/install)

### Firebase Setup

1. Create a new Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an Android and/or iOS app to your Firebase project
3. Download the configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)
4. Enable Authentication methods:
   - Go to Authentication → Sign-in method
   - Enable Email/Password
   - Enable Google Sign-In
5. Create a Cloud Firestore database
6. Set up Firebase Storage

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/sasindu26/LibraryFest.git](https://github.com/sasindu26/LibraryFest.git)
   ```

2. **Navigate to the project directory:**
   ```bash
   cd LibraryFest
   ```

3. **Install the necessary dependencies:**
   ```bash
   flutter pub get
   ```

4. **Configure Firebase:**
   - Place your `google-services.json` in `android/app/`
   - Place your `GoogleService-Info.plist` in `ios/Runner/`

5. **Build and run the application:**
   ```bash
   flutter run
   ```
   (Ensure an emulator is running or a device is connected.)

6. **Create an admin account:**
   - Sign up with an email containing "admin" (e.g., `admin@library.com`)
   - This account will have admin privileges

## Usage

### For Students

1. **Sign Up/Login**: Create an account using email or Google Sign-In
2. **Complete Profile**: Provide phone number, address, and university index number
3. **Browse Books**: Explore the catalog using categories or search
4. **Borrow Books**: Request to borrow books (requires officer approval)
5. **Track Status**: Monitor your pending requests and borrowed books
6. **Return Books**: View borrowing history and manage returns

### For Admins

1. **Login**: Use admin credentials (email containing "admin")
2. **Dashboard**: View overall statistics and quick actions
3. **Manage Requests**: Approve or reject borrow requests
4. **Manage Books**: Add, edit, or delete books from the catalog
5. **Track Books**: See who has borrowed any book with full contact details
6. **Manage Users**: View student profiles and contact information

## Features in Detail

### Borrow Approval Workflow

1. Student submits a borrow request → Status: **Pending** (Orange badge)
2. Request appears in admin's "Borrow Requests" screen in real-time
3. Admin reviews and approves → Status: **Approved** (Green badge)
   - Book availability decreases
   - Student can see the book in "Borrowed Books"
   - Counts in Quick Stats "Borrowed"
4. Admin reviews and rejects → Status: **Rejected** (Red badge)
   - Book remains available
   - Appears in student's history as rejected
   - Does not count in statistics

### Real-time Updates

All changes are synchronized instantly:
- Borrow requests appear immediately in admin panel
- Approvals/rejections update student's view instantly
- Book availability updates in real-time
- No manual refresh needed

## Feedback and Contributions

We welcome any feedback or suggestions for improving **LibraryFest**. If you encounter any issues, have ideas for new features, or would like to contribute to the project, please feel free to submit a pull request or open an issue on GitHub.
