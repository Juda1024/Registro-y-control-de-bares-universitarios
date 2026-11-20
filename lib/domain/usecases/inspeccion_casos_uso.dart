import '../entities/inspeccion.dart';
import '../repositories/inspeccion_repository.dart';

class InspeccionCasosUso {
  final InspeccionRepository repositorio;
  InspeccionCasosUso(this.repositorio);

  Future<List<Inspeccion>> listar(int barId) => repositorio.listar(barId);
  Future<void> registrar(Inspeccion inspeccion) =>
      repositorio.registrar(inspeccion);
}
