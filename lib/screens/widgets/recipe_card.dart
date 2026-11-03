import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import '../recipe/detail_screen.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onToggleFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onToggleFavorite,
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Breakfast':
        return Icons.free_breakfast_outlined;
      case 'Lunch':
        return Icons.lunch_dining_outlined;
      case 'Dinner':
        return Icons.dinner_dining_outlined;
      case 'Dessert':
        return Icons.cake_outlined;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor(recipe.difficulty);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(recipeId: recipe.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Category Icon
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.deepOrange.shade50,
                child: Icon(
                  _getCategoryIcon(recipe.category),
                  color: Colors.deepOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipe.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: difficultyColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipe.difficulty,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: difficultyColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Cook time (e.g. "25 min")
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 14,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${recipe.cookTime} min',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Favorite Toggle Star button
              IconButton(
                icon: Icon(
                  recipe.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: recipe.favorite ? Colors.amber.shade700 : Colors.grey,
                  size: 28,
                ),
                onPressed: onToggleFavorite,
                tooltip: recipe.favorite ? 'Unmark favorite' : 'Mark favorite',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
