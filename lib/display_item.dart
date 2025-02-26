import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DisplayItem extends StatefulWidget {
  @override
  _DisplayItemState createState() => _DisplayItemState();
}

class _DisplayItemState extends State<DisplayItem> {
  List<Map<String, String>> items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

// Load items from Firebase Realtime Database
  Future<void> _loadItems() async {
    final databaseRef = FirebaseDatabase.instance.ref("items");
    final snapshot = await databaseRef.get();

    if (snapshot.exists) {
      List<Map<String, String>> loadedItems = []; // Ensure List<Map<String, String>>

      for (var item in snapshot.children) {
        final data = item.value as Map<dynamic, dynamic>;

        loadedItems.add({
          "key": item.key ?? "", // Ensure key is a String
          "meals": data["mealType"]?.toString() ?? "", // Convert to String safely
          "description": data["description"]?.toString() ?? "",
          "calories": data["calories"]?.toString() ?? "",
          "image": data["image"]?.toString() ?? "",
        });
      }

      setState(() {
        items = loadedItems;
      });
    }
  }


  // Delete an item and reload the list
  Future<void> _deleteItem(String key) async {
    // Use the key to reference the item in Firebase
    final databaseRef = FirebaseDatabase.instance.ref("items/$key");
    await databaseRef.remove();
    // Optionally, update your local state
    setState(() {
      items.removeWhere((item) => item["key"] == key);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Entries'),
      ),
      body: items.isEmpty
          ? Center(child: Text('No items available'))
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
                      // Assuming 'items' is a list of maps where each map contains a "key".
                      final String key = items[index]["key"] as String;
                      _deleteItem(key); // Call delete with the item's key.
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
