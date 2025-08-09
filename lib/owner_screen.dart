// lib/owner_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kossumba_app/owner_service.dart';
import 'package:kossumba_app/kos.dart';
import 'package:kossumba_app/location_picker_screen.dart';
import 'package:latlong2/latlong.dart';

class OwnerScreen extends StatefulWidget {
  final Kos? kosToEdit;
  const OwnerScreen({Key? key, this.kosToEdit}) : super(key: key);

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();

  File? _imageFile;
  String _selectedStatus = 'kosong';
  double? _selectedLatitude;
  double? _selectedLongitude;

  @override
  void initState() {
    super.initState();
    if (widget.kosToEdit != null) {
      _nameController.text = widget.kosToEdit!.name;
      _locationController.text = widget.kosToEdit!.location;
      _priceController.text = widget.kosToEdit!.price;
      _descriptionController.text = widget.kosToEdit!.description;
      _facilitiesController.text = widget.kosToEdit!.facilities.join(', ');
      _selectedStatus = widget.kosToEdit!.status;
      _selectedLatitude = widget.kosToEdit!.latitude;
      _selectedLongitude = widget.kosToEdit!.longitude;
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

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickLocation() async {
    final Map<String, dynamic>? result =
        await Navigator.of(context).push<Map<String, dynamic>>(
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
    if (_formKey.currentState!.validate()) {
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
              const SnackBar(
                  content: Text('Harap pilih gambar untuk kos baru.')),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
    }
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Kos'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) =>
                    value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickLocation,
                icon: const Icon(Icons.map),
                label: Text(_selectedLatitude != null
                    ? 'Lokasi dipilih: (${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)})'
                    : 'Pilih Lokasi dari Peta'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga per Bulan'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Harga tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _facilitiesController,
                decoration: const InputDecoration(
                    labelText: 'Fasilitas (pisahkan dengan koma)'),
                validator: (value) =>
                    value!.isEmpty ? 'Fasilitas tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['kosong', 'terisi'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value.toUpperCase()),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedStatus = newValue;
                    });
                  }
                },
                decoration: const InputDecoration(
                  labelText: 'Status Kos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (widget.kosToEdit == null) ...[
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pilih Gambar'),
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: Text(
                    widget.kosToEdit != null
                        ? 'Simpan Perubahan'
                        : 'Unggah Kos',
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
