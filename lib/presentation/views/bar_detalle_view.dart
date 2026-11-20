import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/bar.dart';
import '../../domain/entities/producto.dart';
import '../../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../viewmodels/bar_viewmodel.dart';
import '../viewmodels/producto_viewmodel.dart';
import '../viewmodels/inspeccion_viewmodel.dart';
import '../widgets/estado_vacio.dart';

class BarDetalleView extends StatefulWidget {
  const BarDetalleView({super.key});

  @override
  State<BarDetalleView> createState() => _BarDetalleViewState();
}

class _BarDetalleViewState extends State<BarDetalleView> {
  int? barId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (barId != null) return;
    barId = ModalRoute.of(context)!.settings.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductoViewModel>().cargar(barId!);
      context.read<InspeccionViewModel>().cargar(barId!);
    });
  }

  Future<bool> confirmar(String titulo, String mensaje) async {
    return await showDialog<bool>(
          context: context,
          builder: (contexto) => AlertDialog(
            title: Text(titulo),
            content: Text(mensaje),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(contexto, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(contexto, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void aviso(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> eliminarBar(Bar bar) async {
    final confirmado = await confirmar(
      'Eliminar bar',
      '¿Seguro que deseas eliminar ${bar.nombre}?',
    );
    if (!confirmado || !mounted) return;
    final vm = context.read<BarViewModel>();
    final correcto = await vm.eliminar(bar.id!);
    if (!mounted) return;
    if (correcto) {
      aviso('Bar eliminado correctamente');
      Navigator.pop(context);
    } else {
      aviso(vm.error);
    }
  }

  Future<void> eliminarProducto(Producto producto) async {
    final confirmado = await confirmar(
      'Eliminar producto',
      '¿Deseas eliminar ${producto.nombre}?',
    );
    if (!confirmado || !mounted) return;
    final vm = context.read<ProductoViewModel>();
    final correcto = await vm.eliminar(producto.id!, producto.barId);
    aviso(correcto ? 'Producto eliminado' : vm.error);
  }

  @override
  Widget build(BuildContext context) {
    final bar = context.watch<BarViewModel>().buscar(barId!);
    final productos = context.watch<ProductoViewModel>();
    final inspecciones = context.watch<InspeccionViewModel>();

    if (bar == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del bar')),
        body: const Center(child: Text('Bar no encontrado')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(bar.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            tooltip: 'Editar datos',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.pushNamed(
              context,
              AppRoutes.barFormulario,
              arguments: bar,
            ),
          ),
          IconButton(
            tooltip: 'Eliminar bar',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => eliminarBar(bar),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bar.habilitado
                        ? const Color(0xFFE4F4EF)
                        : const Color(0xFFFFECEA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            bar.habilitado
                                ? Icons.verified_rounded
                                : Icons.block_rounded,
                            color: bar.habilitado
                                ? AppTheme.verde
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              bar.habilitado ? 'Bar habilitado' : 'Bar inhabilitado',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Ubicación: ${bar.ubicacion}'),
                      const SizedBox(height: 5),
                      Text('Responsable: ${bar.responsable}'),
                      if (!bar.habilitado) ...[
                        const SizedBox(height: 10),
                        const Text('Registra una inspección aprobada para habilitarlo.'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                _encabezado(
                  context,
                  'Productos',
                  'Nuevo producto',
                  Icons.add,
                  bar.habilitado
                      ? () => Navigator.pushNamed(
                            context,
                            AppRoutes.productoFormulario,
                            arguments: ProductoFormularioArgs(bar.id!),
                          )
                      : null,
                ),
                if (!bar.habilitado)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('No se pueden registrar productos mientras el bar esté inhabilitado.'),
                  ),
                if (productos.cargando || productos.barActual != bar.id)
                  const Center(child: CircularProgressIndicator())
                else if (productos.error.isNotEmpty)
                  Text(productos.error, style: const TextStyle(color: Colors.red))
                else if (productos.productos.isEmpty)
                  const EstadoVacio(
                    icono: Icons.inventory_2_outlined,
                    mensaje: 'No hay productos registrados en este bar.',
                  )
                else
                  ...productos.productos.map((producto) {
                    final ventaDisponible = bar.habilitado && producto.disponible;
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 10, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.fastfood, color: AppTheme.verde),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    producto.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  '\$${producto.precio.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(producto.categoria),
                            const SizedBox(height: 4),
                            Text(
                              ventaDisponible ? '● Disponible' : '● No disponible para venta',
                              style: TextStyle(
                                color: ventaDisponible ? AppTheme.verde : Colors.red.shade700,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: 'Editar producto',
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.productoFormulario,
                                    arguments: ProductoFormularioArgs(bar.id!, producto),
                                  ),
                                  icon: const Icon(Icons.edit_outlined),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar producto',
                                  onPressed: () => eliminarProducto(producto),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 28),
                _encabezado(
                  context,
                  'Historial de inspecciones',
                  'Registrar',
                  Icons.assignment_turned_in_outlined,
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.inspeccionFormulario,
                    arguments: bar.id,
                  ),
                ),
                if (inspecciones.cargando || inspecciones.barActual != bar.id)
                  const Center(child: CircularProgressIndicator())
                else if (inspecciones.error.isNotEmpty)
                  Text(inspecciones.error, style: const TextStyle(color: Colors.red))
                else if (inspecciones.inspecciones.isEmpty)
                  const EstadoVacio(
                    icono: Icons.fact_check_outlined,
                    mensaje: 'Este bar aún no tiene inspecciones.',
                  )
                else
                  ...inspecciones.inspecciones.reversed.map((inspeccion) {
                    final aprobado = inspeccion.resultado == 'Aprobado';
                    final negativo = inspeccion.resultado == 'No aprobado';
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: Icon(
                          aprobado ? Icons.check_circle : Icons.info_outline,
                          color: negativo
                              ? Colors.red.shade700
                              : aprobado
                                  ? AppTheme.verde
                                  : Colors.orange.shade700,
                        ),
                        title: Text(inspeccion.resultado,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          '${inspeccion.fecha}\n${inspeccion.observacion}',
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _encabezado(
    BuildContext context,
    String titulo,
    String boton,
    IconData icono,
    VoidCallback? accion,
  ) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: [
            Text(titulo, style: Theme.of(context).textTheme.titleLarge),
            OutlinedButton.icon(
              onPressed: accion,
              icon: Icon(icono),
              label: Text(boton),
            ),
          ],
        ),
      );
}
