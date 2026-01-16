import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Tres extends StatefulWidget {
  const Tres({Key? key}) : super(key: key);

  @override
  _TresState createState() => _TresState();
}

class _TresState extends State<Tres> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _lugaresController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _invitaciones = [];
  
  @override
  void initState() {
    super.initState();
    _cargarInvitaciones();
  }
  
  @override
  void dispose() {
    _nombreController.dispose();
    _lugaresController.dispose();
    _mensajeController.dispose();
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
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar invitaciones: $e')),
      );
    }
  }
  
  Future<void> _crearInvitacion() async {
    if (_nombreController.text.isEmpty || _lugaresController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa nombre y lugares')),
      );
      return;
    }
    
    final lugares = int.tryParse(_lugaresController.text);
    if (lugares == null || lugares <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad de lugares debe ser mayor a 0')),
      );
      return;
    }
    
    try {
      setState(() => _isLoading = true);
      
      // Generar ID único para la invitación
      const uuid = Uuid();
      final invitacionId = uuid.v4();
      
      // Crear documento en Firestore
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
      
      // Limpiar formulario
      _nombreController.clear();
      _lugaresController.clear();
      _mensajeController.clear();
      
      // Recargar lista
      await _cargarInvitaciones();
      
      if (!mounted) return;
      
      // Mostrar diálogo con el link
      _mostrarDialogoLink(invitacionId);
      
      setState(() => _isLoading = false);
      
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear invitación: $e')),
      );
    }
  }
  
  void _mostrarDialogoLink(String invitacionId) {
    // En producción, reemplaza con tu dominio real
    final link = 'https://tu-dominio.web.app/invitacion/$invitacionId';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            '✅ Invitación Creada',
            style: TextStyle(
              color: Color(0xFF7A9B8E),
              fontWeight: FontWeight.w500,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Comparte este enlace con el invitado:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
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
              const Text(
                'ID de invitación:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  invitacionId,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copiado al portapapeles')),
                );
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Copiar Link'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A9B8E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _eliminarInvitacion(String id) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta invitación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitación eliminada')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }
  
  void _verDetalles(Map<String, dynamic> invitacion) {
    final link = 'https://tu-dominio.web.app/invitacion/${invitacion['id']}';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          invitacion['nombre'],
          style: const TextStyle(
            color: Color(0xFF7A9B8E),
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetalleRow('Estado', 
                invitacion['confirmado'] ? '✅ Confirmado' : '⏳ Pendiente'),
              _buildDetalleRow('Lugares asignados', 
                invitacion['lugaresAsignados'].toString()),
              if (invitacion['confirmado'])
                _buildDetalleRow('Lugares confirmados', 
                  invitacion['lugaresConfirmados'].toString()),
              if (invitacion['mensaje'].isNotEmpty)
                _buildDetalleRow('Mensaje', invitacion['mensaje']),
              const Divider(height: 30),
              const Text(
                'Enlace de invitación:',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  link,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: link));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiado')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copiar Link'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7A9B8E),
                    side: const BorderSide(color: Color(0xFF7A9B8E)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetalleRow(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A9B8E),
        title: const Text(
          'Panel de Administración',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7A9B8E),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildFormularioCrear(),
                  _buildListaInvitaciones(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }
  
  Widget _buildFormularioCrear() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Crear Nueva Invitación',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Color(0xFF7A9B8E),
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: _nombreController,
            decoration: InputDecoration(
              labelText: 'Nombre del invitado *',
              hintText: 'Ej: Familia González',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7A9B8E), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _lugaresController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Cantidad de lugares *',
              hintText: 'Ej: 3',
              prefixIcon: const Icon(Icons.people_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7A9B8E), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _mensajeController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Mensaje personalizado (opcional)',
              hintText: '¡Esperamos verte en nuestra boda!',
              prefixIcon: const Icon(Icons.message_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF7A9B8E), width: 2),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _crearInvitacion,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('CREAR INVITACIÓN'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A9B8E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildListaInvitaciones() {
    if (_invitaciones.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 60,
                color: Colors.grey,
              ),
              SizedBox(height: 15),
              Text(
                'No hay invitaciones creadas',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
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
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              'Invitaciones Creadas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Color(0xFF7A9B8E),
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _invitaciones.length,
            itemBuilder: (context, index) {
              final invitacion = _invitaciones[index];
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
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _verDetalles(invitacion),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: confirmado
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    confirmado ? Icons.check_circle : Icons.access_time,
                    color: confirmado ? Colors.green : Colors.orange,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        confirmado
                            ? '${invitacion['lugaresConfirmados']}/${invitacion['lugaresAsignados']} lugares confirmados'
                            : '${invitacion['lugaresAsignados']} lugares asignados',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _eliminarInvitacion(invitacion['id']),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}