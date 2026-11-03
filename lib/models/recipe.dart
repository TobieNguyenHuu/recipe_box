import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String userId;
  final String name;
  final String category;
  final String difficulty;
  final int cookTime;
  final int? servings;
  final bool favorite;
  final String notes;
  final DateTime? createdAt;

  Recipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.cookTime,
    this.servings,
    this.favorite = false,
    this.notes = '',
    this.createdAt,
  });

  factory Recipe.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    
    DateTime? created;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      created = rawCreatedAt.toDate();
    } else if (rawCreatedAt is int) {
      created = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else if (rawCreatedAt is String) {
      created = DateTime.tryParse(rawCreatedAt);
    }

    return Recipe(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? 'Breakfast',
      difficulty: data['difficulty'] as String? ?? 'Easy',
      cookTime: (data['cookTime'] as num?)?.toInt() ?? 0,
      servings: (data['servings'] as num?)?.toInt(),
      favorite: data['favorite'] as bool? ?? false,
      notes: data['notes'] as String? ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'difficulty': difficulty,
      'cookTime': cookTime,
      'servings': servings,
      'favorite': favorite,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }

  Recipe copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    String? difficulty,
    int? cookTime,
    int? servings,
    bool? favorite,
    String? notes,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      cookTime: cookTime ?? this.cookTime,
      servings: servings ?? this.servings,
      favorite: favorite ?? this.favorite,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
