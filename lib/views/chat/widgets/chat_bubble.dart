// =============================================================================
//  chat_bubble.dart — FlashPay Premium Chat Bubble
//
//  🎨 نظام الألوان (فرق واضح بين المستخدم والموظف):
//     • المستخدم (أنا)  : برتقالي الهوية (دافئ) — نص أبيض — على الطرف الأيمن
//     • الموظف (الدعم)  : عائلة زرقاء (بارد)   — على الطرف الأيسر
//         - فاتح: سطح أبيض + حد أزرق + اسم أزرق غامق
//         - داكن: سطح أزرق متوسط + حد أزرق فاتح + اسم أزرق فاتح
//     • طرف ثالث غير موظف: رمادي محايد (نادر)
//  ♿ التمييز لا يعتمد على اللون وحده: الموظف له أيقونة دعم + شارة "الدعم" + اسمه،
//     وكل جهة على طرف مختلف، وللمستخدم علامات ✓/✓✓.
//  ✅ تباين النص ≥ 4.5:1 في كل الحالات
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show Uint8List, debugPrint;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

abstract final class _Pal {
  static const Color navy = Color(0xFF132341);

  // ── الموظف (الدعم): عائلة زرقاء ─────────────────────────────────────────
  static const Color staffBgLight     = Colors.white;
  static const Color staffBgDark      = Color(0xFF223A63);
  static const Color staffBorderLight = Color(0xFFBFD0EA);
  static const Color staffBorderDark  = Color(0xFF3F629C);
  static const Color staffTextLight   = Color(0xFF132341);
  static const Color staffTextDark    = Colors.white;
  static const Color staffNameLight   = Color(0xFF1F4E9E); // 7.9:1 على الأبيض
  static const Color staffNameDark    = Color(0xFFA9C8FF); // على #223A63 > 7:1
  static const Color staffChipLight   = Color(0xFFE6EEFB);
  static const Color staffChipDark    = Color(0xFF2F4F82);

  // ── طرف ثالث غير موظف: رمادي محايد ─────────────────────────────────────
  static const Color otherBgLight = Color(0xFFEDEFF3);
  static const Color otherBgDark  = Color(0xFF2A3342);
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
  final bool    isRead;
  final bool    animate;

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
    this.isRead            = false,
    this.animate           = true,
  }) : super(key: key);

  /// الزوايا: الطرف الذي يلتصق به المرسل يضيق عند التجميع، والذيل أسفل آخر رسالة
  BorderRadius _radius() {
    const full = Radius.circular(20);
    const mid  = Radius.circular(6);
    const tail = Radius.circular(4);
    final top    = groupWithPrevious ? mid : full;
    final bottom = groupWithNext ? mid : tail;

    return isMe
        ? BorderRadius.only(
        topLeft: full, bottomLeft: full, topRight: top, bottomRight: bottom)
        : BorderRadius.only(
        topRight: full, bottomRight: full, topLeft: top, bottomLeft: bottom);
  }

  @override
  Widget build(BuildContext context) {
    final Color textColor;
    final Color? solidBg;
    Gradient? gradient;
    Border? border;

    // لون اسم/أيقونة الموظف وشارته
    final Color staffAccent = isDark ? _Pal.staffNameDark : _Pal.staffNameLight;
    final Color staffChip   = isDark ? _Pal.staffChipDark : _Pal.staffChipLight;

    if (isMe) {
      // برتقالي الهوية مُعتَّم قليلاً ليبلغ تباين النص الأبيض ≥ 4.5:1
      gradient = LinearGradient(
        colors: [
          Color.lerp(brandColor, Colors.black, 0.08)!,
          Color.lerp(brandColor, Colors.black, 0.22)!,
        ],
        begin: Alignment.topLeft,
        end:   Alignment.bottomRight,
      );
      solidBg   = null;
      textColor = Colors.white;
    } else if (isAdmin) {
      solidBg   = isDark ? _Pal.staffBgDark : _Pal.staffBgLight;
      textColor = isDark ? _Pal.staffTextDark : _Pal.staffTextLight;
      border    = Border.all(
        color: isDark ? _Pal.staffBorderDark : _Pal.staffBorderLight,
        width: 1.2,
      );
    } else {
      solidBg   = isDark ? _Pal.otherBgDark : _Pal.otherBgLight;
      textColor = isDark ? Colors.white : _Pal.navy;
    }

    final List<BoxShadow> shadow = isDark
        ? const []
        : [
      BoxShadow(
        color: isMe
            ? brandColor.withOpacity(0.26)
            : (isAdmin
            ? const Color(0xFF1F4E9E).withOpacity(0.10)
            : Colors.black.withOpacity(0.05)),
        blurRadius: isMe ? 16 : 8,
        offset: const Offset(0, 3),
      ),
    ];

    final double screenW   = MediaQuery.of(context).size.width;
    final double maxBubble = screenW * 0.78;
    final double bottomGap = groupWithNext ? 3.0 : 10.0;
    final double topGap    = groupWithPrevious ? 0.0 : 2.0;
    final int    delayMs   = (animationIndex * 35).clamp(0, 300);
    final bool   hasImage  = imageUrl != null && imageUrl!.isNotEmpty;
    final bool   hasText   = message.isNotEmpty;

    final Color metaColor =
    isMe ? Colors.white.withOpacity(0.82) : textColor.withOpacity(0.62);

    final bubble = Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top:    topGap,
          bottom: bottomGap,
          left:   isMe ? 40.0 : 0.0,
          right:  isMe ? 0.0  : 40.0,
        ),
        constraints: BoxConstraints(maxWidth: maxBubble),
        decoration: BoxDecoration(
          gradient:     gradient,
          color:        solidBg,
          border:       border,
          borderRadius: _radius(),
          boxShadow:    shadow,
        ),
        child: Padding(
          // رسالة صورة فقط: حشوة أصغر ليبدو الإطار نظيفاً
          padding: hasImage && !hasText
              ? const EdgeInsets.fromLTRB(5, 5, 5, 6)
              : const EdgeInsets.fromLTRB(13, 9, 13, 7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── اسم المرسل ──────────────────────────────────────────────
              if (!isMe && !groupWithPrevious) ...[
                Padding(
                  padding: hasImage && !hasText
                      ? const EdgeInsets.fromLTRB(6, 3, 6, 0)
                      : EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isAdmin) ...[
                        // أيقونة دعم داخل دائرة زرقاء: إشارة غير لونية للموظف
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: staffChip,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.support_agent_rounded,
                            size: 13,
                            color: staffAccent,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Flexible(
                        child: Text(
                          senderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w800,
                            color: isAdmin
                                ? staffAccent
                                : textColor.withOpacity(0.70),
                          ),
                        ),
                      ),
                      if (isAdmin) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: staffChip,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'الدعم',
                            style: TextStyle(
                              fontSize:   10.5,
                              fontWeight: FontWeight.w700,
                              color:      staffAccent,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 5),
              ],

              // ── الصورة ──────────────────────────────────────────────────
              if (hasImage) ...[
                _BubbleImage(
                  url:        imageUrl!,
                  width:      math.min(maxBubble - 26, 260),
                  brandColor: brandColor,
                  isMe:       isMe,
                  isDark:     isDark,
                ),
                if (hasText) const SizedBox(height: 6),
              ],

              // ── النص ────────────────────────────────────────────────────
              if (hasText)
                Text(
                  message,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize:   14.5,
                    height:     1.55,
                    color:      textColor,
                    fontWeight: FontWeight.w400,
                  ),
                ),

              // ── التوقيت + علامات القراءة ─────────────────────────────────
              if (timestamp != null) ...[
                const SizedBox(height: 3),
                Padding(
                  padding: hasImage && !hasText
                      ? const EdgeInsets.symmetric(horizontal: 8)
                      : EdgeInsets.zero,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isMe) ...[
                          Icon(
                            isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 14,
                            // مقروءة: أبيض ناصع | مُرسلة: أبيض خافت (الأزرق يضيع على البرتقالي)
                            color: isRead
                                ? Colors.white
                                : Colors.white.withOpacity(0.60),
                          ),
                          const SizedBox(width: 3),
                        ],
                        Text(
                          timestamp!,
                          style: TextStyle(
                            fontSize:   11,
                            fontWeight: FontWeight.w500,
                            color:      metaColor,
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
      ),
    );

    if (!animate) return bubble;

    return bubble
        .animate()
        .fadeIn(
      delay:    Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 260),
      curve:    Curves.easeOut,
    )
        .slideY(
      begin:    0.08,
      delay:    Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 260),
      curve:    Curves.easeOut,
    );
  }
}

// =============================================================================
//  _BubbleImage — حجم ثابت + هيكل تحميل + fade-in + إعادة المحاولة
// =============================================================================
class _BubbleImage extends StatefulWidget {
  final String url;
  final double width;
  final Color  brandColor;
  final bool   isMe;
  final bool   isDark;

  const _BubbleImage({
    required this.url,
    required this.width,
    required this.brandColor,
    required this.isMe,
    required this.isDark,
  });

  @override
  State<_BubbleImage> createState() => _BubbleImageState();
}

class _BubbleImageState extends State<_BubbleImage> {
  int _retry = 0;

  @override
  Widget build(BuildContext context) {
    final double h = widget.width * 0.78;
    final Color skeleton = widget.isMe
        ? Colors.white.withOpacity(0.14)
        : (widget.isDark
        ? Colors.white.withOpacity(0.08)
        : const Color(0xFF132341).withOpacity(0.07));

    return Semantics(
      image: true,
      label: 'صورة مرفقة، اضغط للعرض بملء الشاشة',
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            barrierColor: Colors.black,
            pageBuilder: (_, __, ___) =>
                _FullScreenImageViewer(imageUrl: widget.url),
            transitionsBuilder: (_, anim, __, child) =>
                FadeTransition(opacity: anim, child: child),
          ),
        ),
        child: Hero(
          tag: 'chat_img_${widget.url}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: widget.width,
              height: h,
              child: Image.network(
                widget.url,
                key: ValueKey('${widget.url}#$_retry'),
                fit: BoxFit.cover,
                cacheWidth: 700, // يقلّل استهلاك الذاكرة
                frameBuilder: (context, child, frame, sync) {
                  if (sync) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 250),
                    child: child,
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: skeleton,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes!
                            : null,
                        color: widget.isMe ? Colors.white70 : widget.brandColor,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, __, ___) => InkWell(
                  onTap: () => setState(() => _retry++),
                  child: Container(
                    color: skeleton,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 28,
                          color: widget.isMe ? Colors.white70 : Colors.grey,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'تعذّر التحميل، اضغط للمحاولة',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.isMe ? Colors.white70 : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  _FullScreenImageViewer — عرض كامل مع تكبير وحفظ في الاستديو
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

  void _toast(String text, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _saveImage() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _savedSuccess = false;
    });

    try {
      final response = await dio.Dio().get<List<int>>(
        widget.imageUrl,
        options: dio.Options(responseType: dio.ResponseType.bytes),
      );

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data!),
        quality: 100,
        name: 'flashpay_${DateTime.now().millisecondsSinceEpoch}',
      );

      final bool ok = result is Map ? result['isSuccess'] == true : result == true;
      if (!ok) throw Exception('save failed');

      if (mounted) setState(() => _savedSuccess = true);
      _toast('تم حفظ الصورة في الاستديو', const Color(0xFF16A34A),
          Icons.check_circle_rounded);
    } catch (e) {
      debugPrint('Save Image Error: $e');
      _toast('فشل حفظ الصورة، حاول مرة أخرى', const Color(0xFFDC2626),
          Icons.error_rounded);
    } finally {
      if (mounted) setState(() => _isSaving = false);
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
          tooltip: 'رجوع',
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
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Center(
              child: Material(
                color: _savedSuccess
                    ? const Color(0xFF16A34A)
                    : Colors.black.withOpacity(0.55),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: _savedSuccess
                        ? const Color(0xFF16A34A)
                        : Colors.white.withOpacity(0.25),
                  ),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _saveImage,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: _isSaving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
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
            tag: 'chat_img_${widget.imageUrl}',
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, p) {
                if (p == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: p.expectedTotalBytes != null
                        ? p.cumulativeBytesLoaded / p.expectedTotalBytes!
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
                      style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _transformCtrl,
        builder: (_, __) {
          final isZoomed = _transformCtrl.value != Matrix4.identity();
          if (!isZoomed) return const SizedBox.shrink();
          return FloatingActionButton.small(
            tooltip: 'إعادة الضبط',
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