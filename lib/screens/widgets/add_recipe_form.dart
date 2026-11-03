import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/recipe_provider.dart';

class AddRecipeForm extends StatefulWidget {
  const AddRecipeForm({super.key});

  @override
  State<AddRecipeForm> createState() => _AddRecipeFormState();
}

class _AddRecipeFormState extends State<AddRecipeForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedDifficulty;

  bool _submitted = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

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
    _selectedCategory = 'Choose category';
    _selectedDifficulty = 'Choose difficulty';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _nameController.clear();
    _cookTimeController.clear();
    _servingsController.clear();
    _notesController.clear();
    setState(() {
      _selectedCategory = 'Choose category';
      _selectedDifficulty = 'Choose difficulty';
      _submitted = false;
    });
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _submitted = true;
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);

      final cookTime = int.parse(_cookTimeController.text.trim());
      int? servings;
      if (_servingsController.text.trim().isNotEmpty) {
        servings = int.parse(_servingsController.text.trim());
      }

      await recipeProvider.addRecipe(
        name: _nameController.text.trim(),
        category: _selectedCategory!,
        difficulty: _selectedDifficulty!,
        cookTime: cookTime,
        servings: servings,
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;

      _clearForm();
      setState(() {
        _isLoading = false;
        _successMessage = 'Recipe added';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recipe added'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst(RegExp(r'^\[.*?\]\s*'), '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.onUserInteraction
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.deepOrange),
                  const SizedBox(width: 8),
                  Text(
                    'Add a recipe',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name *',
                  hintText: 'e.g. Pho Bo',
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
                  return DropdownMenuItem<String>(
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
                  return DropdownMenuItem<String>(
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
                  hintText: 'e.g. 25',
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
                  hintText: 'e.g. 4',
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
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. Best served hot with lime and fresh basil',
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
              // Error Message on form
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
              // Success Message on form
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              // Submit Button
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleSubmit,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.add),
                label: const Text(
                  'Add Recipe',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
