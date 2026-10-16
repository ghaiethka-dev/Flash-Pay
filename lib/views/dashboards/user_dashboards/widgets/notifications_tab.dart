// =============================================================================
//  notifications_tab.dart — FlashPay
//  Target path: lib/views/dashboard/widgets/notifications_tab.dart
//
//  ✅ قائمة حقيقية مجمّعة حسب اليوم (اليوم / أمس / تاريخ)
//  ✅ غير المقروء مميَّز بنقطة وحد وخلفية خفيفة (وليس باللون وحده)
//  ✅ فلتر: الكل / غير المقروءة   |   تحديد الكل كمقروء   |   مسح الكل بتأكيد
//  ✅ سحب لحذف مع "تراجع"   |   الضغط يفتح المحادثة ويعلّم مقروءاً
//  ✅ حالتان فارغتان واضحتان   |   الوقت النسبي يتجدد تلقائياً
//  ✅ ثيم فاتح/داكن + Semantics + أهداف لمس ≥ 44px
// =============================================================================
import 'package:flashpay/controllers/notification_controller.dart';
import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/models/app_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'fp_theme.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  NotificationController _controller() => Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final c = _controller();
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      children: [
        _NotifHeader(controller: c),
        Expanded(
          child: Obx(() {
            final all = c.items;
            final list = c.unreadOnly.value
                ? all.where((n) => !n.read).toList()
                : all.toList();

            if (all.isEmpty) return _EmptyState(isDark: isDark);
            if (list.isEmpty) {
              return _AllReadState(isDark: isDark, onShowAll: () => c.unreadOnly.value = false);
            }

            // صفوف مسطّحة: عنوان يوم (String) أو إشعار (AppNotification)
            final rows = <Object>[];
            String? lastDay;
            for (final n in list) {
              final label = _dayLabel(n.receivedAt);
              if (label != lastDay) {
                rows.add(label);
                lastDay = label;
              }
              rows.add(n);
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: rows.length,
              itemBuilder: (context, i) {
                final row = rows[i];
                final Widget w = row is String
                    ? _DayLabel(text: row, isDark: isDark)
                    : _NotificationTile(
                  key: ValueKey((row as AppNotification).id),
                  n: row,
                  controller: c,
                  isDark: isDark,
                );
                return i < 6 ? w.fpEntrance(context, i) : w;
              },
            );
          }),
        ),
      ],
    );
  }
}

// ─── أدوات الوقت ──────────────────────────────────────────────────────────────
String _two(int v) => v.toString().padLeft(2, '0');

String _dayLabel(DateTime t) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return 'اليوم';
  if (diff == 1) return 'أمس';
  return '${t.day}/${t.month}/${t.year}';
}

String _ago(DateTime t, DateTime now) {
  final d = now.difference(t);
  if (d.inSeconds < 60) return 'الآن';
  if (d.inMinutes < 60) {
    final m = d.inMinutes;
    if (m == 1) return 'منذ دقيقة';
    if (m == 2) return 'منذ دقيقتين';
    return m <= 10 ? 'منذ $m دقائق' : 'منذ $m دقيقة';
  }
  if (d.inHours < 24) {
    final h = d.inHours;
    if (h == 1) return 'منذ ساعة';
    if (h == 2) return 'منذ ساعتين';
    return h <= 10 ? 'منذ $h ساعات' : 'منذ $h ساعة';
  }
  return '${_two(t.hour)}:${_two(t.minute)}';
}

String _unreadText(int n) {
  if (n == 1) return 'إشعار واحد غير مقروء';
  if (n == 2) return 'إشعاران غير مقروءان';
  return n <= 10 ? '$n إشعارات غير مقروءة' : '$n إشعاراً غير مقروء';
}

// =============================================================================
//  الهيدر: عنوان + إجراءات + فلاتر
// =============================================================================
class _NotifHeader extends StatelessWidget {
  final NotificationController controller;
  const _NotifHeader({required this.controller});

  Future<void> _confirmClear(BuildContext context) async {
    final bool? ok = await Get.dialog<bool>(
      Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('مسح كل الإشعارات؟',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
          content: const Text('سيتم حذف جميع الإشعارات من هذا الجهاز ولا يمكن التراجع.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
              child: const Text('مسح الكل',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
    if (ok == true) controller.clearAll();
  }

  @override
  Widget build(BuildContext context) {
    final double top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 16),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الإشعارات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Obx(() {
                      final u = controller.unread.value;
                      final empty = controller.items.isEmpty;
                      return Text(
                        u > 0
                            ? _unreadText(u)
                            : (empty ? 'ستظهر هنا أحدث التنبيهات' : 'أنت على اطلاع بكل شيء'),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() => _GlassIconButton(
                icon: Icons.done_all_rounded,
                tooltip: 'تحديد الكل كمقروء',
                enabled: controller.unread.value > 0,
                onTap: controller.markAllRead,
              )),
              const SizedBox(width: 8),
              Obx(() => _GlassIconButton(
                icon: Icons.delete_sweep_rounded,
                tooltip: 'مسح كل الإشعارات',
                enabled: controller.items.isNotEmpty,
                onTap: () => _confirmClear(context),
              )),
            ],
          ),
          const SizedBox(height: 14),
          Obx(() => Row(
            children: [
              _FilterChip(
                label: 'الكل',
                selected: !controller.unreadOnly.value,
                onTap: () => controller.unreadOnly.value = false,
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: controller.unread.value > 0
                    ? 'غير المقروءة (${controller.unread.value})'
                    : 'غير المقروءة',
                selected: controller.unreadOnly.value,
                onTap: () => controller.unreadOnly.value = true,
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: enabled ? 1 : 0.4,
          child: Material(
            color: Colors.white.withOpacity(0.16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.22)),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onTap: enabled ? onTap : null,
              child: SizedBox(
                width: 46,
                height: 46,
                child: Icon(icon, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.28),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? FPColors.primary : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  عنوان اليوم
// =============================================================================
class _DayLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  const _DayLabel({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.white60 : FPColors.textMid,
        ),
      ),
    );
  }
}

// =============================================================================
//  بطاقة إشعار (قابلة للسحب للحذف)
// =============================================================================
class _NotificationTile extends StatelessWidget {
  final AppNotification n;
  final NotificationController controller;
  final bool isDark;

  const _NotificationTile({
    Key? key,
    required this.n,
    required this.controller,
    required this.isDark,
  }) : super(key: key);

  void _onDismissed(BuildContext context) {
    final removed = n;
    controller.remove(n.id);
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('تم حذف الإشعار'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () => controller.restore(removed),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = n.color;
    final bool unread = !n.read;
    final Color base = context.theme.cardColor;

    final Color bg = unread
        ? Color.alphaBlend(accent.withOpacity(isDark ? 0.14 : 0.07), base)
        : base;
    final Color border = unread
        ? accent.withOpacity(0.32)
        : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05));
    final Color titleColor = isDark ? Colors.white : FPColors.textDark;
    final Color bodyColor = isDark ? Colors.white70 : FPColors.textMid;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: ValueKey('dismiss_${n.id}'),
        direction: DismissDirection.horizontal,
        background: const _SwipeBg(alignStart: true),
        secondaryBackground: const _SwipeBg(alignStart: false),
        onDismissed: (_) => _onDismissed(context),
        child: Semantics(
          button: n.isActionable,
          label: '${unread ? 'غير مقروء. ' : ''}${n.title}. ${n.body}',
          child: Material(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => controller.open(n),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border, width: unread ? 1.2 : 1),
                  boxShadow: isDark ? const [] : FPShadows.card,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أيقونة النوع
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(isDark ? 0.20 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(n.icon, color: accent, size: 22),
                    ),
                    const SizedBox(width: 12),

                    // المحتوى
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: unread ? FontWeight.w800 : FontWeight.w600,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              if (unread) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 9,
                                  height: 9,
                                  decoration: BoxDecoration(
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (n.body.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              n.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.45,
                                color: bodyColor,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded,
                                  size: 13,
                                  color: isDark ? Colors.white38 : Colors.black38),
                              const SizedBox(width: 4),
                              // يُعاد بناؤه كل دقيقة عبر controller.now
                              Obx(() => Text(
                                _ago(n.receivedAt, controller.now.value),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                              )),
                              const Spacer(),
                              if (n.isActionable)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'فتح المحادثة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: accent,
                                      ),
                                    ),
                                    Icon(Icons.chevron_left_rounded, size: 18, color: accent),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBg extends StatelessWidget {
  final bool alignStart;
  const _SwipeBg({required this.alignStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      alignment: alignStart ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 26),
    );
  }
}

// =============================================================================
//  حالات فارغة
// =============================================================================
class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      isDark: isDark,
      icon: Icons.notifications_none_rounded,
      title: 'لا توجد إشعارات',
      subtitle: 'ستظهر هنا أحدث التنبيهات والتحديثات عن حوالاتك ومحادثاتك',
    );
  }
}

class _AllReadState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onShowAll;
  const _AllReadState({required this.isDark, required this.onShowAll});

  @override
  Widget build(BuildContext context) {
    return _CenteredMessage(
      isDark: isDark,
      icon: Icons.done_all_rounded,
      title: 'كل إشعاراتك مقروءة',
      subtitle: 'لا توجد إشعارات جديدة بانتظارك',
      action: TextButton(
        onPressed: onShowAll,
        child: const Text('عرض كل الإشعارات',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const _CenteredMessage({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: FPColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 56, color: FPColors.primary),
            ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : FPColors.textDark,
              ),
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : FPColors.textMid,
              ),
            ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            if (action != null) ...[
              const SizedBox(height: 10),
              action!.animate().fadeIn(delay: 330.ms, duration: 400.ms),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}