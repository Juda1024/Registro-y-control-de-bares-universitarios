import '../entities/inspeccion.dart';

abstract class InspeccionRepository {
  Future<List<Inspeccion>> listar(int barId);
  Future<void> registrar(Inspeccion inspeccion);
}
