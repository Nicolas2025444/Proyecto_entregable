import 'package:flutter/material.dart';
import 'package:proyecto_3/data/models/user.dart';
import 'package:proyecto_3/data/models/cita.dart';
import 'package:proyecto_3/providers/auth_provider.dart';
import 'package:proyecto_3/providers/cita_provider.dart';
import 'package:proyecto_3/ui/screens/login_screen.dart';
import 'package:proyecto_3/ui/widgets/app_snackbar.dart';
import 'package:proyecto_3/ui/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MedicoHomeScreen extends StatefulWidget {
  const MedicoHomeScreen({super.key, required this.user});

  final User user;

  @override
  State<MedicoHomeScreen> createState() => _MedicoHomeScreenState();
}

class _MedicoHomeScreenState extends State<MedicoHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CitaProvider>().loadCitas(medicoId: widget.user.id);
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
    final citaProvider = context.watch<CitaProvider>();

    return ConnectivityBanner(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel del Médico'),
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
              Tab(icon: Icon(Icons.pending_actions), text: 'Pendientes'),
              Tab(icon: Icon(Icons.history_outlined), text: 'Historial'),
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
                onRefresh: () => context.read<CitaProvider>().loadCitas(medicoId: widget.user.id),
                child: _buildCitasView(citaProvider.pendingCitas, citaProvider, 'No tienes citas pendientes.', colorScheme),
              ),
              RefreshIndicator(
                onRefresh: () => context.read<CitaProvider>().loadCitas(medicoId: widget.user.id),
                child: _buildCitasView(citaProvider.historyCitas, citaProvider, 'No hay historial de citas.', colorScheme),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitasView(List<Cita> citasList, CitaProvider provider, String emptyMsg, ColorScheme colorScheme) {
    if (provider.isLoading) {
      return _buildCitasSkeleton();
    }

    if (provider.errorMessage != null) {
      return _buildErrorState(
        provider.errorMessage!,
        onRetry: () => context.read<CitaProvider>().loadCitas(medicoId: widget.user.id),
        colorScheme: colorScheme,
      );
    }

    if (citasList.isEmpty) {
      return _buildEmptyState(emptyMsg, Icons.assignment_outlined, colorScheme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: citasList.length,
      itemBuilder: (context, index) {
        final cita = citasList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _showCitaDetailsBottomSheet(cita),
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
                          cita.pacienteNombre,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
                        color: Colors.teal.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade100),
                      ),
                      child: Text(
                        'Obs: ${cita.observaciones}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.teal.shade900,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCitaDetailsBottomSheet(Cita cita) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Padding(
          padding: EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalles de la Cita',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  _buildStatusBadge(cita.estado),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailItem(Icons.person, 'Paciente', cita.pacienteNombre),
              _buildDetailItem(Icons.access_time, 'Fecha y Hora', DateFormat('dd/MM/yyyy - hh:mm a').format(cita.fecha)),
              _buildDetailItem(Icons.notes, 'Motivo de consulta', cita.motivo),
              
              if (cita.observaciones != null && cita.observaciones!.isNotEmpty)
                _buildDetailItem(Icons.assignment_outlined, 'Observaciones registradas', cita.observaciones!),
                
              if (cita.estado == 'pendiente') ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _cancelCitaPrompt(cita.id);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Cancelar Cita'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showObservationsForm(cita.id);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Atender / Obs'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cerrar'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelCitaPrompt(int citaId) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('¿Cancelar Cita?'),
          content: const Text('¿Estás seguro de que deseas cancelar esta cita? Se liberará el espacio.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No, volver'),
            ),
            TextButton(
              onPressed: () async {
                final citaProvider = context.read<CitaProvider>();
                Navigator.of(dialogContext).pop();
                final success = await citaProvider.cancelCita(citaId);
                if (!mounted) return;
                
                if (success) {
                  showAppSnackBar(context, message: 'Cita cancelada correctamente.', isError: false);
                } else {
                  final errorMsg = citaProvider.errorMessage ?? 'No se pudo cancelar la cita.';
                  showAppSnackBar(context, message: errorMsg, isError: true);
                }
              },
              child: const Text('Sí, cancelar cita', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showObservationsForm(int citaId) {
    final observationsController = TextEditingController();
    final obsFormKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return AlertDialog(
          title: const Text('Completar Consulta'),
          content: Form(
            key: obsFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Ingresa las observaciones de la consulta y diagnóstico para finalizar la cita.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: observationsController,
                  maxLines: 4,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones y Receta',
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Las observaciones son obligatorias.';
                    }
                    if (value.trim().length < 5) {
                      return 'Por favor, escribe observaciones más detalladas.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                if (!obsFormKey.currentState!.validate()) return;
                final citaProvider = context.read<CitaProvider>();
                Navigator.of(dialogContext).pop();

                final success = await citaProvider.completeCita(
                      citaId,
                      observaciones: observationsController.text,
                    );
                if (!mounted) return;

                if (success) {
                  showAppSnackBar(context, message: 'Consulta finalizada con éxito.', isError: false);
                } else {
                  final errorMsg = citaProvider.errorMessage ?? 'No se pudo registrar la consulta.';
                  showAppSnackBar(context, message: errorMsg, isError: true);
                }
              },
              child: Text('Finalizar', style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ],
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
                      _SkeletonBar(width: 140, height: 16),
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
