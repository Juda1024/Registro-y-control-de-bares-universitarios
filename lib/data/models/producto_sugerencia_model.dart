import '../../domain/entities/producto_sugerencia.dart';

// Convierte el JSON recibido desde DummyJSON a datos que Flutter entiende.
class ProductoSugerenciaModel extends ProductoSugerencia {
  const ProductoSugerenciaModel({
    required super.nombre,
    required super.categoria,
    required super.precio,
  });

  factory ProductoSugerenciaModel.fromJson(Map<String, dynamic> json) =>
      ProductoSugerenciaModel(
        nombre: json['title'],
        categoria: 'Alimentos',
        precio: (json['price'] as num).toDouble(),
      );
}
