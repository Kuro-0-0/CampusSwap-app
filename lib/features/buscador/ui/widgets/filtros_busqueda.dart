import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';

class FiltrosBusqueda extends StatefulWidget {
  final int? categoriaIdInicial;
  final double? minPrecioInicial;
  final double? maxPrecioInicial;
  final String? tipoOperacionInicial;

  const FiltrosBusqueda({
    super.key,
    this.categoriaIdInicial,
    this.minPrecioInicial,
    this.maxPrecioInicial,
    this.tipoOperacionInicial,
  });

  @override
  State<FiltrosBusqueda> createState() => _FiltrosBusquedaState();
}

class _FiltrosBusquedaState extends State<FiltrosBusqueda> {
  int? _selectedCategoriaId;
  String? _selectedTipoOperacion;
  final TextEditingController _minPrecioCtrl = TextEditingController();
  final TextEditingController _maxPrecioCtrl = TextEditingController();

  final List<String> _tiposOperacion = ['VENTA', 'INTERCAMBIO', 'CESION'];

  @override
  void initState() {
    super.initState();
    _selectedCategoriaId = widget.categoriaIdInicial;
    _selectedTipoOperacion = widget.tipoOperacionInicial;
    if (widget.minPrecioInicial != null) _minPrecioCtrl.text = widget.minPrecioInicial.toString();
    if (widget.maxPrecioInicial != null) _maxPrecioCtrl.text = widget.maxPrecioInicial.toString();
  }

  @override
  void dispose() {
    _minPrecioCtrl.dispose();
    _maxPrecioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Filtros de Búsqueda", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 16),

            // FILTRO DE CATEGORÍAS (Usando CategoriaBloc)
            const Text("Categoría", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            BlocBuilder<CategoriaBloc, CategoriaState>(
              builder: (context, state) {
                if (state is CategoriaLoading) return const CircularProgressIndicator();
                if (state is CategoriaSuccess) {
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoriaId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    hint: const Text("Todas las categorías"),
                    items: [
                      const DropdownMenuItem<int>(value: null, child: Text("Todas")),
                      ...state.categorias.map((cat) => DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.nombre),
                          )),
                    ],
                    onChanged: (val) => setState(() => _selectedCategoriaId = val),
                  );
                }
                return const Text("No se pudieron cargar las categorías");
              },
            ),
            const SizedBox(height: 16),

            // FILTRO DE PRECIO
            const Text("Rango de Precio (€)", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPrecioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Mínimo",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPrecioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Máximo",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // FILTRO DE TIPO DE OPERACIÓN
            const Text("Tipo de Operación", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _tiposOperacion.map((tipo) {
                final isSelected = _selectedTipoOperacion == tipo;
                return ChoiceChip(
                  label: Text(tipo),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                  onSelected: (selected) {
                    setState(() => _selectedTipoOperacion = selected ? tipo : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // BOTONES DE ACCIÓN
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategoriaId = null;
                        _selectedTipoOperacion = null;
                        _minPrecioCtrl.clear();
                        _maxPrecioCtrl.clear();
                      });
                    },
                    child: const Text("Limpiar"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                    onPressed: () {
                      // Devolvemos un Map con los filtros aplicados al cerrar el modal
                      Navigator.pop(context, {
                        'categoriaId': _selectedCategoriaId,
                        'minPrecio': double.tryParse(_minPrecioCtrl.text),
                        'maxPrecio': double.tryParse(_maxPrecioCtrl.text),
                        'tipoOperacion': _selectedTipoOperacion,
                      });
                    },
                    child: const Text("Aplicar"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}