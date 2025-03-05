import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'theme/app_theme.dart';

class DisplayItem extends StatefulWidget {
  @override
  _DisplayItemState createState() => _DisplayItemState();
}

class _DisplayItemState extends State<DisplayItem> {
  List<Map<String, String>> items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _error = "Please login to view your meals";
          _isLoading = false;
        });
        return;
      }

      final databaseRef = FirebaseDatabase.instance.ref("items").child(user.uid);
      final snapshot = await databaseRef.get();

      if (snapshot.exists) {
        List<Map<String, String>> loadedItems = [];

        // Sort the items by timestamp in descending order (newest first)
        final itemsList = snapshot.children.toList()
          ..sort((a, b) {
            final aTimestamp = (a.value as Map)['timestamp'] ?? 0;
            final bTimestamp = (b.value as Map)['timestamp'] ?? 0;
            return (bTimestamp as int).compareTo(aTimestamp as int);
          });

        for (var item in itemsList) {
          final data = item.value as Map<dynamic, dynamic>;

          loadedItems.add({
            "key": item.key ?? "",
            "meals": data["mealType"]?.toString() ?? "",
            "description": data["description"]?.toString() ?? "",
            "calories": data["calories"]?.toString() ?? "",
            "image": data["image"]?.toString() ?? "",
          });
        }

        setState(() {
          items = loadedItems;
          _isLoading = false;
        });
      } else {
        setState(() {
          items = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading items: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(String key) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final databaseRef = FirebaseDatabase.instance.ref("items/${user.uid}/$key");
      await databaseRef.remove();
      setState(() {
        items.removeWhere((item) => item["key"] == key);
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $e'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('Meal Entries'),
          backgroundColor: Colors.white,
        ),
        body: Center(child: CupertinoActivityIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text('Meal Entries'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_circle,
                  size: 50,
                  color: AppTheme.errorColor.withOpacity(0.7),
                ),
                SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Meal Entries'),
        backgroundColor: Colors.white,
      ),
      body: items.isEmpty
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.doc_text,
              size: 70,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No meal entries yet',
              style: TextStyle(
                fontSize: 17,
                color: AppTheme.textSecondaryColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          Uint8List? imageData = item['image'] != null && item['image']!.isNotEmpty
              ? base64Decode(item['image']!)
              : null;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radius_md),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Dismissible(
              key: Key(item["key"]!),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor,
                  borderRadius: BorderRadius.circular(AppTheme.radius_md),
                ),
                child: Icon(
                  CupertinoIcons.delete,
                  color: Colors.white,
                ),
              ),
              confirmDismiss: (direction) async {
                return await showCupertinoDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return CupertinoAlertDialog(
                      title: Text('Delete Entry'),
                      content: Text('Are you sure you want to delete this meal entry?'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(false),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          child: Text('Delete'),
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            _deleteItem(item["key"]!);
                          },
                        ),
                      ],
                    );
                  },
                ) ?? false;
              },
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radius_sm),
                      child: imageData != null
                          ? Image.memory(
                        imageData,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                          : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[200],
                        child: Icon(CupertinoIcons.photo, color: Colors.grey[400]),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item['meals'] ?? 'Unknown Meal',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              Spacer(),
                              Text(
                                "${item['calories'] ?? 'N/A'} kcal",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            item['description'] ?? 'No Description',
                            style: TextStyle(
                              fontSize: 16,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}