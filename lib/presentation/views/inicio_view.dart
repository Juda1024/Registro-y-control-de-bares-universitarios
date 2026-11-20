import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../viewmodels/bar_viewmodel.dart';
import '../widgets/estado_vacio.dart';

class InicioView extends StatefulWidget {
  const InicioView({super.key});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<BarViewModel>().cargar();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BarViewModel>();
    final habilitados = vm.bares.where((bar) => bar.habilitado).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Bares', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'Actualizar lista',
            onPressed: vm.cargando ? null : vm.cargar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.barFormulario),
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('Nuevo bar'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF126B60), Color(0xFF259B8A)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.storefront_rounded, color: Colors.white, size: 32),
                    const SizedBox(height: 10),
                    const Text(
                      'Control de bares universitarios',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${vm.bares.length} registrados  ·  $habilitados habilitados',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: vm.cargando
                    ? const Center(child: CircularProgressIndicator())
                    : vm.error.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(vm.error, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  OutlinedButton.icon(
                                    onPressed: vm.cargar,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Reintentar'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : vm.bares.isEmpty
                            ? const Center(
                                child: EstadoVacio(
                                  icono: Icons.store_mall_directory_outlined,
                                  mensaje: 'Todavía no hay bares. Agrega el primero.',
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 92),
                                itemCount: vm.bares.length,
                                itemBuilder: (context, index) {
                                  final bar = vm.bares[index];
                                  return Card(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFFE4F4EF),
                                        child: const Icon(Icons.storefront, color: AppTheme.verde),
                                      ),
                                      title: Text(
                                        bar.nombre,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(bar.ubicacion),
                                          const SizedBox(height: 5),
                                          Text(
                                            bar.habilitado ? '● Habilitado' : '● Inhabilitado',
                                            style: TextStyle(
                                              color: bar.habilitado
                                                  ? AppTheme.verde
                                                  : Colors.red.shade700,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () => Navigator.pushNamed(
                                        context,
                                        AppRoutes.barDetalle,
                                        arguments: bar.id,
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
