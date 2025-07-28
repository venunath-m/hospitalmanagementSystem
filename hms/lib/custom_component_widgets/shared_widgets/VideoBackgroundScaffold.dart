import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBackgroundScaffold extends StatefulWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool scrollable;

  const VideoBackgroundScaffold({
    Key? key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
    this.scrollable = false,
  }) : super(key: key);

  @override
  State<VideoBackgroundScaffold> createState() =>
      _VideoBackgroundScaffoldState();
}

class _VideoBackgroundScaffoldState extends State<VideoBackgroundScaffold> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/bgv1.mp4')
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_controller.value.isInitialized)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: widget.appBar,
          drawer: widget.drawer,
          floatingActionButton: widget.floatingActionButton,
          bottomNavigationBar: widget.bottomNavigationBar,
          body: SafeArea(
            child: widget.scrollable
                ? SingleChildScrollView(child: widget.body)
                : widget.body,
          ),
        ),
      ],
    );
  }
}
