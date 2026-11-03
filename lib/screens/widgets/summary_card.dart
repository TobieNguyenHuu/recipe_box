import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final count = recipeProvider.recipeCount;
    final favorites = recipeProvider.favoriteCount;
    final totalTime = recipeProvider.totalCookTime;
    final breakdown = recipeProvider.categoryBreakdown;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.deepOrange),
                const SizedBox(width: 8),
                Text(
                  'Recipe Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Metrics row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMetricItem(
                  context,
                  label: 'Recipes: $count',
                  icon: Icons.menu_book_rounded,
                  color: Colors.blue,
                ),
                _buildMetricItem(
                  context,
                  label: 'Favorites: $favorites',
                  icon: Icons.star_rounded,
                  color: Colors.amber.shade800,
                ),
                _buildMetricItem(
                  context,
                  label: 'Total time: $totalTime min',
                  icon: Icons.schedule_rounded,
                  color: Colors.green,
                ),
              ],
            ),
            if (breakdown.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Category Breakdown:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              // Category rows
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: breakdown.map((entry) {
                  return Chip(
                    avatar: CircleAvatar(
                      backgroundColor: Colors.deepOrange.shade100,
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                    label: Text('${entry.key}: ${entry.value}'),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide(color: Colors.grey.shade300),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
