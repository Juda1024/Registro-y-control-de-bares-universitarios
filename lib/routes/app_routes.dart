import '../domain/entities/producto.dart';

class AppRoutes {
  static const inicio = '/';
  static const barFormulario = '/bar-formulario';
  static const barDetalle = '/bar-detalle';
  static const productoFormulario = '/producto-formulario';
  static const inspeccionFormulario = '/inspeccion-formulario';
}

// Argumentos tipados: evitamos confundir el ID del bar con el del producto.
class ProductoFormularioArgs {
  final int barId;
  final Producto? producto;

  const ProductoFormularioArgs(this.barId, [this.producto]);
}
