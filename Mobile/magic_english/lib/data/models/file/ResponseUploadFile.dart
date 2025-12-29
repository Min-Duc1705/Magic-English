
class ResponseUploadFile {
  String fileName;

  ResponseUploadFile({
    required this.fileName,
  });

  factory ResponseUploadFile.fromJson(Map<String, dynamic> json) {
    return ResponseUploadFile(
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
    };
  }
}
