import 'package:flutter/material.dart';
import 'package:proyecto_3/data/models/user.dart';
import 'package:proyecto_3/data/models/medico.dart';
import 'package:proyecto_3/data/models/cita.dart';
import 'package:proyecto_3/providers/auth_provider.dart';
import 'package:proyecto_3/providers/medico_provider.dart';
import 'package:proyecto_3/providers/cita_provider.dart';
import 'package:proyecto_3/ui/screens/login_screen.dart';
import 'package:proyecto_3/ui/screens/booking_screen.dart';
import 'package:proyecto_3/ui/widgets/connectivity_banner.dart';
import 'package:proyecto_3/ui/widgets/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PacienteHomeScreen extends StatefulWidget {
  const PacienteHomeScreen({super.key, required this.user});

  final User user;

  @override
  State<PacienteHomeScreen> createState() => _PacienteHomeScreenState();
}

class _PacienteHomeScreenState extends State<PacienteHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicoProvider>().loadMedicos();
      context.read<CitaProvider>().loadCitas(pacienteId: widget.user.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final navigator = Navigator.of(context);
    await context.read<AuthProvider>().logout();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final medicoProvider = context.watch<MedicoProvider>();
    final citaProvider = context.watch<CitaProvider>();

    return ConnectivityBanner(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel del Paciente'),
          actions: [
            IconButton(
              tooltip: 'Cerrar sesión',
              onPressed: () => _logout(context),
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: colorScheme.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.people_outline), text: 'Médicos'),
              Tab(icon: Icon(Icons.calendar_today_outlined), text: 'Mis Citas'),
            ],
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
          ),
          child: TabBarView(
            controller: _tabController,
            children: [
              RefreshIndicator(
                onRefresh: () => context.read<MedicoProvider>().loadMedicos(),
                child: _buildMedicosList(medicoProvider, colorScheme),
              ),
              RefreshIndicator(
                onRefresh: () => context.read<CitaProvider>().loadCitas(pacienteId: widget.user.id),
                child: _buildCitasList(citaProvider, colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicosList(MedicoProvider provider, ColorScheme colorScheme) {
    if (provider.isLoading) {
      return _buildMedicoSkeleton();
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(
        provider.errorMessage!,
        onRetry: () => context.read<MedicoProvider>().loadMedicos(),
        colorScheme: colorScheme,
      );
    }

    final medicos = provider.medicos;
    if (medicos.isEmpty) {
      return _buildEmptyState(
        'No hay médicos disponibles.',
        Icons.people_outline,
        colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: medicos.length,
      itemBuilder: (context, index) {
        final medico = medicos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _openBookingScreen(medico),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      medico.nombre[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medico.nombreCompleto,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            medico.especialidad,
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                medico.email,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCitasList(CitaProvider provider, ColorScheme colorScheme) {
    if (provider.isLoading) {
      return _buildCitasSkeleton();
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(
        provider.errorMessage!,
        onRetry: () => context.read<CitaProvider>().loadCitas(pacienteId: widget.user.id),
        colorScheme: colorScheme,
      );
    }

    final citas = provider.citas;
    if (citas.isEmpty) {
      return _buildEmptyState(
        'Aún no has agendado ninguna cita.',
        Icons.calendar_today_outlined,
        colorScheme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final Cita cita = citas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        cita.medicoNombre,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusBadge(cita.estado),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('dd/MM/yyyy - hh:mm a').format(cita.fecha),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Motivo: ${cita.motivo}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (cita.observaciones != null && cita.observaciones!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assignment_outlined, size: 14, color: Colors.blue),
                            SizedBox(width: 6),
                            Text(
                              'Observaciones del Médico:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cita.observaciones!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (cita.estado == 'pendiente') ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: provider.isSaving ? null : () => _cancelCitaPrompt(cita.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: provider.isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                            )
                          : const Text('Cancelar Cita'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(String estado) {
    Color bgColor;
    Color textColor;
    String label;

    switch (estado.toLowerCase()) {
      case 'pendiente':
        bgColor = Colors.amber.shade50;
        textColor = Colors.amber.shade800;
        label = 'Pendiente';
        break;
      case 'completada':
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade800;
        label = 'Completada';
        break;
      case 'cancelada':
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade800;
        label = 'Cancelada';
        break;
      default:
        bgColor = Colors.grey.shade50;
        textColor = Colors.grey.shade800;
        label = estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  void _openBookingScreen(Medico medico) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookingScreen(medico: medico, paciente: widget.user),
      ),
    ).then((_) {
      if (!mounted) return;
      context.read<CitaProvider>().loadCitas(pacienteId: widget.user.id);
    });
  }

  void _cancelCitaPrompt(int citaId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Cancelar Cita?'),
          content: const Text('¿Estás seguro de que deseas cancelar esta cita? Esta acción liberará tu espacio en la agenda.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No, mantener'),
            ),
            TextButton(
              onPressed: () async {
                final citaProvider = context.read<CitaProvider>();
                Navigator.of(dialogContext).pop();
                final success = await citaProvider.cancelCita(citaId);
                if (!mounted) return;
                
                if (success) {
                  showAppSnackBar(context, message: 'Cita cancelada con éxito.', isError: false);
                } else {
                  final errorMsg = citaProvider.errorMessage ?? 'No se pudo cancelar la cita.';
                  showAppSnackBar(context, message: errorMsg, isError: true);
                }
              },
              child: const Text('Sí, cancelar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMedicoSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const _PulseSkeleton(
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(radius: 30, backgroundColor: Color(0xFFE2E8F0)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SkeletonBar(width: 140, height: 16),
                        SizedBox(height: 8),
                        _SkeletonBar(width: 90, height: 12),
                        SizedBox(height: 8),
                        _SkeletonBar(width: 180, height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCitasSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return const _PulseSkeleton(
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _SkeletonBar(width: 130, height: 16),
                      _SkeletonBar(width: 80, height: 22),
                    ],
                  ),
                  SizedBox(height: 12),
                  Divider(height: 1, color: Color(0xFFF1F5F9)),
                  SizedBox(height: 12),
                  _SkeletonBar(width: 180, height: 14),
                  SizedBox(height: 8),
                  _SkeletonBar(width: 220, height: 14),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message, {required VoidCallback onRetry, required ColorScheme colorScheme}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Ocurrió un error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.primary.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseSkeleton extends StatefulWidget {
  const _PulseSkeleton({required this.child});
  final Widget child;

  @override
  State<_PulseSkeleton> createState() => _PulseSkeletonState();
}

class _PulseSkeletonState extends State<_PulseSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.4,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _controller, child: widget.child);
  }
}

class _SkeletonBar extends StatelessWidget {
  const _SkeletonBar({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
