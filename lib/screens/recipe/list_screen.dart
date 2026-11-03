import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/recipe_provider.dart';
import '../home_screen.dart';
import '../widgets/add_recipe_form.dart';
import '../widgets/recipe_card.dart';
import '../widgets/summary_card.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final _searchController = TextEditingController();
  bool _showAddForm = false;

  final List<String> _categoryOptions = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Dessert',
  ];

  final List<String> _difficultyOptions = [
    'All',
    'Easy',
    'Medium',
    'Hard',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AppAuthProvider>(context, listen: false);
      final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      recipeProvider.updateUserId(auth.userId);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleLogout() async {
    final auth = Provider.of<AppAuthProvider>(context, listen: false);
    final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    recipeProvider.updateUserId('');
    await auth.logout();

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AppAuthProvider>(context);
    final recipeProvider = Provider.of<RecipeProvider>(context);

    // If auth is loading, show loading spinner
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Keep user id in sync
    if (auth.userId.isNotEmpty && recipeProvider.isLoading && recipeProvider.allRecipes.isEmpty) {
      recipeProvider.updateUserId(auth.userId);
    }

    final filteredList = recipeProvider.filteredRecipes;

    return PopScope(
      canPop: false, // Pressing phone's back button must not return to Login or Register
      onPopInvokedWithResult: (didPop, result) {
        // Prevent accidental exit or navigation to login
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Do not show back button to Login/Register
          title: Text(
            auth.userEmail,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: _handleLogout,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            recipeProvider.updateUserId(auth.userId);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Action: Toggle Add Recipe Form
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RecipeBox Collection',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showAddForm ? Colors.grey.shade700 : Colors.deepOrange,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _showAddForm = !_showAddForm;
                          });
                        },
                        icon: Icon(_showAddForm ? Icons.close : Icons.add),
                        label: Text(_showAddForm ? 'Close Form' : 'New Recipe'),
                      ),
                    ],
                  ),
                ),

                // Section A: Add Recipe Form
                if (_showAddForm) const AddRecipeForm(),

                // Filter & Search Controls
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Box
                        TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search by recipe name or notes...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      recipeProvider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          onChanged: (val) {
                            recipeProvider.setSearchQuery(val);
                          },
                        ),
                        const SizedBox(height: 12),
                        // Category & Difficulty dropdowns
                        Row(
                          children: [
                            // Category filter
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: recipeProvider.selectedCategory,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                items: _categoryOptions.map((cat) {
                                  return DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) recipeProvider.setCategory(val);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Difficulty filter
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: recipeProvider.selectedDifficulty,
                                decoration: const InputDecoration(
                                  labelText: 'Difficulty',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                items: _difficultyOptions.map((diff) {
                                  return DropdownMenuItem(
                                    value: diff,
                                    child: Text(diff, style: const TextStyle(fontSize: 13)),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) recipeProvider.setDifficulty(val);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Favorites only switch & Clear button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Switch(
                                  value: recipeProvider.favoritesOnly,
                                  activeThumbColor: Colors.deepOrange,
                                  onChanged: (val) {
                                    recipeProvider.setFavoritesOnly(val);
                                  },
                                ),
                                const Text(
                                  'Favorites only',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            OutlinedButton.icon(
                              onPressed: () {
                                _searchController.clear();
                                recipeProvider.clearFilters();
                              },
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Clear'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Section C: Summary Card
                const SummaryCard(),

                // Section B: The Recipe List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Text(
                    'Recipes (${filteredList.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                if (recipeProvider.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filteredList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No recipes found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final recipe = filteredList[index];
                      return RecipeCard(
                        recipe: recipe,
                        onToggleFavorite: () async {
                          await recipeProvider.toggleFavorite(recipe);
                        },
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
