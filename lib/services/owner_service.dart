import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/config/config.dart';
import 'package:kossumba_app/models/facility.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/models/safe_parser.dart';
import 'package:kossumba_app/services/api_service.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:kossumba_app/services/auth.service.dart';
import 'package:path/path.dart' as path;

class OwnerService {
  // Mengambil daftar properti milik pemilik (Authenticated)
  static Future<List<Property>> fetchOwnerPropertiesList() async {
    return ApiService.getOwnerPropertiesList();
  }

  static Future<Property> uploadProperty({
    required Map<String, dynamic> propertyData,
    required List<File> propertyImages,
    required List<String> propertyImageTypes,
    File? rulesFile,
    required List<Map<String, dynamic>> roomTypesData,
    required List<List<File>> roomTypeImages,
    required List<List<String>> roomTypeImageTypes,
    required List<List<Map<String, dynamic>>> roomsData,
    required List<int> generalFacilities,
    required List<List<int>> roomTypeSpecificFacilities,
  }) async {
    var uri = Uri.parse("$apiBaseUrl/api/owner/properties");
    var request = http.MultipartRequest("POST", uri);

    String? token = await AuthService.getToken();
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    // === FIELDS ===
    propertyData.forEach((key, value) {
      if (value != null &&
          key != 'images' &&
          key != 'room_types' &&
          key != 'facilities') {
        request.fields[key] = value.toString();
      }
    });

    for (var i = 0; i < roomTypesData.length; i++) {
      var rtData = roomTypesData[i];
      request.fields['room_types[$i][name]'] = rtData['name'].toString();
      request.fields['room_types[$i][description]'] =
          rtData['description'].toString();
      request.fields['room_types[$i][size_m2]'] =
          rtData['size_m2']?.toString() ?? '0';
      request.fields['room_types[$i][total_rooms]'] =
          rtData['total_rooms']?.toString() ?? '0';

      List prices = rtData['prices'] as List? ?? [];
      for (var p = 0; p < prices.length; p++) {
        var periodType = prices[p]['period_type'] ?? '';
        var priceVal = prices[p]['price'] ?? 0.0;
        request.fields['room_types[$i][prices][$p][period_type]'] =
            periodType.toString();
        request.fields['room_types[$i][prices][$p][price]'] =
            priceVal.toString();
      }

      List rooms = roomsData.isNotEmpty && roomsData.length > i
          ? roomsData[i] as List? ?? []
          : [];
      for (var j = 0; j < rooms.length; j++) {
        var roomData = rooms[j];
        if (roomData != null) {
          request.fields['rooms[$i][$j][room_number]'] =
              roomData['room_number']?.toString() ?? '';
          request.fields['rooms[$i][$j][floor]'] =
              roomData['floor']?.toString() ?? '1';
          request.fields['rooms[$i][$j][status]'] =
              roomData['status']?.toString() ?? '';
        }
      }

      List specificFacilities = roomTypeSpecificFacilities.isNotEmpty &&
              roomTypeSpecificFacilities[i].isNotEmpty
          ? roomTypeSpecificFacilities[i] as List? ?? []
          : [];
      for (var j = 0; j < specificFacilities.length; j++) {
        request.fields['room_type_specific_facilities[$i][$j]'] =
            specificFacilities[j].toString();
      }
    }

    for (var i = 0; i < generalFacilities.length; i++) {
      request.fields['general_facilities[$i]'] =
          generalFacilities[i].toString();
    }

    // === FILES ===
    if (propertyImages.isNotEmpty) {
      for (var i = 0; i < propertyImages.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'property_images[$i]',
          propertyImages[i].path,
          contentType: MediaType(
              'image', path.extension(propertyImages[i].path).substring(1)),
        ));
        request.fields['property_image_types[$i]'] = propertyImageTypes[i];
      }
    }

    if (roomTypeImages.isNotEmpty) {
      for (var i = 0; i < roomTypeImages.length; i++) {
        for (var j = 0; j < roomTypeImages[i].length; j++) {
          request.files.add(await http.MultipartFile.fromPath(
            'room_type_images[$i][$j]',
            roomTypeImages[i][j].path,
            contentType: MediaType('image',
                path.extension(roomTypeImages[i][j].path).substring(1)),
          ));
          request.fields['room_type_image_types[$i][$j]'] =
              roomTypeImageTypes[i][j];
        }
      }
    }

    if (rulesFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'rules_file',
        rulesFile.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Upload gagal: ${response.statusCode} | $respStr");
    }

    return Property.fromJson(jsonDecode(respStr)['data']);
  }

  static Future<Property> updateProperty({
    required int propertyId,
    required Map<String, dynamic> propertyData,
    List<File>? propertyImagesToAdd,
    List<String>? propertyImageTypesToAdd,
    List<int>? propertyImagesToDelete,
    File? rulesFile,
    required List<Map<String, dynamic>> roomTypesToUpdate,
    List<int>? roomTypesToDelete,
    List<List<File>>? roomTypeImagesToAdd,
    List<List<String>>? roomTypeImageTypesToAdd,
    List<List<Map<String, dynamic>>>? roomsToUpdate,
    List<List<int>>? roomTypeSpecificFacilitiesToUpdate,
    List<int>? generalFacilities,
  }) async {
    final uri = Uri.parse("$apiBaseUrl/api/owner/properties/$propertyId");
    var request = http.MultipartRequest("POST", uri);
    request.fields['_method'] = 'PUT'; // Metode spoofing untuk request PUT
    // Tambahkan print ini untuk melihat payload lengkap
    String? token = await AuthService.getToken();
    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    propertyData.forEach((key, value) {
      if (value != null &&
          key != 'id' &&
          key != 'images' &&
          key != 'room_types' &&
          key != 'facilities') {
        request.fields[key] = value.toString();
      }
    });
    if (propertyImagesToAdd != null) {
      for (var i = 0; i < propertyImagesToAdd.length; i++) {
        var file = propertyImagesToAdd[i];
        request.files.add(await http.MultipartFile.fromPath(
          'property_images_to_add[$i]',
          file.path,
          contentType:
              MediaType('image', path.extension(file.path).substring(1)),
        ));
        request.fields['property_image_types_to_add[$i]'] =
            propertyImageTypesToAdd?[i] ?? 'other';
      }
    }

    // Tambahkan fields untuk data yang akan dihapus
    if (propertyImagesToDelete != null) {
      for (var i = 0; i < propertyImagesToDelete.length; i++) {
        request.fields['property_images_to_delete[$i]'] =
            propertyImagesToDelete[i].toString();
      }
    }
    if (roomTypesToDelete != null) {
      for (var i = 0; i < roomTypesToDelete.length; i++) {
        request.fields['room_types_to_delete[$i]'] =
            roomTypesToDelete[i].toString();
      }
    }
    if (generalFacilities != null) {
      for (var i = 0; i < generalFacilities.length; i++) {
        request.fields['general_facilities[$i]'] =
            generalFacilities[i].toString();
      }
    }

    // Tambahkan fields untuk data yang akan diupdate/ditambahkan
    if (roomTypesToUpdate != null) {
      for (var i = 0; i < roomTypesToUpdate.length; i++) {
        var rtData = roomTypesToUpdate[i];
        request.fields['room_types_to_update[$i][id]'] =
            rtData['id']?.toString() ?? '0';
        request.fields['room_types_to_update[$i][name]'] =
            rtData['name']?.toString() ?? '';
        request.fields['room_types_to_update[$i][description]'] =
            rtData['description']?.toString() ?? '';
        request.fields['room_types_to_update[$i][size_m2]'] =
            rtData['size_m2']?.toString() ?? '0';
        request.fields['room_types_to_update[$i][total_rooms]'] =
            rtData['total_rooms']?.toString() ?? '0';
        // Handle prices
        if (rtData['prices'] != null) {
          List prices = rtData['prices'] as List;
          for (var p = 0; p < prices.length; p++) {
            request.fields[
                    'room_types_to_update[$i][prices][$p][period_type]'] =
                prices[p]['period_type']?.toString() ?? '';
            request.fields['room_types_to_update[$i][prices][$p][price]'] =
                prices[p]['price']?.toString() ?? '0.0';
          }
        }
      }
    }
    // 1. Room types yang akan diupdate
    if (roomTypesToUpdate != null) {
      for (var i = 0; i < roomTypesToUpdate.length; i++) {
        var rt = roomTypesToUpdate[i];
        // Basic info
        request.fields['room_types_to_update[$i][id]'] = rt['id'].toString();
        request.fields['room_types_to_update[$i][name]'] = rt['name'];
        request.fields['room_types_to_update[$i][description]'] =
            rt['description'];
        request.fields['room_types_to_update[$i][size_m2]'] =
            rt['size_m2'].toString();
        request.fields['room_types_to_update[$i][total_rooms]'] =
            rt['total_rooms'].toString();

        // Rooms to update
        if (rt['rooms_to_update'] != null) {
          for (var j = 0; j < (rt['rooms_to_update'] as List).length; j++) {
            var room = rt['rooms_to_update'][j];
            request.fields[
                    'room_types_to_update[$i][rooms_to_update][$j][id]'] =
                room['id'].toString();
            request.fields[
                    'room_types_to_update[$i][rooms_to_update][$j][room_number]'] =
                room['room_number'];
            request.fields[
                    'room_types_to_update[$i][rooms_to_update][$j][floor]'] =
                room['floor'].toString();
            request.fields[
                    'room_types_to_update[$i][rooms_to_update][$j][status]'] =
                room['status'];
          }
        }

        // Rooms to delete
        if (rt['rooms_to_delete'] != null) {
          for (var j = 0; j < (rt['rooms_to_delete'] as List).length; j++) {
            request.fields['room_types_to_update[$i][rooms_to_delete][$j]'] =
                rt['rooms_to_delete'][j].toString();
          }
        }

        // Specific facilities
        if (rt['specific_facilities'] != null) {
          for (var j = 0; j < (rt['specific_facilities'] as List).length; j++) {
            request.fields[
                    'room_types_to_update[$i][specific_facilities][$j]'] =
                rt['specific_facilities'][j].toString();
          }
        }

        // Images to add
        if (rt['images_to_add'] != null) {
          for (var j = 0; j < (rt['images_to_add'] as List<File>).length; j++) {
            var file = rt['images_to_add'][j];
            request.files.add(await http.MultipartFile.fromPath(
              'room_types_to_update[$i][images_to_add][$j]',
              file.path,
              contentType:
                  MediaType('image', path.extension(file.path).substring(1)),
            ));
            request.fields['room_types_to_update[$i][image_types_to_add][$j]'] =
                rt['image_types_to_add']?[j] ?? 'other';
          }
        }

        // Images to delete
        if (rt['images_to_delete'] != null) {
          for (var j = 0;
              j < (rt['images_to_delete'] as List<int>).length;
              j++) {
            request.fields['room_types_to_update[$i][images_to_delete][$j]'] =
                rt['images_to_delete'][j].toString();
          }
        }

        // Prices
        if (rt['prices'] != null) {
          for (var j = 0; j < (rt['prices'] as List).length; j++) {
            request.fields[
                    'room_types_to_update[$i][prices][$j][period_type]'] =
                rt['prices'][j]['period_type'];

            // Pastikan value numeric
            var priceValue = rt['prices'][j]['price'];
            if (priceValue is String) {
              priceValue = double.tryParse(priceValue) ?? 0.0;
            }
            request.fields['room_types_to_update[$i][prices][$j][price]'] =
                priceValue.toString(); // masih string tapi numeric sebenarnya
          }
        }
      }
    }

// 2. Room types yang akan dihapus
    if (roomTypesToDelete != null) {
      for (var i = 0; i < roomTypesToDelete.length; i++) {
        request.fields['room_types_to_delete[$i]'] =
            roomTypesToDelete[i].toString();
      }
    }

// 2. Room types yang akan dihapus
    if (roomTypesToDelete != null) {
      for (var i = 0; i < roomTypesToDelete.length; i++) {
        request.fields['room_types_to_delete[$i]'] =
            roomTypesToDelete[i].toString();
      }
    }

    for (var i = 0; i < roomTypesToUpdate.length; i++) {
      var rtData = roomTypesToUpdate[i];
      if (rtData['images_to_delete'] != null) {
        for (var j = 0;
            j < (rtData['images_to_delete'] as List<int>).length;
            j++) {
          request.fields['room_type_images_to_delete[$i][$j]'] =
              (rtData['images_to_delete'] as List<int>)[j].toString();
        }
      }
    }

    if (rulesFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'rules_file',
        rulesFile.path,
        contentType: MediaType('application', 'pdf'),
      ));
    }
    print("=== Fields yang dikirim ===");
    request.fields.forEach((key, value) {
      print("$key: $value");
    });

    print("=== Files yang dikirim ===");
    for (var f in request.files) {
      print("Field: ${f.field}");
      print("Filename: ${f.filename}");
      print("ContentType: ${f.contentType}");
      print("----");
    }

    var response = await request.send();
    var respStr = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception("Update gagal: ${response.statusCode} | $respStr");
    }

    return Property.fromJson(jsonDecode(respStr)['data']);
  }

  static Future<void> deleteProperty(int propertyId) async {
    final url = Uri.parse('$apiBaseUrl/api/owner/properties/$propertyId');
    String? token = await AuthService.getToken();

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
    if (response.statusCode != 200) {
      throw Exception("Gagal menghapus properti: ${response.statusCode}");
    }
  }

  // Metode untuk update status kamar (Authenticated)
  static Future<void> updateRoomStatus(int roomId, String newStatus) async {
    await ApiService.updateRoomStatus(roomId, newStatus);
  }

  // Metode untuk mengambil daftar fasilitas master (Public)
  static Future<List<Facility>> fetchFacilities() async {
    return ApiService.getFacilities();
  }

// Metode untuk mengirim atau memperbarui data properti ke API
}
