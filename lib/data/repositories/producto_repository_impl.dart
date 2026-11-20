import '../../domain/entities/producto.dart';
import '../../domain/entities/producto_sugerencia.dart';
import '../../domain/repositories/producto_repository.dart';
import '../datasources/datos_temporales.dart';
import '../datasources/producto_api.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final DatosTemporales datos;
  final ProductoApi api;
  ProductoRepositoryImpl(this.datos, this.api);

  @override
  Future<List<Producto>> listar(int barId) async =>
      datos.productos.where((item) => item.barId == barId).toList();

  @override
  Future<List<ProductoSugerencia>> sugerencias() => api.obtenerSugerencias();

  @override
  Future<void> guardar(Producto producto) async {
    if (producto.nombre.trim().isEmpty ||
        producto.categoria.trim().isEmpty ||
        producto.precio <= 0) {
      throw Exception('Completa los datos con un precio mayor que cero');
    }

    if (producto.id == null) {
      final bar = datos.bares.where((item) => item.id == producto.barId);
      if (bar.isEmpty || !bar.first.habilitado) {
        throw Exception('No se pueden registrar productos en este bar');
      }

      // Practicamos POST como en clase y guardamos una copia temporal local.
      await api.crearProducto(producto);
      datos.productos.add(Producto(
        id: datos.siguienteProducto++,
        barId: producto.barId,
        nombre: producto.nombre,
        categoria: producto.categoria,
        precio: producto.precio,
        disponible: producto.disponible,
      ));
    } else {
      final indice = datos.productos.indexWhere((item) => item.id == producto.id);
      if (indice == -1) throw Exception('No se encontró el producto');
      // Editar un registro temporal no requiere otro POST.
      datos.productos[indice] = producto;
    }
  }

  @override
  Future<void> eliminar(int id) async {
    datos.productos.removeWhere((item) => item.id == id);
  }
}
