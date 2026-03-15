import 'package:flutter/material.dart';
import '../models/camera_model.dart';

class SettingsScreen extends StatefulWidget {
  final List<CameraModel> cameras;
  final Function(List<CameraModel>) onChanged;

  const SettingsScreen({super.key, required this.cameras, required this.onChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late List<CameraModel> _cameras;

  @override
  void initState() {
    super.initState();
    _cameras = List.from(widget.cameras);
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameras != widget.cameras) {
      setState(() => _cameras = List.from(widget.cameras));
    }
  }

  void _editCamera(int index) {
    final cam = _cameras[index];
    final nameCtrl = TextEditingController(text: cam.name);
    final urlCtrl = TextEditingController(text: cam.url);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1318),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF1A2A35)),
        ),
        title: Text(
          'CAM-0${index + 1}',
          style: const TextStyle(
            color: Color(0xFF00E5FF),
            fontFamily: 'monospace',
            letterSpacing: 3,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field('Nombre', nameCtrl, Icons.label),
            const SizedBox(height: 12),
            _field('URL del stream', urlCtrl, Icons.link,
                hint: 'rtsp://admin:pass@192.168.68.x:554/live/ch00_0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF4A6572))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _cameras[index] = cam.copyWith(
                  name: nameCtrl.text.trim().toUpperCase(),
                  url: urlCtrl.text.trim(),
                );
              });
              widget.onChanged(_cameras);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar', style: TextStyle(color: Color(0xFF00E5FF))),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, {String? hint}) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Color(0xFFC8DDE8), fontSize: 13, fontFamily: 'monospace'),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Color(0xFF4A6572), fontSize: 11),
        hintStyle: const TextStyle(color: Color(0xFF2A3A45), fontSize: 11),
        prefixIcon: Icon(icon, color: const Color(0xFF4A6572), size: 18),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1A2A35)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00E5FF)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CONFIGURACIÓN',
          style: TextStyle(fontFamily: 'monospace', letterSpacing: 3, fontSize: 14),
        ),
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.05),
              border: Border.all(color: const Color(0xFF1E3A4A)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFF00E5FF), size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Toca una cámara para editar su nombre y URL del stream RTSP.',
                    style: TextStyle(
                      color: Color(0xFF4A6572),
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Camera list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _cameras.length,
              separatorBuilder: (_, __) => const Divider(color: Color(0xFF1A2A35), height: 1),
              itemBuilder: (ctx, i) {
                final cam = _cameras[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF1E3A4A)),
                      borderRadius: BorderRadius.circular(4),
                      color: const Color(0xFF0A1017),
                    ),
                    child: Center(
                      child: Text(
                        '0${i + 1}',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontFamily: 'monospace',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    cam.name,
                    style: const TextStyle(
                      color: Color(0xFFC8DDE8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  subtitle: Text(
                    cam.url.isEmpty ? 'Sin URL configurada' : cam.url,
                    style: TextStyle(
                      color: cam.url.isEmpty ? const Color(0xFFFF3B3B) : const Color(0xFF4A6572),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: cam.enabled,
                        onChanged: (v) {
                          setState(() => _cameras[i] = cam.copyWith(enabled: v));
                          widget.onChanged(_cameras);
                        },
                        activeColor: const Color(0xFF00E5FF),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF4A6572), size: 20),
                        onPressed: () => _editCamera(i),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // RTSP guide
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCC00).withOpacity(0.05),
              border: Border.all(color: const Color(0xFFFFCC00).withOpacity(0.3)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'URLs RTSP para cámaras JOOAN:',
                  style: TextStyle(
                    color: Color(0xFFFFCC00),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Canal principal (HD):\nrtsp://admin:PASS@IP:554/live/ch00_0\n\nCanal secundario (baja res):\nrtsp://admin:PASS@IP:554/live/ch00_1',
                  style: TextStyle(
                    color: Color(0xFF4A6572),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
