import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:campusswap_app/core/models/usuario_response_model.dart';
import 'package:campusswap_app/features/panel_admin/bloc/list_user_bloc.dart';

class ListUserScreen extends StatelessWidget {
  const ListUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ListUserBloc()..add(GetUsuarios()),
      child: const _ListUserView(),
    );
  }
}

class _ListUserView extends StatefulWidget {
  const _ListUserView();

  @override
  State<_ListUserView> createState() => _ListUserViewState();
}

class _ListUserViewState extends State<_ListUserView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filtra admins de cualquier lista antes de usarla
  List<UsuarioResponse> _soloUsuarios(List<UsuarioResponse> todos) =>
      todos.where((u) => !u.roles.contains('ADMIN')).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: BlocListener<ListUserBloc, ListUserState>(
          listener: (context, state) {
            if (state is ListUserBloqueoFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            }
            if (state is ListUserBloqueoSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Usuario bloqueado correctamente'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildSearchBar(),
              BlocBuilder<ListUserBloc, ListUserState>(
                buildWhen: (_, current) => current is ListUserSuccess,
                builder: (context, state) {
                  if (state is ListUserSuccess) {
                    return _buildStats(_soloUsuarios(state.usuarios));
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<ListUserBloc, ListUserState>(
                  builder: (context, state) => _buildBody(context, state),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          BlocBuilder<ListUserBloc, ListUserState>(
            buildWhen: (_, current) => current is ListUserSuccess,
            builder: (context, state) {
              final total = state is ListUserSuccess
                  ? _soloUsuarios(state.usuarios).length
                  : 0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Usuarios',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$total registrados',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Buscador ──────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o email...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────────

  Widget _buildStats(List<UsuarioResponse> usuarios) {
    final total = usuarios.length;
    final bloqueados = usuarios.where((u) => u.bloqueado).length;
    final activos = total - bloqueados;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatChip(
              value: activos.toString(),
              label: 'Activos',
              valueColor: Colors.blue,
            ),
            const SizedBox(width: 10),
            _StatChip(
              value: bloqueados.toString(),
              label: 'Bloqueados',
              valueColor: Colors.red,
            ),
            const SizedBox(width: 10),
            _StatChip(
              value: total.toString(),
              label: 'Total',
              valueColor: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, ListUserState state) {
    return switch (state) {
      ListUserInitial()        => const SizedBox.shrink(),
      ListUserLoading()        => const Center(child: CircularProgressIndicator()),
      ListUserFailure()        => _buildError(context, state.error),
      ListUserSuccess()        => _buildList(state.usuarios),
      ListUserBloqueoLoading() => _buildList(
                                    context.read<ListUserBloc>().ultimaLista,
                                    bloqueandoId: state.usuarioId,
                                  ),
      ListUserBloqueoSuccess() => _buildList(
                                    context.read<ListUserBloc>().ultimaLista,
                                  ),
      ListUserBloqueoFailure() => _buildList(
                                    context.read<ListUserBloc>().ultimaLista,
                                  ),
    };
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.read<ListUserBloc>().add(GetUsuarios()),
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<UsuarioResponse> usuarios, {String? bloqueandoId}) {
    // 👇 filtra admins y aplica búsqueda
    final filtrados = _soloUsuarios(usuarios)
        .where(
          (u) =>
              u.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              u.email.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (filtrados.isEmpty) {
      return const Center(
        child: Text(
          'No se encontraron usuarios.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtrados.length,
      itemBuilder: (context, index) => _UsuarioCard(
        usuario: filtrados[index],
        bloqueandoId: bloqueandoId,
      ),
    );
  }
}

// ── Stat Chip ──────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const _StatChip({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Usuario Card ───────────────────────────────────────────────────────────────

class _UsuarioCard extends StatelessWidget {
  final UsuarioResponse usuario;
  final String? bloqueandoId;

  const _UsuarioCard({
    required this.usuario,
    this.bloqueandoId,
  });

  bool get _isCargando => bloqueandoId == usuario.id;

  String get _fechaFormateada {
    const meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return '${meses[usuario.fechaRegistro.month - 1]} ${usuario.fechaRegistro.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: usuario.bloqueado ? Border.all(color: Colors.red.shade200) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfo(),
                const SizedBox(height: 10),
                _buildBotonBloqueo(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 26,
      backgroundImage:
          usuario.imageUrl.isNotEmpty ? NetworkImage(usuario.imageUrl) : null,
      backgroundColor: Colors.grey.shade200,
      child: usuario.imageUrl.isEmpty
          ? const Icon(Icons.person, color: Colors.grey)
          : null,
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                usuario.nombre,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (usuario.bloqueado) ...[
              const SizedBox(width: 4),
              const Icon(Icons.block, color: Colors.red, size: 16),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          usuario.email,
          style: const TextStyle(color: Colors.grey, fontSize: 13),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 2),
            Text(
              usuario.reputacionMedia?.toStringAsFixed(1) ?? 'N/A',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.calendar_today_outlined,
                size: 13, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              _fechaFormateada,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotonBloqueo(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isCargando || usuario.bloqueado
            ? null
            : () => context
                .read<ListUserBloc>()
                .add(BloquearUsuario(usuario.id)),
        icon: _isCargando
            ? const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                usuario.bloqueado ? Icons.block : Icons.block_outlined,
                size: 18,
                color: usuario.bloqueado ? Colors.grey : Colors.red,
              ),
        label: Text(
          usuario.bloqueado ? 'Bloqueado' : 'Bloquear',
          style: TextStyle(
            color: usuario.bloqueado ? Colors.grey : Colors.red,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
              usuario.bloqueado ? Colors.grey.shade100 : Colors.red.shade50,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
