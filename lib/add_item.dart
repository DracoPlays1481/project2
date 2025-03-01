import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'auth/auth_service.dart';
import 'widgets/button.dart';
import 'widgets/textfield.dart';
import 'display_item.dart';
import 'theme/app_theme.dart';

class AddItem extends StatefulWidget {
  const AddItem({Key? key}) : super(key: key);

  @override
  State<AddItem> createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  TextEditingController _controllerDesc = TextEditingController();
  TextEditingController _controllerCalories = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  Uint8List? imageData;
  String? imageBase64;
  final List<String> mealType = ['Breakfast', 'Lunch', 'Snacks', 'Dinner', 'Supper'];
  final databaseRef = FirebaseDatabase.instance.ref("items");
  String? selectedMeal;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Choose Image Source'),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
              child: const Text('Take Photo'),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
              child: const Text('Choose from Gallery'),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            isDestructiveAction: true,
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 50, // Compress image to reduce size
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          imageData = bytes;
          imageBase64 = base64Encode(bytes);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get image: $e')),
      );
    }
  }

  Future<void> _saveItem() async {
    Map<String, String> newItem = {
      'meals': selectedMeal ?? '',
      'description': _controllerDesc.text,
      'calories': _controllerCalories.text,
      'image': imageBase64 ?? '',
    };
  }

  void saveToFirebase() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please login to add items"))
      );
      return;
    }

    if (key.currentState!.validate() && imageBase64 != null && selectedMeal != null) {
      // Create a reference to the user's items
      final userItemsRef = databaseRef.child(user.uid);

      userItemsRef.push().set({
        'mealType': selectedMeal,
        'description': _controllerDesc.text,
        'calories': _controllerCalories.text,
        'image': imageBase64,
        'timestamp': ServerValue.timestamp,
        'userId': user.uid
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Item added successfully!"))
        );

        _resetForm();
        // Stay on the same page instead of pushing a new one
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => DisplayItem()),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add item: $error"))
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please fill all fields and add an image"))
      );
    }
  }

  void _resetForm() {
    setState(() {
      _controllerDesc.clear();
      _controllerCalories.clear();
      selectedMeal = null;
      imageData = null;
      imageBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Add Food Diary'),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: key,
            child: Column(
              children: [
                _buildMealTypeSelector(),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _controllerDesc,
                  hint: 'Enter the food description',
                  label: 'Food Description',
                  prefixIcon: CupertinoIcons.text_justify,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the food description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _controllerCalories,
                  hint: 'Enter the intake calories (Kcal)',
                  label: 'Calories',
                  prefixIcon: CupertinoIcons.flame,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter intake calories (Kcal)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildImagePicker(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    label: "Submit",
                    onPressed: () async {
                      if (key.currentState!.validate()) {
                        await _saveItem();
                        saveToFirebase();
                      }
                    },
                    size: ButtonSize.large,
                    icon: CupertinoIcons.check_mark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMealTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.radius_lg),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 0.5,
        ),
      ),
      child: FormField<String>(
        validator: (value) {
          if (selectedMeal == null || selectedMeal!.isEmpty) {
            return 'Please select a meal type';
          }
          return null;
        },
        builder: (FormFieldState<String> state) {
          return InputDecorator(
            decoration: InputDecoration(
              errorText: state.hasError ? state.errorText : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing_md,
                vertical: AppTheme.spacing_md,
              ),
              prefixIcon: const Icon(
                CupertinoIcons.time,
                color: AppTheme.textSecondaryColor,
              ),
            ),
            isEmpty: selectedMeal == null,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedMeal,
                hint: const Text(
                  'Select Meal',
                  style: TextStyle(
                    fontSize: 17,
                    letterSpacing: -0.5,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
                items: mealType.map((meal) {
                  return DropdownMenuItem(
                    value: meal,
                    child: Text(
                      meal,
                      style: const TextStyle(
                        fontSize: 17,
                        letterSpacing: -0.5,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedMeal = newValue;
                    state.didChange(newValue);
                  });
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(AppTheme.radius_lg),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 0.5,
              ),
            ),
            child: imageData != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radius_lg),
              child: Image.memory(
                imageData!,
                fit: BoxFit.cover,
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  CupertinoIcons.camera,
                  size: 40,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(height: 8),
                Text(
                  'Add Photo',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondaryColor,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (imageData != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                imageData = null;
                imageBase64 = null;
              });
            },
            child: const Text(
              'Remove Photo',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontSize: 15,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}