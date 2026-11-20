import 'package:flutter/material.dart';
import '../../domain/entities/inspeccion.dart';
import '../../domain/usecases/inspeccion_casos_uso.dart';

class InspeccionViewModel extends ChangeNotifier {
  final InspeccionCasosUso casosUso;
  InspeccionViewModel(this.casosUso);

  List<Inspeccion> inspecciones = [];
  bool cargando = false;
  bool guardando = false;
  String error = '';
  int? barActual;

  Future<void> cargar(int barId) async {
    barActual = barId;
    inspecciones = [];
    cargando = true;
    error = '';
    notifyListeners();
    try {
      inspecciones = await casosUso.listar(barId);
    } catch (e) {
      error = '$e'.replaceFirst('Exception: ', '');
    }
    cargando = false;
    notifyListeners();
  }

  Future<bool> registrar(Inspeccion inspeccion) async {
    guardando = true;
    error = '';
    notifyListeners();
    try {
      await casosUso.registrar(inspeccion);
      await cargar(inspeccion.barId);
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
