import '../../domain/entities/bar.dart';
import '../../domain/repositories/bar_repository.dart';
import '../datasources/datos_temporales.dart';

class BarRepositoryImpl implements BarRepository {
  final DatosTemporales datos;
  BarRepositoryImpl(this.datos);

  @override
  Future<List<Bar>> listar() async => List.of(datos.bares);

  @override
  Future<void> guardar(Bar bar) async {
    if (bar.nombre.trim().isEmpty ||
        bar.ubicacion.trim().isEmpty ||
        bar.responsable.trim().isEmpty) {
      throw Exception('Completa todos los datos del bar');
    }

    if (bar.id == null) {
      datos.bares.add(Bar(
        id: datos.siguienteBar++,
        nombre: bar.nombre,
        ubicacion: bar.ubicacion,
        responsable: bar.responsable,
      ));
    } else {
      final indice = datos.bares.indexWhere((item) => item.id == bar.id);
      if (indice == -1) throw Exception('No se encontró el bar');
      // Conservamos el estado generado por las inspecciones.
      datos.bares[indice] = Bar(
        id: bar.id,
        nombre: bar.nombre,
        ubicacion: bar.ubicacion,
        responsable: bar.responsable,
        habilitado: datos.bares[indice].habilitado,
      );
    }
  }

  @override
  Future<void> eliminar(int id) async {
    if (datos.inspecciones.any((item) => item.barId == id)) {
      throw Exception('No se puede eliminar un bar con inspecciones');
    }
    datos.bares.removeWhere((item) => item.id == id);
    datos.productos.removeWhere((item) => item.barId == id);
  }
}
