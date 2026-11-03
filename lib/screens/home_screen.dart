import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';
import 'recipe/list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);

    // If still checking auth state, show loading indicator (no flash)
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // When logged in, app opens directly on the List screen
    if (authProvider.isAuthenticated) {
      return const ListScreen();
    }

    // Public Home Screen (when logged out)
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RecipeBox',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).primaryColor,
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text(
              'Register',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'RecipeBox',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'A personal private collection of recipes you cook or want to try, organized into meal categories and difficulty levels.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Feature cards
            _buildFeatureCard(
              icon: Icons.bookmark_added_rounded,
              title: 'Save your recipes',
              description:
                  'Keep all your culinary creations and cooking notes safely stored in one place.',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.timer_outlined,
              title: 'Sort by cooking time',
              description:
                  'Instantly view your recipes sorted from fastest to longest cooking times.',
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              icon: Icons.star_rounded,
              title: 'Mark your favorites',
              description:
                  'Highlight your top-rated favorite meals for quick access anytime.',
            ),
            const SizedBox(height: 36),
            ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Get Started - Login'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.deepOrange.shade50,
              child: Icon(icon, color: Colors.deepOrange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
