import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class BackgroundSelectorService {
  static Future<String?> showBackgroundSelector(
    BuildContext context,
    List<String> backgroundOptions,
  ) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Background'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: backgroundOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final bg = backgroundOptions[index];
              final isVideo = bg.toLowerCase().endsWith('.mp4');

              return GestureDetector(
                onTap: () => Navigator.pop(ctx, bg),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: isVideo
                      ? _VideoThumbnail(path: bg)
                      : Image.asset(bg, fit: BoxFit.cover),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VideoThumbnail extends StatefulWidget {
  final String path;
  const _VideoThumbnail({required this.path});

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.path)
      ..initialize().then((_) {
        _controller.setVolume(0);
        _controller.setLooping(true);
        _controller.play();
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
