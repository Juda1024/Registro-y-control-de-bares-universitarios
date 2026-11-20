class Bar {
  final int? id;
  final String nombre;
  final String ubicacion;
  final String responsable;
  final bool habilitado;

  const Bar({
    this.id,
    required this.nombre,
    required this.ubicacion,
    required this.responsable,
    this.habilitado = true,
  });
}
