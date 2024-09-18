// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:myapp/screen/pages/client/client_modal_page.dart';
import 'package:myapp/services/client_service.dart';
import 'package:myapp/models/client_model.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ClientsPageState createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  late List<Client> _clientList = [];
  late List<Client> _filteredClientList = [];
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_filterClients);
    _loadClients();
  }

  Future<void> _loadClients() async {
    try {
      List<Client> activeClients = await ApiServiceClient.getActiveClients();
      List<Client> inactiveClients =
          await ApiServiceClient.getInactiveClients();
      _clientList = [...activeClients, ...inactiveClients];
      _clientList
          .sort((a, b) => a.names.compareTo(b.names)); // Ordena por nombres
      _filteredClientList =
          _clientList; // Inicialmente, muestra todos los clientes
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los clientes: $e')),
      );
    }
  }

  void _filterClients() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClientList = _clientList.where((client) {
        return client.names.toLowerCase().contains(query) ||
            client.lastName.toLowerCase().contains(query) ||
            (client.email != null && client.email!.toLowerCase().contains(query)) ||
            client.typeDocument.toLowerCase().contains(query) ||
            client.numberDocument.contains(query);
      }).toList();
      _filteredClientList.sort(
          (a, b) => a.names.compareTo(b.names)); // Ordena la lista filtrada
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
                  hintText: 'Buscar clientes',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 28,
                    ),
                    onPressed: () {
                      _navigateToClientDetail(Client.empty());
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
                  _buildClientList(true),
                  _buildClientList(false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList(bool showActive) {
    List<Client> filteredClients = _filteredClientList
        .where((client) => client.active == (showActive ? 'A' : 'I'))
        .toList();

    // Verificar si no hay clientes según la pestaña activa
    if (filteredClients.isEmpty) {
      return Center(
        child: Text(showActive
            ? 'No hay Clientes activos'
            : 'No hay Clientes inactivos'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: filteredClients.length,
      itemBuilder: (context, index) {
        Client client = filteredClients[index];
        bool isActive = client.active == 'A';
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
              '${client.names} ${client.lastName}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
             '${client.typeDocument}: ${client.numberDocument}',
              style: const TextStyle(
                color: Color.fromARGB(255, 79, 79, 79),
                fontSize: 12,
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '${client.names.substring(0, 1)}${client.lastName.substring(0, 1)}',
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
                      _showConfirmationDialog(context, client);
                    },
                  )
                : IconButton(
                    icon: const Icon(
                      Icons.restore,
                      color: Color.fromARGB(255, 0, 104, 248),
                      size: 20,
                    ),
                    onPressed: () {
                      _showConfirmationDialog(context, client);
                    },
                  ),
            onTap: () {
              if (isActive) {
                _navigateToClientDetail(client);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se puede abrir el formulario para clientes inactivos.',
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

  void _showConfirmationDialog(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              client.active == 'A' ? "Eliminar Cliente" : "Restaurar Cliente"),
          content: Text(client.active == 'A'
              ? "¿Estás seguro de eliminar este cliente?"
              : "¿Estás seguro de restaurar este cliente?"),
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
                if (client.active == 'A') {
                  _deleteClient(context, client.id);
                } else {
                  _restoreClient(context, client.id);
                }
              },
              child: Text(
                  client.active == 'A' ? "Sí, Eliminar" : "Sí, Restaurar",
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteClient(BuildContext context, int clientId) async {
    try {
      await ApiServiceClient.deleteClient(clientId);
      _loadClients();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente eliminado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el cliente: $e')),
      );
    }
  }

  void _restoreClient(BuildContext context, int clientId) async {
    try {
      await ApiServiceClient.activeClient(clientId);
      _loadClients();
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente restaurado exitosamente')),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Close the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al restaurar el cliente: $e')),
      );
    }
  }

  void _handleClientSaved(Client client, bool isNewClient) {
    _loadClients();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isNewClient
              ? 'Cliente insertado exitosamente'
              : 'Cliente editado exitosamente',
        ),
      ),
    );
  }

  void _navigateToClientDetail(Client client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientModalPage(
          client: client,
          onClientSaved: _handleClientSaved,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
