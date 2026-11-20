import '../entities/bar.dart';

abstract class BarRepository {
  Future<List<Bar>> listar();
  Future<void> guardar(Bar bar);
  Future<void> eliminar(int id);
}
