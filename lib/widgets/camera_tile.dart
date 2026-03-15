import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import '../models/camera_model.dart';

class CameraTile extends StatefulWidget {
  final CameraModel camera;
  final int index;
  final VoidCallback onTap;

  const CameraTile({
    super.key,
    required this.camera,
    required this.index,
    required this.onTap,
  });

  @override
  State<CameraTile> createState() => _CameraTileState();
}

class _CameraTileState extends State<CameraTile> {
  VlcPlayerController? _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.camera.enabled && widget.camera.url.isNotEmpty) {
      _initPlayer();
    }
  }

  @override
  void didUpdateWidget(CameraTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.camera.url != widget.camera.url ||
        oldWidget.camera.enabled != widget.camera.enabled) {
      _disposePlayer();
      if (widget.camera.enabled && widget.camera.url.isNotEmpty) {
        _initPlayer();
      }
    }
  }

  void _initPlayer() {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _initialized = false;
    });

    _controller = VlcPlayerController.network(
      widget.camera.url,
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          VlcAdvancedOptions.networkCaching(2000),
       ]),
      ),
    );

    _controller!.addListener(_onPlayerStateChange);
  }

  void _onPlayerStateChange() {
    if (!mounted) return;
    final state = _controller?.value.playingState;
    if (state == PlayingState.playing && !_initialized) {
      setState(() {
        _isLoading = false;
        _initialized = true;
        _hasError = false;
      });
    } else if (state == PlayingState.error) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _disposePlayer() {
    _controller?.removeListener(_onPlayerStateChange);
    _controller?.stopRendererScanning();
    _controller?.dispose();
    _controller = null;
    _initialized = false;
  }

  void _retry() {
    _disposePlayer();
    _initPlayer();
  }

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1017),
          border: Border.all(color: const Color(0xFF1A2A35)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: const BoxDecoration(
                color: Color(0xFF060D12),
                border: Border(bottom: BorderSide(color: Color(0xFF1A2A35))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _hasError
                          ? const Color(0xFFFF3B3B)
                          : _initialized
                              ? const Color(0xFF00FF88)
                              : const Color(0xFFFFCC00),
                      boxShadow: [
                        BoxShadow(
                          color: (_hasError
                                  ? const Color(0xFFFF3B3B)
                                  : _initialized
                                      ? const Color(0xFF00FF88)
                                      : const Color(0xFFFFCC00))
                              .withOpacity(0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CAM-0${widget.index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF00E5FF),
                      fontFamily: 'monospace',
                      fontSize: 9,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.camera.name,
                      style: const TextStyle(
                        color: Color(0xFFC8DDE8),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_initialized)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFFF3B3B)),
                        borderRadius: BorderRadius.circular(2),
                        color: const Color(0xFFFF3B3B).withOpacity(0.1),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Color(0xFFFF3B3B),
                          fontSize: 8,
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Video area
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // VLC Player
                  if (_controller != null && !_hasError)
                    VlcPlayer(
                      controller: _controller!,
                      aspectRatio: 16 / 9,
                      placeholder: const SizedBox(),
                    ),

                  // Corner decorations
                  ..._corners(),

                  // Loading overlay
                  if (_isLoading && !_hasError)
                    Container(
                      color: const Color(0xFF020507),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: const Color(0xFF00E5FF).withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'CONECTANDO...',
                              style: TextStyle(
                                color: Color(0xFF4A6572),
                                fontFamily: 'monospace',
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Error overlay
                  if (_hasError)
                    Container(
                      color: const Color(0xFF020507),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.videocam_off,
                                color: Color(0xFF4A6572), size: 24),
                            const SizedBox(height: 6),
                            const Text(
                              'SIN SEÑAL',
                              style: TextStyle(
                                color: Color(0xFF4A6572),
                                fontFamily: 'monospace',
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: _retry,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: const Color(0xFF1E3A4A)),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: const Text(
                                  'REINTENTAR',
                                  style: TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontFamily: 'monospace',
                                    fontSize: 8,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // No URL configured
                  if (widget.camera.url.isEmpty)
                    Container(
                      color: const Color(0xFF020507),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.videocam_off,
                                color: Color(0xFF2A3A45), size: 24),
                            SizedBox(height: 6),
                            Text(
                              'SIN CONFIGURAR',
                              style: TextStyle(
                                color: Color(0xFF2A3A45),
                                fontFamily: 'monospace',
                                fontSize: 9,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _corners() {
    const c = Color(0xFF00E5FF);
    const size = 10.0;
    const thick = 1.5;
    const opacity = 0.3;
    return [
      Positioned(
        top: 4,
        left: 4,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size,
            height: size,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c, width: thick),
                  left: BorderSide(color: c, width: thick),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        top: 4,
        right: 4,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size,
            height: size,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: c, width: thick),
                  right: BorderSide(color: c, width: thick),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 4,
        left: 4,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size,
            height: size,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: c, width: thick),
                  left: BorderSide(color: c, width: thick),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 4,
        right: 4,
        child: Opacity(
          opacity: opacity,
          child: SizedBox(
            width: size,
            height: size,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: c, width: thick),
                  right: BorderSide(color: c, width: thick),
                ),
              ),
            ),
          ),
        ),
      ),
    ];
  }
}
