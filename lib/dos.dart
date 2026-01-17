import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class Dos extends StatefulWidget {
  const Dos({Key? key}) : super(key: key);

  @override
  _DosState createState() => _DosState();
}

class _DosState extends State<Dos> with TickerProviderStateMixin {  final TextEditingController _lugaresController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _mensajeController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  bool _canUploadPhotos = false;
  String? _invitacionId;
  Map<String, dynamic>? _datosInvitacion;
  bool _invitacionCargada = false;
  late AnimationController _floatingController;
  bool _debugMode = true;
    late YoutubePlayerController _musicController;
  bool _isMusicPlaying = true;
  bool _musicStarted = false; 

  Future<void> _confirmarAsistencia() async {
  if (_lugaresController.text.isEmpty || _nombreController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(child: Text('Por favor completa los campos obligatorios')),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return;
  }
  
  final lugaresConfirmados = int.tryParse(_lugaresController.text) ?? 0;
  
  if (_invitacionCargada && _invitacionId != null && _datosInvitacion != null) {
    final lugaresAsignados = _datosInvitacion!['lugaresAsignados'] as int;
    
    if (lugaresConfirmados > lugaresAsignados) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text('Solo puedes confirmar hasta $lugaresAsignados lugares')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    if (lugaresConfirmados <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Debes confirmar al menos 1 lugar'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    if (_datosInvitacion!['confirmado'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(child: Text('Esta invitación ya fue confirmada anteriormente')),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    try {
      await FirebaseFirestore.instance
          .collection('invitaciones')
          .doc(_invitacionId)
          .update({
        'confirmado': true,
        'lugaresConfirmados': lugaresConfirmados,
        'mensajeRespuesta': _mensajeController.text.trim(),
        'fechaConfirmacion': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      
      final mensajeInvitacion = _datosInvitacion!['mensaje'] ?? '';
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => FadeIn(
          duration: const Duration(milliseconds: 500),
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            backgroundColor: Colors.white,
            title: Column(
              children: [
                BounceInDown(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade400, Colors.green.shade700],
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '¡Confirmación Exitosa!',
                  style: GoogleFonts.playfairDisplay(
                    color: const Color(0xFFD946A6),
                    fontWeight: FontWeight.w600,
                    fontSize: 26,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '¡Gracias por confirmar tu asistencia!',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.green.shade100],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.green.shade300, width: 2),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.people, color: Colors.green.shade700, size: 35),
                        const SizedBox(height: 10),
                        Text(
                          'Lugares confirmados',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$lugaresConfirmados de $lugaresAsignados',
                          style: GoogleFonts.playfairDisplay(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (mensajeInvitacion.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3EF),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFE8E4DC)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.favorite, color: Colors.pink.shade300, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Mensaje de los novios:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: const Color(0xFF7A9B8E),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            mensajeInvitacion,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.celebration, color: Colors.amber.shade700, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '¡Te esperamos!',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF7A9B8E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.celebration, color: Colors.amber.shade700, size: 22),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _mensajeController.clear();
                    _cargarDatosInvitacion(_invitacionId!);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD946A6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    'Cerrar',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar: $e')),
      );
    }
  } else {
    // Usuario sin invitación personalizada - NO PUEDE CONFIRMAR MÁS DE LO QUE INGRESÓ
    if (lugaresConfirmados <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Debes confirmar al menos 1 lugar'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    try {
      final confirmados = FirebaseFirestore.instance.collection('confirmados');
      final snapshot = await confirmados.get();
      final nextIndex = snapshot.docs.length;
      
      await confirmados.doc(nextIndex.toString()).set({
        'cantidadLugares': lugaresConfirmados,
        'nombreReserva': _nombreController.text.trim(),
        'mensajeNovios': _mensajeController.text.trim(),
        'fechaConfirmacion': FieldValue.serverTimestamp(),
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('¡Confirmación enviada exitosamente!'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      
      _lugaresController.clear();
      _nombreController.clear();
      _mensajeController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al confirmar: $e')),
      );
    }
  }
}


Widget _buildBautizoSection() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icono
          Bounce(
            duration: const Duration(milliseconds: 1500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.child_care,
                color: Colors.blue.shade400,
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Título
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Bautizo',
              style: GoogleFonts.playfairDisplay(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Nombre de la bebé
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.favorite, color: Colors.pink.shade300, size: 30),
                const SizedBox(height: 15),
                Text(
                  'Emily Catalyna',
                  style: GoogleFonts.greatVibes(
                    fontSize: 38,
                    color: const Color(0xFFD946A6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Quintana Del Villar',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          
          // Padrinos
          SlideInUp(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.stars, color: const Color(0xFFD946A6), size: 22),
                      const SizedBox(width: 10),
                      Text(
                        'Padrinos',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD946A6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPadrinoSimple('Víctor Uriel Del Villar Ramírez'),
                  const SizedBox(height: 12),
                  _buildPadrinoSimple('René Ali López Nieva'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          // Información del evento
          SlideInUp(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.access_time,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2:00 PM',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFD946A6),
                              ),
                            ),
                            Text(
                              'Salón "La Cabaña"',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _abrirMaps('https://maps.app.goo.gl/ecDdwpAtArqD7Ufr7'),
                      icon: const Icon(Icons.map, size: 18),
                      label: const Text('VER EN MAPA'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade400,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPadrinoSimple(String nombre) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.purple.shade200),
    ),
    child: Row(
      children: [
        Icon(Icons.workspace_premium, color: Colors.purple.shade400, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            nombre,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget _buildHeroSection() {
  return Container(
    height: 550,
    decoration: const BoxDecoration(
      color: Color(0xFFE8E4DC),
      image: DecorationImage(
        image: AssetImage('assets/1.jpeg'),
        fit: BoxFit.cover,
      ),
    ),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.transparent,
            const Color(0xFFF5F3EF),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'NOS CASAMOS',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                letterSpacing: 4,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 15),
          FadeInUp(
            duration: const Duration(milliseconds: 1500),
            delay: const Duration(milliseconds: 600),
            child: Text(
              'Itzel & Oscar',
              style: GoogleFonts.greatVibes(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.w400,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // NUEVO: Línea del bautizo
          FadeInUp(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 750),
            child: Text(
              'Y BAUTIZO DE',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                letterSpacing: 3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          FadeInUp(
            duration: const Duration(milliseconds: 1500),
            delay: const Duration(milliseconds: 850),
            child: Text(
              'Emily',
              style: GoogleFonts.greatVibes(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w400,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInUp(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 900),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '14 • FEBRERO • 2026',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD946A6),
                  fontSize: 16,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          CustomPaint(
            size: const Size(double.infinity, 40),
            painter: TornPaperPainter(),
          ),
        ],
      ),
    ),
  );
}


@override
void initState() {
  super.initState();
  _checkUploadDate();
  _cargarInvitacionDesdeUrl();
  
  _floatingController = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat(reverse: true);
  
  // INICIALIZAR REPRODUCTOR DE MÚSICA
  _musicController = YoutubePlayerController.fromVideoId(
    videoId: 'mKs3bybeTO8',
    autoPlay: false,
    params: const YoutubePlayerParams(
      showControls: false,
      showFullscreenButton: false,
      mute: false,
      loop: true,
      enableCaption: false,
      strictRelatedVideos: true,
    ),
  );
}@override
void dispose() {
  _lugaresController.dispose();
  _nombreController.dispose();
  _mensajeController.dispose();
  _codigoController.dispose();
  _floatingController.dispose();
  _musicController.close();
  super.dispose();
}void _toggleMusic() {
  setState(() {
    if (!_musicStarted) {
      _musicStarted = true;
      _isMusicPlaying = true;
      _musicController.playVideo();
    } else {
      _isMusicPlaying = !_isMusicPlaying;
      if (_isMusicPlaying) {
        _musicController.playVideo();
      } else {
        _musicController.pauseVideo();
      }
    }
  });
}

Widget _buildCodigoVestimenta() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey.shade100, Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Swing(
            duration: const Duration(milliseconds: 1500),
            child: Icon(Icons.checkroom, color: const Color(0xFFD946A6), size: 50),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Código de Vestimenta',
              style: GoogleFonts.playfairDisplay(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
            ),
          ),
          const SizedBox(height: 25),
          ZoomIn(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 500),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Formal',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.block, color: Colors.red.shade600, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Por favor evitar el color blanco y colores afines al blanco.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          BounceInUp(
            duration: const Duration(milliseconds: 1200),
            delay: const Duration(milliseconds: 700),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.orange.shade300, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.orange.shade800, size: 24),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fecha límite de confirmación:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
  '1 de Febrero, 2026',
  style: GoogleFonts.playfairDisplay(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.orange.shade900,
  ),
),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


Widget _buildCountdown() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 400),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          SlideInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 600),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, color: const Color(0xFFD946A6), size: 24),
                const SizedBox(width: 10),
                Text(
                  'FALTAN',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    letterSpacing: 3,
                    color: const Color(0xFFD946A6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          StreamBuilder(
            stream: Stream.periodic(const Duration(seconds: 1)),
            builder: (context, snapshot) {
              final targetDate = DateTime(2026, 2, 14, 11, 0);
              final now = DateTime.now();
              final difference = targetDate.difference(now);
              
              return ZoomIn(
                duration: const Duration(milliseconds: 1200),
                delay: const Duration(milliseconds: 800),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimeUnit(difference.inDays.toString(), 'Días'),
                    _buildTimeUnit((difference.inHours % 24).toString(), 'horas'),
                    _buildTimeUnit((difference.inMinutes % 60).toString(), 'minutos'),
                    _buildTimeUnit((difference.inSeconds % 60).toString(), 'segundos'),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildNoviosSection() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.pink.shade50],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Pulse(
            duration: const Duration(milliseconds: 1500),
            child: Icon(Icons.favorite, color: const Color(0xFFD946A6), size: 50),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Los Novios',
              style: GoogleFonts.playfairDisplay(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: SlideInLeft(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: _buildNovioCard(
                    'Itzel Yarani',
                    'Del Villar Ramírez',
                    Icons.female,
                    Colors.pink.shade100,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Pulse(
                duration: const Duration(milliseconds: 1500),
                infinite: true,
                child: Icon(Icons.favorite, color: const Color(0xFFD946A6), size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: SlideInRight(
                  duration: const Duration(milliseconds: 1000),
                  delay: const Duration(milliseconds: 500),
                  child: _buildNovioCard(
                    'Oscar',
                    'Quintana Lozano',
                    Icons.male,
                    Colors.blue.shade100,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildPadresSection() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          BounceInDown(
            duration: const Duration(milliseconds: 1200),
            child: Icon(Icons.family_restroom, color: const Color(0xFFD946A6), size: 50),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Con la Bendición de Nuestros Padres',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          SlideInLeft(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 500),
            child: _buildPadreItem('Padres de la Novia', [
              'Lourdes Ramírez Medina',
              'José Víctor Del Villar Flores',
            ], Icons.people),
          ),
          const SizedBox(height: 25),
          SlideInRight(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 700),
            child: _buildPadreItem('Padres del Novio', [
              'Petra Lozano Salcedo',
              'Arturo Eduardo Quintana Briseño',
            ], Icons.people_outline),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPadrinosSection() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.pink.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Spin(
            duration: const Duration(milliseconds: 2000),
            child: Icon(Icons.stars, color: const Color(0xFFD946A6), size: 50),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Nuestros Padrinos',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SlideInLeft(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 500),
            child: _buildPadrinoCard('Ma. Elena Ramírez Medina'),
          ),
          const SizedBox(height: 15),
          SlideInRight(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 700),
            child: _buildPadrinoCard('Abigail Paloma Vera'),
          ), const SizedBox(height: 25),
          SlideInLeft(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 500),
            child: _buildPadrinoCard('Augusto Baldera Ramírez'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildItinerarioSection() {
  return FadeInUp(
    duration: const Duration(milliseconds: 1000),
    delay: const Duration(milliseconds: 200),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          BounceInDown(
            duration: const Duration(milliseconds: 1200),
            child: Icon(Icons.event_note, color: const Color(0xFFD946A6), size: 50),
          ),
          const SizedBox(height: 20),
          FadeInDown(
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 300),
            child: Text(
              'Itinerario del Día',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
            ),
          ),
          const SizedBox(height: 30),
          SlideInLeft(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 500),
            child: _buildEventoCard(
              '11:00 AM',
              'Ceremonia Religiosa',
              'Parroquia de la Asunción y del Sagrado Corazón',
              'Apan, Hidalgo',
              Icons.church,
              Colors.purple.shade100,
              'https://maps.app.goo.gl/TQzfessn7mXviAaQA',
            ),
          ),
          const SizedBox(height: 20),
          SlideInRight(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 700),
            child: _buildEventoCard(
              '2:00 PM',
              'Recepción',
              'Salón "La Cabaña"',
              'Capacidad: 150-200 personas',
              Icons.celebration,
              Colors.green.shade100,
              'https://maps.app.goo.gl/ecDdwpAtArqD7Ufr7',
            ),
          ),
          const SizedBox(height: 20),
          SlideInLeft(
            duration: const Duration(milliseconds: 1000),
            delay: const Duration(milliseconds: 900),
            child: _buildEventoCard(
              '3:00 PM',
              'Ceremonia Civil',
              'Salón "La Cabaña"',
              '',
              Icons.gavel,
              Colors.blue.shade100,
              null,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDivider() {
  return FadeIn(
    duration: const Duration(milliseconds: 800),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Pulse(
              duration: const Duration(milliseconds: 2000),
              infinite: true,
              child: Icon(Icons.favorite, color: const Color(0xFFD946A6), size: 20),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        ],
      ),
    ),
  );
}

Widget _buildTimeUnit(String value, String label) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Text(
          value.padLeft(2, '0'),
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD946A6),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildPadreItem(String titulo, List<String> nombres, IconData icono) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F3EF),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFE8E4DC)),
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, color: const Color(0xFFD946A6), size: 20),
            const SizedBox(width: 10),
            Text(
              titulo,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD946A6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...nombres.map((nombre) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            nombre,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        )),
      ],
    ),
  );
}

Widget _buildPadrinoCard(String nombre) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFD946A6), width: 2),
    ),
    child: Row(
      children: [
        Icon(Icons.workspace_premium, color: const Color(0xFFD946A6), size: 28),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            nombre,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildEventoCard(String hora, String titulo, String lugar, String detalle, 
                        IconData icono, Color color, String? mapsUrl) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color, width: 2),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hora,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFD946A6),
                    ),
                  ),
                  Text(
                    titulo,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Icon(Icons.location_on, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lugar,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (detalle.isNotEmpty)
                    Text(
                      detalle,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        if (mapsUrl != null) ...[
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _abrirMaps(mapsUrl),
              icon: const Icon(Icons.map, size: 18),
              label: const Text('VER EN MAPA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD946A6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _buildConfirmacionSection() {
  final yaConfirmada = _invitacionCargada && 
                        _datosInvitacion != null && 
                        _datosInvitacion!['confirmado'] == true;
  
  return FadeInUp(
    child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: yaConfirmada 
            ? [Colors.green.shade50, Colors.green.shade100]
            : [Colors.white, const Color(0xFFF5F3EF)],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  yaConfirmada ? Icons.check_circle : Icons.how_to_reg,
                  color: yaConfirmada ? Colors.green.shade600 : const Color(0xFFD946A6),
                  size: 60,
                ),
                const SizedBox(height: 20),
                Text(
                  yaConfirmada ? '¡Ya Confirmaste!' : 'Confirma tu Asistencia',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: yaConfirmada ? Colors.green.shade700 : const Color(0xFFD946A6),
                  ),
                ),
                if (_invitacionCargada && _datosInvitacion != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: yaConfirmada
                          ? [Colors.green.shade200, Colors.green.shade300]
                          : [const Color(0xFFD946A6), const Color(0xFFC535A0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (yaConfirmada ? Colors.green : const Color(0xFFD946A6)).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Lugares asignados para ti:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          yaConfirmada 
                            ? '${_datosInvitacion!['lugaresConfirmados']} de ${_datosInvitacion!['lugaresAsignados']}'
                            : '${_datosInvitacion!['lugaresAsignados']}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),   ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 30),
      
      if (yaConfirmada) ...[
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.green.shade300, width: 2),
          ),
          child: Column(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade600, size: 60),
              const SizedBox(height: 20),
              Text(
                'Tu asistencia ya fue confirmada',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Confirmaste ${_datosInvitacion!['lugaresConfirmados']} lugares',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              if (_datosInvitacion!['mensajeRespuesta'] != null &&
                  _datosInvitacion!['mensajeRespuesta'].toString().isNotEmpty) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.message, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            'Tu mensaje:',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _datosInvitacion!['mensajeRespuesta'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ] else ...[
        TextField(
          controller: _nombreController,
          readOnly: _invitacionCargada,
          decoration: InputDecoration(
            labelText: 'Nombre de la reserva *',
            hintText: 'Ej: Familia González',
            filled: true,
            fillColor: _invitacionCargada ? Colors.grey.shade100 : Colors.white,
            prefixIcon: Icon(Icons.person, color: const Color(0xFFD946A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFD946A6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _lugaresController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: _invitacionCargada 
                ? 'Cantidad de lugares que confirmas *'
                : 'Cantidad de lugares *',
            hintText: _invitacionCargada 
                ? 'Máximo: ${_datosInvitacion!['lugaresAsignados']}'
                : 'Ej: 2',
            helperText: _invitacionCargada 
                ? 'Puedes confirmar de 1 hasta ${_datosInvitacion!['lugaresAsignados']} lugares'
                : null,
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.people, color: const Color(0xFFD946A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFD946A6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _mensajeController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Mensaje para los novios (opcional)',
            hintText: '¡Escribe tus mejores deseos!',
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.message, color: const Color(0xFFD946A6)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFD946A6), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _confirmarAsistencia,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'CONFIRMAR ASISTENCIA',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    letterSpacing: 1.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ],
  ),
),
);
}void _mostrarDialogoConfirmacionFoto(XFile image) {
  final TextEditingController mensajeLocalController = TextEditingController();
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Compartir Foto',
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xFFD946A6),
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          image.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return FutureBuilder<Uint8List>(
                              future: image.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                            );
                          },
                        )
                      : Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: mensajeLocalController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Mensaje (opcional)',
                  hintText: '¡Escribe un mensaje para los novios!',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD946A6)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD946A6), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              mensajeLocalController.dispose();
              Navigator.pop(context);
            },
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final mensaje = mensajeLocalController.text.trim();
              mensajeLocalController.dispose();
              Navigator.pop(context);
              await _subirFotoConMensaje(image, mensaje);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD946A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Compartir',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> _subirFotoConMensaje(XFile image, String mensaje) async {
  try {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD946A6),
        ),
      ),
    );
    
    final storage = FirebaseStorage.instanceFor(
      bucket: 'gs://invitacione-be055.firebasestorage.app'
    );
    
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final Reference storageRef = storage
        .ref()
        .child('Evento')
        .child(fileName);
    
    if (kIsWeb) {
      final bytes = await image.readAsBytes();
      await storageRef.putData(bytes);
    } else {
      await storageRef.putFile(File(image.path));
    }
    
    final String downloadUrl = await storageRef.getDownloadURL();
    
    final mensajes = FirebaseFirestore.instance.collection('Mensajes');
    final snapshot = await mensajes.get();
    final nextIndex = snapshot.docs.length;
    
    await mensajes.doc(nextIndex.toString()).set({
      'mensaje': mensaje.isEmpty ? '' : mensaje,
      'fotoUrl': downloadUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    if (!mounted) return;
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 10),
            Text('¡Foto compartida exitosamente!'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al subir foto: $e')),
    );
  }
}



Future<void> _cargarInvitacionDesdeUrl() async {
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    String? invitacionId;
    
    // Obtener la URI completa
    final uri = Uri.base;
    if (_debugMode) {
      print('=== DEBUG URL ===');
      print('URI completo: $uri');
      print('Path: ${uri.path}');
      print('Fragment: ${uri.fragment}');
      print('Query params directos: ${uri.queryParameters}');
    }
    
    // Método 1: Intentar leer directamente de query parameters
    invitacionId = uri.queryParameters['id'];
    if (_debugMode) print('ID desde query directo: $invitacionId');
    
    // Método 2: Parsear el fragment (lo más común en Flutter Web con hash routing)
    if ((invitacionId == null || invitacionId.isEmpty) && uri.fragment.isNotEmpty) {
      final fragment = uri.fragment;
      if (_debugMode) print('Procesando fragment: $fragment');
      
      // El fragment puede venir como: "/dos?id=xxx" o "dos?id=xxx"
      // Remover el slash inicial si existe
      final cleanFragment = fragment.startsWith('/') ? fragment.substring(1) : fragment;
      
      // Dividir en path y query string
      final parts = cleanFragment.split('?');
      if (parts.length > 1) {
        // Parsear los query parameters del fragment
        final queryString = parts[1];
        final queryParams = Uri.splitQueryString(queryString);
        invitacionId = queryParams['id'];
        if (_debugMode) print('ID desde fragment query: $invitacionId');
      }
    }
    
    // Método 3: Leer de los argumentos de la ruta (RouteSettings)
    if ((invitacionId == null || invitacionId.isEmpty)) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is Map) {
        invitacionId = args['id'] as String?;
        if (_debugMode) print('ID desde argumentos de ruta: $invitacionId');
      }
    }
    
    if (_debugMode) print('ID final encontrado: $invitacionId');
    
    if (invitacionId != null && invitacionId.isNotEmpty) {
      await _cargarDatosInvitacion(invitacionId);
    } else {
      if (_debugMode) print('No se encontró ID de invitación');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text('Visualizando invitación general. Para ver una invitación específica, usa el enlace proporcionado.'),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  });
}


Future<void> _cargarDatosInvitacion(String invitacionId) async {
  try {
    if (_debugMode) print('Intentando cargar invitación: $invitacionId');
    
    final doc = await FirebaseFirestore.instance
        .collection('invitaciones')
        .doc(invitacionId)
        .get();
    
    if (_debugMode) print('Documento existe: ${doc.exists}');
    
    if (doc.exists) {
      final datos = doc.data()!;
      if (_debugMode) print('Datos cargados: $datos');
      
      if (datos['confirmado'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(child: Text('Esta invitación ya fue confirmada anteriormente')),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      
      setState(() {
        _invitacionId = invitacionId;
        _datosInvitacion = datos;
        _invitacionCargada = true;
        _nombreController.text = datos['nombre'] ?? '';
        _lugaresController.text = datos['lugaresAsignados'].toString();
      });
      
      if (_debugMode) print('Estado actualizado correctamente');
    } else {
      if (_debugMode) print('Documento no encontrado');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text('Invitación no encontrada'),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  } catch (e) {
    if (_debugMode) print('Error al cargar invitación: $e');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar invitación: $e')),
    );
  }
}


  
  void _checkUploadDate() {
    DateTime now = DateTime.now();
    if ((now.month == 2 && now.day >= 14 && now.day <= 16) || true) {
      setState(() {
        _canUploadPhotos = true;
      });
    }
  }
  
  
  
  Future<void> _abrirMaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Google Maps')),
      );
    }
  }
  
  
  Future<void> _seleccionarYMostrarFoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;
      if (!mounted) return;
      _mostrarDialogoConfirmacionFoto(image);
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar foto: $e')),
      );
    }
  }
  
  
  
  void _mostrarDialogoCodigo() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Acceso Especial'),
          content: TextField(
            controller: _codigoController,
            decoration: InputDecoration(
              hintText: 'Ingresa el código',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_codigoController.text == '020422') {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, 'tres');
                  _codigoController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Código incorrecto')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7A9B8E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ingresar'),
            ),
          ],
        );
      },
    );
  }
  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F3EF),
    body: Stack(
      children: [
        // REPRODUCTOR DE MÚSICA OCULTO
        Positioned(
          left: -1000,
          top: -1000,
          child: SizedBox(
            width: 1,
            height: 1,
            child: YoutubePlayer(
              controller: _musicController,
              aspectRatio: 16 / 9,
            ),
          ),
        ),
        
        // CONTENIDO PRINCIPAL
        SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroSection(),
              _buildCountdown(),
              _buildNoviosSection(),
              Container(height: 50),
              _buildPadresSection(),
              _buildDivider(),
              _buildPadrinosSection(),
              _buildDivider(),
              _buildItinerarioSection(),
              _buildDivider(),
              _buildCodigoVestimenta(),
              _buildDivider(),
              _buildConfirmacionSection(),
              if (_canUploadPhotos) _buildFotosSection(),
              // NUEVO: Sección del bautizo después de fotos
              _buildDivider(),
              _buildBautizoSection(),
              const SizedBox(height: 100),
            ],
          ),
        ),
        
        // BOTÓN DE CÓDIGO (esquina inferior derecha)
        Positioned(
          bottom: 20,
          right: 20,
          child: GestureDetector(
            onTap: _mostrarDialogoCodigo,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        
        // BOTÓN DE MÚSICA (esquina inferior izquierda)
        Positioned(
          bottom: 20,
          left: 20,
          child: GestureDetector(
            onTap: _toggleMusic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                horizontal: _musicStarted ? 12 : 15,
                vertical: _musicStarted ? 10 : 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFD946A6),
                    Colors.pink.shade300,
                  ],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD946A6).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    !_musicStarted 
                        ? Icons.music_note 
                        : (_isMusicPlaying ? Icons.pause : Icons.play_arrow),
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    !_musicStarted 
                        ? 'Reproduce nuestra canción' 
                        : (_isMusicPlaying ? 'Pausar' : 'Reproducir'),
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  
  
  
  Widget _buildNovioCard(String nombre, String apellido, IconData icono, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Icon(icono, size: 40, color: color.withOpacity(0.8)),
          const SizedBox(height: 15),
          Text(
            nombre,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          Text(
            apellido,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  
  
  
  
  
  
  
  
  Widget _buildFotosSection() {
    return FadeInUp(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade50, Colors.pink.shade50],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                Icons.photo_camera,
                color: Colors.purple.shade600,
                size: 50,
              ),
            ),
            const SizedBox(height: 25),
            Text(
              '📸 Comparte tus Fotos',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF7A9B8E),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Captura los mejores momentos de nuestra celebración y compártelos con nosotros',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _seleccionarYMostrarFoto,
                icon: const Icon(Icons.add_a_photo, size: 24),
                label: Text(
                  'SELECCIONAR FOTO',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  elevation: 5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TornPaperPainter extends CustomPainter {
  final bool isTop;
  
  TornPaperPainter({this.isTop = false});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF5F3EF)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    
    if (isTop) {
      path.moveTo(0, size.height);
      
      double step = size.width / 20;
      for (double x = 0; x < size.width; x += step) {
        path.lineTo(x, size.height - (x % (step * 2) == 0 ? 15 : 5));
      }
      
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else {
      path.moveTo(0, 0);
      
      double step = size.width / 20;
      for (double x = 0; x < size.width; x += step) {
        path.lineTo(x, x % (step * 2) == 0 ? 15 : 5);
      }
      
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    
    path.close();
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}