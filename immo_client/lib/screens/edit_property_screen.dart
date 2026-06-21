// lib/screens/edit_property_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/property.dart';

class EditPropertyScreen extends StatefulWidget {
  @override
  _EditPropertyScreenState createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  String? _selectedDistrict;
  final _chambresController = TextEditingController();
  final _superficieController = TextEditingController();
  Uint8List? _imageBytes;
  bool _isLoading = false;
  int? _propertyId;
  Property? _property;

  final List<String> _districts = [
    'Almadies', 'Ngor', 'Plateau', 'Fann', 'Médina', 'Grand-Yoff',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _propertyId = ModalRoute.of(context)?.settings.arguments as int?;
    if (_propertyId != null) {
      _loadProperty();
    }
  }

  Future<void> _loadProperty() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getProperties();
      final props = data.map((json) => Property.fromJson(json)).toList();
      final property = props.firstWhere((p) => p.id == _propertyId);
      setState(() {
        _property = property;
        _titreController.text = property.titre;
        _descriptionController.text = property.description;
        _prixController.text = property.prix.toString();
        _selectedDistrict = property.district;
        _chambresController.text = property.chambres.toString();
        _superficieController.text = property.superficie?.toString() ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur chargement : $e')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: null,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() => _imageBytes = bytes);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_propertyId == null) return;

    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data = {
        'titre': _titreController.text,
        'description': _descriptionController.text,
        'prix': int.parse(_prixController.text),
        'district': _selectedDistrict!,
        'chambres': int.parse(_chambresController.text),
      };
      if (_superficieController.text.isNotEmpty) {
        data['superficie'] = int.parse(_superficieController.text);
      }

      if (_imageBytes != null) {
        await ApiService.updatePropertyWithImage(
          id: _propertyId!,
          titre: data['titre'],
          description: data['description'],
          prix: data['prix'],
          district: data['district'],
          chambres: data['chambres'],
          superficie: data['superficie'],
          photoBytes: _imageBytes!,
          fileName: 'image.jpg',
        );
      } else {
        await ApiService.updateProperty(_propertyId!, data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annonce modifiée !')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Modifier l\'annonce')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(_titreController, 'Titre *'),
                    _buildTextField(_descriptionController, 'Description *', maxLines: 4),
                    _buildTextField(_prixController, 'Prix (FCFA) *', keyboardType: TextInputType.number),
                    _buildDistrictDropdown(),
                    _buildTextField(_chambresController, 'Nombre de pièces *', keyboardType: TextInputType.number),
                    _buildTextField(_superficieController, 'Superficie (m²)', keyboardType: TextInputType.number),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo),
                      label: Text('Changer la photo'),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12)),
                    ),
                    if (_imageBytes != null) ...[
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(_imageBytes!, height: 150, width: double.infinity, fit: BoxFit.cover),
                      ),
                    ] else if (_property?.photo != null) ...[
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          'http://127.0.0.1:8000${_property!.photo}',
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('Enregistrer les modifications'),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => v!.isEmpty ? 'Requis' : null,
      ),
    );
  }

  Widget _buildDistrictDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Quartier *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          alignLabelWithHint: true,
        ),
        value: _selectedDistrict,
        hint: Text('Sélectionnez un quartier'),
        items: [
          DropdownMenuItem(child: Text('Choisir'), value: null),
          ..._districts.map((d) => DropdownMenuItem(value: d, child: Text(d))),
        ],
        onChanged: (v) => setState(() => _selectedDistrict = v),
        validator: (v) => v == null ? 'Sélectionnez un quartier' : null,
      ),
    );
  }
}