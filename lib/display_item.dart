import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
        appBar: AppBar(title: Text('Meal Entries')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('Meal Entries')),
        body: Center(child: Text(_error!)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Entries'),
      ),
      body: items.isEmpty
          ? Center(child: Text('No meal entries yet'))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];
          Uint8List? imageData = item['image'] != null && item['image']!.isNotEmpty
              ? base64Decode(item['image']!)
              : null;

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (imageData != null)
                    Image.memory(imageData, width: 80, height: 80, fit: BoxFit.cover),
                  if (imageData == null)
                    Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey,
                      child: Icon(Icons.image, color: Colors.white),
                    ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['meals'] ?? 'Unknown Meal',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text("Description: ${item['description'] ?? 'No Description'}"),
                        SizedBox(height: 5),
                        Text("Calories: ${item['calories'] ?? 'N/A'} kcal"),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Delete Entry'),
                            content: Text('Are you sure you want to delete this meal entry?'),
                            actions: [
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              TextButton(
                                child: Text('Delete'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _deleteItem(item["key"]!);
                                },
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}