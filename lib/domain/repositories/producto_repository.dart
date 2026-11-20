import '../entities/producto.dart';
import '../entities/producto_sugerencia.dart';

abstract class ProductoRepository {
  Future<List<Producto>> listar(int barId);
  Future<List<ProductoSugerencia>> sugerencias();
  Future<void> guardar(Producto producto);
  Future<void> eliminar(int id);
}
