import '../entities/bar.dart';
import '../repositories/bar_repository.dart';

// Los casos de uso mantienen la interfaz separada del acceso a los datos.
class BarCasosUso {
  final BarRepository repositorio;
  BarCasosUso(this.repositorio);

  Future<List<Bar>> listar() => repositorio.listar();
  Future<void> guardar(Bar bar) => repositorio.guardar(bar);
  Future<void> eliminar(int id) => repositorio.eliminar(id);
}
