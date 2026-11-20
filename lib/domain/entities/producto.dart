class Producto {
  final int? id;
  final int barId;
  final String nombre;
  final String categoria;
  final double precio;
  final bool disponible;

  const Producto({
    this.id,
    required this.barId,
    required this.nombre,
    required this.categoria,
    required this.precio,
    required this.disponible,
  });
}
