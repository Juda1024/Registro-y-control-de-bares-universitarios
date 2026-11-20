import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/datasources/datos_temporales.dart';
import 'data/datasources/producto_api.dart';
import 'data/repositories/bar_repository_impl.dart';
import 'data/repositories/producto_repository_impl.dart';
import 'data/repositories/inspeccion_repository_impl.dart';
import 'domain/usecases/bar_casos_uso.dart';
import 'domain/usecases/producto_casos_uso.dart';
import 'domain/usecases/inspeccion_casos_uso.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/viewmodels/bar_viewmodel.dart';
import 'presentation/viewmodels/producto_viewmodel.dart';
import 'presentation/viewmodels/inspeccion_viewmodel.dart';
import 'presentation/views/inicio_view.dart';
import 'presentation/views/bar_formulario_view.dart';
import 'presentation/views/bar_detalle_view.dart';
import 'presentation/views/producto_formulario_view.dart';
import 'presentation/views/inspeccion_formulario_view.dart';
import 'routes/app_routes.dart';

void main() {
  final datos = DatosTemporales();
  final api = ProductoApi();

  // Compartimos los datos en memoria entre los tres ViewModels.
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => BarViewModel(BarCasosUso(BarRepositoryImpl(datos))),
      ),
      ChangeNotifierProvider(
        create: (_) => ProductoViewModel(
          ProductoCasosUso(ProductoRepositoryImpl(datos, api)),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => InspeccionViewModel(
          InspeccionCasosUso(InspeccionRepositoryImpl(datos)),
        ),
      ),
    ],
    child: const MiApp(),
  ));
}

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Bares universitarios',
        theme: AppTheme.tema,
        initialRoute: AppRoutes.inicio,
        routes: {
          AppRoutes.inicio: (_) => const InicioView(),
          AppRoutes.barFormulario: (_) => const BarFormularioView(),
          AppRoutes.barDetalle: (_) => const BarDetalleView(),
          AppRoutes.productoFormulario: (_) => const ProductoFormularioView(),
          AppRoutes.inspeccionFormulario: (_) => const InspeccionFormularioView(),
        },
      );
}
