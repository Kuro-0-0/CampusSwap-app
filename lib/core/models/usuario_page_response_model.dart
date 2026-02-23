import 'package:campusswap_app/core/models/usuario_response_model.dart';

class UsuarioPageResponse {
  final List<UsuarioResponse> content;
  final int totalElements;
  final int totalPages;

  UsuarioPageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
  });

  factory UsuarioPageResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> pageData = json['page'] ?? json;

    return UsuarioPageResponse(
      content: json['content'] != null
          ? (json['content'] as List<dynamic>)
                .map((e) => UsuarioResponse.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      totalElements: pageData['totalElements'] as int? ?? 0,
      totalPages: pageData['totalPages'] as int? ?? 0,
    );
  }
}
