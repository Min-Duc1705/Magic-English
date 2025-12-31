import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:magic_enlish/data/models/BackendResponse.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:magic_enlish/data/models/file/ResponseUploadFile.dart';

class FileService {
  Future<BackendResponse<ResponseUploadFile>> uploadFile(
    String token,
    List<int> fileBytes,
    String fileName,
    String folder,
  ) async {
    final String url = dotenv.env['Backend_URL'] ?? '';

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$url/api/v1/files'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      // Add file as multipart
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

      // Add folder as form field
      request.fields['folder'] = folder;

      // Send with timeout of 60 seconds
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw TimeoutException(
            'Upload timeout - server took too long to respond',
          );
        },
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        return BackendResponse<ResponseUploadFile>.fromJson(
          jsonData,
          (data) => ResponseUploadFile.fromJson(data as Map<String, dynamic>),
        );
      } else {
        // Return error response
        return BackendResponse<ResponseUploadFile>(
          statusCode: response.statusCode,
          message: 'Upload failed: ${response.reasonPhrase}',
          data: null,
        );
      }
    } on TimeoutException catch (e) {
      return BackendResponse<ResponseUploadFile>(
        statusCode: 408,
        message: 'Upload timeout: ${e.message}',
        data: null,
      );
    } catch (e) {
      return BackendResponse<ResponseUploadFile>(
        statusCode: 500,
        message: 'Upload error: $e',
        data: null,
      );
    }
  }
}
