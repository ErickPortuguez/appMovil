// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/models/category_model.dart';
import 'package:myapp/services/category_service.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategoryListScreenState createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen> {
  List<Category> _categories = [];
  List<Category> _filteredCategories = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiServiceCategory.getActiveCategories();
      setState(() {
        _categories = categories;
        _filteredCategories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar las categorías: $e'),
        ),
      );
    }
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategories = _categories
          .where((category) =>
              category.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Categorías'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar categoría',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterCategories,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                final category = _filteredCategories[index];
                return ListTile(
                  title: Text(category.name),
                  onTap: () {
                    // Aquí debes implementar la lógica para seleccionar la categoría
                    Navigator.pop(context, category);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
