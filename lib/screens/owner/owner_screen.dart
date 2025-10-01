import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/helper/color_extensions.dart';
import 'package:kossumba_app/models/facility.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/models/property_image.dart';
import 'package:kossumba_app/models/room_type_image.dart';
import 'package:kossumba_app/screens/location_picker_screen.dart';
import 'package:kossumba_app/screens/property_detail_screen.dart';
import 'package:kossumba_app/services/owner_service.dart';

class OwnerScreen extends StatefulWidget {
  final dynamic propertyToEdit;

  const OwnerScreen({Key? key, this.propertyToEdit}) : super(key: key);

  @override
  State<OwnerScreen> createState() => _OwnerScreenState();
}

class _OwnerScreenState extends State<OwnerScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;
  final _stepFormKeys = List.generate(5, (index) => GlobalKey<FormState>());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rulesController = TextEditingController();
  final TextEditingController _yearBuiltController = TextEditingController();
  final TextEditingController _managerNameController = TextEditingController();
  final TextEditingController _managerPhoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _genderPreference = 'Campur';
  File? _rulesFile;
  DateTime? _selectedYearBuilt;
  bool _hasManager = false;

  final TextEditingController _addressStreetController =
      TextEditingController();
  final TextEditingController _addressCityController = TextEditingController();
  final TextEditingController _addressProvinceController =
      TextEditingController();
  final TextEditingController _addressZipCodeController =
      TextEditingController();
  double? _selectedLatitude;
  double? _selectedLongitude;

  final List<File> _propertyImages = [];
  final List<String> _propertyImageTypes = [];
  List<PropertyImage> _existingPropertyImages = [];
  final List<int> _propertyImagesToDelete = [];

  List<int> _selectedGeneralFacilities = [];
  final List<int> _selectedSpecificFacilities = [];
  List<Facility> _allFacilities = [];
  final TextEditingController _totalRoomsController = TextEditingController();
  List<Map<String, dynamic>> _roomTypesData = [];
  final List<int> _roomTypesToDelete = [];
  final List<Map<String, dynamic>> _generatedRooms = [];
  // Variabel untuk mengontrol tampilan harga tambahan di _buildRoomTypeForm
  bool _showOptionalPrices = false;
  final Map<String, TextEditingController> _floorControllers = {};
  void _fillFormForEdit() {
    final p = widget.propertyToEdit!;
    // Basic fields
    _nameController.text = p.name ?? '';
    _genderPreference = p.genderPreference ?? 'Campur';
    _descriptionController.text = p.description ?? '';
    _rulesController.text = p.rules ?? '';
    _selectedYearBuilt = p.yearBuilt != null ? DateTime(p.yearBuilt!) : null;
    _yearBuiltController.text = p.yearBuilt?.toString() ?? '';

    // Manager info
    if (p.managerName != null && p.managerName!.isNotEmpty) {
      _hasManager = true;
      _managerNameController.text = p.managerName ?? '';
      _managerPhoneController.text = p.managerPhone ?? '';
      _notesController.text = p.notes ?? '';
    }
    // Address
    _addressStreetController.text = p.addressStreet ?? '';
    _addressCityController.text = p.addressCity ?? '';
    _addressProvinceController.text = p.addressProvince ?? '';
    _addressZipCodeController.text = p.addressZipCode ?? '';
    _selectedLatitude = p.latitude ?? 0.0;
    _selectedLongitude = p.longitude ?? 0.0;
    _roomTypesData = [];
    if (p.roomTypes != null && p.roomTypes!.isNotEmpty) {
      for (var rt in p.roomTypes!) {
        final Map<String, dynamic> roomTypeData = {
          'id': rt.id,
          'name': rt.name,
          'description': rt.description ?? '',
          'size_m2': rt.sizeM2 ?? 0,
          'total_rooms': rt.totalRooms,
          'available_rooms': rt.availableRooms,
          'prices': (rt.prices ?? []).map((p) => p.toJson()).toList(),
          'images': (rt.images ?? []).map((i) => i.toJson()).toList(),
          'image_files': <File>[],
          'image_types': <String>[],
          'images_to_delete': <int>[],
          'rooms': (rt.rooms ?? []).map((r) => r.toJson()).toList(),
          'rooms_to_delete': <int>[],
          'specific_facilities':
              (rt.facilities ?? []).cast<Facility>().map((f) => f.id).toList(),
        };

        _roomTypesData.add(roomTypeData);
      }
    }
    _showOptionalPrices = _roomTypesData.any((roomType) {
      final prices = (roomType['prices'] as List<dynamic>?);
      // Cek apakah ada harga dengan periodType selain 'monthly'
      return prices?.any((price) => price['period_type'] != 'monthly') ?? false;
    });
    _existingPropertyImages = List.from(p.images ?? []);

    _selectedGeneralFacilities =
        (p.facilities ?? []).map<int>((Facility f) => f.id ?? 0).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadFacilities();
    if (widget.propertyToEdit != null) {
      _fillFormForEdit();
    }
    if (_roomTypesData.isEmpty) {
      _addRoomType();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    _yearBuiltController.dispose();
    _managerNameController.dispose();
    _managerPhoneController.dispose();
    _notesController.dispose();
    _addressStreetController.dispose();
    _addressCityController.dispose();
    _addressProvinceController.dispose();
    _addressZipCodeController.dispose();
    _totalRoomsController.dispose();
    super.dispose();
  }

  Future<void> _selectYearBuilt(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedYearBuilt ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedYearBuilt) {
      setState(() {
        _selectedYearBuilt = picked;
        _yearBuiltController.text = picked.year.toString();
      });
    }
  }

  void _addRoomType() {
    setState(() {
      _roomTypesData.add({
        'name': '',
        'description': '',
        'size_m2': '',
        'total_rooms': 1,
        'available_rooms': 1,
        'prices': <Map<String, dynamic>>[
          {'period_type': 'monthly', 'price': 0.0},
          {'period_type': 'daily', 'price': 0.0},
          {'period_type': '3_months', 'price': 0.0},
          {'period_type': '6_months', 'price': 0.0},
        ],
        'images': <Map<String, dynamic>>[],
        'image_files': <File>[],
        'image_types': <String>[],
        'images_to_delete': <int>[],
        'rooms': <Map<String, dynamic>>[
          {'room_number': '', 'floor': '', 'status': 'available'}
        ],
        'rooms_to_delete': <int>[],
        'specific_facilities': <int>[],
      });
    });
  }

  Future<void> _pickRulesFile() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Fitur pilih file peraturan belum diimplementasikan.')),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result != null) {
      setState(() {
        _addressStreetController.text = result["address_street"] ?? "";
        _addressCityController.text = result["address_city"] ?? "";
        _addressProvinceController.text = result["address_province"] ?? "";
        _addressZipCodeController.text = result["address_zip_code"] ?? "";
        _selectedLatitude = result["latitude"];
        _selectedLongitude = result["longitude"];
      });
    }
  }

  Future<void> _loadFacilities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _allFacilities = await OwnerService.fetchFacilities();
      if (widget.propertyToEdit != null) {
        _fillFormForEdit();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat fasilitas: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Kumpulkan data yang diperlukan
      final propertyData = _collectPropertyData();

      final roomTypesData = _collectRoomTypesDataForSubmission();
      final roomTypeImages = _collectRoomTypeImagesForSubmission();
      final roomTypeImageTypes = _collectRoomTypeImageTypesForSubmission();
      final roomsData = _collectIndividualRoomsDataForSubmission();
      final generalFacilities = _selectedGeneralFacilities;
      final roomTypeSpecificFacilities =
          _collectRoomTypeSpecificFacilitiesForSubmission();

      Property resultProperty;
      if (widget.propertyToEdit == null) {
        resultProperty = await OwnerService.uploadProperty(
          propertyData: propertyData.toJson(),
          propertyImages: _propertyImages,
          propertyImageTypes: _propertyImageTypes,
          rulesFile: _rulesFile,
          roomTypesData: roomTypesData,
          roomTypeImages: roomTypeImages,
          roomTypeImageTypes: roomTypeImageTypes,
          roomsData: roomsData,
          generalFacilities: generalFacilities,
          roomTypeSpecificFacilities: roomTypeSpecificFacilities,
        );
      } else {
        resultProperty = await OwnerService.updateProperty(
          propertyId: widget.propertyToEdit!.id,
          propertyData: propertyData.toJson(),
          propertyImagesToAdd: _propertyImages,
          propertyImageTypesToAdd: _propertyImageTypes,
          propertyImagesToDelete: _propertyImagesToDelete,
          rulesFile: _rulesFile,
          roomTypesToUpdate: roomTypesData,
          roomTypesToDelete: _roomTypesToDelete,
          roomTypeImagesToAdd: roomTypeImages,
          roomTypeImageTypesToAdd: roomTypeImageTypes,
          roomsToUpdate: roomsData,
          roomTypeSpecificFacilitiesToUpdate: roomTypeSpecificFacilities,
          generalFacilities: generalFacilities,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Properti berhasil diupdate!')),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PropertyDetailScreen(propertyId: resultProperty.id),
        ),
      );
    } catch (e) {
      print('Error occurred while submitting form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan properti: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<List<Map<String, dynamic>>> _collectIndividualRoomsDataForSubmission() {
    List<List<Map<String, dynamic>>> roomsData = [];

    for (var rtIndex = 0; rtIndex < _roomTypesData.length; rtIndex++) {
      List<Map<String, dynamic>> individualRooms = [];

      var roomsInState = (_roomTypesData[rtIndex]['rooms'] as List)
          .cast<Map<String, dynamic>>();

      for (var roomIndex = 0; roomIndex < roomsInState.length; roomIndex++) {
        final floorController =
            _floorControllers['floor_${rtIndex}_$roomIndex'];
        individualRooms.add({
          'id': roomsInState[roomIndex]['id'],
          'room_number': roomsInState[roomIndex]['room_number'],
          'floor': floorController?.text.isEmpty == true
              ? null
              : int.tryParse(floorController?.text ?? ''),
          'status': roomsInState[roomIndex]['status'],
        });
      }
      roomsData.add(individualRooms);
    }

    return roomsData;
  }

  void _onStepContinue() {
    if (!_stepFormKeys[_currentStep].currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Harap perbaiki kesalahan di langkah ini.')),
      );
      return;
    }

    if (_currentStep < _getSteps().length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      _submitForm();
    }
  }

  bool _isLastStep() => _currentStep == 4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Properti Baru'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Stepper(
                type: StepperType.vertical,
                currentStep: _currentStep,
                onStepContinue: _onStepContinue,
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep--;
                    });
                  }
                },
                onStepTapped: (step) {
                  if (step < _currentStep) {
                    setState(() {
                      _currentStep = step;
                    });
                  }
                  // Jika langkah yang dituju lebih besar, periksa validasi langkah saat ini
                  else if (step > _currentStep) {
                    if (_stepFormKeys[_currentStep].currentState!.validate()) {
                      setState(() {
                        _currentStep = step;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Harap lengkapi langkah ini sebelum melanjutkan.'),
                        ),
                      );
                    }
                  }
                },
                controlsBuilder:
                    (BuildContext context, ControlsDetails details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(_isLastStep() ? 'Simpan' : 'Lanjut'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (_currentStep > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: details.onStepCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade600,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Kembali'),
                            ),
                          ),
                      ],
                    ),
                  );
                },
                steps: _getSteps(),
              ),
            ),
    );
  }

  List<Step> _getSteps() {
    return [
      Step(
        title: const Text('Data Properti Utama'),
        content: _buildStep1(),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Alamat & Lokasi'),
        content: _buildStep2(),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Foto Properti'),
        content: _buildStep3(),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Fasilitas Umum'),
        content: _buildStep4(),
        isActive: _currentStep >= 3,
        state: _currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Tipe Kamar & Harga Sewa'),
        content: _buildStep5(),
        isActive: _currentStep >= 4,
        state: _currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
    ];
  }

  Widget _buildStep1() {
    return Form(
      key: _stepFormKeys[0],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnimatedSection(
              title: 'Informasi Dasar Properti',
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Properti Kos',
                    validator: (value) =>
                        value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  _buildDropdownField(
                    value: _genderPreference,
                    label: 'Disewakan untuk',
                    items: ['Putra', 'Putri', 'Campur'],
                    onChanged: (val) =>
                        setState(() => _genderPreference = val!),
                  ),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Deskripsi Kos',
                    maxLines: 3,
                    validator: (value) =>
                        value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
                  ),
                  _buildTextField(
                    controller: _rulesController,
                    label: 'Peraturan Kos (teks)',
                    maxLines: 3,
                  ),
                  ElevatedButton.icon(
                    onPressed: _pickRulesFile,
                    icon: Icon(
                      Icons.upload_file,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary, // icon kontras
                    ),
                    label: Text(
                      _rulesFile != null
                          ? 'File Terpilih ✅'
                          : 'Upload File Peraturan',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary, // teks kontras
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary, // sesuai tema
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _selectYearBuilt(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _yearBuiltController,
                        label: 'Tahun Dibangun',
                        suffixIcon: const Icon(Icons.calendar_today),
                        validator: (value) => value!.isEmpty
                            ? 'Tahun dibangun tidak boleh kosong'
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildAnimatedSection(
              title: 'Data Pengelola',
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: CheckboxListTile(
                      key: ValueKey(_hasManager),
                      title: const Text('Apakah ada Pengelola?'),
                      value: _hasManager,
                      onChanged: (bool? value) {
                        setState(() {
                          _hasManager = value ?? false;
                          if (!_hasManager) {
                            _managerNameController.clear();
                            _managerPhoneController.clear();
                            _notesController.clear();
                          }
                        });
                      },
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 500),
                    child: _hasManager
                        ? Column(
                            children: [
                              _buildTextField(
                                controller: _managerNameController,
                                label: 'Nama Pengelola',
                                validator: (value) =>
                                    _hasManager && value!.isEmpty
                                        ? 'Nama pengelola tidak boleh kosong'
                                        : null,
                              ),
                              _buildTextField(
                                controller: _managerPhoneController,
                                label: 'Nomor Telepon Pengelola',
                                keyboardType: TextInputType.phone,
                                validator: (value) => _hasManager &&
                                        value!.isEmpty
                                    ? 'Nomor telepon pengelola tidak boleh kosong'
                                    : null,
                              ),
                              _buildTextField(
                                controller: _notesController,
                                label: 'Catatan (Opsional)',
                                maxLines: 2,
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedSection({
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final primaryLight = primary.withOpacity(0.08);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: primary.withOpacity(0.15),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: primary.darken(0.2),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(
              thickness: 1.0,
              color: Colors.grey,
              height: 20,
            ),
            child,
          ],
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
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.deepPurple.withOpacity(0.05),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.deepPurple.withOpacity(0.05),
        ),
        items: items.map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _stepFormKeys[1],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAnimatedSection(
              title: 'Alamat Lengkap',
              child: Column(
                children: [
                  _buildTextField(
                    controller: _addressStreetController,
                    label: 'Jalan',
                    validator: (value) =>
                        value!.isEmpty ? 'Jalan tidak boleh kosong' : null,
                  ),
                  _buildTextField(
                    controller: _addressCityController,
                    label: 'Kota',
                    validator: (value) =>
                        value!.isEmpty ? 'Kota tidak boleh kosong' : null,
                  ),
                  _buildTextField(
                    controller: _addressProvinceController,
                    label: 'Provinsi',
                    validator: (value) =>
                        value!.isEmpty ? 'Provinsi tidak boleh kosong' : null,
                  ),
                  _buildTextField(
                    controller: _addressZipCodeController,
                    label: 'Kode Pos',
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            _buildAnimatedSection(
              title: 'Lokasi di Peta',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickLocation,
                    icon: const Icon(Icons.map),
                    label: Text(
                      _selectedLatitude != null
                          ? 'Lokasi dipilih: (${_selectedLatitude!.toStringAsFixed(4)}, ${_selectedLongitude!.toStringAsFixed(4)})'
                          : 'Pilih Lokasi dari Peta',
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimary, // teks kontras
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primary, // sesuai tema
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _selectedLatitude == null
                        ? Padding(
                            key: const ValueKey(0),
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Harap pilih lokasi dari peta.',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(
                            key: ValueKey(1),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    // Tipe gambar yang tersedia
    final List<String> imageTypes = [
      'front_view',
      'interior',
      'street_view',
      'other'
    ];
    final List<String> imageLabels = [
      'Tampak Depan Bangunan',
      'Tampilan Dalam Bangunan',
      'Tampak dari Jalan',
      'Lainnya'
    ];

    return Form(
      key: _stepFormKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Upload Foto Bangunan Kos'),
          ...imageTypes.asMap().entries.map((entry) {
            int idx = entry.key;
            String imageType = entry.value;
            String imageLabel = imageLabels[idx];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _pickPropertyImage(imageType),
                  icon: const Icon(Icons.add_a_photo),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primary, // sesuai tema
                    foregroundColor: Theme.of(context)
                        .colorScheme
                        .onPrimary, // teks & ikon kontras
                  ),
                  label: Text('Tambah Foto $imageLabel'),
                ),
                const SizedBox(height: 8),
                _buildImagePreviewsByType(imageType),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return Form(
      key: _stepFormKeys[3],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSectionTitle('Pilih Fasilitas Umum Kos'),
          _buildGeneralFacilitiesCheckboxes(),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    if (_roomTypesData.isEmpty) {
      _addRoomType();
    }

    return Form(
      key: _stepFormKeys[4],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            _buildSectionTitle('Tipe Kamar'),
            ..._roomTypesData.asMap().entries.map((entry) {
              int idx = entry.key;
              Map<String, dynamic> roomType = entry.value;
              return _buildRoomTypeForm(idx, roomType);
            }).toList(),
            ElevatedButton.icon(
              onPressed: _addRoomType,
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // sesuai tema
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary, // teks & ikon kontras
              ),
              label: const Text('Tambah Tipe Kamar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreviewsByType(String imageType) {
    final existingImages =
        _existingPropertyImages.where((img) => img.type == imageType).toList();
    final newImages = _propertyImages
        .asMap()
        .entries
        .where((entry) => _propertyImageTypes[entry.key] == imageType)
        .map((entry) => entry.value)
        .toList();

    if (existingImages.isEmpty && newImages.isEmpty) {
      return const Text('Belum ada foto untuk tipe ini.',
          style: TextStyle(fontStyle: FontStyle.italic));
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ...existingImages.asMap().entries.map((entry) {
          PropertyImage img = entry.value;
          int idx = entry.key;
          return Stack(
            children: [
              Image.network('$apiBaseUrl/storage/${img.imageUrl}',
                  width: 100, height: 100, fit: BoxFit.cover),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _existingPropertyImages
                          .removeWhere((e) => e.id == img.id);
                      _propertyImagesToDelete.add(img.id);
                    });
                  },
                  child: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ),
            ],
          );
        }).toList(),
        ...newImages.asMap().entries.map((entry) {
          int idx = entry.key;
          File imgFile = entry.value;
          return Stack(
            children: [
              Image.file(imgFile, width: 100, height: 100, fit: BoxFit.cover),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    final originalIndex = _propertyImages.indexOf(imgFile);
                    if (originalIndex != -1) {
                      setState(() {
                        _propertyImages.removeAt(originalIndex);
                        _propertyImageTypes.removeAt(originalIndex);

                        // debug print
                        print("Removed image: ${imgFile.path}");
                      });
                    }
                  },
                  child: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Future<void> _pickPropertyImage(String imageType) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _propertyImages.add(File(pickedFile.path));
        _propertyImageTypes.add(imageType);
      });
    }
  }

  Widget _buildGeneralFacilitiesCheckboxes() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _allFacilities.where((f) => f.type == 'umum').map((facility) {
        return FilterChip(
          label: Text(facility.name),
          selected: _selectedGeneralFacilities.contains(facility.id),
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                _selectedGeneralFacilities.add(facility.id);
              } else {
                _selectedGeneralFacilities.remove(facility.id);
              }
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildRoomTypeForm(int rtIndex, Map<String, dynamic> roomType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tipe Kamar ${rtIndex + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      if (roomType['id'] != null) {
                        (roomType['images_to_delete'] as List<dynamic>)
                            .cast<int>()
                            .add(roomType['id'] as int);
                        _roomTypesToDelete.add(roomType['id'] as int);
                      }
                      _roomTypesData.removeAt(rtIndex);
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              initialValue: roomType['name'],
              decoration: const InputDecoration(labelText: 'Nama Tipe Kamar'),
              onChanged: (val) => roomType['name'] = val,
              validator: (value) =>
                  value!.isEmpty ? 'Nama tipe kamar tidak boleh kosong' : null,
            ),
            TextFormField(
              initialValue: roomType['description'],
              decoration:
                  const InputDecoration(labelText: 'Deskripsi Tipe Kamar'),
              onChanged: (val) => roomType['description'] = val,
            ),
            TextFormField(
              initialValue: roomType['size_m2']?.toString(),
              decoration: const InputDecoration(labelText: 'Ukuran Kamar (m2)'),
              keyboardType: TextInputType.number,
              onChanged: (val) => roomType['size_m2'] = double.tryParse(val),
            ),
            TextFormField(
              initialValue: roomType['total_rooms']?.toString(),
              decoration:
                  const InputDecoration(labelText: 'Jumlah Total Kamar'),
              keyboardType: TextInputType.number,
              validator: (value) => value!.isEmpty || int.tryParse(value)! <= 0
                  ? 'Jumlah kamar harus > 0'
                  : null,
              onChanged: (val) {
                roomType['total_rooms'] = int.tryParse(val);
                roomType['available_rooms'] = int.tryParse(val);
              },
            ),
            // Harga Sewa
            _buildSectionTitle('Harga Sewa'),
            TextFormField(
              initialValue: (roomType['prices'] as List)
                  .firstWhere((p) => p['period_type'] == 'monthly',
                      orElse: () => {'price': null})['price']
                  ?.toString(),
              decoration: const InputDecoration(labelText: 'Bulanan (Wajib)'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Harga bulanan tidak boleh kosong' : null,
              onChanged: (val) {
                if ((roomType['prices'] as List)
                    .any((p) => p['period_type'] == 'monthly')) {
                  (roomType['prices'] as List).firstWhere(
                          (p) => p['period_type'] == 'monthly')['price'] =
                      double.tryParse(val);
                } else {
                  (roomType['prices'] as List).add({
                    'period_type': 'monthly',
                    'price': double.tryParse(val)
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Tambahkan Opsi Harga Lain?'),
              value: _showOptionalPrices,
              onChanged: (bool? value) {
                setState(() {
                  _showOptionalPrices = value ?? false;
                });
              },
            ),
            if (_showOptionalPrices) ...[
              TextFormField(
                initialValue: (roomType['prices'] as List)
                    .firstWhere((p) => p['period_type'] == 'daily',
                        orElse: () => {'price': null})['price']
                    ?.toString(),
                decoration: const InputDecoration(labelText: 'Harian'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if ((roomType['prices'] as List)
                      .any((p) => p['period_type'] == 'daily')) {
                    (roomType['prices'] as List).firstWhere(
                            (p) => p['period_type'] == 'daily')['price'] =
                        double.tryParse(val);
                  } else {
                    (roomType['prices'] as List).add({
                      'period_type': 'daily',
                      'price': double.tryParse(val)
                    });
                  }
                },
              ),
              TextFormField(
                initialValue: (roomType['prices'] as List)
                    .firstWhere((p) => p['period_type'] == '3_months',
                        orElse: () => {'price': null})['price']
                    ?.toString(),
                decoration: const InputDecoration(labelText: '3 Bulanan'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if ((roomType['prices'] as List)
                      .any((p) => p['period_type'] == '3_months')) {
                    (roomType['prices'] as List).firstWhere(
                            (p) => p['period_type'] == '3_months')['price'] =
                        double.tryParse(val);
                  } else {
                    (roomType['prices'] as List).add({
                      'period_type': '3_months',
                      'price': double.tryParse(val)
                    });
                  }
                },
              ),
              TextFormField(
                initialValue: (roomType['prices'] as List)
                    .firstWhere((p) => p['period_type'] == '6_months',
                        orElse: () => {'price': null})['price']
                    ?.toString(),
                decoration: const InputDecoration(labelText: '6 Bulanan'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  if ((roomType['prices'] as List)
                      .any((p) => p['period_type'] == '6_months')) {
                    (roomType['prices'] as List).firstWhere(
                            (p) => p['period_type'] == '6_months')['price'] =
                        double.tryParse(val);
                  } else {
                    (roomType['prices'] as List).add({
                      'period_type': '6_months',
                      'price': double.tryParse(val)
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  ['interior', 'cover', 'bathroom', 'other'].map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary, // sesuai tema
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary, // teks & ikon kontras
                      ),
                      onPressed: () => _pickRoomTypeImageByCategory(
                          rtIndex, roomType, category),
                      icon: const Icon(Icons.add_a_photo),
                      label: Text('Tambah Foto ${category.toTitleCase()}'),
                    ),
                    const SizedBox(height: 4),
                    _buildRoomTypeImagePreviewsByCategory(
                        rtIndex, roomType, category),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            _buildSectionTitle('Fasilitas Tipe Kamar'),
            _buildRoomTypeFacilitiesCheckboxes(rtIndex, roomType),
            const SizedBox(height: 16),
            _buildSectionTitle('Kamar Individual'),
            ...roomType['rooms'].asMap().entries.map((entry) {
              int roomIdx = entry.key;
              Map<String, dynamic> room = entry.value;
              return _buildIndividualRoomForm(roomType, rtIndex, roomIdx, room);
            }).toList(),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  (roomType['rooms'] as List).add({
                    'room_number': '',
                    'floor': '',
                    'status': 'available',
                  });
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary, // sesuai tema
                foregroundColor: Theme.of(context)
                    .colorScheme
                    .onPrimary, // teks & ikon kontras
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Kamar Individual'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomTypeImagePreviewsByCategory(
      int rtIndex, Map<String, dynamic> roomType, String category) {
    // Filter existing images sesuai kategori
    final existingImages = (roomType['images'] as List? ?? [])
        .cast<Map<String, dynamic>>()
        .map((e) => RoomTypeImage.fromJson(e))
        .where((img) => img.type == category)
        .toList();

    // Filter new images sesuai kategori
    final newImages = <File>[];
    final imageTypes = roomType['image_types'] as List<String>? ?? [];
    final files = roomType['image_files'] as List<File>? ?? [];

    for (int i = 0; i < files.length; i++) {
      if (imageTypes[i] == category) {
        newImages.add(files[i]);
      }
    }

    if (existingImages.isEmpty && newImages.isEmpty) {
      return const Text(
        'Belum ada foto untuk kategori ini.',
        style: TextStyle(fontStyle: FontStyle.italic),
      );
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        // Existing images
        ...existingImages.asMap().entries.map((entry) {
          final idx = entry.key;
          final img = entry.value;
          return Stack(
            children: [
              Image.network(
                '$apiBaseUrl/storage/${img.imageUrl}',
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      roomType['images_to_delete'] ??= <int>[];
                      if (!roomType['images_to_delete'].contains(img.id)) {
                        roomType['images_to_delete'].add(img.id);
                      }

                      // Hapus gambar dari list asli berdasarkan ID, bukan index
                      (roomType['images'] as List)
                          .removeWhere((e) => (e is Map && e['id'] == img.id));

                      print(
                          "Images to delete for roomType ${roomType['name']}: ${roomType['images_to_delete']}");
                    });
                  },
                  child: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ),
            ],
          );
        }).toList(),

        // New images
        ...newImages.asMap().entries.map((entry) {
          final idx = entry.key;
          final file = entry.value;
          return Stack(
            children: [
              Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      final filesList = roomType['image_files'] as List<File>;
                      final typesList = roomType['image_types'] as List<String>;
                      // Cari index asli di list
                      final originalIndex = filesList.indexOf(file);
                      if (originalIndex != -1) {
                        filesList.removeAt(originalIndex);
                        typesList.removeAt(originalIndex);
                      }
                    });
                  },
                  child: const Icon(Icons.remove_circle, color: Colors.red),
                ),
              ),
            ],
          );
        }).toList(),
      ],
    );
  }

  Future<void> _pickRoomTypeImageByCategory(
      int rtIndex, Map<String, dynamic> roomType, String category) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        // Pastikan list untuk file ada
        roomType['image_files'] ??= <File>[];
        roomType['image_types'] ??= <String>[];

        roomType['image_files'].add(File(pickedFile.path));
        roomType['image_types'].add(category); // Simpan kategorinya
      });
    }
  }

  Future<void> _pickRoomTypeImage(
      int rtIndex, Map<String, dynamic> roomType) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        (roomType['image_files'] as List<File>).add(File(pickedFile.path));
        (roomType['image_types'] as List<String>).add('other');
      });
    }
  }

  List<Map<String, dynamic>> _collectRoomTypesDataForSubmissions() {
    List<Map<String, dynamic>> roomTypesToSubmit = [];

    for (var rtData in _roomTypesData) {
      // rooms yang mau diupdate = rooms asli minus rooms_to_delete
      List<Map<String, dynamic>> roomsToUpdate = [];
      if (rtData['rooms'] != null) {
        roomsToUpdate = (rtData['rooms'] as List<dynamic>)
            .where((r) => !(rtData['rooms_to_delete'] ?? []).contains(r['id']))
            .map((room) => {
                  'id': room['id']?.toString() ?? '0',
                  'room_number': room['room_number'] ?? '',
                  'floor': room['floor']?.toString() ?? '0',
                  'status': room['status'] ?? 'available',
                })
            .toList();
      }

      roomTypesToSubmit.add({
        'id': rtData['id']?.toString() ?? '0',
        'name': rtData['name'] ?? '',
        'description': rtData['description'] ?? '',
        'size_m2': rtData['size_m2']?.toString() ?? '0',
        'total_rooms': rtData['total_rooms']?.toString() ?? '0',
        'rooms_to_delete':
            rtData['rooms_to_delete']?.map((r) => r.toString()).toList() ?? [],
        'rooms_to_update': roomsToUpdate,
        'prices': rtData['prices'] ?? [],
        'images_to_delete':
            rtData['images_to_delete']?.map((i) => i.toString()).toList() ?? [],
        'specific_facilities': rtData['specific_facilities'] ?? [],
        'images_to_add': rtData['images_to_add'] ?? [],
      });
    }

    return roomTypesToSubmit;
  }

  List<Map<String, dynamic>> _collectRoomTypesDataForSubmission() {
    List<Map<String, dynamic>> roomTypesToSubmit = [];
    for (var rtData in _roomTypesData) {
      roomTypesToSubmit.add({
        'id': rtData['id'],
        'name': rtData['name'],
        'description': rtData['description'],
        'size_m2': rtData['size_m2'],
        'total_rooms': rtData['total_rooms'],
        'available_rooms': rtData['available_rooms'],
        'prices': rtData['prices'],
        'images_to_delete': rtData['images_to_delete'],
        'specific_facilities': rtData['specific_facilities'],
        'rooms_to_delete': rtData['rooms_to_delete'] ?? [],
        'rooms': rtData['rooms'],
        'rooms_to_update': (rtData['rooms'] as List<dynamic>?)
                ?.map((room) => {
                      'id': room['id'],
                      'room_number': room['room_number'],
                      'floor': room['floor'],
                      'status': room['status'],
                    })
                .toList() ??
            [],
        'images_to_add': rtData['image_files'] ?? [],
        'image_types_to_add': rtData['image_types'] ?? [],
      });
    }
    return roomTypesToSubmit;
  }

  Property _collectPropertyData() {
    return Property(
      id: widget.propertyToEdit?.id ?? 0,
      userId: 0,
      name: _nameController.text,
      genderPreference: _genderPreference,
      description: _descriptionController.text,
      rules: _rulesController.text,
      rulesFileUrl: null,
      yearBuilt: int.tryParse(_yearBuiltController.text),
      managerName: _hasManager ? _managerNameController.text : null,
      managerPhone: _hasManager ? _managerPhoneController.text : null,
      notes: _hasManager ? _notesController.text : null,
      addressStreet: _addressStreetController.text,
      addressCity: _addressCityController.text,
      addressProvince: _addressProvinceController.text,
      addressZipCode: _addressZipCodeController.text,
      latitude: _selectedLatitude,
      longitude: _selectedLongitude,
      totalRooms: _roomTypesData.fold(
          0, (sum, rt) => sum + (rt['total_rooms'] as int? ?? 0)),
      availableRooms: _roomTypesData.fold(
          0, (sum, rt) => sum + (rt['available_rooms'] as int? ?? 0)),
      images: [],
      roomTypes: [],
      facilities: _allFacilities
          .where((f) => _selectedGeneralFacilities.contains(f.id))
          .toList(),
      reviews: [],
    );
  }

  List<List<File>> _collectRoomTypeImagesForSubmission() {
    List<List<File>> images = [];
    for (var rtData in _roomTypesData) {
      images.add(rtData['image_files'] as List<File>);
    }
    return images;
  }

  List<List<String>> _collectRoomTypeImageTypesForSubmission() {
    List<List<String>> types = [];
    for (var rtData in _roomTypesData) {
      types.add(rtData['image_types'] as List<String>);
    }
    return types;
  }

// Perbaikan pada fungsi _collectRoomTypeSpecificFacilitiesForSubmission()
  List<List<int>> _collectRoomTypeSpecificFacilitiesForSubmission() {
    final facilitiesData = _roomTypesData.map((roomTypeData) {
      final facilities = roomTypeData['specific_facilities'];
      if (facilities is List) {
        // Pastikan inner list memiliki tipe List<int>
        return facilities.whereType<int>().toList();
      }
      // Kembalikan list kosong jika tidak ada fasilitas
      return <int>[];
    }).toList();

    // Ubah tipe data List terluar ke List<List<int>>
    return facilitiesData.cast<List<int>>();
  }

  List<List<int>> _collectRoomTypeSpecificFacilitiesForSubmission1() {
    List<List<int>> facilities = [];
    for (var rtData in _roomTypesData) {
      facilities.add(rtData['specific_facilities'] as List<int>);
    }
    return facilities;
  }

  Widget _buildRoomTypeFacilitiesCheckboxes(
      int rtIndex, Map<String, dynamic> roomType) {
    final relevantFacilities = _allFacilities
        .where((f) => f.type == 'kamar' || f.type == 'kamar_mandi')
        .toList();

    if (relevantFacilities.isEmpty) {
      return const Text('Tidak ada fasilitas spesifik kamar yang tersedia.');
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: relevantFacilities.map((facility) {
        return FilterChip(
          label: Text(facility.name),
          selected: (roomType['specific_facilities'] as List<dynamic>)
              .map((item) => item as int)
              .toList()
              .contains(facility.id),
          onSelected: (bool selected) {
            setState(() {
              // Get the list and convert it to List<int> safely
              final facilitiesList = (roomType['specific_facilities'] as List)
                  .map((item) => item as int)
                  .toList();

              if (selected) {
                if (!facilitiesList.contains(facility.id)) {
                  facilitiesList.add(facility.id);
                }
              } else {
                facilitiesList.remove(facility.id);
              }
              // Assign the new, updated list back to the map
              roomType['specific_facilities'] = facilitiesList;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildIndividualRoomForm(Map<String, dynamic> roomType, int rtIndex,
      int roomIdx, Map<String, dynamic> room) {
    // Dapatkan atau buat controller untuk lantai
    final floorController = _floorControllers.putIfAbsent(
        'floor_${rtIndex}_$roomIdx', () => TextEditingController());
    if (room['floor'] != null && floorController.text.isEmpty) {
      floorController.text = room['floor'].toString();
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kamar ${roomIdx + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  // Kode onpressed yang sudah diperbaiki

                  onPressed: () {
                    setState(() {
                      if (room['id'] != null) {
                        // Ambil daftar rooms_to_delete, pastikan itu List<dynamic>,
                        // lalu tambahkan ID dengan konversi yang aman
                        final roomsToDelete =
                            (roomType['rooms_to_delete'] as List);
                        roomsToDelete.add(room['id']);
                      }
                      // Hapus kamar dari daftar rooms yang sedang diedit
                      (roomType['rooms'] as List).removeAt(roomIdx);
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              initialValue: room['room_number'],
              decoration: const InputDecoration(labelText: 'Nomor/Nama Kamar'),
              onChanged: (val) {
                setState(() {
                  room['room_number'] = val;
                });
              },
              validator: (value) => value == null || value.isEmpty
                  ? 'Nomor kamar tidak boleh kosong'
                  : null,
            ),
            TextFormField(
              controller: floorController,
              decoration: const InputDecoration(labelText: 'Lantai'),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty
                  ? 'Lantai tidak boleh kosong'
                  : null,
            ),
            DropdownButtonFormField<String>(
              value: room['status'],
              decoration: const InputDecoration(labelText: 'Status Kamar'),
              items:
                  ['available', 'occupied', 'maintenance'].map((String value) {
                return DropdownMenuItem<String>(
                    value: value, child: Text(value.toUpperCase()));
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    room['status'] = newValue;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}
