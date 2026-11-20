import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/producto.dart';
import '../../domain/entities/producto_sugerencia.dart';
import '../models/producto_sugerencia_model.dart';

// Mismos métodos GET y POST utilizados en el ejercicio de clase con DummyJSON.
class ProductoApi {
  final String url = 'https://dummyjson.com/products';

  Future<List<ProductoSugerencia>> obtenerSugerencias() async {
    final respuesta = await http.get(
      Uri.parse('$url/category/groceries'),
    ).timeout(const Duration(seconds: 12));

    if (respuesta.statusCode != 200) {
      throw Exception('No se pudo consultar el catálogo de la API');
    }

    final datos = jsonDecode(respuesta.body);
    final lista = datos['products'] as List;
    return lista.take(12)
        .map((item) => ProductoSugerenciaModel.fromJson(item))
        .toList();
  }

  Future<void> crearProducto(Producto producto) async {
    // DummyJSON confirma la petición POST, pero no guarda el producto.
    // Por eso también lo registramos en nuestra lista temporal.
    final respuesta = await http.post(
      Uri.parse('$url/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': producto.nombre,
        'price': producto.precio,
        'category': producto.categoria,
      }),
    ).timeout(const Duration(seconds: 12));

    if (respuesta.statusCode != 201) {
      throw Exception('La API no pudo registrar el producto');
    }
  }
}
