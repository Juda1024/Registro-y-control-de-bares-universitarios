class Inspeccion {
  static const resultados = [
    'Aprobado',
    'Aprobado con observaciones',
    'No aprobado',
  ];

  final int? id;
  final int barId;
  final String fecha;
  final String observacion;
  final String resultado;

  const Inspeccion({
    this.id,
    required this.barId,
    required this.fecha,
    required this.observacion,
    required this.resultado,
  });
}
