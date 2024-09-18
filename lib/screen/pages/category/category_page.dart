// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:myapp/screen/pages/category/category_modal_page.dart';
import 'package:myapp/services/category_service.dart';
import 'package:myapp/models/category_model.dart';

class CategorysPage extends StatefulWidget {
  const CategorysPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CategorysPageState createState() => _CategorysPageState();
}

class _CategorysPageState extends State<CategorysPage> {
  late List<Category> _categoryList = [];
  late List<Category> _filteredCategoryList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterCategorys);
    _loadCategorys();
  }

 Future<void> _loadCategorys() async {
    try {
      List<Category> activeCategorys = await ApiServiceCategory.getActiveCategories();
      List<Category> inactiveCategorys =
          await ApiServiceCategory.getInactiveCategories();
      _categoryList = [...activeCategorys, ...inactiveCategorys];
      _filteredCategoryList =
          _categoryList; // Inicialmente, muestra todos los Categoriae
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las categorias: $e')),
      );
    }
  }

  void _filterCategorys() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategoryList = _categoryList.where((category) {
        return category.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const SizedBox(
                  height: 16.0), // Espacio de 16.0 puntos arriba del TextField
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Buscar Categoria',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToCategoryDetail(Category.empty());
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: Colors.blue,
            tabs: [
              Tab(
                child: Text(
                  'Activos',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Inactivos',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildCategoryList(true),
                  _buildCategoryList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(bool showActive) {
    List<Category> filteredCategorys = _filteredCategoryList
        .where((category) => category.active == (showActive ? 'A' : 'I'))
        .toList();

    // Verificar si no hay categorias según la pestaña activa
    if (filteredCategorys.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay categorias activos'
            : 'No hay categorias inactivos'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredCategorys.length,
      itemBuilder: (context, index) {
        Category category = filteredCategorys[index];
        bool isActive = category.active == 'A';
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              category.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                category.name.substring(0, 1),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            trailing: isActive
                ? IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Color.fromARGB(255, 248, 0, 0),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, category);
                    },
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 0, 104, 248),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, category);
                    },
                  ),
            onTap: () {
              if (isActive) {
                _navigateToCategoryDetail(category);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede abrir el formulario para categorias inactivos.',
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 16.0),
    );
  }

  void _showConfirmationDialog(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category.active == 'A'
              ? "Eliminar Categoria"
              : "Restaurar Categoria"),
          content: Text(category.active == 'A'
              ? "¿Estás seguro de eliminar esta categoria?"
              : "¿Estás seguro de restaurar esta categoria?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                if (category.active == 'A') {
                  _deleteCategory(context, category.id);
                } else {
                  _restoreCategory(context, category.id);
                }
              },
              child: Text(
                  category.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, int categoryId) async {
    try {
      await ApiServiceCategory.deleteCategory(categoryId);
      _loadCategorys();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el Categoria: $e')),
      );
    }
  }

  void _restoreCategory(BuildContext context, int categoryId) async {
    try {
      await ApiServiceCategory.activeCategory(categoryId);
      _loadCategorys();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categoria restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el Categoria: $e')),
      );
    }
  }

  void _handleCategorySaved(Category category, bool isNewCategory) {
    _loadCategorys();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewCategory
              ? 'Categoria insertado exitosamente'
              : 'Categoria editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToCategoryDetail(Category category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryModalPage(
          category: category,
          onCategorySaved: _handleCategorySaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategorys);
    _searchController.dispose();
    super.dispose();
  }
}
