import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/inspeccion.dart';
import '../viewmodels/bar_viewmodel.dart';
import '../viewmodels/inspeccion_viewmodel.dart';

class InspeccionFormularioView extends StatefulWidget {
  const InspeccionFormularioView({super.key});

  @override
  State<InspeccionFormularioView> createState() =>
      _InspeccionFormularioViewState();
}

class _InspeccionFormularioViewState extends State<InspeccionFormularioView> {
  final formulario = GlobalKey<FormState>();
  final observacion = TextEditingController();
  DateTime fecha = DateTime.now();
  String resultado = Inspeccion.resultados.first;

  @override
  void dispose() {
    observacion.dispose();
    super.dispose();
  }

  Future<void> elegirFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (seleccionada != null) setState(() => fecha = seleccionada);
  }

  Future<void> guardar() async {
    if (!formulario.currentState!.validate()) return;
    final barId = ModalRoute.of(context)!.settings.arguments as int;
    final inspeccion = Inspeccion(
      barId: barId,
      fecha: fecha.toIso8601String().substring(0, 10),
      observacion: observacion.text.trim(),
      resultado: resultado,
    );
    final vm = context.read<InspeccionViewModel>();
    final correcto = await vm.registrar(inspeccion);
    if (!mounted) return;
    if (correcto) {
      // Una inspección puede cambiar la habilitación del bar.
      await context.read<BarViewModel>().cargar();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inspección registrada correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final guardando = context.watch<InspeccionViewModel>().guardando;
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva inspección')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formulario,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.fact_check_outlined,
                      size: 54, color: Color(0xFF126B60)),
                  const SizedBox(height: 16),
                  Text('Resultado de la inspección',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Registra el cumplimiento y funcionamiento del bar.'),
                  const SizedBox(height: 22),
                  OutlinedButton.icon(
                    onPressed: elegirFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text('Fecha: ${fecha.day}/${fecha.month}/${fecha.year}'),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    value: resultado,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Resultado',
                      prefixIcon: Icon(Icons.checklist_rtl),
                    ),
                    items: Inspeccion.resultados.map((valor) => DropdownMenuItem(
                      value: valor,
                      child: Text(valor),
                    )).toList(),
                    onChanged: (valor) {
                      if (valor != null) setState(() => resultado = valor);
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: observacion,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Observación',
                      alignLabelWithHint: true,
                      hintText: 'Describe lo observado durante la visita',
                    ),
                    validator: (valor) => valor == null || valor.trim().isEmpty
                        ? 'La observación es obligatoria'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: guardando ? null : guardar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(guardando ? 'Guardando...' : 'Registrar inspección'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
