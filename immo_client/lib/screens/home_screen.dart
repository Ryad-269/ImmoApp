import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/property.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Property> _properties = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;
  String? _selectedDistrict;
  int? _minPrice;
  int? _maxPrice;
  int? _selectedRooms;

  final List<String> _districts = [
    'Almadies',
    'Ngor',
    'Plateau',
    'Fann',
    'Médina',
    'Grand-Yoff',
  ];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _fetchProperties();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  Future<void> _fetchProperties() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProperties(
        district: _selectedDistrict,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        rooms: _selectedRooms,
      );
      final properties = data.map((json) => Property.fromJson(json)).toList();
      setState(() {
        _properties = properties;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur détaillée : $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }
  }

  void _applyFilters() {
    _fetchProperties();
  }

  void _resetFilters() {
    setState(() {
      _selectedDistrict = null;
      _minPrice = null;
      _maxPrice = null;
      _selectedRooms = null;
    });
    _fetchProperties();
  }

  // 🔐 Fonction de test de connexion
  Future<void> _testLogin() async {
    // Remplacez par les identifiants de votre superutilisateur
    const String username = 'Administrateur'; // ex: 'admin'
    const String password = 'monapplication'; // ex: 'admin123'

    try {
      await ApiService.login(username, password);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Connexion superutilisateur réussie !')),
      );
      // Optionnel : récupérer les infos utilisateur
      final userInfo = await ApiService.getUserInfo();
      print('User info: $userInfo');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('❌ Échec connexion : $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ImmoDakar'),
        actions: [
          if (_isLoggedIn)
            IconButton(
              icon: Icon(Icons.dashboard),
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              tooltip: 'Mon espace',
            )
          else
            IconButton(
              icon: Icon(Icons.login),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Quartier'),
                        value: _selectedDistrict,
                        items: [
                          DropdownMenuItem(child: Text('Tous'), value: null),
                          ..._districts.map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedDistrict = value);
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Prix min'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _minPrice = int.tryParse(value),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(labelText: 'Prix max'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _maxPrice = int.tryParse(value),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(labelText: 'Pièces'),
                        value: _selectedRooms,
                        items: [
                          DropdownMenuItem(child: Text('Tous'), value: null),
                          for (int i = 1; i <= 5; i++)
                            DropdownMenuItem(value: i, child: Text('$i')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedRooms = value);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: Text('Rechercher'),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: _resetFilters,
                      child: Text('Réinitialiser'),
                    ),
                    SizedBox(width: 8),
                    
                  ],
                ),
              ],
            ),
          ),

          // Dans le body du Scaffold
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      icon: Icon(Icons.key, color: Colors.white),
                      label: Text(
                        'Se connecter (propriétaire)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[700],
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vous êtes propriétaire ? Connectez-vous pour publier et gérer vos annonces.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _properties.isEmpty
                ? Center(child: Text('Aucune annonce trouvée'))
                : ListView.builder(
                    itemCount: _properties.length,
                    itemBuilder: (context, index) {
                      final prop = _properties[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ListTile(
                          
                            leading: prop.photo != null
                                ? Image.network(
                                    prop.photo!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[300],
                                        child: Icon(Icons.broken_image, color: Colors.grey[600]),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: Icon(Icons.home, size: 40, color: Colors.grey[400]),
                                  ),
                          title: Text(prop.titre),
                          subtitle: Text(
                            '${prop.prix} FCFA - ${prop.district} - ${prop.chambres} pièces',
                          ),
                          onTap: () {
                            // Naviguer vers détail
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
