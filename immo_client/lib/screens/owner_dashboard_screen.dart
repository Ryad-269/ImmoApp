// lib/screens/owner_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/property.dart';

class OwnerDashboardScreen extends StatefulWidget {
  @override
  _OwnerDashboardScreenState createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  List<Property> _properties = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      // Non authentifié : retour à l'accueil
      Navigator.pushReplacementNamed(context, '/');
    } else {
      await _fetchMyProperties();
    }
  }

  Future<void> _fetchMyProperties() async {
    setState(() => _isLoading = true);
    try {
      // Appel à un endpoint spécifique pour les annonces du propriétaire
      // Pour l'instant, on récupère toutes et on filtre (à améliorer)
      final allData = await ApiService.getProperties();
      final allProps = allData.map((json) => Property.fromJson(json)).toList();
      final userInfo = await ApiService.getUserInfo();
      final myProps = allProps
          .where((p) => p.proprietaireNom == userInfo['username'])
          .toList();
      setState(() {
        _properties = myProps;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _deleteProperty(int id) async {
    try {
      await ApiService.deleteProperty(id);
      _fetchMyProperties();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Annonce supprimée')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes annonces'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-property'),
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _properties.isEmpty
          ? Center(child: Text('Aucune annonce. Appuyez sur + pour ajouter'))
          : ListView.builder(
              itemCount: _properties.length,
              itemBuilder: (context, index) {
                final prop = _properties[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(prop.titre),
                    subtitle: Text('${prop.prix} FCFA - ${prop.district}'),
                    
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/edit-property',
                              arguments: prop.id,  // Passer l'ID de l'annonce
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProperty(prop.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
