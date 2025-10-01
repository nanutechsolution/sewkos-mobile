import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kossumba_app/screens/manage_rooms_screen.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

enum KosType { putra, putri, campur }

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  int _currentStep = 0;
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  final _propertyNameController = TextEditingController();
  final _propertyDescriptionController = TextEditingController();
  final _propertyAddressController = TextEditingController();
  final _propertyCityController = TextEditingController();
  final _houseRulesController = TextEditingController();

  final Map<String, List<String>> _propertyPhotos = {
    'cover_photo': [],
    'front_photo': [],
    'street_view_photo': [],
  };

  KosType _selectedKosType = KosType.campur;

  final List<Map<String, dynamic>> _roomTypes = [
    {
      'name': TextEditingController(),
      'floor': TextEditingController(text: 'Lantai 1'),
      'size': TextEditingController(),
      'price': TextEditingController(),
      'total_rooms': TextEditingController(text: '1'),
      'facilities': <String>{},
      'images': {
        'interior': [],
        'bathroom': [],
      },
      'rooms': <Map<String, dynamic>>[
        {'name': TextEditingController(text: 'Kamar 1'), 'status': 'Kosong'}
      ],
    },
  ];

  final List<String> _availableFacilities = [
    'WiFi',
    'AC',
    'Kamar Mandi Dalam',
    'Parkir Motor',
    'Dapur',
    'TV',
    'Gym'
  ];

  bool _isLastStep() => _currentStep == 4;

  void _onStepContinue() {
    if (_formKeys[_currentStep].currentState!.validate()) {
      if (_isLastStep()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Properti berhasil disimpan!')),
        );
        Navigator.of(context).pop();
      } else {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _addRoomType() {
    setState(() {
      _roomTypes.add({
        'name': TextEditingController(),
        'floor': TextEditingController(text: 'Lantai ${_roomTypes.length + 1}'),
        'size': TextEditingController(),
        'price': TextEditingController(),
        'total_rooms': TextEditingController(),
        'facilities': <String>{},
        'images': {
          'interior': [],
          'bathroom': [],
        },
        'rooms': <Map<String, dynamic>>[],
      });
    });
  }

  void _removeRoomType(int index) {
    setState(() {
      if (_roomTypes.length > 1) {
        _roomTypes.removeAt(index);
      }
    });
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _propertyDescriptionController.dispose();
    _propertyAddressController.dispose();
    _propertyCityController.dispose();
    _houseRulesController.dispose();
    for (var room in _roomTypes) {
      (room['name'] as TextEditingController).dispose();
      (room['floor'] as TextEditingController).dispose();
      (room['size'] as TextEditingController).dispose();
      (room['price'] as TextEditingController).dispose();
      (room['total_rooms'] as TextEditingController).dispose();
      for (var roomData in room['rooms']) {
        (roomData['name'] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text('Tambah Properti Baru',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        leading: const BackButton(color: Colors.black87),
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        controlsBuilder: (BuildContext context, ControlsDetails details) {
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
                    child: Text(_isLastStep() ? 'Simpan Properti' : 'Lanjut'),
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
        steps: <Step>[
          _buildGeneralDataStep(),
          _buildAddressStep(),
          _buildPhotosStep(),
          _buildHouseRulesStep(),
          _buildRoomTypesStep(),
        ],
      ),
    );
  }

  Step _buildGeneralDataStep() {
    return Step(
      title: const Text('Data Umum'),
      content: Form(
        key: _formKeys[0],
        child: Column(
          children: [
            TextFormField(
              controller: _propertyNameController,
              decoration: const InputDecoration(labelText: 'Nama Properti'),
              validator: (value) =>
                  value!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _propertyDescriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi Singkat'),
              maxLines: 3,
              validator: (value) =>
                  value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Jenis Kos',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<KosType>(
              segments: const [
                ButtonSegment(value: KosType.putra, label: Text('Putra')),
                ButtonSegment(value: KosType.putri, label: Text('Putri')),
                ButtonSegment(value: KosType.campur, label: Text('Campur')),
              ],
              selected: {_selectedKosType},
              onSelectionChanged: (Set<KosType> newSelection) {
                setState(() {
                  _selectedKosType = newSelection.first;
                });
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blue.shade600;
                    }
                    return null;
                  },
                ),
                foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.blue.shade800;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                side: MaterialStateProperty.all(
                    const BorderSide(color: Colors.blue)),
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildAddressStep() {
    return Step(
      title: const Text('Alamat'),
      content: Form(
        key: _formKeys[1],
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Cari Alamat',
                hintText: 'Misalnya: Jl. Merdeka 10',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon:
                      const Icon(Icons.location_on_rounded, color: Colors.blue),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Membuka pencarian alamat...')),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _propertyAddressController,
              decoration: const InputDecoration(labelText: 'Alamat Lengkap'),
              validator: (value) =>
                  value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _propertyCityController,
              decoration: const InputDecoration(labelText: 'Kota/Kabupaten'),
              validator: (value) =>
                  value!.isEmpty ? 'Kota tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _houseRulesController,
              decoration: const InputDecoration(
                labelText: 'Peraturan Kos',
                hintText:
                    'Misalnya: Dilarang membawa hewan peliharaan, jam malam pukul 22:00',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
              validator: (value) =>
                  value!.isEmpty ? 'Peraturan tidak boleh kosong' : null,
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildPhotosStep() {
    return Step(
      title: const Text('Foto Properti'),
      content: Form(
        key: _formKeys[2],
        child: Column(
          children: [
            _buildPhotoGallery('Foto Cover', _propertyPhotos, 'cover_photo',
                isRoomImage: false),
            const SizedBox(height: 16),
            _buildPhotoGallery('Foto Depan', _propertyPhotos, 'front_photo',
                isRoomImage: false),
            const SizedBox(height: 16),
            _buildPhotoGallery(
                'Foto Tampak Jalan', _propertyPhotos, 'street_view_photo',
                isRoomImage: false),
          ],
        ),
      ),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildHouseRulesStep() {
    return Step(
      title: const Text('Peraturan Kos'),
      content: Form(
        key: _formKeys[3],
        child: TextFormField(
          controller: _houseRulesController,
          decoration: const InputDecoration(
            labelText: 'Peraturan Kos',
            hintText:
                'Misalnya: Dilarang membawa hewan peliharaan, jam malam pukul 22:00',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
          validator: (value) =>
              value!.isEmpty ? 'Peraturan tidak boleh kosong' : null,
        ),
      ),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    );
  }

  Step _buildRoomTypesStep() {
    return Step(
      title: const Text('Tipe Kamar'),
      content: Form(
        key: _formKeys[4],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._roomTypes.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> room = entry.value;
              return _buildRoomTypeCard(index, room);
            }).toList(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addRoomType,
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text('Tambah Tipe Kamar'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade600,
                  side: BorderSide(color: Colors.green.shade600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    );
  }

  Widget _buildRoomTypeCard(int index, Map<String, dynamic> room) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tipe Kamar #${index + 1}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                if (_roomTypes.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.red),
                    onPressed: () => _removeRoomType(index),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: room['name'] as TextEditingController,
              decoration: const InputDecoration(labelText: 'Nama Tipe Kamar'),
              validator: (value) =>
                  value!.isEmpty ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: room['floor'] as TextEditingController,
                    decoration: const InputDecoration(labelText: 'Lantai'),
                    validator: (value) =>
                        value!.isEmpty ? 'Lantai tidak boleh kosong' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: room['size'] as TextEditingController,
                    decoration: const InputDecoration(
                        labelText: 'Ukuran Kamar (contoh: 3x4 m)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: room['price'] as TextEditingController,
              decoration: const InputDecoration(labelText: 'Harga per Bulan'),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value!.isEmpty ? 'Harga tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: room['total_rooms'] as TextEditingController,
              decoration:
                  const InputDecoration(labelText: 'Jumlah Total Kamar'),
              keyboardType: TextInputType.number,
              validator: (value) {
                final count = int.tryParse(value ?? '0') ?? 0;
                if (count == 0) {
                  return 'Jumlah kamar tidak boleh kosong';
                }
                return null;
              },
              onChanged: (value) {
                int newCount = int.tryParse(value) ?? 0;
                final currentRooms =
                    room['rooms'] as List<Map<String, dynamic>>;
                int currentCount = currentRooms.length;

                if (newCount > currentCount) {
                  for (int i = currentCount; i < newCount; i++) {
                    currentRooms.add({
                      'name': TextEditingController(
                          text:
                              '${room['name'].text.isEmpty ? 'Kamar' : room['name'].text} ${room['floor'].text} #${i + 1}'),
                      'status': 'Kosong',
                    });
                  }
                } else if (newCount < currentCount) {
                  for (int i = currentCount - 1; i >= newCount; i--) {
                    (currentRooms[i]['name'] as TextEditingController)
                        .dispose();
                    currentRooms.removeAt(i);
                  }
                }
                setState(() {});
              },
            ),
            const SizedBox(height: 16),
            Align(
                alignment: Alignment.centerLeft,
                child: Text('Fasilitas',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _availableFacilities.map((fac) {
                final isSelected =
                    (room['facilities'] as Set<String>).contains(fac);
                return FilterChip(
                  label: Text(fac),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        (room['facilities'] as Set<String>).add(fac);
                      } else {
                        (room['facilities'] as Set<String>).remove(fac);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildRoomImageGallery(room['images']),
            const SizedBox(height: 16),
            if ((room['rooms'] as List).isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final updatedRooms = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ManageRoomsScreen(
                          rooms: room['rooms'] as List<Map<String, dynamic>>,
                          roomTypeName:
                              (room['name'] as TextEditingController).text,
                        ),
                      ),
                    );
                    if (updatedRooms != null) {
                      setState(() {
                        room['rooms'] = updatedRooms;
                      });
                    }
                  },
                  icon: const Icon(Icons.manage_accounts_rounded),
                  label: Text('Kelola ${room['rooms'].length} Kamar'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoGallery(
      String label, Map<String, dynamic> imageMap, String key,
      {required bool isRoomImage}) {
    List<String> images = (imageMap[key] as List).cast<String>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length + 1,
            itemBuilder: (context, index) {
              if (index == images.length) {
                return _buildAddPhotoButton(label, imageMap, key,
                    isRoomImage: isRoomImage);
              }
              return _buildPhotoItem(images[index], label, imageMap, key,
                  index: index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton(
      String label, Map<String, dynamic> imageMap, String key,
      {required bool isRoomImage}) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Memilih foto untuk $label...')),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.add_a_photo_rounded, color: Colors.grey, size: 36),
      ),
    );
  }

  Widget _buildPhotoItem(
      String imageUrl, String label, Map<String, dynamic> imageMap, String key,
      {required int index}) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                (imageMap[key] as List).removeAt(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomImageGallery(Map<String, dynamic> roomImages) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto Kamar',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildPhotoGallery('Interior', roomImages, 'interior',
                  isRoomImage: true),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildPhotoGallery('Kamar Mandi', roomImages, 'bathroom',
                  isRoomImage: true),
            ),
          ],
        ),
      ],
    );
  }
}
