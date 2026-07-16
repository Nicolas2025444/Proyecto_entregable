import 'package:flutter/material.dart';
import 'package:proyecto_3/data/models/medico.dart';
import 'package:proyecto_3/data/models/user.dart';
import 'package:proyecto_3/providers/cita_provider.dart';
import 'package:proyecto_3/ui/widgets/app_snackbar.dart';
import 'package:proyecto_3/ui/widgets/connectivity_banner.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.medico, required this.paciente});

  final Medico medico;
  final User paciente;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoController = TextEditingController();
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTime;

  // Franjas horarias predefinidas de atención
  final List<String> _timeSlots = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Seleccionar por defecto hoy o mañana si ya pasó el horario
    _selectedDay = _focusedDay;
  }

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  // Verifica si una hora en particular ya está agendada para este médico el día seleccionado
  bool _isSlotBooked(String timeSlot) {
    if (_selectedDay == null) return false;

    final citaProvider = context.read<CitaProvider>();
    
    return citaProvider.citas.any((cita) {
      if (cita.medicoId != widget.medico.id || cita.estado == 'cancelada') {
        return false;
      }
      
      // Comparar solo año, mes y día
      final mismaFecha = cita.fecha.year == _selectedDay!.year &&
          cita.fecha.month == _selectedDay!.month &&
          cita.fecha.day == _selectedDay!.day;
          
      if (!mismaFecha) return false;

      // Comparar la hora formateada
      final horaCitaStr = DateFormat('hh:00 a').format(cita.fecha).toUpperCase();
      final horaSlotStr = timeSlot.toUpperCase();

      return horaCitaStr == horaSlotStr;
    });
  }

  Future<void> _submitBooking() async {
    FocusScope.of(context).unfocus();

    if (_selectedDay == null) {
      showAppSnackBar(context, message: 'Por favor, selecciona un día.', isError: true);
      return;
    }

    if (_selectedTime == null) {
      showAppSnackBar(context, message: 'Por favor, selecciona un horario.', isError: true);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    // Crear la fecha y hora final combinada
    // Parseamos la hora desde el formato 'hh:mm a'
    final timeParts = _selectedTime!.split(' ');
    final hourMin = timeParts[0].split(':');
    var hour = int.parse(hourMin[0]);
    final minute = int.parse(hourMin[1]);
    final isPm = timeParts[1] == 'PM';

    if (isPm && hour < 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    final fechaCompleta = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
      hour,
      minute,
    );

    final success = await context.read<CitaProvider>().createCita(
          medicoId: widget.medico.id,
          fecha: fechaCompleta,
          motivo: _motivoController.text,
        );

    if (!mounted) return;

    if (success) {
      _showSuccessDialog();
    } else {
      final errorMsg = context.read<CitaProvider>().errorMessage ?? 'No se pudo agendar la cita.';
      showAppSnackBar(context, message: errorMsg, isError: true);
    }
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 72,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '¡Cita Agendada!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu cita con el/la ${widget.medico.nombreCompleto} ha sido registrada con éxito.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildDetailRow('Especialidad:', widget.medico.especialidad),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Fecha y Hora:',
                  '${DateFormat('dd/MM/yyyy').format(_selectedDay!)} a las $_selectedTime',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra diálogo
                      Navigator.of(this.context).pop(); // Vuelve a pantalla anterior
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Entendido'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B)),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final citaProvider = context.watch<CitaProvider>();

    return ConnectivityBanner(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agendar Cita'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info del Médico
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: colorScheme.primary.withOpacity(0.1),
                          child: Icon(Icons.person_pin, color: colorScheme.primary, size: 30),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.medico.nombreCompleto,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.medico.especialidad,
                                style: TextStyle(color: colorScheme.secondary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Calendario
                const Text(
                  '1. Selecciona el día',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: TableCalendar<void>(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                          _selectedTime = null; // Reiniciar hora al cambiar día
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                        outsideDaysVisible: false,
                        weekendTextStyle: const TextStyle(color: Colors.red),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Deshabilitar fines de semana si es requerido
                      enabledDayPredicate: (day) {
                        // Sábado (6) y Domingo (7) no se atiende
                        return day.weekday != DateTime.saturday && day.weekday != DateTime.sunday;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Horarios
                const Text(
                  '2. Selecciona la hora',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                _selectedDay == null
                    ? const Center(child: Text('Selecciona un día primero.'))
                    : Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _timeSlots.map((time) {
                              final isBooked = _isSlotBooked(time);
                              final isSelected = _selectedTime == time;

                              return ChoiceChip(
                                label: Text(time),
                                selected: isSelected,
                                onSelected: isBooked
                                    ? null
                                    : (selected) {
                                        setState(() {
                                          _selectedTime = selected ? time : null;
                                        });
                                      },
                                selectedColor: colorScheme.primary,
                                backgroundColor: isBooked ? Colors.grey.shade100 : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color: isBooked
                                        ? Colors.grey.shade200
                                        : isSelected
                                            ? Colors.transparent
                                            : Colors.grey.shade300,
                                  ),
                                ),
                                labelStyle: TextStyle(
                                  color: isBooked
                                      ? Colors.grey.shade400
                                      : isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // Formulario del Motivo
                const Text(
                  '3. Detalles de la Consulta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _motivoController,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Motivo de la consulta',
                      hintText: 'Describe brevemente tus síntomas o el motivo del chequeo...',
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El motivo de la consulta es obligatorio.';
                      }
                      if (value.trim().length < 10) {
                        return 'Por favor, describe con un poco más de detalle (mínimo 10 caracteres).';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),

                // Botón de Registrar Cita
                FilledButton(
                  onPressed: citaProvider.isSaving ? null : _submitBooking,
                  child: citaProvider.isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Confirmar Reservación'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
