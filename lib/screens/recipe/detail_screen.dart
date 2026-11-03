import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';

class DetailScreen extends StatefulWidget {
  final String recipeId;

  const DetailScreen({super.key, required this.recipeId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cookTimeController;
  late TextEditingController _servingsController;
  late TextEditingController _notesController;

  String? _selectedCategory;
  String? _selectedDifficulty;

  bool _submitted = false;
  bool _isSaving = false;
  String? _errorMessage;

  final List<String> _categories = [
    'Choose category',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
  ];

  final List<String> _difficulties = [
    'Choose difficulty',
    'Easy',
    'Medium',
    'Hard',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cookTimeController = TextEditingController();
    _servingsController = TextEditingController();
    _notesController = TextEditingController();
  }

  void _populateControllers(Recipe recipe) {
    _nameController.text = recipe.name;
    _cookTimeController.text = recipe.cookTime.toString();
    _servingsController.text = recipe.servings != null ? recipe.servings.toString() : '';
    _notesController.text = recipe.notes;
    _selectedCategory = recipe.category;
    _selectedDifficulty = recipe.difficulty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(Recipe currentRecipe) async {
    setState(() {
      _submitted = true;
      _errorMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

      final cookTime = int.parse(_cookTimeController.text.trim());
      int? servings;
      if (_servingsController.text.trim().isNotEmpty) {
        servings = int.parse(_servingsController.text.trim());
      }

      await recipeProvider.updateRecipe(
        recipe: currentRecipe,
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        difficulty: _selectedDifficulty!,
        cookTime: cookTime,
        servings: servings,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _isEditing = false;
        _submitted = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe updated successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = e.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
      });
    }
  }

  void _confirmDelete(Recipe recipe) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Recipe'),
          content: Text('Are you sure you want to delete "${recipe.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // close dialog
                final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
                await recipeProvider.deleteRecipe(recipe.id);

                if (!mounted) return;
                Navigator.of(context).pop(); // return to List screen
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // Find the recipe in the provider's list
    final recipeIndex = recipeProvider.allRecipes.indexWhere(
      (r) => r.id == widget.recipeId,
    );

    if (recipeIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recipe Details')),
        body: const Center(
          child: Text(
            'Recipe not found or deleted',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    final recipe = recipeProvider.allRecipes[recipeIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe.name),
        actions: [
          IconButton(
            icon: Icon(
              recipe.favorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: recipe.favorite ? Colors.amber : Colors.white,
              size: 28,
            ),
            onPressed: () async {
              await recipeProvider.toggleFavorite(recipe);
            },
            tooltip: recipe.favorite ? 'Unmark favorite' : 'Mark favorite',
          ),
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Recipe',
              onPressed: () {
                _populateControllers(recipe);
                setState(() {
                  _isEditing = true;
                  _submitted = false;
                  _errorMessage = null;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete Recipe',
              onPressed: () => _confirmDelete(recipe),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: _isEditing ? _buildEditMode(recipe) : _buildViewMode(recipe),
      ),
    );
  }

  Widget _buildViewMode(Recipe recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (recipe.favorite)
                      const Chip(
                        avatar: Icon(Icons.star, color: Colors.amber, size: 18),
                        label: Text('Favorite', style: TextStyle(fontWeight: FontWeight.bold)),
                        backgroundColor: Color(0xFFFFF8E1),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTag(
                      Icons.category_outlined,
                      recipe.category,
                      Colors.blue.shade50,
                      Colors.blue.shade800,
                    ),
                    const SizedBox(width: 8),
                    _buildTag(
                      Icons.speed,
                      recipe.difficulty,
                      Colors.orange.shade50,
                      Colors.orange.shade800,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Metrics card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cooking Specifications',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                _buildDetailRow(
                  Icons.timer_outlined,
                  'Cook time',
                  '${recipe.cookTime} min',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  Icons.people_outline,
                  'Servings',
                  recipe.servings != null ? '${recipe.servings} people' : 'Not specified',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Notes card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notes & Instructions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20),
                Text(
                  recipe.notes.isNotEmpty ? recipe.notes : 'No notes added for this recipe.',
                  style: TextStyle(
                    fontSize: 15,
                    color: recipe.notes.isNotEmpty ? Colors.black87 : Colors.black45,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Edit & Delete bottom buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text('Edit Recipe'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  _populateControllers(recipe);
                  setState(() {
                    _isEditing = true;
                    _submitted = false;
                    _errorMessage = null;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _confirmDelete(recipe),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditMode(Recipe recipe) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Edit Recipe',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
              ),
              const Divider(height: 24),
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  if (value.length > 80) {
                    return 'Name must be at most 80 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val;
                  });
                },
                validator: (val) {
                  if (val == null || val == 'Choose category') {
                    return 'Please choose a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Difficulty Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDifficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.speed),
                ),
                items: _difficulties.map((diff) {
                  return DropdownMenuItem(
                    value: diff,
                    child: Text(diff),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedDifficulty = val;
                  });
                },
                validator: (val) {
                  if (val == null || val == 'Choose difficulty') {
                    return 'Please choose a difficulty';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Cook Time Field
              TextFormField(
                controller: _cookTimeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cook time (minutes) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Cook time is required';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 1 || parsed > 600) {
                    return 'Cook time must be a whole number from 1 to 600';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Servings Field (optional)
              TextFormField(
                controller: _servingsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Servings (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people_outline),
                ),
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final parsed = int.tryParse(value.trim());
                    if (parsed == null || parsed < 1 || parsed > 20) {
                      return 'Servings must be a whole number from 1 to 20';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Notes Field (optional)
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.note_alt_outlined),
                ),
                validator: (value) {
                  if (value != null && value.length > 300) {
                    return 'Notes must be at most 300 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Save and Cancel buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving ? null : () => _handleSave(recipe),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isSaving
                          ? null
                          : () {
                              setState(() {
                                _isEditing = false;
                                _submitted = false;
                                _errorMessage = null;
                              });
                            },
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepOrange),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
