class ValoracionResponseModel {
  final List<Valoracion> content;
  final PageInfo page;

  ValoracionResponseModel({
    required this.content,
    required this.page,
  });

  factory ValoracionResponseModel.fromJson(Map<String, dynamic> json) {
    return ValoracionResponseModel(
      content: (json['content'] as List)
          .map((e) => Valoracion.fromJson(e))
          .toList(),
      page: PageInfo.fromJson(json['page']),
    );
  }

  Map<String, dynamic> toJson() => {
        'content': content.map((e) => e.toJson()).toList(),
        'page': page.toJson(),
      };
}

class Valoracion {
  final int id;
  final double puntuacion;
  final String comentario;
  final String fecha;
  final String evaluadorNombre;
  final String? fotoPerfilEvaluador;
  final String anuncioTitulo;

  Valoracion({
    required this.id,
    required this.puntuacion,
    required this.comentario,
    required this.fecha,
    required this.evaluadorNombre,
    this.fotoPerfilEvaluador,
    required this.anuncioTitulo,
  });

  factory Valoracion.fromJson(Map<String, dynamic> json) {
    return Valoracion(
      id: json['id'],
      puntuacion: (json['puntuacion'] as num).toDouble(),
      comentario: json['comentario'],
      fecha: json['fecha'],
      evaluadorNombre: json['evaluadorNombre'],
      fotoPerfilEvaluador: json['fotoPerfilEvaluador'],
      anuncioTitulo: json['anuncioTitulo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'puntuacion': puntuacion,
        'comentario': comentario,
        'fecha': fecha,
        'evaluadorNombre': evaluadorNombre,
        'fotoPerfilEvaluador': fotoPerfilEvaluador,
        'anuncioTitulo': anuncioTitulo,
      };
}

class PageInfo {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PageInfo({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageInfo.fromJson(Map<String, dynamic> json) {
    return PageInfo(
      size: json['size'],
      number: json['number'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() => {
        'size': size,
        'number': number,
        'totalElements': totalElements,
        'totalPages': totalPages,
      };
}