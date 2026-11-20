import '../../domain/entities/bar.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/inspeccion.dart';

// Los registros duran mientras la aplicación esté abierta.
// Compartimos esta instancia entre los tres repositorios.
class DatosTemporales {
  final List<Bar> bares = [];
  final List<Producto> productos = [];
  final List<Inspeccion> inspecciones = [];

  int siguienteBar = 1;
  int siguienteProducto = 1;
  int siguienteInspeccion = 1;
}
