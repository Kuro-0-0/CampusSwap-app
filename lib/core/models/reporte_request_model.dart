class ReporteRequestModel {
  final String motivo;

  ReporteRequestModel({
    required this.motivo,
  });

  Map<String, dynamic> toJson() {
    return {
      'motivo': motivo,
    };
  }

  factory ReporteRequestModel.fromJson(Map<String, dynamic> json) {
    return ReporteRequestModel(
      motivo: json['motivo'] ?? '',
    );
  }
}

class MotivoOption {
  final String valor;
  final String label;

  const MotivoOption({required this.valor, required this.label});
}

// Motivos disponibles
final List<MotivoOption> motivosDisponibles = [
  const MotivoOption(
    valor: 'FRAUDE',
    label: 'Fraude',
  ),
  const MotivoOption(
    valor: 'CONTENIDO_INAPROPIADO',
    label: 'Contenido inapropiado',
  ),
  const MotivoOption(
    valor: 'SPAM',
    label: 'Spam',
  ),
  const MotivoOption(
    valor: 'OTRO',
    label: 'Otro',
  ),
];
