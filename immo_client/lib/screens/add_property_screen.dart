// lib/screens/add_property_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddPropertyScreen extends StatefulWidget {
  @override
  _AddPropertyScreenState createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  String? _selectedDistrict;
  final _chambresController = TextEditingController();
  final _superficieController = TextEditingController();
  Uint8List? _imageBytes;  // 👈 MODIFICATION
  bool _isLoading = false;

  final List<String> _districts = [
    'Almadies',
    'Ngor',
    'Plateau',
    'Fann',
    'Médina',
    'Grand-Yoff',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: null,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();  // 👈 MODIFICATION
      setState(() => _imageBytes = bytes);           // 👈 MODIFICATION
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageBytes == null) {                        // 👈 MODIFICATION
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez sélectionner une photo')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiService.createPropertyWithImage(
        titre: _titreController.text,
        description: _descriptionController.text,
        prix: int.parse(_prixController.text),
        district: _selectedDistrict!,
        chambres: int.parse(_chambresController.text),
        superficie: _superficieController.text.isNotEmpty
            ? int.parse(_superficieController.text)
            : null,
        photoBytes: _imageBytes!,                       // 👈 MODIFICATION
        fileName: 'image.jpg',                          // 👈 MODIFICATION
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Annonce publiée ! En attente de validation.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Publier une annonce')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTextField(
                      controller: _titreController,
                      label: 'Titre *',
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description *',
                      maxLines: 4,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    _buildTextField(
                      controller: _prixController,
                      label: 'Prix (FCFA) *',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    _buildDistrictDropdown(),
                    _buildTextField(
                      controller: _chambresController,
                      label: 'Nombre de pièces *',
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    _buildTextField(
                      controller: _superficieController,
                      label: 'Superficie (m²)',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.photo),
                      label: Text('Choisir une photo'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                    // 👇 AFFICHAGE DE L'IMAGE MODIFIÉ
                    if (_imageBytes != null) ...[
                      SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          _imageBytes!,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('Publier'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
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
        validator: validator,
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
        validator: (v) => v == null ? 'Veuillez sélectionner un quartier' : null,
      ),
    );
  }
}