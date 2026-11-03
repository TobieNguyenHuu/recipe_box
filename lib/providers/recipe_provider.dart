import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/recipe.dart';

class RecipeProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _subscription;

  List<Recipe> _allRecipes = [];
  bool _isLoading = true;
  String _currentUserId = '';

  // Filter & Search states
  String _selectedCategory = 'All';
  String _selectedDifficulty = 'All';
  bool _favoritesOnly = false;
  String _searchQuery = '';

  List<Recipe> get allRecipes => _allRecipes;
  bool get isLoading => _isLoading;
  String get selectedCategory => _selectedCategory;
  String get selectedDifficulty => _selectedDifficulty;
  bool get favoritesOnly => _favoritesOnly;
  String get searchQuery => _searchQuery;

  void updateUserId(String userId) {
    if (_currentUserId == userId && _subscription != null) return;
    _currentUserId = userId;
    _subscription?.cancel();

    if (userId.isEmpty) {
      _allRecipes = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _subscription = _firestore
        .collection('recipes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _allRecipes = snapshot.docs.map((doc) => Recipe.fromFirestore(doc)).toList();
        // Sort: cook time shortest first; equal cook times ordered by name, case-insensitive
        _sortRecipes(_allRecipes);
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _sortRecipes(List<Recipe> list) {
    list.sort((a, b) {
      final timeCompare = a.cookTime.compareTo(b.cookTime);
      if (timeCompare != 0) return timeCompare;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
  }

  // Filtered recipes
  List<Recipe> get filteredRecipes {
    final query = _searchQuery.trim().toLowerCase();

    final result = _allRecipes.where((recipe) {
      // Category filter
      if (_selectedCategory != 'All' && recipe.category != _selectedCategory) {
        return false;
      }
      // Difficulty filter
      if (_selectedDifficulty != 'All' && recipe.difficulty != _selectedDifficulty) {
        return false;
      }
      // Favorites only
      if (_favoritesOnly && !recipe.favorite) {
        return false;
      }
      // Search query in name or notes
      if (query.isNotEmpty) {
        final matchesName = recipe.name.toLowerCase().contains(query);
        final matchesNotes = recipe.notes.toLowerCase().contains(query);
        if (!matchesName && !matchesNotes) {
          return false;
        }
      }
      return true;
    }).toList();

    _sortRecipes(result);
    return result;
  }

  // Summary calculations
  int get recipeCount => filteredRecipes.length;

  int get favoriteCount => filteredRecipes.where((r) => r.favorite).length;

  int get totalCookTime => filteredRecipes.fold(0, (total, r) => total + r.cookTime);

  /// Category breakdown:
  /// Category with the most recipes first.
  /// Equal counts order: Breakfast, Lunch, Dinner, then Dessert.
  List<MapEntry<String, int>> get categoryBreakdown {
    final Map<String, int> counts = {};
    for (final recipe in filteredRecipes) {
      counts[recipe.category] = (counts[recipe.category] ?? 0) + 1;
    }

    final priority = {
      'Breakfast': 1,
      'Lunch': 2,
      'Dinner': 3,
      'Dessert': 4,
    };

    final entries = counts.entries.toList();
    entries.sort((a, b) {
      final countCompare = b.value.compareTo(a.value); // highest count first
      if (countCompare != 0) return countCompare;
      final prioA = priority[a.key] ?? 99;
      final prioB = priority[b.key] ?? 99;
      return prioA.compareTo(prioB);
    });

    return entries;
  }

  // Filter setters
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setDifficulty(String difficulty) {
    _selectedDifficulty = difficulty;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    _favoritesOnly = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _selectedDifficulty = 'All';
    _favoritesOnly = false;
    _searchQuery = '';
    notifyListeners();
  }

  // Database operations
  Future<void> addRecipe({
    required String name,
    required String category,
    required String difficulty,
    required int cookTime,
    int? servings,
    String? notes,
  }) async {
    if (_currentUserId.isEmpty) {
      throw Exception('User is not logged in');
    }

    final trimmedName = name.trim();
    final normalizedName = trimmedName.toLowerCase();

    // Check if duplicate name exists for this user (case-insensitive)
    final isDuplicate = _allRecipes.any(
      (r) => r.name.trim().toLowerCase() == normalizedName,
    );
    if (isDuplicate) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A recipe with the name "$trimmedName" already exists.',
      );
    }

    final docId = '${_currentUserId}_$normalizedName';
    final docRef = _firestore.collection('recipes').doc(docId);

    final docSnap = await docRef.get();
    if (docSnap.exists) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'already-exists',
        message: 'A recipe with the name "$trimmedName" already exists.',
      );
    }

    final data = {
      'id': docId,
      'userId': _currentUserId,
      'name': trimmedName,
      'category': category,
      'difficulty': difficulty,
      'cookTime': cookTime,
      'servings': servings,
      'favorite': false,
      'notes': notes?.trim() ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(data);
  }

  Future<void> toggleFavorite(Recipe recipe) async {
    final newFavorite = !recipe.favorite;
    await _firestore.collection('recipes').doc(recipe.id).update({
      'favorite': newFavorite,
    });
  }

  Future<void> updateRecipe({
    required Recipe recipe,
    required String name,
    required String category,
    required String difficulty,
    required int cookTime,
    int? servings,
    String? notes,
  }) async {
    if (_currentUserId.isEmpty) {
      throw Exception('User is not logged in');
    }

    final trimmedName = name.trim();
    final normalizedName = trimmedName.toLowerCase();
    final newDocId = '${_currentUserId}_$normalizedName';

    // If the name changed, check uniqueness
    if (trimmedName.toLowerCase() != recipe.name.trim().toLowerCase()) {
      final isDuplicate = _allRecipes.any(
        (r) => r.id != recipe.id && r.name.trim().toLowerCase() == normalizedName,
      );
      if (isDuplicate) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'A recipe with the name "$trimmedName" already exists.',
        );
      }

      // Check if document exists in Firestore
      final newDocSnap = await _firestore.collection('recipes').doc(newDocId).get();
      if (newDocSnap.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'already-exists',
          message: 'A recipe with the name "$trimmedName" already exists.',
        );
      }

      // Atomically create new document and delete old document
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('recipes').doc(recipe.id));
      batch.set(_firestore.collection('recipes').doc(newDocId), {
        'id': newDocId,
        'userId': _currentUserId,
        'name': trimmedName,
        'category': category,
        'difficulty': difficulty,
        'cookTime': cookTime,
        'servings': servings,
        'favorite': recipe.favorite,
        'notes': notes?.trim() ?? '',
        'createdAt': recipe.createdAt != null
            ? Timestamp.fromDate(recipe.createdAt!)
            : FieldValue.serverTimestamp(),
      });
      await batch.commit();
    } else {
      // Just update existing document
      await _firestore.collection('recipes').doc(recipe.id).update({
        'name': trimmedName,
        'category': category,
        'difficulty': difficulty,
        'cookTime': cookTime,
        'servings': servings,
        'notes': notes?.trim() ?? '',
      });
    }
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestore.collection('recipes').doc(recipeId).delete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
