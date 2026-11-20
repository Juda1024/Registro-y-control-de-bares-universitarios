import 'package:flutter/material.dart';
import '../../domain/entities/bar.dart';
import '../../domain/usecases/bar_casos_uso.dart';

class BarViewModel extends ChangeNotifier {
  final BarCasosUso casosUso;
  BarViewModel(this.casosUso);

  List<Bar> bares = [];
  bool cargando = false;
  bool guardando = false;
  String error = '';

  Bar? buscar(int id) {
    for (final bar in bares) {
      if (bar.id == id) return bar;
    }
    return null;
  }

  Future<void> cargar() async {
    cargando = true;
    error = '';
    // notifyListeners actualiza las pantallas que escuchan este ViewModel.
    notifyListeners();
    try {
      bares = await casosUso.listar();
    } catch (e) {
      error = '$e'.replaceFirst('Exception: ', '');
    }
    cargando = false;
    notifyListeners();
  }

  Future<bool> guardar(Bar bar) async {
    guardando = true;
    error = '';
    notifyListeners();
    try {
      await casosUso.guardar(bar);
      await cargar();
      return error.isEmpty;
    } catch (e) {
      error = '$e'.replaceFirst('Exception: ', '');
      return false;
    } finally {
      guardando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminar(int id) async {
    guardando = true;
    error = '';
    notifyListeners();
    try {
      await casosUso.eliminar(id);
      await cargar();
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
