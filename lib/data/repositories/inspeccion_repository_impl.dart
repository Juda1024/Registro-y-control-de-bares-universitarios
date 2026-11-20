import '../../domain/entities/bar.dart';
import '../../domain/entities/inspeccion.dart';
import '../../domain/repositories/inspeccion_repository.dart';
import '../datasources/datos_temporales.dart';

class InspeccionRepositoryImpl implements InspeccionRepository {
  final DatosTemporales datos;
  InspeccionRepositoryImpl(this.datos);

  @override
  Future<List<Inspeccion>> listar(int barId) async =>
      datos.inspecciones.where((item) => item.barId == barId).toList();

  @override
  Future<void> registrar(Inspeccion inspeccion) async {
    final indice = datos.bares.indexWhere((item) => item.id == inspeccion.barId);
    if (indice == -1) throw Exception('No se encontró el bar');
    if (inspeccion.observacion.trim().isEmpty ||
        !Inspeccion.resultados.contains(inspeccion.resultado)) {
      throw Exception('Completa la inspección correctamente');
    }

    datos.inspecciones.add(Inspeccion(
      id: datos.siguienteInspeccion++,
      barId: inspeccion.barId,
      fecha: inspeccion.fecha,
      observacion: inspeccion.observacion,
      resultado: inspeccion.resultado,
    ));

    final bar = datos.bares[indice];
    var habilitado = bar.habilitado;
    if (inspeccion.resultado == 'No aprobado') habilitado = false;
    if (inspeccion.resultado == 'Aprobado') habilitado = true;

    datos.bares[indice] = Bar(
      id: bar.id,
      nombre: bar.nombre,
      ubicacion: bar.ubicacion,
      responsable: bar.responsable,
      habilitado: habilitado,
    );
  }
}
