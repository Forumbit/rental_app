import 'package:material_ui/material_ui.dart';

import '../../core/format.dart';
import '../../data/models.dart';
import 'common.dart';

/// Swipeable photo gallery with dots, a counter, hover arrows and a
/// full-screen viewer on tap.
class Gallery extends StatefulWidget {
  const Gallery({super.key, required this.images, required this.heroTag, this.borderRadius = BorderRadius.zero});

  final List<ListingImage> images;
  final String heroTag;
  final BorderRadius borderRadius;

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  final _controller = PageController();
  int _page = 0;
  bool _hovered = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int page) =>
      _controller.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.easeOutCubic);

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final scheme = Theme.of(context).colorScheme;
    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Hero(
          tag: widget.heroTag,
          child: ColoredBox(
            color: scheme.secondaryContainer,
            child: Center(child: Icon(Icons.home_work_outlined, size: 72, color: scheme.onSecondaryContainer)),
          ),
        ),
      );
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (page) => setState(() => _page = page),
              itemBuilder: (context, i) {
                final image = AppNetworkImage(images[i].fullUrl);
                return GestureDetector(
                  onTap: () => _openViewer(context, i),
                  child: i == 0 ? Hero(tag: widget.heroTag, child: image) : image,
                );
              },
            ),
            if (images.length > 1) ...[
              Positioned(right: 16, top: 16, child: _Pill(child: Text(context.l10n.photoOf(_page + 1, images.length)))),
              Positioned(
                left: 0,
                right: 0,
                bottom: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < images.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: i == _page ? 1 : 0.6),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
                        ),
                      ),
                  ],
                ),
              ),
              _Arrow(
                visible: _hovered && _page > 0,
                alignment: Alignment.centerLeft,
                icon: Icons.chevron_left_rounded,
                onPressed: () => _go(_page - 1),
              ),
              _Arrow(
                visible: _hovered && _page < images.length - 1,
                alignment: Alignment.centerRight,
                icon: Icons.chevron_right_rounded,
                onPressed: () => _go(_page + 1),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openViewer(BuildContext context, int initial) async {
    final page = await Navigator.of(context, rootNavigator: true).push<int>(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) => PhotoViewer(images: widget.images, initialPage: initial),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
    if (page != null && page != _page && _controller.hasClients) _controller.jumpToPage(page);
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.visible, required this.alignment, required this.icon, required this.onPressed});

  final bool visible;
  final Alignment alignment;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
    alignment: alignment,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: IgnorePointer(
          ignoring: !visible,
          child: IconButton.filledTonal(onPressed: onPressed, icon: Icon(icon)),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        child: child,
      ),
    ),
  );
}

/// Full-screen photos with pinch/scroll zoom; returns the last page.
class PhotoViewer extends StatefulWidget {
  const PhotoViewer({super.key, required this.images, required this.initialPage});

  final List<ListingImage> images;
  final int initialPage;

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final _controller = PageController(initialPage: widget.initialPage);
  late int _page = widget.initialPage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.images.length,
            onPageChanged: (page) => setState(() => _page = page),
            itemBuilder: (_, i) => InteractiveViewer(
              maxScale: 4,
              child: Center(child: AppNetworkImage(widget.images[i].fullUrl, fit: BoxFit.contain)),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: context.l10n.close,
                    onPressed: () => Navigator.pop(context, _page),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  if (widget.images.length > 1)
                    _Pill(child: Text(context.l10n.photoOf(_page + 1, widget.images.length))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
