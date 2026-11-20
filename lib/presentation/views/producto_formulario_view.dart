import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/producto.dart';
import '../../routes/app_routes.dart';
import '../viewmodels/producto_viewmodel.dart';

class ProductoFormularioView extends StatefulWidget {
  const ProductoFormularioView({super.key});

  @override
  State<ProductoFormularioView> createState() =>
      _ProductoFormularioViewState();
}

class _ProductoFormularioViewState extends State<ProductoFormularioView> {
  final formulario = GlobalKey<FormState>();
  final nombre = TextEditingController();
  final categoria = TextEditingController();
  final precio = TextEditingController();
  late ProductoFormularioArgs argumentos;
  bool inicializado = false;
  bool disponible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (inicializado) return;
    inicializado = true;
    argumentos = ModalRoute.of(context)!.settings.arguments as ProductoFormularioArgs;
    final producto = argumentos.producto;
    if (producto != null) {
      nombre.text = producto.nombre;
      categoria.text = producto.categoria;
      precio.text = producto.precio.toStringAsFixed(2);
      disponible = producto.disponible;
    }
  }

  @override
  void dispose() {
    nombre.dispose();
    categoria.dispose();
    precio.dispose();
    super.dispose();
  }

  String? validarTexto(String? valor) =>
      valor == null || valor.trim().isEmpty ? 'Campo obligatorio' : null;

  String? validarPrecio(String? valor) {
    final numero = double.tryParse((valor ?? '').replaceAll(',', '.'));
    return numero == null || numero <= 0 ? 'Ingresa un precio mayor que 0' : null;
  }

  Future<void> guardar() async {
    if (!formulario.currentState!.validate()) return;
    final vm = context.read<ProductoViewModel>();
    final producto = Producto(
      id: argumentos.producto?.id,
      barId: argumentos.barId,
      nombre: nombre.text.trim(),
      categoria: categoria.text.trim(),
      precio: double.parse(precio.text.replaceAll(',', '.')),
      disponible: disponible,
    );
    final correcto = await vm.guardar(producto);
    if (!mounted) return;
    if (correcto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto guardado correctamente')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(vm.error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductoViewModel>();
    final guardando = vm.guardando;
    return Scaffold(
      appBar: AppBar(title: Text(
        argumentos.producto == null ? 'Registrar producto' : 'Editar producto',
      )),
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
                  const Icon(Icons.lunch_dining, size: 54, color: Color(0xFF126B60)),
                  const SizedBox(height: 16),
                  Text('Información del producto',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  const Text('Agrega los productos que ofrece este bar.'),
                  const SizedBox(height: 24),
                  if (argumentos.producto == null) ...[
                    OutlinedButton.icon(
                      onPressed: vm.cargandoApi ? null : vm.cargarSugerencias,
                      icon: const Icon(Icons.cloud_download_outlined),
                      label: Text(vm.cargandoApi
                          ? 'Consultando API...'
                          : 'Consultar alimentos en DummyJSON'),
                    ),
                    if (vm.errorApi.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(vm.errorApi,
                          style: const TextStyle(color: Colors.red)),
                    ],
                    if (vm.sugerencias.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Toca un alimento para completar los campos:'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: vm.sugerencias.map((sugerencia) => ActionChip(
                          label: Text(sugerencia.nombre),
                          onPressed: () {
                            nombre.text = sugerencia.nombre;
                            categoria.text = sugerencia.categoria;
                            precio.text = sugerencia.precio.toStringAsFixed(2);
                          },
                        )).toList(),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: nombre,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto',
                      prefixIcon: Icon(Icons.fastfood_outlined),
                    ),
                    validator: validarTexto,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: categoria,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      hintText: 'Ej. Bebidas, sánduches, snacks',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    validator: validarTexto,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: precio,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Precio en USD',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: validarPrecio,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Disponible para la venta'),
                    subtitle: const Text('Desactiva si el producto está agotado.'),
                    value: disponible,
                    onChanged: (valor) => setState(() => disponible = valor),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: guardando ? null : guardar,
                    icon: const Icon(Icons.save_outlined),
                    label: Text(guardando ? 'Guardando...' : 'Guardar producto'),
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
