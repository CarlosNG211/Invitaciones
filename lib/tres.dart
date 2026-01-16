import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Tres extends StatefulWidget {
  const Tres({Key? key}) : super(key: key);

  @override
  _TresState createState() => _TresState();
}

class _TresState extends State<Tres> with SingleTickerProviderStateMixin {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _lugaresController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  bool _isLoading = false;
  List<Map<String, dynamic>> _invitaciones = [];
  late AnimationController _animationController;
  String _filtroEstado = 'Todos'; 
  
  void _mostrarDialogoLink(String invitacionId) {
  // Cambiado el formato del link para usar el parámetro 'id' en la ruta 'dos'
   final link = 'https://invitaciones-indol-sigma.vercel.app/#/dos?id=$invitacionId';

  
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A9B8E).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Color(0xFF7A9B8E),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '¡Invitación Creada!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Comparte este enlace con tu invitado',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.link, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Enlace de invitación',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SelectableText(
                      link,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF7A9B8E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'ID: ${invitacionId.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue.shade900,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Cerrar'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      _mostrarSnackBar('¡Enlace copiado al portapapeles!');
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copiar Enlace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A9B8E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _verDetalles(Map<String, dynamic> invitacion) {
  // Cambiado el formato del link
   final link = 'https://invitaciones-indol-sigma.vercel.app/#/dos?id=${invitacion['id']}';
  
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7A9B8E).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF7A9B8E),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            invitacion['nombre'],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C3E50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: invitacion['confirmado']
                                  ? Colors.green.shade50
                                  : Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: invitacion['confirmado']
                                    ? Colors.green.shade300
                                    : Colors.orange.shade300,
                              ),
                            ),
                            child: Text(
                              invitacion['confirmado'] ? '✓ Confirmado' : '⏳ Pendiente',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: invitacion['confirmado']
                                    ? Colors.green.shade700
                                    : Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                const Divider(),
                const SizedBox(height: 20),
                _buildDetalleItem(
                  Icons.event_seat,
                  'Lugares asignados',
                  invitacion['lugaresAsignados'].toString(),
                  Colors.blue,
                ),
                if (invitacion['confirmado'])
                  _buildDetalleItem(
                    Icons.check_circle,
                    'Lugares confirmados',
                    invitacion['lugaresConfirmados'].toString(),
                    Colors.green,
                  ),
                if (invitacion['mensaje'].isNotEmpty)
                  _buildDetalleItem(
                    Icons.message,
                    'Mensaje personalizado',
                    invitacion['mensaje'],
                    Colors.purple,
                  ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                const Text(
                  'Enlace de invitación',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    link,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A9B8E),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: link));
                      _mostrarSnackBar('¡Enlace copiado!');
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copiar Enlace'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7A9B8E),
                      side: const BorderSide(color: Color(0xFF7A9B8E), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  
  @override
  void initState() {
    super.initState();
    _cargarInvitaciones();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _nombreController.dispose();
    _lugaresController.dispose();
    _mensajeController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _cargarInvitaciones() async {
    setState(() => _isLoading = true);
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('invitaciones')
          .orderBy('fechaCreacion', descending: true)
          .get();
      
      setState(() {
        _invitaciones = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            ...doc.data(),
          };
        }).toList();
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _mostrarSnackBar('Error al cargar invitaciones: $e', error: true);
    }
  }
  
  Future<void> _crearInvitacion() async {
    if (_nombreController.text.isEmpty || _lugaresController.text.isEmpty) {
      _mostrarSnackBar('Por favor completa nombre y lugares', error: true);
      return;
    }
    
    final lugares = int.tryParse(_lugaresController.text);
    if (lugares == null || lugares <= 0) {
      _mostrarSnackBar('La cantidad de lugares debe ser mayor a 0', error: true);
      return;
    }
    
    try {
      setState(() => _isLoading = true);
      
      const uuid = Uuid();
      final invitacionId = uuid.v4();
      
      await FirebaseFirestore.instance
          .collection('invitaciones')
          .doc(invitacionId)
          .set({
        'nombre': _nombreController.text.trim(),
        'lugaresAsignados': lugares,
        'lugaresConfirmados': 0,
        'mensaje': _mensajeController.text.trim(),
        'confirmado': false,
        'fechaCreacion': FieldValue.serverTimestamp(),
        'fechaConfirmacion': null,
      });
      
      _nombreController.clear();
      _lugaresController.clear();
      _mensajeController.clear();
      
      await _cargarInvitaciones();
      
      if (!mounted) return;
      
      _mostrarDialogoLink(invitacionId);
      
      setState(() => _isLoading = false);
      
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _mostrarSnackBar('Error al crear invitación: $e', error: true);
    }
  }
  
  
  Future<void> _eliminarInvitacion(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
            const SizedBox(width: 10),
            const Text('Confirmar eliminación'),
          ],
        ),
        content: const Text(
          '¿Estás seguro de eliminar esta invitación? Esta acción no se puede deshacer.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirmar != true) return;
    
    try {
      await FirebaseFirestore.instance
          .collection('invitaciones')
          .doc(id)
          .delete();
      
      await _cargarInvitaciones();
      
      if (!mounted) return;
      _mostrarSnackBar('Invitación eliminada correctamente');
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBar('Error al eliminar: $e', error: true);
    }
  }
  
  
  Widget _buildDetalleItem(IconData icon, String label, String valor, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _mostrarSnackBar(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: error ? Colors.red.shade600 : const Color(0xFF7A9B8E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  List<Map<String, dynamic>> get _invitacionesFiltradas {
    if (_filtroEstado == 'Todos') return _invitaciones;
    if (_filtroEstado == 'Confirmados') {
      return _invitaciones.where((inv) => inv['confirmado'] == true).toList();
    }
    return _invitaciones.where((inv) => inv['confirmado'] == false).toList();
  }
  
  Map<String, int> get _estadisticas {
    final total = _invitaciones.length;
    final confirmados = _invitaciones.where((inv) => inv['confirmado'] == true).length;
    final pendientes = total - confirmados;
    final lugaresTotales = _invitaciones.fold<int>(
      0, (sum, inv) => sum + (inv['lugaresAsignados'] as int),
    );
    final lugaresConfirmados = _invitaciones.fold<int>(
      0, (sum, inv) => sum + (inv['lugaresConfirmados'] as int),
    );
    
    return {
      'total': total,
      'confirmados': confirmados,
      'pendientes': pendientes,
      'lugaresTotales': lugaresTotales,
      'lugaresConfirmados': lugaresConfirmados,
    };
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A9B8E),
        elevation: 0,
        title: const Text(
          'Panel de Administración',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _cargarInvitaciones,
            tooltip: 'Actualizar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7A9B8E),
                strokeWidth: 3,
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarInvitaciones,
              color: const Color(0xFF7A9B8E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildEstadisticas(),
                    _buildFormularioCrear(),
                    _buildFiltros(),
                    _buildListaInvitaciones(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildEstadisticas() {
    final stats = _estadisticas;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  stats['total'].toString(),
                  Icons.mail_outline,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Confirmados',
                  stats['confirmados'].toString(),
                  Icons.check_circle_outline,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Pendientes',
                  stats['pendientes'].toString(),
                  Icons.access_time,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF7A9B8E),
                  const Color(0xFF7A9B8E).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7A9B8E).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLugaresInfo(
                  'Lugares Totales',
                  stats['lugaresTotales'].toString(),
                  Icons.event_seat,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildLugaresInfo(
                  'Confirmados',
                  stats['lugaresConfirmados'].toString(),
                  Icons.people,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildLugaresInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFormularioCrear() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF7A9B8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add_circle,
                  color: Color(0xFF7A9B8E),
                  size: 28,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'Crear Nueva Invitación',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _nombreController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre del invitado',
              hintText: 'Ej: Familia González',
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF7A9B8E)),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7A9B8E), width: 2),
              ),
              labelStyle: const TextStyle(color: Color(0xFF7A9B8E)),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _lugaresController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Cantidad de lugares',
              hintText: 'Ej: 3',
              prefixIcon: const Icon(Icons.people_outline, color: Color(0xFF7A9B8E)),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7A9B8E), width: 2),
              ),
              labelStyle: const TextStyle(color: Color(0xFF7A9B8E)),
            ),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _mensajeController,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Mensaje personalizado (opcional)',
              hintText: '¡Esperamos verte en nuestra boda!',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 50),
                child: Icon(Icons.message_outlined, color: Color(0xFF7A9B8E)),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF7A9B8E), width: 2),
              ),
              labelStyle: const TextStyle(color: Color(0xFF7A9B8E)),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _crearInvitacion,
              icon: const Icon(Icons.add_circle_outline, size: 22),
              label: const Text(
                'CREAR INVITACIÓN',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A9B8E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFiltros() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Text(
            'Filtrar por:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFiltroChip('Todos'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('Confirmados'),
                  const SizedBox(width: 8),
                  _buildFiltroChip('Pendientes'),
                ],
              ),
            ),
          ),
        ],
      )
    );
  }
  
  Widget _buildFiltroChip(String label) {
    final isSelected = _filtroEstado == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtroEstado = label;
        });
      },
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF7A9B8E).withOpacity(0.2),
      checkmarkColor: const Color(0xFF7A9B8E),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF7A9B8E) : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? const Color(0xFF7A9B8E) : Colors.grey.shade300,
        width: isSelected ? 1.5 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
  
  Widget _buildListaInvitaciones() {
    final invitaciones = _invitacionesFiltradas;
    
    if (invitaciones.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                _filtroEstado == 'Todos' ? Icons.inbox_outlined : Icons.search_off,
                size: 70,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                _filtroEstado == 'Todos'
                    ? 'No hay invitaciones creadas'
                    : 'No hay invitaciones ${_filtroEstado.toLowerCase()}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _filtroEstado == 'Todos'
                    ? 'Crea tu primera invitación arriba'
                    : 'Intenta con otro filtro',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              children: [
                const Text(
                  'Invitaciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7A9B8E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${invitaciones.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A9B8E),
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: invitaciones.length,
            itemBuilder: (context, index) {
              final invitacion = invitaciones[index];
              return _buildInvitacionCard(invitacion);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildInvitacionCard(Map<String, dynamic> invitacion) {
    final bool confirmado = invitacion['confirmado'] ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _verDetalles(invitacion),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: confirmado
                          ? [Colors.green.shade400, Colors.green.shade600]
                          : [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: (confirmado ? Colors.green : Colors.orange)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    confirmado ? Icons.check_circle : Icons.schedule,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitacion['nombre'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            confirmado
                                ? '${invitacion['lugaresConfirmados']}/${invitacion['lugaresAsignados']} confirmados'
                                : '${invitacion['lugaresAsignados']} asignados',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () => _eliminarInvitacion(invitacion['id']),
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.red.shade600,
                    ),
                    tooltip: 'Eliminar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}