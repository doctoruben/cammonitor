import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/camera_model.dart';
import '../widgets/camera_tile.dart';
import '../widgets/camera_fullscreen.dart';

enum LayoutMode { grid2x2, stack, horizontal }

class DashboardScreen extends StatefulWidget {
  final List<CameraModel> cameras;
  const DashboardScreen({super.key, required this.cameras});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  LayoutMode _layout = LayoutMode.grid2x2;

  void _openFullscreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraFullscreen(camera: widget.cameras[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00E5FF)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.videocam, size: 16, color: Color(0xFF00E5FF)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CAMMONITOR',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    letterSpacing: 4,
                    color: Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.cameras.where((c) => c.enabled).length} cámaras activas',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF4A6572),
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          _layoutButton(LayoutMode.grid2x2, Icons.grid_view, '2×2'),
          _layoutButton(LayoutMode.stack, Icons.view_agenda, 'Lista'),
          _layoutButton(LayoutMode.horizontal, Icons.view_column, 'Horiz'),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildGrid(isLandscape),
    );
  }

  Widget _layoutButton(LayoutMode mode, IconData icon, String tooltip) {
    final isActive = _layout == mode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: IconButton(
        icon: Icon(icon, size: 18),
        tooltip: tooltip,
        color: isActive ? const Color(0xFF00E5FF) : const Color(0xFF4A6572),
        style: isActive
            ? IconButton.styleFrom(
                backgroundColor: const Color(0xFF00E5FF).withOpacity(0.1),
              )
            : null,
        onPressed: () => setState(() => _layout = mode),
      ),
    );
  }

  Widget _buildGrid(bool isLandscape) {
    final cams = widget.cameras;
    if (cams.isEmpty) {
      return const Center(
        child: Text(
          'Sin cámaras configuradas.\nVe a Configurar para añadirlas.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4A6572), fontFamily: 'monospace'),
        ),
      );
    }

    switch (_layout) {
      case LayoutMode.grid2x2:
        return GridView.builder(
          padding: const EdgeInsets.all(6),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLandscape ? 2 : 2,
            childAspectRatio: 16 / 9,
            crossAxisSpacing: 6,
            mainAxisSpacing: 6,
          ),
          itemCount: cams.length,
          itemBuilder: (ctx, i) => CameraTile(
            camera: cams[i],
            index: i,
            onTap: () => _openFullscreen(i),
          ),
        );

      case LayoutMode.stack:
        return ListView.separated(
          padding: const EdgeInsets.all(6),
          itemCount: cams.length,
          separatorBuilder: (_, __) => const SizedBox(height: 6),
          itemBuilder: (ctx, i) => AspectRatio(
            aspectRatio: 16 / 9,
            child: CameraTile(
              camera: cams[i],
              index: i,
              onTap: () => _openFullscreen(i),
            ),
          ),
        );

      case LayoutMode.horizontal:
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(6),
          itemCount: cams.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (ctx, i) => AspectRatio(
            aspectRatio: 16 / 9,
            child: CameraTile(
              camera: cams[i],
              index: i,
              onTap: () => _openFullscreen(i),
            ),
          ),
        );
    }
  }
}
