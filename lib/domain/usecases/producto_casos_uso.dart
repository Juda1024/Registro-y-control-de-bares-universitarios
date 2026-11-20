import '../entities/producto.dart';
import '../entities/producto_sugerencia.dart';
import '../repositories/producto_repository.dart';

class ProductoCasosUso {
  final ProductoRepository repositorio;
  ProductoCasosUso(this.repositorio);

  Future<List<Producto>> listar(int barId) => repositorio.listar(barId);
  Future<List<ProductoSugerencia>> sugerencias() => repositorio.sugerencias();
  Future<void> guardar(Producto producto) => repositorio.guardar(producto);
  Future<void> eliminar(int id) => repositorio.eliminar(id);
}
