import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/bar.dart';
import '../viewmodels/bar_viewmodel.dart';

class BarFormularioView extends StatefulWidget {
  const BarFormularioView({super.key});

  @override
  State<BarFormularioView> createState() => _BarFormularioViewState();
}

class _BarFormularioViewState extends State<BarFormularioView> {
  final formulario = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final ubicacion = TextEditingController();
  final responsable = TextEditingController();
  Bar? original;
  bool inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (inicializado) return;
    inicializado = true;
    original = ModalRoute.of(context)?.settings.arguments as Bar?;
    if (original != null) {
      nombre.text = original!.nombre;
      ubicacion.text = original!.ubicacion;
      responsable.text = original!.responsable;
    }
  }

  @override
  void dispose() {
    nombre.dispose();
    ubicacion.dispose();
    responsable.dispose();
    super.dispose();
  }

  String? obligatorio(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Este campo es obligatorio' : null;

  Future<void> guardar() async {
    if (!formulario.currentState!.validate()) return;
    final vm = context.read<BarViewModel>();
    final correcto = await vm.guardar(Bar(
      id: original?.id,
      nombre: nombre.text.trim(),
      ubicacion: ubicacion.text.trim(),
      responsable: responsable.text.trim(),
      habilitado: original?.habilitado ?? true,
    ));

    if (!mounted) return;
    if (correcto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bar guardado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final guardando = context.watch<BarViewModel>().guardando;
    return Scaffold(
      appBar: AppBar(title: Text(original == null ? 'Registrar bar' : 'Editar bar')),
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
                  const Icon(Icons.storefront_rounded, size: 54, color: Color(0xFF126B60)),
                  const SizedBox(height: 16),
                  Text(
                    'Datos del establecimiento',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Completa la información del bar universitario.'),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del bar',
                      prefixIcon: Icon(Icons.store),
                    ),
                    validator: obligatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ubicacion,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: obligatorio,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: responsable,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Responsable',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: obligatorio,
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: guardando ? null : guardar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(guardando ? 'Guardando...' : 'Guardar bar'),
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
