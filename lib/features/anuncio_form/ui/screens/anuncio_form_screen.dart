import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/theme/app_colors.dart';
import 'package:campusswap_app/core/models/anuncio_response_model.dart';
import 'package:campusswap_app/core/models/anuncio_request_model.dart';
import 'package:campusswap_app/features/categorias/bloc/categoria_bloc.dart';
import 'package:campusswap_app/features/anuncio_form/bloc/anuncio_form_bloc.dart';

class AnuncioFormScreen extends StatefulWidget {
  final Anuncio? anuncioAEditar;

  const AnuncioFormScreen({super.key, this.anuncioAEditar});

  @override
  State<AnuncioFormScreen> createState() => _AnuncioFormScreenState();
}

class _AnuncioFormScreenState extends State<AnuncioFormScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 1;

  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();

  final _tituloCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  String _imagenBaseUrl = "https://via.placeholder.com/300";

  int? _selectedCategoriaId;
  String? _selectedTipoOperacion;
  String? _selectedCondicion;
  final _precioCtrl = TextEditingController();

  final List<String> _tiposOperacion = ['VENTA', 'INTERCAMBIO', 'CESION'];
  final List<String> _condiciones = ['NUEVO', 'COMO_NUEVO', 'USADO', 'DETERIORADO'];

  @override
  void initState() {
    super.initState();
    if (widget.anuncioAEditar != null) {
      final a = widget.anuncioAEditar!;
      _tituloCtrl.text = a.titulo;
      _descripcionCtrl.text = a.descripcion;
      _imagenBaseUrl = a.imagen;
      _selectedTipoOperacion = a.tipoOperacion;
      _selectedCondicion = a.condicion;
      if (a.precio != null) _precioCtrl.text = a.precio.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_formKeyStep1.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep = 2);
    }
  }

  void _previousStep() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() => _currentStep = 1);
  }

  void _submitForm(BuildContext context) {
    if (_formKeyStep2.currentState!.validate()) {
      if (_selectedCategoriaId == null || _selectedTipoOperacion == null || _selectedCondicion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecciona categoría, tipo y condición.'), backgroundColor: Colors.red),
        );
        return;
      }

      final request = AnuncioRequestModel(
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descripcionCtrl.text.trim(),
        precio: _selectedTipoOperacion == "VENTA"
            ? (double.tryParse(_precioCtrl.text.trim()) ?? 0.0)
            : null,
        imagen: _imagenBaseUrl,
        tipoOperacion: _selectedTipoOperacion!,
        condicion: _selectedCondicion!,
        categoriaId: _selectedCategoriaId!,
      );

      context.read<AnuncioFormBloc>().add(
        SubmitAnuncio(request: request, anuncioId: widget.anuncioAEditar?.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.anuncioAEditar != null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AnuncioFormBloc()),
        BlocProvider(create: (_) => CategoriaBloc()..add(CargarCategorias())),
      ],
      child: MultiBlocListener(
        listeners: [
          BlocListener<AnuncioFormBloc, AnuncioFormState>(
            listener: (context, state) {
              if (state is AnuncioFormSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? 'Anuncio actualizado con éxito' : 'Anuncio publicado con éxito'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context, true); 
              } else if (state is AnuncioFormError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                );
              }
            },
          ),

          BlocListener<CategoriaBloc, CategoriaState>(
            listener: (context, state) {
              if (state is CategoriaSuccess && isEditing && _selectedCategoriaId == null) {
                try {
                  final categoriaMatch = state.categorias.firstWhere(
                    (c) => c.nombre.toLowerCase() == widget.anuncioAEditar!.categoria.toLowerCase(),
                  );
                  
                  setState(() {
                    _selectedCategoriaId = categoriaMatch.id;
                  });
                } catch (e) {
                  print("No se encontró la categoría pre-seleccionada");
                }
              }
            },
          ),
        ],
        child: BlocBuilder<AnuncioFormBloc, AnuncioFormState>(
          builder: (context, formState) {
            final isLoading = formState is AnuncioFormLoading;

            return Scaffold(
              backgroundColor: AppColors.background,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: AppColors.textDark),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _currentStep == 2 ? _previousStep : () => Navigator.pop(context),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? "Editar Anuncio" : "Publicar Anuncio",
                      style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Text(
                      "Paso $_currentStep de 2",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(4),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 4, color: AppColors.primaryBlue)),
                      Expanded(child: Container(height: 4, color: _currentStep == 2 ? AppColors.primaryBlue : Colors.grey.shade300)),
                    ],
                  ),
                ),
              ),
              body: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1(),
                  _buildStep2(context, isLoading),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Fotos del artículo *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.camera_alt_outlined, color: Colors.grey, size: 32),
                    SizedBox(height: 8),
                    Text("Añadir", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text("Máximo 5 fotos", style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 24),

            const Text("Título del anuncio *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _tituloCtrl,
              maxLength: 60,
              decoration: InputDecoration(
                hintText: "Ej: Calculadora Científica Casio FX-991",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              validator: (val) => val == null || val.isEmpty ? "Requerido" : null,
            ),
            const SizedBox(height: 16),

            const Text("Descripción *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descripcionCtrl,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: "Describe el estado, características...",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
              validator: (val) => val == null || val.isEmpty ? "Requerido" : null,
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Continuar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context, bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKeyStep2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Categoría *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            BlocBuilder<CategoriaBloc, CategoriaState>(
              builder: (context, state) {
                if (state is CategoriaLoading) return const CircularProgressIndicator();
                if (state is CategoriaSuccess) {
                  return DropdownButtonFormField<int>(
                    initialValue: _selectedCategoriaId,
                    decoration: InputDecoration(
                      hintText: "Seleccionar categoría",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                    ),
                    items: state.categorias.map((cat) => DropdownMenuItem<int>(
                      value: cat.id,
                      child: Text(cat.nombre),
                    )).toList(),
                    
                    onChanged: (val) => setState(() => _selectedCategoriaId = val),
                    validator: (val) => val == null ? "Requerido" : null,
                  );
                }
                return const Text("Error al cargar categorías");
              },
            ),
            const SizedBox(height: 24),

            const Text("Tipo de operación *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: _tiposOperacion.map((tipo) {
                final isSelected = _selectedTipoOperacion == tipo;
                return ChoiceChip(
                  label: Text(tipo),
                  selected: isSelected,
                  selectedColor: AppColors.primaryBlue,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark),
                  backgroundColor: Colors.white,
                  onSelected: (selected) {
                    setState(() => _selectedTipoOperacion = selected ? tipo : null);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            if (_selectedTipoOperacion == "VENTA") ...[
              const Text("Precio (€) *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: "0.00",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
                validator: (val) => val == null || val.isEmpty ? "Requerido" : null,
              ),
            ],
            const SizedBox(height: 24),

            const Text("Condición del producto *", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _condiciones.map((cond) {
                final isSelected = _selectedCondicion == cond;
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 60) / 2, // 2 columnas
                  child: ChoiceChip(
                    label: Center(child: Text(cond)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark),
                    backgroundColor: Colors.white,
                    onSelected: (selected) {
                      setState(() => _selectedCondicion = selected ? cond : null);
                    },
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _submitForm(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.anuncioAEditar != null ? "Guardar Cambios" : "Publicar Anuncio",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}