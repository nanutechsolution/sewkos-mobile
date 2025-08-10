import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kossumba_app/owner_service.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/location_picker_screen.dart';

class OwnerScreen extends StatefulWidget {
  final Kos? kosToEdit;
  const OwnerScreen({Key? key, this.kosToEdit}) : super(key: key);

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _facilitiesController = TextEditingController();

  File? _imageFile;
  String _selectedStatus = 'kosong';
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    if (widget.kosToEdit != null) {
      final kos = widget.kosToEdit!;
      _nameController.text = kos.name;
      _locationController.text = kos.location;
      _priceController.text = kos.price;
      _descriptionController.text = kos.description;
      _facilitiesController.text = kos.facilities.join(', ');
      _selectedStatus = kos.status;
      _selectedLatitude = kos.latitude;
      _selectedLongitude = kos.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _facilitiesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );
    if (result != null) {
      setState(() {
        _selectedLatitude = result['latitude'];
        _selectedLongitude = result['longitude'];
        _locationController.text = result['address'];
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
      return;
    }

    try {
      if (widget.kosToEdit != null) {
        await OwnerService.updateKos(
          kosId: widget.kosToEdit!.id,
          name: _nameController.text,
          location: _locationController.text,
          price: _priceController.text,
          description: _descriptionController.text,
          facilities: _facilitiesController.text,
          status: _selectedStatus,
          latitude: _selectedLatitude,
          longitude: _selectedLongitude,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kos berhasil diperbarui!')),
        );
      } else {
        if (_imageFile == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Harap pilih gambar untuk kos baru')),
          );
          return;
        }
        await OwnerService.uploadKos(
          name: _nameController.text,
          location: _locationController.text,
          price: _priceController.text,
          description: _descriptionController.text,
          facilities: _facilitiesController.text,
          status: _selectedStatus,
          image: _imageFile!,
          latitude: _selectedLatitude,
          longitude: _selectedLongitude,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kos berhasil diunggah!')),
        );
      }
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kosToEdit != null ? 'Edit Kos' : 'Unggah Kos Baru'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _sectionTitle('Informasi Kos'),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Nama Kos'),
                validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration('Lokasi'),
                validator: (v) =>
                    v!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(_selectedLatitude != null
                    ? '(${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)})'
                    : 'Pilih Lokasi dari Peta'),
              ),
              const SizedBox(height: 16),
              _sectionTitle('Detail & Harga'),
              TextFormField(
                controller: _priceController,
                decoration: _inputDecoration('Harga per Bulan'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDecoration('Deskripsi'),
                maxLines: 3,
                validator: (v) =>
                    v!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _facilitiesController,
                decoration:
                    _inputDecoration('Fasilitas (pisahkan dengan koma)'),
                validator: (v) =>
                    v!.isEmpty ? 'Fasilitas tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              _sectionTitle('Status Kos'),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: _inputDecoration('Status Kos'),
                items: ['kosong', 'terisi'].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value));
                }).toList(),
                onChanged: (v) => setState(() => _selectedStatus = v!),
              ),
              const SizedBox(height: 16),
              if (widget.kosToEdit == null) ...[
                _sectionTitle('Foto Kos'),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar'),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Image.file(_imageFile!, height: 200),
                  ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  widget.kosToEdit != null ? 'Simpan Perubahan' : 'Unggah Kos',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
