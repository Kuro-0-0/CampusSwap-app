import 'dart:async';
import 'package:campusswap_app/features/buscador/ui/widgets/filtros_busqueda.dart';
import 'package:campusswap_app/features/home/ui/widgets/catalogo_anuncios.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/home/bloc/home_bloc.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';

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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query, BuildContext context) {
    setState(() {
      _currentQuery = query;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _ejecutarBusqueda(context);
    });
  }

  void _ejecutarBusqueda(BuildContext context) {
    context.read<HomeBloc>().add(
      CargarCatalogo(
        q: _currentQuery.isNotEmpty && _currentQuery.length >= 3
            ? _currentQuery
            : _currentQuery = '',
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
          value: context.read<CategoriaBloc>(),
          child: FiltrosBusqueda(
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
      _ejecutarBusqueda(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()..add(CargarCatalogo())),
        BlocProvider(create: (_) => CategoriaBloc()..add(CargarCategorias())),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textDark),
          title: Builder(
            builder: (context) {
              return TextField(
                autofocus: true,
                onChanged: (val) => _onSearchChanged(val, context),
                decoration: const InputDecoration(
                  hintText: "Buscar anuncios...",
                  border: InputBorder.none,
                ),
              );
            },
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
                    onRetry: () => _ejecutarBusqueda(context),
                    topContent: (_currentQuery.isNotEmpty || isFiltroActivo)
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              children: [
                                if(_currentQuery.isNotEmpty && _currentQuery.length >= 3)
                                  Expanded(
                                    child: Text(
                                      "Resultados para '$_currentQuery'",
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
    );
  }
}
