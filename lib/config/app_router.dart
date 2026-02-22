import 'package:go_router/go_router.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/assessment_screen.dart';
import '../screens/main_layout.dart';
import '../screens/mood/mood_check_in_screen.dart';
import '../screens/mood/mood_history_screen.dart';
import '../screens/chat/chat_screen.dart';
import '../screens/journal/journal_list_screen.dart';
import '../screens/journal/journal_entry_screen.dart';
import '../screens/assessment/assessment_result_screen.dart';
import '../screens/insights/insights_screen.dart';
import '../screens/resources/resources_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/assessment',
        builder: (context, state) => const AssessmentScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayout(),
      ),
      GoRoute(
        path: '/mood-check-in',
        builder: (context, state) => const MoodCheckInScreen(),
      ),
      GoRoute(
        path: '/mood-history',
        builder: (context, state) => const MoodHistoryScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
      GoRoute(
        path: '/journals',
        builder: (context, state) => const JournalListScreen(),
      ),
      GoRoute(
        path: '/journal-entry',
        builder: (context, state) => const JournalEntryScreen(),
      ),
      GoRoute(
        path: '/journal-entry/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return JournalEntryScreen(journalId: id);
        },
      ),
      GoRoute(
        path: '/assessment-result',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>?;
          return AssessmentResultScreen(
            score: extras?['score'] ?? 0,
            riskLevel: extras?['riskLevel'] ?? 'Low',
          );
        },
      ),
      GoRoute(
        path: '/insights',
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/resources',
        builder: (context, state) => const ResourcesScreen(),
      ),
    ],
  );
}
