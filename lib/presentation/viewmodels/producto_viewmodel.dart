import 'package:flutter/material.dart';
import '../../domain/entities/producto.dart';
import '../../domain/entities/producto_sugerencia.dart';
import '../../domain/usecases/producto_casos_uso.dart';

class ProductoViewModel extends ChangeNotifier {
  final ProductoCasosUso casosUso;
  ProductoViewModel(this.casosUso);

  List<Producto> productos = [];
  List<ProductoSugerencia> sugerencias = [];
  bool cargando = false;
  bool cargandoApi = false;
  bool guardando = false;
  String error = '';
  String errorApi = '';
  int? barActual;

  Future<void> cargarSugerencias() async {
    cargandoApi = true;
    errorApi = '';
    notifyListeners();
    try {
      sugerencias = await casosUso.sugerencias();
    } catch (_) {
      errorApi = 'No se pudo consultar DummyJSON. Revisa tu conexión.';
    }
    cargandoApi = false;
    notifyListeners();
  }

  Future<void> cargar(int barId) async {
    barActual = barId;
    productos = [];
    cargando = true;
    error = '';
    notifyListeners();
    try {
      productos = await casosUso.listar(barId);
    } catch (e) {
      error = '$e'.replaceFirst('Exception: ', '');
    }
    cargando = false;
    notifyListeners();
  }

  Future<bool> guardar(Producto producto) async {
    guardando = true;
    error = '';
    notifyListeners();
    try {
      await casosUso.guardar(producto);
      await cargar(producto.barId);
      return error.isEmpty;
    } catch (e) {
      error = '$e'.replaceFirst('Exception: ', '');
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminar(int id, int barId) async {
    guardando = true;
    error = '';
    notifyListeners();
    try {
      await casosUso.eliminar(id);
      await cargar(barId);
      return error.isEmpty;
    } catch (e) {
      error = '$e'.replaceFirst('Exception: ', '');
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }
}
