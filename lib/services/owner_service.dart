import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kossumba_app/Models/facility.dart';
import 'package:kossumba_app/models/property.dart';
import 'package:kossumba_app/services/api_service.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class OwnerService {
  // Mengambil daftar properti milik pemilik (Authenticated)
  static Future<List<Property>> fetchOwnerPropertiesList() async {
    return ApiService.getOwnerPropertiesList();
  }

  // Metode untuk mengunggah properti baru (Authenticated, Multipart)
  static Future<Property> uploadProperty({
    required Property propertyData,
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
    // Kumpulkan semua fields dan files untuk ApiService
    Map<String, dynamic> fields = {
      'name': propertyData.name,
      'gender_preference': propertyData.genderPreference,
      'description': propertyData.description,
      'rules': propertyData.rules ?? '',
      'rules_file_url': propertyData.rulesFileUrl ?? '',
      'year_built': propertyData.yearBuilt?.toString() ?? '',
      'manager_name': propertyData.managerName ?? '',
      'manager_phone': propertyData.managerPhone ?? '',
      'notes': propertyData.notes ?? '',
      'address_street': propertyData.addressStreet,
      'address_city': propertyData.addressCity,
      'address_province': propertyData.addressProvince,
      'address_zip_code': propertyData.addressZipCode ?? '',
      'latitude': propertyData.latitude?.toString() ?? '',
      'longitude': propertyData.longitude?.toString() ?? '',
      'total_rooms': propertyData.totalRooms.toString(),
      'available_rooms': propertyData.availableRooms.toString(),
      'room_types':
          jsonEncode(roomTypesData), // Encode room_types ke JSON string
      'rooms': jsonEncode(roomsData), // Encode rooms ke JSON string
      'general_facilities': jsonEncode(
          generalFacilities), // Encode general_facilities ke JSON string
      'room_type_specific_facilities': jsonEncode(
          roomTypeSpecificFacilities), // Encode room_type_specific_facilities ke JSON string
    };

    List<http.MultipartFile> files = [];
    if (rulesFile != null) {
      files
          .add(await http.MultipartFile.fromPath('rules_file', rulesFile.path));
    }
    for (int i = 0; i < propertyImages.length; i++) {
      files.add(await http.MultipartFile.fromPath(
        'property_images[$i]',
        propertyImages[i].path,
        contentType: MediaType(
            'image', path.extension(propertyImages[i].path).substring(1)),
      ));
      fields['property_image_types[$i]'] = propertyImageTypes[i];
    }
    for (int rtIndex = 0; rtIndex < roomTypeImages.length; rtIndex++) {
      for (int imgIndex = 0;
          imgIndex < roomTypeImages[rtIndex].length;
          imgIndex++) {
        files.add(await http.MultipartFile.fromPath(
          'room_type_images[$rtIndex][$imgIndex]',
          roomTypeImages[rtIndex][imgIndex].path,
          contentType: MediaType(
              'image',
              path
                  .extension(roomTypeImages[rtIndex][imgIndex].path)
                  .substring(1)),
        ));
        fields['room_type_image_types[$rtIndex][$imgIndex]'] =
            roomTypeImageTypes[rtIndex][imgIndex];
      }
    }

    return ApiService.uploadProperty(fields: fields, files: files);
  }

  // Metode untuk memperbarui properti yang sudah ada (Authenticated, Multipart)
  static Future<Property> updateProperty({
    required int propertyId,
    required Property propertyData,
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
    Map<String, dynamic> fields = {
      'name': propertyData.name,
      'gender_preference': propertyData.genderPreference,
      'description': propertyData.description,
      'rules': propertyData.rules ?? '',
      'rules_file_url': propertyData.rulesFileUrl ?? '',
      'year_built': propertyData.yearBuilt?.toString() ?? '',
      'manager_name': propertyData.managerName ?? '',
      'manager_phone': propertyData.managerPhone ?? '',
      'notes': propertyData.notes ?? '',
      'address_street': propertyData.addressStreet,
      'address_city': propertyData.addressCity,
      'address_province': propertyData.addressProvince,
      'address_zip_code': propertyData.addressZipCode ?? '',
      'latitude': propertyData.latitude?.toString() ?? '',
      'longitude': propertyData.longitude?.toString() ?? '',
      'total_rooms': propertyData.totalRooms.toString(),
      'available_rooms': propertyData.availableRooms.toString(),
      'room_types_to_update': jsonEncode(roomTypesToUpdate),
      'room_types_to_delete': jsonEncode(roomTypesToDelete ?? []),
      'property_images_to_delete': jsonEncode(propertyImagesToDelete ?? []),
      'rooms_to_update': jsonEncode(roomsToUpdate ?? []),
      'general_facilities': jsonEncode(generalFacilities ?? []),
      'room_type_specific_facilities_to_update':
          jsonEncode(roomTypeSpecificFacilitiesToUpdate ?? []),
    };

    List<http.MultipartFile> files = [];
    if (rulesFile != null) {
      files
          .add(await http.MultipartFile.fromPath('rules_file', rulesFile.path));
    }
    if (propertyImagesToAdd != null && propertyImageTypesToAdd != null) {
      for (int i = 0; i < propertyImagesToAdd.length; i++) {
        files.add(await http.MultipartFile.fromPath(
          'property_images_to_add[$i]',
          propertyImagesToAdd[i].path,
          contentType: MediaType('image',
              path.extension(propertyImagesToAdd[i].path).substring(1)),
        ));
        fields['property_image_types_to_add[$i]'] = propertyImageTypesToAdd[i];
      }
    }
    if (roomTypeImagesToAdd != null && roomTypeImageTypesToAdd != null) {
      for (int rtIndex = 0; rtIndex < roomTypeImagesToAdd.length; rtIndex++) {
        for (int imgIndex = 0;
            imgIndex < roomTypeImagesToAdd[rtIndex].length;
            imgIndex++) {
          files.add(await http.MultipartFile.fromPath(
            'room_type_images_to_add[$rtIndex][$imgIndex]',
            roomTypeImagesToAdd[rtIndex][imgIndex].path,
            contentType: MediaType(
                'image',
                path
                    .extension(roomTypeImagesToAdd[rtIndex][imgIndex].path)
                    .substring(1)),
          ));
          fields['room_type_image_types_to_add[$rtIndex][$imgIndex]'] =
              roomTypeImageTypesToAdd[rtIndex][imgIndex];
        }
      }
    }

    return ApiService.updateProperty(
        propertyId: propertyId, fields: fields, files: files);
  }

  // Metode untuk menghapus properti (Authenticated)
  static Future<void> deleteProperty(int propertyId) async {
    await ApiService.deleteProperty(propertyId);
  }

  // Metode untuk update status kamar (Authenticated)
  static Future<void> updateRoomStatus(int roomId, String newStatus) async {
    await ApiService.updateRoomStatus(roomId, newStatus);
  }

  // Metode untuk mengambil daftar fasilitas master (Public)
  static Future<List<Facility>> fetchFacilities() async {
    return ApiService.getFacilities();
  }

  // mediatype
}
