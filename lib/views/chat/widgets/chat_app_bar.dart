// =============================================================================
//  chat_bubble.dart  — FlashPay Premium Chat Bubble
//  ✅ إصلاح مشكلة الفقاعة الكبيرة: Row التوقيت MainAxisSize.max → min
//  ✅ إزالة IntrinsicWidth (كانت تسبب assert infinity width crash)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

abstract final class _R {
  static const double full = 20.0;
  static const double tail = 4.0;
  static const double mid  = 6.0;

  static const BorderRadius sSolo = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(tail),
  );
  static const BorderRadius sFirst = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(mid),
  );
  static const BorderRadius sMid = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(mid),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(mid),
  );
  static const BorderRadius sLast = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(mid),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(tail),
  );

  static const BorderRadius rSolo = BorderRadius.only(
    topLeft:     Radius.circular(tail),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(tail),
    bottomRight: Radius.circular(full),
  );
  static const BorderRadius rFirst = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(mid),
    bottomRight: Radius.circular(full),
  );
  static const BorderRadius rMid = BorderRadius.only(
    topLeft:     Radius.circular(mid),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(mid),
    bottomRight: Radius.circular(full),
  );
  static const BorderRadius rLast = BorderRadius.only(
    topLeft:     Radius.circular(mid),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(tail),
    bottomRight: Radius.circular(full),
  );

  static const Color rxBgLight   = Color(0xFFC75D05);
  static const Color rxBgDark    = Color(0xFFC75D05);
  static const Color rxTextLight = Color(0xFFEBEAEE);
  static const Color rxTextDark  = Color(0xFFEBEAEE);

  static const Color adminBgLight   = Color(0x9DFFFDFD);
  static const Color adminBgDark    = Color(0x9DFFFDFD);
  static const Color adminTextLight = Color(0xFF1A1A2E);
  static const Color adminTextDark  = Color(0xFF1A1A2E);

  static const double tsAlpha = 0.55;
}

class ChatBubble extends StatelessWidget {
  final String  message;
  final String? imageUrl;
  final String  senderName;
  final bool    isMe;
  final bool    isDark;
  final Color   brandColor;
  final bool    isAdmin;
  final String? timestamp;
  final bool    groupWithPrevious;
  final bool    groupWithNext;
  final int     animationIndex;

  const ChatBubble({
    Key? key,
    required this.message,
    this.imageUrl,
    required this.senderName,
    required this.isMe,
    required this.isDark,
    required this.brandColor,
    this.isAdmin           = false,
    this.timestamp,
    this.groupWithPrevious = false,
    this.groupWithNext     = false,
    this.animationIndex    = 0,
  }) : super(key: key);

  BorderRadius _resolveRadius() {
    final bool onRight = isMe;
    final bool first   = !groupWithPrevious;
    final bool last    = !groupWithNext;

    if (onRight) {
      if (first && last) return _R.sSolo;
      if (first)         return _R.sFirst;
      if (last)          return _R.sLast;
      return _R.sMid;
    } else {
      if (first && last) return _R.rSolo;
      if (first)         return _R.rFirst;
      if (last)          return _R.rLast;
      return _R.rMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bubbleBg;
    final Color textColor;
    Gradient? bubbleGradient;

    if (isMe) {
      bubbleGradient = LinearGradient(
        colors: [
          Color.lerp(brandColor, Colors.white, 0.18)!,
          brandColor,
          Color.lerp(brandColor, Colors.black, 0.18)!,
        ],
        begin: Alignment.topLeft,
        end:   Alignment.bottomRight,
      );
      bubbleBg  = brandColor;
      textColor = Colors.white;
    } else if (isAdmin) {
      bubbleBg  = isDark ? _R.adminBgDark  : _R.adminBgLight;
      textColor = isDark ? _R.adminTextDark : _R.adminTextLight;
    } else {
      bubbleBg  = isDark ? _R.rxBgDark  : _R.rxBgLight;
      textColor = isDark ? _R.rxTextDark : _R.rxTextLight;
    }

    final List<BoxShadow> shadow = isDark
        ? []
        : [
      BoxShadow(
        color: isMe
            ? brandColor.withOpacity(0.30)
            : isAdmin
            ? const Color(0xFF7C3AED).withOpacity(0.15)
            : Colors.black.withOpacity(0.07),
        blurRadius:   isMe ? 20 : 10,
        spreadRadius: 0,
        offset: const Offset(0, 4),
      ),
    ];

    final int    delayMs   = (animationIndex * 35).clamp(0, 400);
    final double bottomGap = groupWithNext     ? 3.0  : 10.0;
    final double topGap    = groupWithPrevious ? 0.0  : 2.0;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top:    topGap,
          bottom: bottomGap,
          left:   isMe ? 52.0 : 0.0,
          right:  isMe ? 0.0  : 52.0,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        // ✅ الديكور مباشرة على Container — بدون IntrinsicWidth
        decoration: BoxDecoration(
          gradient:     isMe ? bubbleGradient : null,
          color:        isMe ? null : bubbleBg,
          borderRadius: _resolveRadius(),
          boxShadow:    shadow,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 9, 13, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── اسم المرسل ────────────────────────────────────────────────
              if (!isMe && !groupWithPrevious) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isAdmin) ...[
                      Icon(
                        Icons.support_agent_rounded,
                        size:  12,
                        color: textColor.withOpacity(0.70),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      senderName,
                      style: TextStyle(
                        fontSize:      11,
                        fontWeight:    FontWeight.w700,
                        letterSpacing: 0.3,
                        color: isAdmin
                            ? (isDark
                            ? const Color(0xFF050505)
                            : const Color(0xFF6D28D9))
                            : textColor.withOpacity(0.58),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
              ],

              // ── الصورة ────────────────────────────────────────────────────
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      barrierColor: Colors.black,
                      pageBuilder: (_, __, ___) =>
                          _FullScreenImageViewer(imageUrl: imageUrl!),
                      transitionsBuilder: (_, anim, __, child) =>
                          FadeTransition(opacity: anim, child: child),
                    ),
                  ),
                  child: Hero(
                    tag: imageUrl!,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 80,
                          maxHeight: 220,
                        ),
                        child: Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              height: 150,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: isMe ? Colors.white70 : brandColor,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => const SizedBox(
                            height: 150,
                            child: Center(
                              child: Icon(Icons.broken_image_rounded,
                                  color: Colors.grey),
                            ),
                          ),
                        ),
                      ),  // ConstrainedBox
                    ),
                  ),
                ),
                if (message.isNotEmpty) const SizedBox(height: 6),
              ],

              // ── النص ──────────────────────────────────────────────────────
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(
                    fontSize:   14.5,
                    height:     1.50,
                    color:      textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              // ── التوقيت + علامة الإرسال ────────────────────────────────────
              if (timestamp != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize:      MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (isMe) ...[
                        Icon(
                          Icons.done_all_rounded,
                          size:  13,
                          color: Colors.white.withOpacity(0.60),
                        ),
                        const SizedBox(width: 3),
                      ],
                      Text(
                        timestamp!,
                        style: TextStyle(
                          fontSize:      10,
                          fontWeight:    FontWeight.w500,
                          letterSpacing: 0.2,
                          color: textColor.withOpacity(_R.tsAlpha),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
      delay:    Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeOut,
    )
        .slideY(
      begin:    0.10,
      delay:    Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeOut,
    );
  }
}
// =============================================================================
//  _FullScreenImageViewer
//  شاشة عرض الصورة بالكامل مع إمكانية التكبير والحفظ
// =============================================================================
class _FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  final TransformationController _transformCtrl = TransformationController();
  bool _isSaving = false;
  bool _savedSuccess = false;

  @override
  void dispose() {
    _transformCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;
    setState(() { _isSaving = true; _savedSuccess = false; });

    try {
      // تنزيل الصورة كـ bytes ثم حفظها مباشرة بدون ملف مؤقت
      final response = await dio.Dio().get<List<int>>(
        widget.imageUrl,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data!),
        quality: 100,
        name: 'flashpay_${DateTime.now().millisecondsSinceEpoch}',
      );

      final bool isSuccess = result is Map
          ? result['isSuccess'] == true
          : result == true;

      if (isSuccess) {
        setState(() { _savedSuccess = true; });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('تم حفظ الصورة في الاستديو ✅'),
                ],
              ),
              backgroundColor: const Color(0xFF16A34A),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        throw Exception('فشل الحفظ');
      }
    } catch (e) {
      if (mounted) {
        print(  "Save Image Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('فشل حفظ الصورة، حاول مرة أخرى'),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _saveImage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _savedSuccess
                      ? const Color(0xFF16A34A)
                      : Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: _savedSuccess
                        ? const Color(0xFF16A34A)
                        : Colors.white.withOpacity(0.25),
                    width: 1.2,
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _savedSuccess
                          ? Icons.check_rounded
                          : Icons.download_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _savedSuccess ? 'تم الحفظ' : 'حفظ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
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

      body: Center(
        child: InteractiveViewer(
          transformationController: _transformCtrl,
          minScale: 0.8,
          maxScale: 5.0,
          child: Hero(
            tag: widget.imageUrl,
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                );
              },
              errorBuilder: (_, __, ___) => const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_rounded,
                      color: Colors.white38, size: 64),
                  SizedBox(height: 12),
                  Text('تعذّر تحميل الصورة',
                      style: TextStyle(color: Colors.white38)),
                ],
              ),
            ),
          ),
        ),
      ),

      // زر إعادة الضبط عند التكبير
      floatingActionButton: AnimatedBuilder(
        animation: _transformCtrl,
        builder: (_, __) {
          final isZoomed = _transformCtrl.value != Matrix4.identity();
          if (!isZoomed) return const SizedBox.shrink();
          return FloatingActionButton.small(
            backgroundColor: Colors.black54,
            onPressed: () => _transformCtrl.value = Matrix4.identity(),
            child: const Icon(Icons.zoom_out_map_rounded,
                color: Colors.white, size: 20),
          );
        },
      ),
    );
  }
}