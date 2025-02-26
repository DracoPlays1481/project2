import 'package:flutter/material.dart';
import '../widgets/custom_card.dart';
import '../models/recipe.dart';
import '../services/database_service.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  State<RecipeScreen> createState() => _ReceipeScreenState();
}

class _ReceipeScreenState extends State<RecipeScreen> {
final _databaseService = DatabaseService();
List<Recipe> _recipes = [];
bool _isLoading = false;
String _searchQuery = '';

@override
void initState() {
  super.initState();
  _loadRecipes();
}

Future<void> _loadRecipes() async {
  setState(() => _isLoading = true);
  try {
    final recipes = await _databaseService.getRecipes();
    setState(() => _recipes = recipes);
  } finally {
    setState(() => _isLoading = false);
  }
}

List<Recipe> get _filteredRecipes {
  if (_searchQuery.isEmpty) return _recipes;
  return _recipes
      .where((recipe) =>
  recipe.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      recipe.description.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Healthy Recipes'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredRecipes.isEmpty
              ? const Center(child: Text('No recipes found'))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = _filteredRecipes[index];
              return CustomCard(
                onTap: () => _showRecipeDetails(context, recipe),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe.imageUrl.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          recipe.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  recipe.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${recipe.calories.round()} kcal',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            recipe.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.timer,
                                size: 16,
                                color:
                                Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${recipe.preparationTime} min',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.restaurant,
                                size: 16,
                                color:
                                Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.difficulty,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

void _showRecipeDetails(BuildContext context, Recipe recipe) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (recipe.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  recipe.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              recipe.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              recipe.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            Text(
              'Ingredients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...recipe.ingredients.map(
                  (ingredient) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.fiber_manual_record,
                      size: 8,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(ingredient),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Instructions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ...recipe.instructions.asMap().entries.map(
                  (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entry.value),
                    ),
                  ],
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