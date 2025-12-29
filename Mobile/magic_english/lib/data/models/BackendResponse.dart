class BackendResponse<T> {
  final int statusCode;
  final String? error;
  final String message;
  final T? data;

  BackendResponse({
    required this.statusCode,
    this.error,
    required this.message,
    this.data,
  });

  factory BackendResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return BackendResponse<T>(
      statusCode: json['statusCode'] ?? 0,
      error: json['error'],
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T)? toJsonT) {
    return {
      'statusCode': statusCode,
      'error': error,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }
}
