import 'package:flutter/material.dart';

import 'screens/add_exam_screen.dart';
import 'screens/add_question_screen.dart';
import 'screens/admin_dashboard.dart';
import 'screens/analytics_screen.dart';
import 'screens/edit_exam_screen.dart';
import 'screens/edit_question_screen.dart';
import 'screens/exam_detail_screen.dart';
import 'screens/exam_list_screen.dart';
import 'screens/exam_result_screen.dart';
import 'screens/login_screen.dart';
import 'screens/my_results_screen.dart';
import 'screens/question_list_screen.dart';
import 'screens/register_screen.dart';
import 'screens/student_dashboard.dart';
import 'screens/take_exam_screen.dart';

void main() {
  runApp(const OnlineExamApp());
}

class OnlineExamApp extends StatelessWidget {
  const OnlineExamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Online Examination & Evaluation System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/admin-dashboard': (context) => const AdminDashboard(),
        '/student-dashboard': (context) => const StudentDashboard(),
        '/exam-list': (context) => const ExamListScreen(),
        '/add-exam': (context) => const AddExamScreen(),
        '/question-list': (context) => const QuestionListScreen(),
        '/add-question': (context) => const AddQuestionScreen(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/my-results': (context) => const MyResultsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/edit-exam') {
          return MaterialPageRoute(
            builder: (context) => EditExamScreen(exam: settings.arguments as Map<String, dynamic>),
          );
        }
        if (settings.name == '/exam-detail') {
          return MaterialPageRoute(
            builder: (context) => ExamDetailScreen(exam: settings.arguments as Map<String, dynamic>),
          );
        }
        if (settings.name == '/take-exam') {
          return MaterialPageRoute(
            builder: (context) => TakeExamScreen(exam: settings.arguments as Map<String, dynamic>),
          );
        }
        if (settings.name == '/exam-result') {
          return MaterialPageRoute(
            builder: (context) => ExamResultScreen(result: settings.arguments as Map<String, dynamic>),
          );
        }
        if (settings.name == '/edit-question') {
          return MaterialPageRoute(
            builder: (context) => EditQuestionScreen(question: settings.arguments as Map<String, dynamic>),
          );
        }
        return null;
      },
    );
  }
}
