import 'package:flutter/material.dart';
import 'package:myapp/models/client_model.dart';
import 'package:myapp/services/client_service.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClientListScreenState createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      final clients = await ApiServiceClient.getActiveClients();
      setState(() {
        _clients = clients;
        _filteredClients = clients;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar los clientes: $e'),
        ),
      );
    }
  }

  void _filterClients(String query) {
    setState(() {
      _filteredClients = _clients
          .where((client) =>
              client.names.toLowerCase().contains(query.toLowerCase()) ||
              client.lastName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 21, 0, 156),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Lista de Clientes',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16), // Espacio agregado encima del TextField
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar cliente',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterClients,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredClients.length,
              itemBuilder: (context, index) {
                final client = _filteredClients[index];
                return ListTile(
                  title: Text('${client.names} ${client.lastName}'),
                  onTap: () {
                    Navigator.pop(context, client);
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
