import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';
import 'package:campusswap_app/features/home/ui/widgets/catalogo_anuncios.dart';
import 'package:campusswap_app/features/buscador/ui/widgets/filtros_busqueda.dart'; // Ajusta el import si tu archivo se llama distinto

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _currentQuery = '';
  Timer? _debounce;

  int? _categoriaId;
  double? _minPrecio;
  double? _maxPrecio;
  String? _tipoOperacion;

  // 1. CREAMOS UN BLOC PRIVADO SOLO PARA LAS BÚSQUEDAS
  late HomeBloc _localSearchBloc;

  @override
  void initState() {
    super.initState();
    // Lo iniciamos pidiendo todos los anuncios por defecto
    _localSearchBloc = HomeBloc()..add(CargarCatalogo());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _localSearchBloc.close(); // Importante cerrarlo para no consumir memoria
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _currentQuery = query;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _ejecutarBusqueda();
    });
  }

  void _ejecutarBusqueda() {
    // IMPORTANTE: Disparamos la búsqueda en el BLOC LOCAL
    _localSearchBloc.add(
      CargarCatalogo(
        q: _currentQuery.isNotEmpty ? _currentQuery : null,
        categoriaId: _categoriaId,
        minPrecio: _minPrecio,
        maxPrecio: _maxPrecio,
        tipoOperacion: _tipoOperacion,
      ),
    );
  }

  void _abrirFiltros(BuildContext context) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return BlocProvider.value(
          // Le pasamos el BLoC de categorías global para que dibuje el modal
          value: context.read<CategoriaBloc>(),
          child: FiltrosBusqueda(
            // Comprueba si tu clase se llama FiltrosBusqueda o FiltrosBusquedaModal
            categoriaIdInicial: _categoriaId,
            minPrecioInicial: _minPrecio,
            maxPrecioInicial: _maxPrecio,
            tipoOperacionInicial: _tipoOperacion,
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _categoriaId = result['categoriaId'];
        _minPrecio = result['minPrecio'];
        _maxPrecio = result['maxPrecio'];
        _tipoOperacion = result['tipoOperacion'];
      });
      _ejecutarBusqueda();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 2. EL ESPÍA: Escuchamos al HomeBloc GLOBAL (el del MainLayout)
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, globalState) {
        // Si el catálogo global se actualiza (porque borraste, creaste o editaste)...
        if (globalState is HomeSuccess) {
          // ...obligamos a nuestra búsqueda a recargarse en segundo plano
          _ejecutarBusqueda();
        }
      },
      // 3. PROVEEDOR LOCAL: Los widgets de esta pantalla usarán el BLoC privado
      child: BlocProvider.value(
        value: _localSearchBloc,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.textDark),
            title: TextField(
              autofocus:
                  false, // Mejor false para que no salte el teclado al navegar por las pestañas
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: "Buscar anuncios...",
                border: InputBorder.none,
              ),
            ),
            actions: [
              Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _abrirFiltros(ctx),
                ),
              ),
            ],
          ),
          body: Builder(
            builder: (context) {
              final isFiltroActivo =
                  _categoriaId != null ||
                  _minPrecio != null ||
                  _maxPrecio != null ||
                  _tipoOperacion != null;

              return Column(
                children: [
                  Expanded(
                    child: CatalogoAnunciosWidget(
                      onRetry: _ejecutarBusqueda,
                      onRefresh: () async {
                        _ejecutarBusqueda();
                        await Future.delayed(const Duration(seconds: 1));
                      },
                      topContent: (_currentQuery.isNotEmpty || isFiltroActivo)
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _currentQuery.isNotEmpty
                                          ? "Resultados para '$_currentQuery'"
                                          : "Anuncios filtrados",
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isFiltroActivo)
                                    GestureDetector(
                                      onTap: () => _abrirFiltros(context),
                                      child: Row(
                                        children: const [
                                          Text(
                                            "Filtros activos ",
                                            style: TextStyle(
                                              color: AppColors.primaryBlue,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Icon(
                                            Icons.check_circle,
                                            size: 16,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
