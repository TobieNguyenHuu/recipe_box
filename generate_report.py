import os
from docx import Document
from docx.shared import Inches, Pt, Cm, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.enum.section import WD_ORIENT
from docx.oxml.ns import qn

OUTPUT_PATH = r"C:\Users\DELL\.gemini\antigravity\scratch\recipe_box\QE190171.docx"

doc = Document()

# ─── Page Setup ───
for section in doc.sections:
    section.top_margin = Cm(2)
    section.bottom_margin = Cm(2)
    section.left_margin = Cm(2.5)
    section.right_margin = Cm(2.5)

style = doc.styles['Normal']
font = style.font
font.name = 'Times New Roman'
font.size = Pt(13)
style.paragraph_format.space_after = Pt(6)
style.paragraph_format.line_spacing = 1.15

# ─── Helper Functions ───
def add_heading_styled(text, level=1):
    h = doc.add_heading(text, level=level)
    for run in h.runs:
        run.font.color.rgb = RGBColor(0xC0, 0x39, 0x2B)
        run.font.name = 'Times New Roman'
    return h

def add_bold_text(paragraph, text, size=13):
    run = paragraph.add_run(text)
    run.bold = True
    run.font.size = Pt(size)
    run.font.name = 'Times New Roman'
    return run

def add_normal_text(paragraph, text, size=13):
    run = paragraph.add_run(text)
    run.font.size = Pt(size)
    run.font.name = 'Times New Roman'
    return run

def add_code_block(code_text, lang_label=""):
    """Add a code block with monospaced font and grey background."""
    if lang_label:
        p_label = doc.add_paragraph()
        run_label = p_label.add_run(f"📄 {lang_label}")
        run_label.font.size = Pt(10)
        run_label.font.color.rgb = RGBColor(0x66, 0x66, 0x66)
        run_label.font.name = 'Consolas'
        p_label.paragraph_format.space_after = Pt(0)

    for line in code_text.strip().split('\n'):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(0)
        p.paragraph_format.line_spacing = 1.0
        run = p.add_run(line)
        run.font.name = 'Consolas'
        run.font.size = Pt(9)
        run.font.color.rgb = RGBColor(0x2D, 0x2D, 0x2D)
        # Grey background shading
        shading = run._element
        rPr = shading.get_or_add_rPr()
        shd = rPr.makeelement(qn('w:shd'), {
            qn('w:fill'): 'F2F2F2',
            qn('w:val'): 'clear',
        })
        rPr.append(shd)

def add_bullet(text):
    p = doc.add_paragraph(text, style='List Bullet')
    for run in p.runs:
        run.font.name = 'Times New Roman'
        run.font.size = Pt(13)
    return p

def add_info_table(rows_data):
    """rows_data = list of (label, value) tuples"""
    table = doc.add_table(rows=len(rows_data), cols=2)
    table.style = 'Light Grid Accent 1'
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    for i, (label, value) in enumerate(rows_data):
        cell_l = table.cell(i, 0)
        cell_l.text = label
        for p in cell_l.paragraphs:
            for run in p.runs:
                run.bold = True
                run.font.name = 'Times New Roman'
                run.font.size = Pt(12)
        cell_r = table.cell(i, 1)
        cell_r.text = value
        for p in cell_r.paragraphs:
            for run in p.runs:
                run.font.name = 'Times New Roman'
                run.font.size = Pt(12)
    return table

# ═══════════════════════════════════════════════════════════════════════
# COVER PAGE
# ═══════════════════════════════════════════════════════════════════════

for _ in range(3):
    doc.add_paragraph()

p_uni = doc.add_paragraph()
p_uni.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_uni = p_uni.add_run("FPT UNIVERSITY")
run_uni.bold = True
run_uni.font.size = Pt(22)
run_uni.font.color.rgb = RGBColor(0xE8, 0x6C, 0x00)
run_uni.font.name = 'Times New Roman'

p_dept = doc.add_paragraph()
p_dept.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_dept = p_dept.add_run("SOFTWARE ENGINEERING DEPARTMENT")
run_dept.font.size = Pt(14)
run_dept.font.color.rgb = RGBColor(0x66, 0x66, 0x66)
run_dept.font.name = 'Times New Roman'

doc.add_paragraph()

p_line = doc.add_paragraph()
p_line.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_line = p_line.add_run("━" * 40)
run_line.font.color.rgb = RGBColor(0xE8, 0x6C, 0x00)
run_line.font.size = Pt(14)

doc.add_paragraph()

p_title = doc.add_paragraph()
p_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_title = p_title.add_run("PRACTICAL EXAMINATION REPORT")
run_title.bold = True
run_title.font.size = Pt(26)
run_title.font.color.rgb = RGBColor(0xC0, 0x39, 0x2B)
run_title.font.name = 'Times New Roman'

p_sub = doc.add_paragraph()
p_sub.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_sub = p_sub.add_run("PRM393 – Mobile Programming")
run_sub.font.size = Pt(16)
run_sub.font.name = 'Times New Roman'

p_sub2 = doc.add_paragraph()
p_sub2.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_sub2 = p_sub2.add_run("Fall 2026")
run_sub2.font.size = Pt(14)
run_sub2.font.color.rgb = RGBColor(0x99, 0x99, 0x99)
run_sub2.font.name = 'Times New Roman'

doc.add_paragraph()

p_app = doc.add_paragraph()
p_app.alignment = WD_ALIGN_PARAGRAPH.CENTER
run_app = p_app.add_run("📱 RecipeBox Application")
run_app.bold = True
run_app.font.size = Pt(20)
run_app.font.color.rgb = RGBColor(0xE8, 0x6C, 0x00)
run_app.font.name = 'Times New Roman'

for _ in range(3):
    doc.add_paragraph()

# Section 4 Required Submission Format (Template verbatim)
p_sub_hdr = doc.add_paragraph()
r_sub_hdr = p_sub_hdr.add_run("Submission Template (Section 4):")
r_sub_hdr.font.bold = True
r_sub_hdr.font.name = 'Times New Roman'
r_sub_hdr.font.size = Pt(13)

sub_items = [
    ("Student Code: ", "QE190171"),
    ("Full Name: ", "Nguyen Huu Nhat Duy"),
    ("GitHub Repository URL: ", "https://github.com/TobieNguyenHuu/recipe_box"),
    ("APK Download Link: ", "https://github.com/TobieNguyenHuu/recipe_box/releases/download/v1.0/app-release.apk"),
    ("Firebase Project ID: ", "bookshelf-prm393-a61c8"),
    ("Test account email: ", "grader.qe190171@example.com"),
    ("Test account password: ", "Test1234!"),
]
for lbl, val in sub_items:
    p_line = doc.add_paragraph()
    p_line.paragraph_format.space_after = Pt(2)
    r1 = p_line.add_run(lbl)
    r1.font.bold = True
    r1.font.name = 'Times New Roman'
    r1.font.size = Pt(11)
    r2 = p_line.add_run(val)
    r2.font.name = 'Times New Roman'
    r2.font.size = Pt(11)

doc.add_paragraph()

# Section 4 Required Submission Format (Template verbatim)
p_sub_hdr = doc.add_paragraph()
r_sub_hdr = p_sub_hdr.add_run("Submission Template (Section 4):")
r_sub_hdr.font.bold = True
r_sub_hdr.font.name = 'Times New Roman'
r_sub_hdr.font.size = Pt(13)

sub_items = [
    ("Student Code: ", "QE190171"),
    ("Full Name: ", "Nguyen Huu Nhat Duy"),
    ("GitHub Repository URL: ", "https://github.com/TobieNguyenHuu/recipe_box"),
    ("APK Download Link: ", "https://github.com/TobieNguyenHuu/recipe_box/releases/download/v1.0/app-release.apk"),
    ("Firebase Project ID: ", "bookshelf-prm393-a61c8"),
    ("Test account email: ", "grader.qe190171@example.com"),
    ("Test account password: ", "Test1234!"),
]
for lbl, val in sub_items:
    p_line = doc.add_paragraph()
    p_line.paragraph_format.space_after = Pt(2)
    r1 = p_line.add_run(lbl)
    r1.font.bold = True
    r1.font.name = 'Times New Roman'
    r1.font.size = Pt(11)
    r2 = p_line.add_run(val)
    r2.font.name = 'Times New Roman'
    r2.font.size = Pt(11)

doc.add_paragraph()

# Student Info Table on cover
info_table = doc.add_table(rows=4, cols=2)
info_table.alignment = WD_TABLE_ALIGNMENT.CENTER
info_data = [
    ("Student Name", "Nguyễn Hữu Nhật Duy"),
    ("Student Code", "QE190171"),
    ("Class", "SE1870"),
    ("Subject", "PRM393 – Mobile Programming"),
]
for i, (label, value) in enumerate(info_data):
    cell_l = info_table.cell(i, 0)
    cell_r = info_table.cell(i, 1)
    cell_l.text = label
    cell_r.text = value
    for p in cell_l.paragraphs:
        p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        for run in p.runs:
            run.bold = True
            run.font.name = 'Times New Roman'
            run.font.size = Pt(13)
    for p in cell_r.paragraphs:
        for run in p.runs:
            run.font.name = 'Times New Roman'
            run.font.size = Pt(13)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# TABLE OF CONTENTS
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("Table of Contents", level=1)

toc_items = [
    "1. Project Overview",
    "2. Technology Stack",
    "3. Project Structure",
    "4. Firebase Configuration",
    "    4.1. Firebase Project Setup",
    "    4.2. Firebase Authentication",
    "    4.3. Firestore Database",
    "    4.4. Firestore Security Rules",
    "5. Data Model",
    "6. Application Architecture (Provider Pattern)",
    "    6.1. Auth Provider",
    "    6.2. Recipe Provider",
    "7. User Interface Screens",
    "    7.1. Home Screen (Public Landing)",
    "    7.2. Login Screen",
    "    7.3. Register Screen",
    "    7.4. List Screen (Main Dashboard)",
    "    7.5. Detail Screen (View / Edit / Delete)",
    "8. Business Logic & Validation Rules",
    "    8.1. Field Validation (Client-side)",
    "    8.2. Unique Name Constraint (Case-insensitive)",
    "    8.3. Firestore Security Rules (Server-side)",
    "9. Filter, Search & Summary Features",
    "10. Test Account & Sample Data",
    "11. Screenshots",
    "12. Conclusion",
]

for item in toc_items:
    p = doc.add_paragraph(item)
    for run in p.runs:
        run.font.name = 'Times New Roman'
        run.font.size = Pt(12)
    p.paragraph_format.space_after = Pt(2)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 1. PROJECT OVERVIEW
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("1. Project Overview", level=1)

doc.add_paragraph(
    "RecipeBox is a personal private collection of recipes organized into meal categories "
    "(Breakfast, Lunch, Dinner, Dessert) and difficulty levels (Easy, Medium, Hard). "
    "The application is built using Flutter for Android, integrated with Firebase Authentication "
    "for user management and Cloud Firestore for real-time data storage. "
    "Firestore Security Rules enforce strict server-side validation to protect data integrity."
)

doc.add_paragraph(
    "Key features include:"
)

features = [
    "User authentication (Register, Login, Logout) with Firebase Auth",
    "Full CRUD operations on recipes (Create, Read, Update, Delete)",
    "Case-insensitive unique recipe name constraint per user",
    "Client-side and server-side (Firestore Rules) field validation",
    "Filtering by Category, Difficulty, and Favorites",
    "Search by recipe name or notes",
    "Real-time summary dashboard with recipe count, favorite count, total cook time, and category breakdown",
    "Recipes sorted by cook time ascending (ties broken by name alphabetically)",
    "Toggle favorite status with a star icon",
]

for f in features:
    add_bullet(f)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 2. TECHNOLOGY STACK
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("2. Technology Stack", level=1)

tech_data = [
    ("Framework", "Flutter 3.47.9 (Stable Channel)"),
    ("Language", "Dart 3.13.7"),
    ("State Management", "Provider (ChangeNotifier)"),
    ("Backend", "Firebase (Authentication + Cloud Firestore)"),
    ("Security", "Firestore Security Rules v2"),
    ("Target Platform", "Android (minSdk 23 / Android 6.0+)"),
    ("IDE", "Android Studio / VS Code"),
    ("Build Tool", "Gradle 9.3.1"),
]

add_info_table(tech_data)

doc.add_paragraph()
doc.add_paragraph(
    "The application follows a clean separation of concerns using Provider pattern with "
    "ChangeNotifier classes for AuthProvider and RecipeProvider."
)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 3. PROJECT STRUCTURE
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("3. Project Structure", level=1)

structure_text = """lib/
├── main.dart                          # App entry point, Firebase init, Provider setup
├── firebase_options.dart              # Auto-generated Firebase configuration
├── models/
│   └── recipe.dart                    # Recipe data model (fromFirestore, toMap, copyWith)
├── providers/
│   ├── auth_provider.dart             # Authentication state (login, register, logout)
│   └── recipe_provider.dart           # Recipe CRUD, filtering, search, summary
└── screens/
    ├── home_screen.dart               # Public landing page (unauthenticated)
    ├── auth/
    │   ├── login_screen.dart          # Login form with validation
    │   └── register_screen.dart       # Registration form with validation
    ├── recipe/
    │   ├── list_screen.dart           # Main dashboard: list, filter, search, summary
    │   └── detail_screen.dart         # View, Edit, Delete a single recipe
    └── widgets/
        ├── add_recipe_form.dart       # Inline Add Recipe form component
        ├── recipe_card.dart           # Recipe list item card component
        └── summary_card.dart          # Summary statistics card component"""

add_code_block(structure_text, "Project Directory Structure")

doc.add_paragraph()
doc.add_paragraph(
    "Each layer has a clear responsibility: Models define data shape, Providers manage state "
    "and business logic, Screens handle UI rendering, and Widgets are reusable UI components."
)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 4. FIREBASE CONFIGURATION
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("4. Firebase Configuration", level=1)

add_heading_styled("4.1. Firebase Project Setup", level=2)

firebase_info = [
    ("Firebase Project ID", "bookshelf-prm393-a61c8"),
    ("Android App Package", "com.recipebox.recipe_box"),
    ("Firebase App ID", "1:647054908760:android:4212b3e1c0c3c1f20f992d"),
    ("Configuration Tool", "FlutterFire CLI"),
]
add_info_table(firebase_info)

doc.add_paragraph()

add_heading_styled("4.2. Firebase Authentication", level=2)

doc.add_paragraph(
    "Firebase Authentication is configured with Email/Password sign-in method. "
    "The application supports user registration and login. Each user's recipes are "
    "isolated by their unique Firebase UID."
)

add_heading_styled("4.3. Firestore Database", level=2)

doc.add_paragraph(
    "Cloud Firestore is used in Native mode with a single collection named 'recipes'. "
    "Each document in the collection represents one recipe and is identified by a composite "
    "document ID: {userId}_{lowercaseName}. This structure enforces case-insensitive "
    "uniqueness per user at the document level."
)

p = doc.add_paragraph()
add_bold_text(p, "Document Schema:")

schema_data = [
    ("Field", "Type", "Required", "Constraints"),
    ("id", "string", "Yes", "Document ID = {userId}_{name.toLowerCase()}"),
    ("userId", "string", "Yes", "Must match authenticated user's UID"),
    ("name", "string", "Yes", "Non-empty, max 80 chars, unique per user (case-insensitive)"),
    ("category", "string", "Yes", "One of: Breakfast, Lunch, Dinner, Dessert"),
    ("difficulty", "string", "Yes", "One of: Easy, Medium, Hard"),
    ("cookTime", "int", "Yes", "Whole number from 1 to 600"),
    ("servings", "int", "No", "Whole number from 1 to 20 (nullable)"),
    ("favorite", "bool", "Yes", "Default: false"),
    ("notes", "string", "No", "Max 300 chars (nullable)"),
    ("createdAt", "timestamp", "Yes", "Server timestamp on creation"),
]

table = doc.add_table(rows=len(schema_data), cols=4)
table.style = 'Light Grid Accent 1'
table.alignment = WD_TABLE_ALIGNMENT.CENTER
for i, row_data in enumerate(schema_data):
    for j, cell_text in enumerate(row_data):
        cell = table.cell(i, j)
        cell.text = cell_text
        for p in cell.paragraphs:
            for run in p.runs:
                run.font.name = 'Times New Roman'
                run.font.size = Pt(10)
                if i == 0:
                    run.bold = True

doc.add_paragraph()

add_heading_styled("4.4. Firestore Security Rules", level=2)

doc.add_paragraph(
    "Firestore Security Rules enforce all validation constraints at the database level. "
    "This means even if a malicious client bypasses the UI, invalid data is still rejected. "
    "The rules are deployed via Firebase CLI."
)

rules_code = r"""rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /recipes/{recipeId} {
      function isAuthenticated() {
        return request.auth != null;
      }

      function isValidRecipe(data) {
        return data.userId == request.auth.uid
          && data.name is string
          && data.name.trim().size() > 0
          && data.name.size() <= 80
          && data.category in ['Breakfast', 'Lunch', 'Dinner', 'Dessert']
          && data.difficulty in ['Easy', 'Medium', 'Hard']
          && data.cookTime is int
          && data.cookTime >= 1
          && data.cookTime <= 600
          && (!('servings' in data) || data.servings == null
              || (data.servings is int && data.servings >= 1
                  && data.servings <= 20))
          && (!('notes' in data) || data.notes == null
              || (data.notes is string && data.notes.size() <= 300))
          && (!('favorite' in data) || data.favorite is bool);
      }

      allow read: if isAuthenticated()
        && resource.data.userId == request.auth.uid;

      allow create: if isAuthenticated()
        && isValidRecipe(request.resource.data)
        && !exists(/databases/$(database)/documents/recipes/$(recipeId));

      allow update: if isAuthenticated()
        && resource.data.userId == request.auth.uid
        && isValidRecipe(request.resource.data)
        && request.resource.data.userId == resource.data.userId;

      allow delete: if isAuthenticated()
        && resource.data.userId == request.auth.uid;
    }
  }
}"""

add_code_block(rules_code, "firestore.rules")

p = doc.add_paragraph()
add_bold_text(p, "Key Security Enforcements:")
rules_bullets = [
    "Authentication required: All operations require a logged-in user (request.auth != null)",
    "Data isolation: Users can only read/write their own recipes (userId == request.auth.uid)",
    "Field validation: Name must be non-empty string ≤ 80 chars",
    "Enum validation: Category must be one of 4 values; Difficulty must be one of 3 values",
    "Range validation: cookTime 1–600, servings 1–20",
    "Uniqueness: Document ID is {userId}_{lowerCaseName}, and !exists() prevents duplicates",
    "Ownership immutability: userId cannot be changed during update",
]
for b in rules_bullets:
    add_bullet(b)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 5. DATA MODEL
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("5. Data Model", level=1)

doc.add_paragraph(
    "The Recipe class is the core data model of the application. It includes factory "
    "constructors for Firestore deserialization, a toMap() method for serialization, "
    "and a copyWith() method for immutable updates."
)

recipe_model_code = """class Recipe {
  final String id;
  final String userId;
  final String name;
  final String category;     // Breakfast | Lunch | Dinner | Dessert
  final String difficulty;    // Easy | Medium | Hard
  final int cookTime;         // 1..600 minutes
  final int? servings;        // 1..20 (nullable)
  final bool favorite;        // default false
  final String notes;         // max 300 chars
  final DateTime? createdAt;  // server timestamp

  // Factory: Recipe.fromFirestore(DocumentSnapshot doc)
  // Method: Map<String, dynamic> toMap()
  // Method: Recipe copyWith({...})
}"""

add_code_block(recipe_model_code, "models/recipe.dart (simplified)")

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 6. APPLICATION ARCHITECTURE
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("6. Application Architecture (Provider Pattern)", level=1)

doc.add_paragraph(
    "The application uses Provider with ChangeNotifier for state management. "
    "Two main providers manage the entire application state:"
)

add_heading_styled("6.1. Auth Provider (AppAuthProvider)", level=2)

auth_features = [
    "Listens to Firebase authStateChanges() stream for real-time auth state",
    "Exposes: user, isAuthenticated, isLoading, userEmail, userId",
    "Methods: login(email, password), register(email, password), logout()",
    "Maps FirebaseAuthException codes to user-friendly error messages",
]
for f in auth_features:
    add_bullet(f)

add_heading_styled("6.2. Recipe Provider (RecipeProvider)", level=2)

recipe_features = [
    "Subscribes to Firestore real-time snapshots filtered by userId",
    "Maintains local filter state: selectedCategory, selectedDifficulty, favoritesOnly, searchQuery",
    "Computed property filteredRecipes applies all filters in sequence",
    "Summary computations: recipeCount, favoriteCount, totalCookTime, categoryBreakdown",
    "CRUD methods: addRecipe(), updateRecipe(), deleteRecipe(), toggleFavorite()",
    "Duplicate name checking (case-insensitive) before add/update operations",
    "Default sort: cookTime ascending, then name alphabetically (case-insensitive)",
]
for f in recipe_features:
    add_bullet(f)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 7. USER INTERFACE SCREENS
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("7. User Interface Screens", level=1)

add_heading_styled("7.1. Home Screen (Public Landing)", level=2)
doc.add_paragraph(
    "The Home Screen is the first screen visible to unauthenticated users. It displays "
    "the app's name 'RecipeBox', a brief description, and three feature cards highlighting "
    "key capabilities. Navigation buttons lead to Login and Register screens."
)
doc.add_paragraph(
    "When a user is already logged in, this screen is automatically bypassed and "
    "the app navigates directly to the List Screen."
)

add_heading_styled("7.2. Login Screen", level=2)
doc.add_paragraph(
    "Provides email and password fields with client-side validation (email format, "
    "required fields). On successful login, navigates to the List Screen and clears "
    "the navigation stack to prevent back-navigation to login. Firebase errors are "
    "displayed in a styled error container below the submit button."
)

add_heading_styled("7.3. Register Screen", level=2)
doc.add_paragraph(
    "Includes email, password, and confirm password fields. Password minimum length "
    "is 6 characters. Confirm password must match. On success, displays a green "
    "'Registration successful' message and SnackBar notification."
)

add_heading_styled("7.4. List Screen (Main Dashboard)", level=2)

doc.add_paragraph("The List Screen is the primary authenticated view, containing:")

list_features = [
    "AppBar showing the logged-in user's email and a Logout button",
    "Toggle button to show/hide the inline Add Recipe Form",
    "Filter card with: Search bar, Category dropdown, Difficulty dropdown, Favorites-only switch, and Clear button",
    "Summary Card showing recipe count, favorite count, total cook time, and category breakdown",
    "Scrollable recipe list with RecipeCard widgets (showing name, category badge, difficulty badge, cook time, and favorite star toggle)",
    "Empty state illustration when no recipes match the current filters",
    "Back button is disabled (PopScope) to prevent accidental navigation to login",
]
for f in list_features:
    add_bullet(f)

add_heading_styled("7.5. Detail Screen (View / Edit / Delete)", level=2)

doc.add_paragraph(
    "Tapping a recipe card navigates to the Detail Screen, which has two modes:"
)

p = doc.add_paragraph()
add_bold_text(p, "View Mode: ")
add_normal_text(p, "Displays recipe name, category & difficulty tags, cook time, servings, "
    "notes, and favorite status in styled cards. Edit and Delete buttons are available "
    "at the bottom. A favorite toggle star is in the AppBar.")

p = doc.add_paragraph()
add_bold_text(p, "Edit Mode: ")
add_normal_text(p, "Transforms into a pre-populated form with all fields editable. "
    "When the name is changed, uniqueness is re-validated. If the name changes, the old "
    "document is atomically deleted and a new one is created via a Firestore batch write. "
    "Cancel returns to View Mode without saving.")

p = doc.add_paragraph()
add_bold_text(p, "Delete: ")
add_normal_text(p, "Shows a confirmation AlertDialog before deleting. On confirmation, "
    "the document is removed from Firestore and the user is navigated back to the List Screen.")

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 8. BUSINESS LOGIC & VALIDATION RULES
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("8. Business Logic & Validation Rules", level=1)

add_heading_styled("8.1. Field Validation (Client-side)", level=2)

validation_data = [
    ("Field", "Validation Rule"),
    ("Name", "Required, non-empty after trim, max 80 characters"),
    ("Category", "Required, must select from: Breakfast, Lunch, Dinner, Dessert"),
    ("Difficulty", "Required, must select from: Easy, Medium, Hard"),
    ("Cook Time", "Required, whole number (int), range 1–600"),
    ("Servings", "Optional, if provided must be whole number (int), range 1–20"),
    ("Notes", "Optional, max 300 characters"),
]

table = doc.add_table(rows=len(validation_data), cols=2)
table.style = 'Light Grid Accent 1'
table.alignment = WD_TABLE_ALIGNMENT.CENTER
for i, (label, value) in enumerate(validation_data):
    cell_l = table.cell(i, 0)
    cell_r = table.cell(i, 1)
    cell_l.text = label
    cell_r.text = value
    for p in cell_l.paragraphs:
        for run in p.runs:
            run.font.name = 'Times New Roman'
            run.font.size = Pt(11)
            if i == 0:
                run.bold = True
    for p in cell_r.paragraphs:
        for run in p.runs:
            run.font.name = 'Times New Roman'
            run.font.size = Pt(11)
            if i == 0:
                run.bold = True

doc.add_paragraph()

add_heading_styled("8.2. Unique Name Constraint (Case-insensitive)", level=2)

doc.add_paragraph(
    "The same user cannot save two recipes with the same name, even if letter case differs. "
    "This is enforced at three levels:"
)

uniqueness_levels = [
    "Document ID Convention: Document ID = {userId}_{name.trim().toLowerCase()}. "
    "Since Firestore document IDs are inherently unique within a collection, two recipes "
    "with names like 'Pho Bo' and 'pho bo' would map to the same document ID, preventing duplicates.",
    "Client-side Check: Before saving, the provider checks allRecipes for any existing recipe "
    "whose name.trim().toLowerCase() matches the new name. If found, an error is thrown "
    "immediately without making a network request.",
    "Firestore Security Rules: The create rule includes !exists() to reject writes where "
    "the document already exists. Even if a malicious client bypasses the app, the rule blocks "
    "the duplicate at the database level.",
]

for i, level in enumerate(uniqueness_levels, 1):
    p = doc.add_paragraph()
    add_bold_text(p, f"Level {i}: ")
    add_normal_text(p, level)

add_heading_styled("8.3. Firestore Security Rules (Server-side)", level=2)

doc.add_paragraph(
    "All client-side validations are mirrored in Firestore Security Rules to ensure "
    "data integrity even if the client is tampered with. Specifically:"
)

server_rules = [
    "Only authenticated users can perform any operation",
    "Users can only access their own recipes (userId isolation)",
    "All required fields must be present with correct types",
    "Category must be one of the four allowed values",
    "Difficulty must be one of the three allowed values",
    "cookTime must be an integer between 1 and 600",
    "servings (if present) must be an integer between 1 and 20",
    "notes (if present) must be a string of max 300 characters",
    "favorite must be a boolean",
    "userId cannot be changed during updates",
    "Duplicate document IDs are rejected via !exists()",
]
for r in server_rules:
    add_bullet(r)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 9. FILTER, SEARCH & SUMMARY
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("9. Filter, Search & Summary Features", level=1)

add_heading_styled("Filtering", level=2)

filter_features = [
    "Category filter dropdown: All, Breakfast, Lunch, Dinner, Dessert",
    "Difficulty filter dropdown: All, Easy, Medium, Hard",
    "Favorites-only toggle switch",
    "Clear button resets all filters and search to defaults",
]
for f in filter_features:
    add_bullet(f)

add_heading_styled("Search", level=2)

doc.add_paragraph(
    "The search bar performs real-time filtering on recipe name and notes fields. "
    "The search is case-insensitive and matches partial strings (contains)."
)

add_heading_styled("Summary Dashboard", level=2)

doc.add_paragraph(
    "The Summary Card displays real-time statistics computed from the currently filtered recipe list:"
)

summary_features = [
    "Recipes count: Total number of recipes matching current filters",
    "Favorites count: Number of favorite recipes in the filtered set",
    "Total cook time: Sum of all cookTime values in the filtered set (in minutes)",
    "Category breakdown: Count per category, sorted by highest count first. "
    "Equal counts are ordered: Breakfast → Lunch → Dinner → Dessert",
]
for f in summary_features:
    add_bullet(f)

add_heading_styled("Sorting", level=2)

doc.add_paragraph(
    "Recipes are always sorted by cook time in ascending order (shortest first). "
    "When two recipes have the same cook time, they are ordered alphabetically by name "
    "(case-insensitive)."
)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 10. TEST ACCOUNT & SAMPLE DATA
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("10. Test Account & Sample Data", level=1)

add_heading_styled("Test Account Credentials", level=2)

test_info = [
    ("Email", "grader.qe190171@example.com"),
    ("Password", "Test1234!"),
    ("Firebase UID", "nn2bnWKN1fPkttSF9GR0vV9ZTvh2"),
]
add_info_table(test_info)

doc.add_paragraph()

add_heading_styled("Pre-loaded Sample Recipes", level=2)

doc.add_paragraph(
    "Five sample recipes have been pre-loaded into Firestore for the test account:"
)

sample_data = [
    ("Recipe Name", "Category", "Difficulty", "Cook Time", "Servings", "Favorite"),
    ("Banh Mi Thit", "Breakfast", "Easy", "15 min", "2", "No"),
    ("Che Khuc Bach", "Dessert", "Easy", "20 min", "5", "No"),
    ("Com Tam Suon Nuong", "Lunch", "Medium", "30 min", "3", "Yes"),
    ("Pho Bo", "Breakfast", "Medium", "45 min", "4", "Yes"),
    ("Bun Cha Ha Noi", "Dinner", "Hard", "60 min", "4", "Yes"),
]

table = doc.add_table(rows=len(sample_data), cols=6)
table.style = 'Light Grid Accent 1'
table.alignment = WD_TABLE_ALIGNMENT.CENTER
for i, row_data in enumerate(sample_data):
    for j, cell_text in enumerate(row_data):
        cell = table.cell(i, j)
        cell.text = cell_text
        for p in cell.paragraphs:
            for run in p.runs:
                run.font.name = 'Times New Roman'
                run.font.size = Pt(10)
                if i == 0:
                    run.bold = True

doc.add_paragraph()
doc.add_paragraph(
    "Note: Recipes are displayed sorted by cook time ascending. The order shown in the "
    "table above matches the expected display order in the app."
)

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 11. SCREENSHOTS
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("11. Screenshots", level=1)

doc.add_paragraph(
    "Please refer to the attached screenshots taken from the running application on an "
    "Android emulator. Screenshots demonstrate:"
)

screenshot_items = [
    "Home Screen (public landing page)",
    "Login Screen (with validation errors and successful login)",
    "Register Screen (with validation and success message)",
    "List Screen showing all recipes sorted by cook time",
    "Add Recipe Form with validation",
    "Duplicate name error (case-insensitive)",
    "Filter by Category / Difficulty / Favorites",
    "Search functionality",
    "Summary Card with recipe statistics",
    "Detail Screen – View Mode",
    "Detail Screen – Edit Mode",
    "Delete Confirmation Dialog",
    "Firebase Console – Authentication users",
    "Firebase Console – Firestore data",
    "Firebase Console – Security Rules",
]
for s in screenshot_items:
    add_bullet(s)

doc.add_paragraph()

p = doc.add_paragraph()
add_bold_text(p, "⚠️ NOTE: ")
add_normal_text(p, "Screenshots should be inserted here after running the app on an emulator "
    "or physical device. Use the Print Screen or Android emulator screenshot feature, "
    "then paste or insert images into this section.")

# Add placeholder boxes for screenshots in exact Section 3 order
screenshot_captions = [
    "Firebase console – Authentication: the Users list showing your test account",
    "Firebase console – Firestore data: the recipes collection with at least 3 sample documents belonging to your test account",
    "Firebase console – Security Rules: the Rules tab showing the rules you actually have published, not just saved in an editor",
    "Register screen – validation: the form submitted empty, showing the error messages",
    "Register screen – success: right after a successful sign-up, showing Registration successful",
    "Login screen: the empty sign-in form",
    "List screen – after login: showing the user's e-mail, the Logout button, and at least 3 recipes already in the list",
    "Add Recipe form – validation: the form submitted empty or with bad input, showing the error messages",
    "Add Recipe form – success: right after adding a recipe, showing Recipe added and the new recipe now in the list",
    "Filters and search: the category filter, the difficulty filter, the favorites-only switch, and the search box each changing what is shown",
    "Summary: the Recipes, Favorites and Total time values and the category breakdown visible, with more than one category represented",
    "Detail screen – view mode: one recipe's full details (name, category, difficulty, cook time, servings, notes)",
    "Detail screen – edit mode, validation: an edit submitted with bad input, showing the error messages",
    "Detail screen – after Save: showing the edited values now saved",
    "Favorite toggle and Delete: a before/after pair showing the star toggled, and a recipe deleted and gone from the list",
    "Empty state: the List screen with the text No recipes found – easiest to capture with a second, fresh test account before it has any recipes",
]

for title in screenshot_captions:
    p = doc.add_paragraph()
    add_bold_text(p, title)
    p2 = doc.add_paragraph()
    run = p2.add_run("[Insert screenshot here]")
    run.font.color.rgb = RGBColor(0x99, 0x99, 0x99)
    run.font.italic = True
    run.font.name = 'Times New Roman'
    run.font.size = Pt(11)
    doc.add_paragraph()

doc.add_page_break()

# ═══════════════════════════════════════════════════════════════════════
# 12. CONCLUSION
# ═══════════════════════════════════════════════════════════════════════

add_heading_styled("12. Conclusion", level=1)

doc.add_paragraph(
    "The RecipeBox application has been successfully developed and meets all the "
    "requirements specified in the PRM393 Practical Examination:"
)

conclusion_items = [
    "✅ Flutter application running on Android with Firebase integration",
    "✅ Firebase Authentication with Email/Password (Register, Login, Logout)",
    "✅ Cloud Firestore for real-time recipe data storage and retrieval",
    "✅ Complete CRUD operations (Create, Read, Update, Delete) on recipes",
    "✅ Client-side form validation for all required and optional fields",
    "✅ Firestore Security Rules enforcing server-side validation and data isolation",
    "✅ Case-insensitive unique recipe name constraint per user",
    "✅ Filtering by Category, Difficulty, and Favorites",
    "✅ Search functionality on recipe name and notes",
    "✅ Real-time summary dashboard with statistics and category breakdown",
    "✅ Recipes sorted by cook time ascending with alphabetical tie-breaking",
    "✅ Clean, responsive UI with Material Design 3 components",
    "✅ Provider state management with ChangeNotifier pattern",
    "✅ Test account with pre-loaded sample data for grading",
]
for item in conclusion_items:
    add_bullet(item)

doc.add_paragraph()

p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
add_bold_text(p, "— End of Report —", size=14)

# ═══════════════════════════════════════════════════════════════════════
# SAVE
# ═══════════════════════════════════════════════════════════════════════

doc.save(OUTPUT_PATH)
print(f"Report saved to: {OUTPUT_PATH}")
