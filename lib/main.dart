import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const CampusApp());
}

// ═════════════════════════ THEME ═════════════════════════
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

const kPri = Color(0xFF4F46E5);
const kPri2 = Color(0xFF7C3AED);
const kDeep = Color(0xFF1E1B4B);

class Pal {
  final bool dark;
  const Pal(this.dark);
  static Pal of(BuildContext c) => Pal(Theme.of(c).brightness == Brightness.dark);
  Color get bg => dark ? const Color(0xFF0C0E1A) : const Color(0xFFF5F6FA);
  Color get card => dark ? const Color(0xFF161A2B) : Colors.white;
  Color get text => dark ? const Color(0xFFF1F3FA) : const Color(0xFF14172B);
  Color get sub => dark ? const Color(0xFF9AA1BC) : const Color(0xFF6B7194);
  Color get line => dark ? const Color(0xFF2A3050) : const Color(0xFFE2E5F3);
  Color get soft => dark ? const Color(0xFF1F2445) : const Color(0xFFEEF0FF);
}

ThemeData buildTheme(bool dark) => ThemeData(
  useMaterial3: true,
  brightness: dark ? Brightness.dark : Brightness.light,
  colorScheme: ColorScheme.fromSeed(
      seedColor: kPri, brightness: dark ? Brightness.dark : Brightness.light),
  scaffoldBackgroundColor: Pal(dark).bg,
);

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeMode,
    builder: (_, m, __) => MaterialApp(
      title: 'AVIT Connect',
      debugShowCheckedModeBanner: false,
      themeMode: m,
      theme: buildTheme(false),
      darkTheme: buildTheme(true),
      home: const Shell(),
    ),
  );
}

// ═════════════════════════ DATA ═════════════════════════
const kName = 'Suguna';
const kCollege = 'AVIT';
const kId = 'AVIT2024-1082';
const kProgram = 'B.Sc. Computer Science • Year 2 • AVIT';

// Photos load from the internet. If offline / blocked, the generated artwork is shown instead.
String _u(String id) => 'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=900&q=70';
final kImgCampus = _u('1541339907198-e08756dedf3f');
final kImgGrad = _u('1523050854058-8df90110c9f1');
final kImgClass = _u('1524178232363-1fb2b075b655');
final kImgLibrary = _u('1562774053-701939374585');

const kGrads = <List<Color>>[
  [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  [Color(0xFF0EA5E9), Color(0xFF2563EB)],
  [Color(0xFF10B981), Color(0xFF0D9488)],
  [Color(0xFFF97316), Color(0xFFE11D48)],
  [Color(0xFFEC4899), Color(0xFF8B5CF6)],
];

class Slot {
  final int day;
  final String name, code, room, start, end, who;
  final Color color;
  const Slot(this.day, this.name, this.code, this.room, this.start, this.end, this.who, this.color);
}

class Ev {
  final String title, date, venue, cat, going, img;
  final IconData icon;
  const Ev(this.title, this.date, this.venue, this.cat, this.going, this.icon, this.img);
}

class Svc {
  final String name, sub, info;
  final IconData icon;
  final Color color;
  const Svc(this.name, this.sub, this.icon, this.color, this.info);
}

const classes = <Slot>[
  Slot(0, 'Data Structures', 'CS201', 'Lab 3', '09:00', '11:00', 'Dr. Lim', Color(0xFF4F46E5)),
  Slot(0, 'Discrete Math', 'MA210', 'Hall B', '13:00', '15:00', 'Prof. Kumar', Color(0xFFF59E0B)),
  Slot(1, 'Database Systems', 'CS230', 'Room 12', '10:00', '12:00', 'Dr. Aminah', Color(0xFF10B981)),
  Slot(1, 'Web Development', 'CS245', 'Lab 1', '14:00', '16:00', 'Mr. Tan', Color(0xFFEC4899)),
  Slot(2, 'Data Structures', 'CS201', 'Hall A', '09:00', '10:30', 'Dr. Lim', Color(0xFF4F46E5)),
  Slot(2, 'Technical English', 'EN101', 'Room 5', '11:00', '12:30', 'Ms. Sofia', Color(0xFF06B6D4)),
  Slot(3, 'Database Systems', 'CS230', 'Lab 2', '09:00', '11:00', 'Dr. Aminah', Color(0xFF10B981)),
  Slot(3, 'Discrete Math', 'MA210', 'Hall B', '14:00', '15:30', 'Prof. Kumar', Color(0xFFF59E0B)),
  Slot(4, 'Web Development', 'CS245', 'Lab 1', '09:00', '11:00', 'Mr. Tan', Color(0xFFEC4899)),
  Slot(4, 'Student Seminar', 'GE300', 'Auditorium', '13:00', '14:00', 'Faculty', Color(0xFF8B5CF6)),
];

final events = <Ev>[
  Ev('Annual Tech Fest 2026', '12 Oct • 9:00 AM', 'Main Auditorium', 'Tech', '248 going', Icons.memory, _u('1518770660439-4636190af475')),
  Ev('Global Career Fair', '18 Oct • 10:00 AM', 'Sports Complex', 'Career', '412 going', Icons.work_outline, _u('1521737604893-d14cc237f11d')),
  Ev('Inter-Faculty Football', '21 Oct • 4:30 PM', 'Main Field', 'Sports', '176 going', Icons.sports_soccer, _u('1461896836934-ffe607ba8211')),
  Ev('International Cultural Night', '25 Oct • 7:00 PM', 'Open Air Theatre', 'Culture', '530 going', Icons.music_note, _u('1514525253161-7a46d19cd819')),
  Ev('Wellness Workshop', '30 Oct • 2:00 PM', 'Student Centre', 'Wellness', '64 going', Icons.self_improvement, _u('1506126613408-eca07ce68773')),
];

const services = <Svc>[
  Svc('Library', 'Books & study rooms', Icons.local_library_rounded, Color(0xFF4F46E5), 'Open 8:00 AM – 10:00 PM. Silent floors, group rooms and 24/7 e-resources. You have 2 books due in 3 days.'),
  Svc('Canteen', 'Today\'s menu', Icons.restaurant_rounded, Color(0xFFF59E0B), 'Today: Nasi Lemak, Pasta, Veg Curry and fresh juices. Open until 8:00 PM.'),
  Svc('Transport', 'Campus shuttle', Icons.directions_bus_rounded, Color(0xFF10B981), 'Campus shuttle runs every 15 minutes. Next bus at 10:25 AM from Gate A.'),
  Svc('Results', 'Grades & GPA', Icons.assignment_rounded, Color(0xFFEC4899), 'Semester 3 GPA: 3.62. Cumulative CGPA: 3.55. Transcripts can be requested at the Admin Block.'),
  Svc('Fees', 'Payments', Icons.account_balance_wallet_rounded, Color(0xFF06B6D4), 'No outstanding balance. Next payment due 5 January.'),
  Svc('Hostel', 'Room & requests', Icons.apartment_rounded, Color(0xFF8B5CF6), 'Block C, Room 214. Laundry on level 2. No open maintenance requests.'),
  Svc('Sports', 'Gym & courts', Icons.sports_basketball_rounded, Color(0xFFEF4444), 'Gym, pool, football field and courts. Book a slot from 6:00 AM to 10:00 PM.'),
  Svc('Helpdesk', 'Get support', Icons.support_agent_rounded, Color(0xFF64748B), 'Email help@avit.edu, visit Admin Block Level 1 (9:00 AM – 5:00 PM), or send a request from the Request tab.'),
];

const notices = <List<String>>[
  ['Mid-semester exam timetable is now published', 'Exams', '2h ago'],
  ['Library extended hours during exam week', 'Library', 'Yesterday'],
  ['Scholarship applications close this Friday', 'Finance', '2 days ago'],
];

int todayIdx() {
  final d = DateTime.now().weekday - 1;
  return d > 4 ? 0 : d;
}

// ═════════════════════════ VISUAL EFFECT WIDGETS ═════════════════════════

/// Frosted-glass panel: blurs whatever is behind it + translucent gradient + light border.
class Glass extends StatelessWidget {
  final Widget child;
  final double radius, blur, opacity;
  final double? width, height;
  final EdgeInsetsGeometry? padding;
  final Color? tint, border;
  final bool shadow;
  const Glass({
    super.key,
    required this.child,
    this.radius = 22,
    this.blur = 18,
    this.opacity = .16,
    this.width,
    this.height,
    this.padding,
    this.tint,
    this.border,
    this.shadow = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = tint ?? Colors.white;
    final r = BorderRadius.circular(radius);
    final panel = ClipRRect(
      borderRadius: r,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: r,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base.withOpacity(math.min(1.0, opacity + .10)), base.withOpacity(opacity)],
            ),
            border: Border.all(color: border ?? Colors.white.withOpacity(.30), width: 1.1),
          ),
          child: child,
        ),
      ),
    );
    if (!shadow) return panel;
    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: const [BoxShadow(color: Color(0x1F1E1B4B), blurRadius: 24, offset: Offset(0, 10))],
      ),
      child: panel,
    );
  }
}

/// Standard content card, glass style (replaces the old flat card).
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const GlassCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 20});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Glass(
      radius: radius,
      blur: 16,
      tint: p.card,
      opacity: p.dark ? .52 : .66,
      border: p.line.withOpacity(.7),
      shadow: !p.dark,
      padding: padding,
      child: child,
    );
  }
}

/// Slowly drifting colour blobs behind everything, so the glass has something to blur.
class Aurora extends StatefulWidget {
  const Aurora({super.key});
  @override
  State<Aurora> createState() => _AuroraState();
}

class _AuroraState extends State<Aurora> with SingleTickerProviderStateMixin {
  late final AnimationController c =
  AnimationController(vsync: this, duration: const Duration(seconds: 22))..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  Widget blob(double size, Color col, double a) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [col.withOpacity(a), col.withOpacity(0)]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final a = p.dark ? .38 : .30;
    return RepaintBoundary(
      child: LayoutBuilder(builder: (_, b) {
        final w = b.maxWidth, h = b.maxHeight;
        return AnimatedBuilder(
          animation: c,
          builder: (_, __) {
            final t = c.value * 2 * math.pi;
            return Container(
              color: p.bg,
              child: Stack(children: [
                Positioned(
                    left: w * .45 + math.sin(t) * w * .25 - 220,
                    top: h * .10 + math.cos(t) * 60 - 220,
                    child: blob(440, kPri, a)),
                Positioned(
                    left: -140 + math.cos(t) * 50,
                    top: h * .48 + math.sin(t) * 80,
                    child: blob(380, const Color(0xFFEC4899), a * .8)),
                Positioned(
                    right: -150 + math.sin(t) * 60,
                    top: h * .72 - math.cos(t) * 70,
                    child: blob(400, const Color(0xFF06B6D4), a * .8)),
              ]),
            );
          },
        );
      }),
    );
  }
}

/// Network photo with graceful fallback to generated artwork.
class NetImage extends StatelessWidget {
  final String url;
  final List<Color> fallback;
  final int seed;
  const NetImage(this.url, this.fallback, this.seed, {super.key});
  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    loadingBuilder: (_, child, prog) => prog == null ? child : Art(colors: fallback, seed: seed, radius: 0),
    errorBuilder: (_, __, ___) => Art(colors: fallback, seed: seed, radius: 0),
  );
}

/// Photo header with a deep-blue colour wash so white text stays readable.
class PhotoBackdrop extends StatelessWidget {
  final String url;
  final int seed;
  final double radius;
  final Widget child;
  const PhotoBackdrop({super.key, required this.url, required this.seed, required this.radius, required this.child});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.vertical(bottom: Radius.circular(radius)),
    child: Stack(children: [
      Positioned.fill(child: NetImage(url, const [kDeep, kPri], seed)),
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [kDeep.withOpacity(.80), kPri.withOpacity(.72)],
            ),
          ),
        ),
      ),
      child,
    ]),
  );
}

/// Event card background: photo + bottom shade + coloured glow shadow.
class EventPhoto extends StatelessWidget {
  final Ev e;
  final int i;
  final double radius;
  final Widget child;
  const EventPhoto({super.key, required this.e, required this.i, required this.child, this.radius = 26});
  @override
  Widget build(BuildContext context) {
    final g = kGrads[i % kGrads.length];
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [BoxShadow(color: g[0].withOpacity(.35), blurRadius: 24, offset: const Offset(0, 12))],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(children: [
          Positioned.fill(child: NetImage(e.img, g, i + 10)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [g[0].withOpacity(.10), Colors.black.withOpacity(.62)],
                ),
              ),
            ),
          ),
          Positioned.fill(child: child),
        ]),
      ),
    );
  }
}

/// Fade + slide-up entrance animation.
class Reveal extends StatelessWidget {
  final Widget child;
  final int index;
  const Reveal({super.key, required this.child, this.index = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 450 + index * 90),
    curve: Curves.easeOutCubic,
    builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 26 * (1 - v)), child: c)),
    child: child,
  );
}

/// Press-to-shrink tap feedback.
class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const Tap({super.key, required this.child, this.onTap});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => setState(() => down = true),
    onTapUp: (_) => setState(() => down = false),
    onTapCancel: () => setState(() => down = false),
    onTap: widget.onTap,
    child: AnimatedScale(
      scale: down ? .95 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: widget.child,
    ),
  );
}

// ═════════════════════════ SHARED WIDGETS ═════════════════════════
class _ArtPainter extends CustomPainter {
  final List<Color> colors;
  final int seed;
  _ArtPainter(this.colors, this.seed);
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)
              .createShader(rect));
    final r = math.Random(seed);
    final m = size.shortestSide;
    for (int i = 0; i < 4; i++) {
      final c = Offset(r.nextDouble() * size.width, r.nextDouble() * size.height);
      canvas.drawCircle(c, m * (.25 + r.nextDouble() * .5),
          Paint()..color = Colors.white.withOpacity(.05 + r.nextDouble() * .07));
    }
    for (int i = 0; i < 2; i++) {
      final c = Offset(size.width * (.6 + r.nextDouble() * .4), size.height * r.nextDouble());
      canvas.drawCircle(
          c,
          m * (.35 + r.nextDouble() * .3),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = Colors.white.withOpacity(.18));
    }
    final dot = Paint()..color = Colors.white.withOpacity(.22);
    for (int x = 0; x < 6; x++) {
      for (int y = 0; y < 4; y++) {
        canvas.drawCircle(Offset(size.width - 28 - x * 12.0, 22 + y * 12.0), 1.6, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) => false;
}

/// Generated artwork background (works offline, no images needed).
class Art extends StatelessWidget {
  final List<Color> colors;
  final int seed;
  final Widget? child;
  final double radius;
  const Art({super.key, required this.colors, this.seed = 1, this.child, this.radius = 24});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Stack(children: [
      Positioned.fill(child: CustomPaint(painter: _ArtPainter(colors, seed))),
      if (child != null) child!,
    ]),
  );
}

class PageHeader extends StatelessWidget {
  final String title, sub, img;
  final int seed;
  final Widget? extra;
  const PageHeader(this.title, this.sub, this.img, {super.key, this.seed = 2, this.extra});
  @override
  Widget build(BuildContext context) => PhotoBackdrop(
    url: img,
    seed: seed,
    radius: 32,
    child: SizedBox(
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.5)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            if (extra != null) ...[const SizedBox(height: 16), extra!],
          ]),
        ),
      ),
    ),
  );
}

class Avatar extends StatelessWidget {
  final double size;
  const Avatar(this.size, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(colors: [Color(0xFF22D3EE), kPri2]),
      border: Border.all(color: Colors.white.withOpacity(.7), width: 2),
      boxShadow: [BoxShadow(color: kPri2.withOpacity(.55), blurRadius: size * .4)],
    ),
    child: Text(kName[0],
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: size * .34)),
  );
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;
  final bool onDark;
  const Pill(this.text, this.color, {super.key, this.icon, this.onDark = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: onDark ? Colors.white.withOpacity(.2) : color.withOpacity(.12),
      borderRadius: BorderRadius.circular(20),
      border: onDark ? Border.all(color: Colors.white.withOpacity(.3)) : null,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 14, color: onDark ? Colors.white : color), const SizedBox(width: 4)],
      Text(text,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: onDark ? Colors.white : color)),
    ]),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 28, 0, 14),
    child: Row(children: [
      Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.3))),
      if (action != null)
        GestureDetector(
            onTap: onTap,
            child: Text(action!, style: const TextStyle(color: kPri, fontWeight: FontWeight.w700))),
    ]),
  );
}

class ClassCard extends StatelessWidget {
  final Slot s;
  final int index;
  const ClassCard(this.s, this.index, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Reveal(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          child: Row(children: [
            SizedBox(
              width: 48,
              child: Column(children: [
                Text(s.start, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(s.end, style: TextStyle(color: p.sub, fontSize: 12)),
              ]),
            ),
            Container(
              width: 4,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: s.color,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [BoxShadow(color: s.color.withOpacity(.6), blurRadius: 10)],
              ),
            ),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${s.code} • ${s.who}', style: TextStyle(color: p.sub, fontSize: 13)),
                const SizedBox(height: 8),
                Pill(s.room, s.color, icon: Icons.place_outlined),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

void showService(BuildContext context, Svc s) {
  final p = Pal.of(context);
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    builder: (_) => ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          decoration: BoxDecoration(
            color: p.card.withOpacity(p.dark ? .72 : .78),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(.5))),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 44, height: 5, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 24),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: s.color.withOpacity(.16),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: s.color.withOpacity(.35)),
                boxShadow: [BoxShadow(color: s.color.withOpacity(.35), blurRadius: 28)],
              ),
              child: Icon(s.icon, color: s.color, size: 36),
            ),
            const SizedBox(height: 16),
            Text(s.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(s.info, textAlign: TextAlign.center, style: TextStyle(color: p.sub, fontSize: 15, height: 1.5)),
            const SizedBox(height: 24),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kPri,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
      ),
    ),
  );
}

// ═════════════════════════ SHELL + NAV ═════════════════════════
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int i = 0;
  static const items = [
    [Icons.home_rounded, 'Home'],
    [Icons.calendar_month_rounded, 'Schedule'],
    [Icons.edit_note_rounded, 'Request'],
    [Icons.grid_view_rounded, 'Services'],
    [Icons.person_rounded, 'Profile'],
  ];

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: Aurora()),
        IndexedStack(index: i, children: [
          HomePage(go: (n) => setState(() => i = n)),
          const SchedulePage(),
          const RequestPage(),
          const ServicesPage(),
          const ProfilePage(),
        ]),
      ]),
      bottomNavigationBar: MediaQuery.of(context).viewInsets.bottom > 0 ? null : SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Glass(
            radius: 28,
            blur: 26,
            height: 68,
            opacity: p.dark ? .10 : .55,
            border: p.dark ? Colors.white.withOpacity(.16) : Colors.white.withOpacity(.85),
            shadow: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              for (int n = 0; n < items.length; n++)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => i = n),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    padding: EdgeInsets.symmetric(horizontal: i == n ? 16 : 12, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: i == n ? const LinearGradient(colors: [kPri, kPri2]) : null,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: i == n ? [BoxShadow(color: kPri.withOpacity(.5), blurRadius: 16, offset: const Offset(0, 6))] : null,
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(items[n][0] as IconData, size: 22, color: i == n ? Colors.white : p.sub),
                      if (i == n) ...[
                        const SizedBox(width: 8),
                        Text(items[n][1] as String,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                    ]),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════ HOME ═════════════════════════
class _RingPainter extends CustomPainter {
  final double v;
  final Color color, track;
  _RingPainter(this.v, this.color, this.track);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 7;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawCircle(c, r, paint);
    paint.color = color;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, 2 * math.pi * v, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter o) => o.v != v;
}

class HomePage extends StatelessWidget {
  final void Function(int) go;
  const HomePage({super.key, required this.go});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final hr = DateTime.now().hour;
    final greet = hr < 12 ? 'Good morning' : hr < 18 ? 'Good afternoon' : 'Good evening';
    final today = classes.where((c) => c.day == todayIdx()).toList();
    final next = today.isNotEmpty ? today.first : classes.first;

    return ListView(padding: EdgeInsets.zero, children: [
      // ── Header (photo + glass) ──
      PhotoBackdrop(
        url: kImgCampus,
        seed: 7,
        radius: 34,
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Avatar(48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('$greet • $kCollege', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      const Text(kName,
                          style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  Glass(
                    radius: 22,
                    width: 44,
                    height: 44,
                    opacity: .18,
                    child: Stack(alignment: Alignment.center, children: [
                      const Icon(Icons.notifications_none_rounded, color: Colors.white),
                      Positioned(
                        top: 10,
                        right: 11,
                        child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                                color: const Color(0xFFFB7185),
                                shape: BoxShape.circle,
                                border: Border.all(color: kPri, width: 1.5))),
                      ),
                    ]),
                  ),
                ]),
                const SizedBox(height: 20),
                Tap(
                  onTap: () => go(3),
                  child: Glass(
                    radius: 16,
                    height: 50,
                    opacity: .16,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(children: [
                      Icon(Icons.search_rounded, color: Colors.white70),
                      SizedBox(width: 10),
                      Text('Search classes, events, services',
                          style: TextStyle(color: Colors.white70, fontSize: 14)),
                    ]),
                  ),
                ),
                const SizedBox(height: 22),
                Tap(
                  onTap: () => go(1),
                  child: Glass(
                    radius: 22,
                    blur: 22,
                    opacity: .16,
                    padding: const EdgeInsets.all(18),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Pill('NEXT CLASS', Colors.white, onDark: true),
                          const SizedBox(height: 10),
                          Text(next.name,
                              style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 4),
                          Text('${next.start} – ${next.end}  •  ${next.room}  •  ${next.who}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.white.withOpacity(.5), blurRadius: 14)],
                        ),
                        child: const Icon(Icons.arrow_forward_rounded, color: kPri),
                      ),
                    ]),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Quick actions (glass tiles) ──
          const SectionTitle('Quick access'),
          Reveal(
            index: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (final a in [
                [Icons.calendar_month_rounded, 'Timetable', const Color(0xFF4F46E5), 1],
                [Icons.edit_note_rounded, 'Request', const Color(0xFFEC4899), 2],
                [Icons.local_library_rounded, 'Library', const Color(0xFF10B981), 0],
                [Icons.assignment_rounded, 'Results', const Color(0xFFF59E0B), 3],
              ])
                Tap(
                  onTap: () {
                    final t = a[3] as int;
                    if (a[1] == 'Library') {
                      showService(context, services[0]);
                    } else if (a[1] == 'Results') {
                      showService(context, services[3]);
                    } else {
                      go(t);
                    }
                  },
                  child: Column(children: [
                    Glass(
                      radius: 22,
                      width: 66,
                      height: 66,
                      tint: a[2] as Color,
                      opacity: .20,
                      border: (a[2] as Color).withOpacity(.35),
                      child: Icon(a[0] as IconData, color: a[2] as Color, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(a[1] as String,
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.sub)),
                  ]),
                ),
            ]),
          ),

          // ── Academic overview ──
          const SectionTitle('Academic overview'),
          Reveal(
            index: 1,
            child: GlassCard(
              radius: 22,
              padding: const EdgeInsets.all(20),
              child: Row(children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: .92),
                    duration: const Duration(milliseconds: 1400),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, __) => Stack(alignment: Alignment.center, children: [
                      CustomPaint(size: const Size(100, 100), painter: _RingPainter(v, kPri, p.soft)),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('${(v * 100).round()}%', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        Text('Attendance', style: TextStyle(fontSize: 10.5, color: p.sub)),
                      ]),
                    ]),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(children: [
                    _bar(p, 'CGPA', '3.55 / 4.00', .89, const Color(0xFF10B981)),
                    const SizedBox(height: 16),
                    _bar(p, 'Credits', '84 / 120', .70, const Color(0xFFF59E0B)),
                  ]),
                ),
              ]),
            ),
          ),

          // ── Today ──
          SectionTitle("Today's classes", action: 'See all', onTap: () => go(1)),
          if (today.isEmpty)
            Text('No classes today 🎉', style: TextStyle(color: p.sub))
          else
            for (int k = 0; k < today.length; k++) ClassCard(today[k], k),

          // ── Events ──
          SectionTitle('Upcoming events', action: 'View all', onTap: () => openEvents(context)),
        ]),
      ),
      SizedBox(
        height: 196,
        child: ListView.separated(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => Tap(
            onTap: () => openEvents(context),
            child: SizedBox(
              width: 262,
              child: EventPhoto(
                e: events[i],
                i: i,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Align(alignment: Alignment.centerLeft, child: Pill(events[i].cat, Colors.white, onDark: true)),
                    const Spacer(),
                    Glass(
                      radius: 16,
                      blur: 14,
                      tint: Colors.black,
                      opacity: .26,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(events[i].title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 2),
                        Text(events[i].date, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),

      // ── Notices ──
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Announcements'),
          for (int k = 0; k < notices.length; k++)
            Reveal(
              index: k,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GlassCard(
                  child: Row(children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: p.soft, borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.campaign_rounded, color: kPri),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(notices[k][0], style: const TextStyle(fontWeight: FontWeight.w700, height: 1.3)),
                        const SizedBox(height: 4),
                        Text('${notices[k][1]} • ${notices[k][2]}', style: TextStyle(color: p.sub, fontSize: 12.5)),
                      ]),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    ]);
  }

  Widget _bar(Pal p, String label, String value, double v, Color c) => Column(children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(color: p.sub, fontWeight: FontWeight.w600, fontSize: 13)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
    ]),
    const SizedBox(height: 8),
    ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: v),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (_, val, __) =>
            LinearProgressIndicator(value: val, minHeight: 8, color: c, backgroundColor: c.withOpacity(.14)),
      ),
    ),
  ]);
}

// ═════════════════════════ SCHEDULE ═════════════════════════
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});
  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int day = todayIdx();
  static const names = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
  static const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final now = DateTime.now();
    final mon = now.subtract(Duration(days: now.weekday - 1));
    final list = classes.where((c) => c.day == day).toList();
    return Column(children: [
      PageHeader('Schedule', '${months[now.month - 1]} ${now.year}', kImgClass, seed: 4),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
        child: Row(
          children: List.generate(5, (i) {
            final sel = i == day;
            final d = mon.add(Duration(days: i));
            return Expanded(
              child: Tap(
                onTap: () => setState(() => day = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: sel ? const LinearGradient(colors: [kPri, kPri2]) : null,
                    color: sel ? null : p.card.withOpacity(p.dark ? .5 : .7),
                    borderRadius: BorderRadius.circular(18),
                    border: sel ? null : Border.all(color: p.line),
                    boxShadow: sel ? [BoxShadow(color: kPri.withOpacity(.45), blurRadius: 16, offset: const Offset(0, 6))] : null,
                  ),
                  child: Column(children: [
                    Text(names[i],
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: sel ? Colors.white70 : p.sub)),
                    const SizedBox(height: 6),
                    Text('${d.day}',
                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: sel ? Colors.white : p.text)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: ListView(
            key: ValueKey(day),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            children: list.isEmpty
                ? [Padding(padding: const EdgeInsets.only(top: 60), child: Center(child: Text('No classes 🎉', style: TextStyle(color: p.sub, fontSize: 16))))]
                : [for (int k = 0; k < list.length; k++) ClassCard(list[k], k)],
          ),
        ),
      ),
    ]);
  }
}

// ═════════════════════════ EVENTS ═════════════════════════
class EventsPage extends StatefulWidget {
  const EventsPage({super.key});
  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  final Set<int> going = {};
  String filter = 'All';

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final cats = ['All', ...{for (final e in events) e.cat}];
    return Column(children: [
      PageHeader('Events', 'Discover what\'s happening at AVIT', kImgGrad, seed: 9),
      SizedBox(
        height: 66,
        child: ListView.separated(
          padding: const EdgeInsets.all(14),
          scrollDirection: Axis.horizontal,
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final sel = filter == cats[i];
            return Tap(
              onTap: () => setState(() => filter = cats[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? kPri : p.card.withOpacity(p.dark ? .5 : .7),
                  borderRadius: BorderRadius.circular(30),
                  border: sel ? null : Border.all(color: p.line),
                  boxShadow: sel ? [BoxShadow(color: kPri.withOpacity(.4), blurRadius: 14, offset: const Offset(0, 5))] : null,
                ),
                child: Text(cats[i], style: TextStyle(fontWeight: FontWeight.w700, color: sel ? Colors.white : p.sub)),
              ),
            );
          },
        ),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 120), children: [
          for (int i = 0; i < events.length; i++)
            if (filter == 'All' || events[i].cat == filter)
              Reveal(
                index: i,
                child: Container(
                  height: 252,
                  margin: const EdgeInsets.only(bottom: 18),
                  child: EventPhoto(
                    e: events[i],
                    i: i,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Row(children: [
                          Pill(events[i].cat, Colors.white, onDark: true),
                          const Spacer(),
                          Glass(
                            radius: 20,
                            width: 40,
                            height: 40,
                            opacity: .2,
                            child: Icon(events[i].icon, color: Colors.white, size: 20),
                          ),
                        ]),
                        const Spacer(),
                        Glass(
                          radius: 20,
                          blur: 16,
                          tint: Colors.black,
                          opacity: .28,
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(events[i].title,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -.3)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.schedule_rounded, color: Colors.white70, size: 15),
                              const SizedBox(width: 5),
                              Text(events[i].date, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
                              const SizedBox(width: 12),
                              const Icon(Icons.place_outlined, color: Colors.white70, size: 15),
                              const SizedBox(width: 4),
                              Expanded(child: Text(events[i].venue, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 12.5))),
                            ]),
                            const SizedBox(height: 10),
                            Row(children: [
                              Text(events[i].going, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Tap(
                                onTap: () {
                                  setState(() => going.contains(i) ? going.remove(i) : going.add(i));
                                  if (going.contains(i)) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text('Registered for ${events[i].title}'),
                                    ));
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: going.contains(i) ? const Color(0xFF22C55E) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(going.contains(i) ? '✓ Going' : 'Register',
                                      style: TextStyle(fontWeight: FontWeight.w800, color: going.contains(i) ? Colors.white : kPri)),
                                ),
                              ),
                            ]),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
        ]),
      ),
    ]);
  }
}

// ═════════════════════════ SERVICES ═════════════════════════
class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});
  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final list = services.where((s) => s.name.toLowerCase().contains(q.toLowerCase())).toList();
    return Column(children: [
      PageHeader(
        'Services',
        'Everything you need, one tap away',
        kImgLibrary,
        seed: 15,
        extra: Glass(
          radius: 16,
          height: 48,
          opacity: .16,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Icon(Icons.search_rounded, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => q = v),
                cursorColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search services',
                  hintStyle: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ]),
        ),
      ),
      Expanded(
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.08),
          itemBuilder: (_, i) {
            final s = list[i];
            return Reveal(
              index: i,
              child: Tap(
                onTap: () => showService(context, s),
                child: GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: s.color.withOpacity(.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: s.color.withOpacity(.3)),
                        boxShadow: [BoxShadow(color: s.color.withOpacity(.28), blurRadius: 16)],
                      ),
                      child: Icon(s.icon, color: s.color, size: 26),
                    ),
                    const Spacer(),
                    Text(s.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(s.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.sub, fontSize: 12.5)),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

// ═════════════════════════ PROFILE ═════════════════════════
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _stat(Pal p, String v, String l) => Expanded(
    child: GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(children: [
        Text(v, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(l, style: TextStyle(color: p.sub, fontSize: 12.5)),
      ]),
    ),
  );

  Widget _tile(Pal p, IconData i, Color c, String t, Widget trailing) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: c.withOpacity(.13), borderRadius: BorderRadius.circular(12)),
        child: Icon(i, color: c, size: 21),
      ),
      const SizedBox(width: 14),
      Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
      trailing,
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return ListView(padding: EdgeInsets.zero, children: [
      PhotoBackdrop(
        url: kImgGrad,
        seed: 21,
        radius: 32,
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(children: [
                const Avatar(92),
                const SizedBox(height: 14),
                const Text(kName, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(kProgram, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Pill(kId, Colors.white, icon: Icons.badge_outlined, onDark: true),
              ]),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(children: [
          Reveal(
            child: Row(children: [
              _stat(p, '3.55', 'CGPA'),
              const SizedBox(width: 12),
              _stat(p, '92%', 'Attendance'),
              const SizedBox(width: 12),
              _stat(p, '84', 'Credits'),
            ]),
          ),
          const SizedBox(height: 20),
          Reveal(
            index: 2,
            child: GlassCard(
              padding: EdgeInsets.zero,
              radius: 22,
              child: Column(children: [
                _tile(p, Icons.person_outline_rounded, const Color(0xFF4F46E5), 'Edit profile',
                    Icon(Icons.chevron_right_rounded, color: p.sub)),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.notifications_none_rounded, const Color(0xFFF59E0B), 'Notifications',
                    Icon(Icons.chevron_right_rounded, color: p.sub)),
                Divider(height: 1, color: p.line),
                _tile(
                  p,
                  Icons.dark_mode_outlined,
                  const Color(0xFF8B5CF6),
                  'Dark mode',
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeMode,
                    builder: (_, m, __) => Switch(
                      value: m == ThemeMode.dark,
                      activeColor: kPri,
                      onChanged: (v) => themeMode.value = v ? ThemeMode.dark : ThemeMode.light,
                    ),
                  ),
                ),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.language_rounded, const Color(0xFF06B6D4), 'Language',
                    Text('English', style: TextStyle(color: p.sub, fontWeight: FontWeight.w600))),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.help_outline_rounded, const Color(0xFF10B981), 'Help & support',
                    Icon(Icons.chevron_right_rounded, color: p.sub)),
              ]),
            ),
          ),
        ]),
      ),
    ]);
  }
}

// ═════════════════════════ EVENTS (opened as its own screen) ═════════════════════════
void openEvents(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsScreen()));

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: Aurora()),
        const EventsPage(),
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Tap(
                onTap: () => Navigator.of(context).pop(),
                child: const Glass(
                  radius: 22,
                  width: 44,
                  height: 44,
                  opacity: .22,
                  child: Icon(Icons.close_rounded, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ═════════════════════════ SERVICE REQUEST FORM ═════════════════════════
// Colour system: primary kPri, accent kPri2, field fill = Pal.soft, error / success below.
const kError = Color(0xFFE11D48);
const kSuccess = Color(0xFF16A34A);
const kDomain = '@avit.edu'; // campus email domain
const kAuto = AutovalidateMode.onUserInteraction; // errors appear once the user interacts

const kCategories = <String>[
  'Library Services',
  'Hostel & Accommodation',
  'IT & Wi-Fi Support',
  'Fees & Scholarship',
  'Transport',
  'Exams & Results',
  'Counselling & Wellbeing',
];
const kUrgency = <String>['Low', 'Normal', 'High', 'Urgent'];
const kContact = <String>['Email', 'Phone call', 'WhatsApp', 'In person'];

// ADVANCED #1: extra field that only appears for some categories -> [label, hint]
const kExtra = <String, List<String>>{
  'Library Services': ['Book title or ID', 'e.g. Operating Systems, 3rd edition'],
  'Hostel & Accommodation': ['Block and room number', 'e.g. Block C, Room 214'],
  'IT & Wi-Fi Support': ['Device or location', 'e.g. Lab 2, PC 14'],
  'Transport': ['Route or bus stop', 'e.g. Gate A shuttle'],
};

const kMonthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String fmtDate(DateTime d) => '${d.day} ${kMonthsShort[d.month - 1]} ${d.year}';

/// One consistent input style for every field (borders, focus colour, error style, icons).
InputDecoration campusDecoration(Pal p, {required String label, String? hint, IconData? icon}) {
  OutlineInputBorder border(Color c, [double w = 1.2]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: kPri),
    filled: true,
    fillColor: p.soft,
    labelStyle: TextStyle(color: p.sub, fontSize: 15),
    hintStyle: TextStyle(color: p.sub.withOpacity(.7)),
    errorMaxLines: 2,
    errorStyle: const TextStyle(color: kError, fontWeight: FontWeight.w600, fontSize: 12.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(p.line),
    enabledBorder: border(p.line),
    focusedBorder: border(kPri, 2),
    errorBorder: border(kError),
    focusedErrorBorder: border(kError, 2),
  );
}

/// ADVANCED #3: reusable text field. Every text input in the form is built from this widget.
class CampusTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final String? Function(String?) validator;
  final FormFieldSetter<String>? onSaved;
  final TextInputType keyboard;
  final TextInputAction action;
  final TextCapitalization caps;
  final int maxLines;
  final int? maxLength; // ADVANCED #2: shows a live character counter (e.g. 120/300)
  final List<TextInputFormatter>? formatters;

  const CampusTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.validator,
    this.onSaved,
    this.hint,
    this.keyboard = TextInputType.text,
    this.action = TextInputAction.next,
    this.caps = TextCapitalization.none,
    this.maxLines = 1,
    this.maxLength,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        autovalidateMode: kAuto,
        validator: validator,
        onSaved: onSaved,
        keyboardType: keyboard,
        textInputAction: action,
        textCapitalization: caps,
        minLines: maxLines > 1 ? 4 : 1,
        maxLines: maxLines,
        maxLength: maxLength,
        inputFormatters: formatters,
        style: TextStyle(fontSize: 15.5, color: p.text),
        decoration: campusDecoration(p, label: label, hint: hint, icon: icon),
      ),
    );
  }
}

/// Single-choice chips that behave like a real form field (validator, onSaved, reset).
class ChoiceField extends FormField<String> {
  ChoiceField({
    super.key,
    required String label,
    required IconData icon,
    required List<String> options,
    super.onSaved,
    super.validator,
  }) : super(
    autovalidateMode: kAuto,
    builder: (state) {
      final p = Pal.of(state.context);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          isEmpty: false,
          decoration: campusDecoration(p, label: label, icon: icon)
              .copyWith(errorText: state.errorText, contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 12)),
          child: Wrap(spacing: 8, runSpacing: 8, children: [
            for (final o in options)
              ChoiceChip(
                label: Text(o),
                selected: state.value == o,
                showCheckmark: false,
                selectedColor: kPri,
                labelStyle: TextStyle(
                    fontWeight: FontWeight.w700, color: state.value == o ? Colors.white : p.text),
                onSelected: (_) => state.didChange(o),
              ),
          ]),
        ),
      );
    },
  );
}

/// Date picker as a form field; the date can never be earlier than today.
class DateField extends FormField<DateTime> {
  DateField({super.key, required String label, super.onSaved})
      : super(
    autovalidateMode: kAuto,
    validator: (d) {
      if (d == null) return 'Choose a preferred response date';
      final now = DateTime.now();
      if (d.isBefore(DateTime(now.year, now.month, now.day))) return 'The date cannot be in the past';
      return null;
    },
    builder: (state) {
      final p = Pal.of(state.context);
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final d = await showDatePicker(
              context: state.context,
              initialDate: state.value ?? today,
              firstDate: today, // past dates are not selectable
              lastDate: today.add(const Duration(days: 90)),
              helpText: 'Preferred response date',
            );
            if (d != null) state.didChange(d);
          },
          child: InputDecorator(
            isEmpty: state.value == null,
            decoration: campusDecoration(p, label: label, icon: Icons.event_rounded).copyWith(
              errorText: state.errorText,
              suffixIcon: Icon(Icons.arrow_drop_down_rounded, color: p.sub),
            ),
            child: Text(state.value == null ? '' : fmtDate(state.value!),
                style: TextStyle(fontSize: 15.5, color: p.text)),
          ),
        ),
      );
    },
  );
}

/// Declaration checkbox: validation fails until it is ticked.
class DeclarationField extends FormField<bool> {
  DeclarationField({super.key, required String text, super.onSaved})
      : super(
    initialValue: false,
    autovalidateMode: kAuto,
    validator: (v) => v == true ? null : 'You must accept the declaration before submitting',
    builder: (state) {
      final p = Pal.of(state.context);
      final on = state.value ?? false;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => state.didChange(!on),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(
              value: on,
              activeColor: kPri,
              side: BorderSide(color: state.hasError ? kError : p.sub, width: 2),
              onChanged: (v) => state.didChange(v ?? false),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Text(text, style: TextStyle(fontSize: 14, height: 1.4, color: p.text)),
              ),
            ),
          ]),
        ),
        if (state.hasError)
          Padding(
            padding: const EdgeInsets.only(left: 14, bottom: 8),
            child: Text(state.errorText!,
                style: const TextStyle(color: kError, fontWeight: FontWeight.w600, fontSize: 12.5)),
          ),
      ]);
    },
  );
}

/// Values collected by save() and shown in the success summary.
class ServiceRequest {
  String name = '', studentId = '', email = '', phone = '';
  String category = '', extraLabel = '', extra = '', subject = '', details = '';
  String urgency = '', contact = '';
  DateTime? date;
}

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});
  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  // The form key gives access to validate(), save() and reset() through currentState.
  final _formKey = GlobalKey<FormState>();
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _id = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _subject = TextEditingController();
  final _details = TextEditingController();
  final _extra = TextEditingController();

  String? _category; // non-Form state: must be cleared on reset too
  ServiceRequest _req = ServiceRequest();

  // Controllers must be disposed when the State is removed.
  @override
  void dispose() {
    for (final c in [_name, _id, _email, _phone, _subject, _details, _extra]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  // ── Validators: each message says what is wrong and what is expected ──
  String? _vName(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please enter your full name';
    if (t.length < 3) return 'Name is too short (at least 3 characters)';
    if (!RegExp(r"^[A-Za-z][A-Za-z .'-]*$").hasMatch(t)) return 'Use letters only, e.g. Suguna K';
    return null;
  }

  String? _vId(String? v) {
    final t = (v ?? '').trim().toUpperCase();
    if (t.isEmpty) return 'Student ID is required';
    if (!RegExp(r'^AVIT\d{4}-\d{4}$').hasMatch(t)) return 'Use the format AVIT2024-1082';
    return null;
  }

  String? _vEmail(String? v) {
    final t = (v ?? '').trim().toLowerCase();
    if (t.isEmpty) return 'Campus email is required';
    if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(t)) return 'Enter a valid email, e.g. suguna$kDomain';
    if (!t.endsWith(kDomain)) return 'Use your campus email ending in $kDomain';
    return null;
  }

  String? _vPhone(String? v) {
    final t = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
    if (t.isEmpty) return null; // optional field
    if (!RegExp(r'^\+?\d{10,13}$').hasMatch(t)) return 'Enter 10–13 digits, with an optional leading +';
    return null;
  }

  String? _vSubject(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please add a short subject';
    if (t.length < 5) return 'Subject is too short (at least 5 characters)';
    return null;
  }

  String? _vDetails(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Please describe your request';
    if (t.length < 20) return 'Add more detail (${t.length}/20 characters minimum)';
    return null;
  }

  // ── Submit: validate first, save only when every rule passes ──
  void _submit() {
    FocusScope.of(context).unfocus();
    final form = _formKey.currentState!;
    if (!form.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: kError,
        content: Text('Please fix the highlighted fields before submitting.'),
      ));
      return; // stay on the form, keep valid data
    }
    _req = ServiceRequest();
    form.save(); // runs every onSaved callback
    _showSuccess();
  }

  // ── Reset: clear the Form, the controllers AND the non-Form state ──
  void _reset({bool silent = false}) {
    FocusScope.of(context).unfocus();
    setState(() {
      for (final c in [_name, _id, _email, _phone, _subject, _details, _extra]) {
        c.clear();
      }
      _category = null;
      _req = ServiceRequest();
    });
    // Reset after the rebuild so dropdown/chips/date/checkbox return to their initial values.
    WidgetsBinding.instance.addPostFrameCallback((_) => _formKey.currentState?.reset());
    if (_scroll.hasClients) {
      _scroll.animateTo(0, duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
    }
    if (!silent) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Form cleared. You can start a new request.'),
      ));
    }
  }

  void _showSuccess() {
    final r = _req;
    final ref = 'AVIT-SR-${1000 + math.Random().nextInt(9000)}';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final p = Pal.of(ctx);
        Widget row(String l, String v) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 82, child: Text(l, style: TextStyle(color: p.sub, fontSize: 13))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
          ]),
        );
        return AlertDialog(
          backgroundColor: p.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          icon: const Icon(Icons.check_circle_rounded, color: kSuccess, size: 60),
          title: const Text('Request received!', textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Pill(ref, kSuccess, icon: Icons.confirmation_number_outlined),
              const SizedBox(height: 12),
              Text(
                'Thank you, ${r.name.split(' ').first}. The ${r.category} team will contact you by '
                    '${r.contact.toLowerCase()} on or before ${fmtDate(r.date!)}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: p.sub, height: 1.45),
              ),
              const SizedBox(height: 16),
              Divider(color: p.line),
              const SizedBox(height: 8),
              row('Student', '${r.name} (${r.studentId})'),
              row('Category', r.category),
              if (r.extra.isNotEmpty) row(r.extraLabel, r.extra),
              row('Subject', r.subject),
              row('Urgency', r.urgency),
              row('Contact', r.contact),
              row('Date', fmtDate(r.date!)),
            ]),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: kPri,
                minimumSize: const Size(180, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _reset(silent: true); // start fresh after a successful submission
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('New request', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _section(Pal p, String title, IconData icon, List<Widget> kids) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: GlassCard(
      radius: 22,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: kPri.withOpacity(.14), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: kPri, size: 20),
          ),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 16),
        ...kids,
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final extra = kExtra[_category];
    return Form(
      key: _formKey,
      autovalidateMode: kAuto,
      child: ListView(
        controller: _scroll, // scrollable body: no overflow on small screens or with the keyboard open
        padding: EdgeInsets.zero,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        children: [
          // ── App header: name, form title, icon and short instruction ──
          PhotoBackdrop(
            url: kImgLibrary,
            seed: 31,
            radius: 32,
            child: SizedBox(
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Glass(
                        radius: 16,
                        width: 48,
                        height: 48,
                        opacity: .2,
                        child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text('AVIT Help Desk',
                            style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 14),
                    const Text('Student Service Request',
                        style: TextStyle(
                            color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                    const SizedBox(height: 4),
                    const Text('Tell us what you need and the right team will reply within 2 working days.',
                        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4)),
                    const SizedBox(height: 14),
                    const Pill('Fields marked * are required', Colors.white,
                        icon: Icons.info_outline_rounded, onDark: true),
                  ]),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // ── Section 1: student details ──
              _section(p, 'Student details', Icons.badge_outlined, [
                CampusTextField(
                  controller: _name,
                  label: 'Full name *',
                  hint: 'e.g. Suguna K',
                  icon: Icons.person_outline_rounded,
                  caps: TextCapitalization.words,
                  validator: _vName,
                  onSaved: (v) => _req.name = v!.trim(),
                ),
                CampusTextField(
                  controller: _id,
                  label: 'Student ID *',
                  hint: 'AVIT2024-1082',
                  icon: Icons.numbers_rounded,
                  caps: TextCapitalization.characters,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]'))],
                  validator: _vId,
                  onSaved: (v) => _req.studentId = v!.trim().toUpperCase(),
                ),
                CampusTextField(
                  controller: _email,
                  label: 'Campus email *',
                  hint: 'name$kDomain',
                  icon: Icons.alternate_email_rounded,
                  keyboard: TextInputType.emailAddress,
                  validator: _vEmail,
                  onSaved: (v) => _req.email = v!.trim().toLowerCase(),
                ),
                CampusTextField(
                  controller: _phone,
                  label: 'Phone number (optional)',
                  hint: '+91 98765 43210',
                  icon: Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                  formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]'))],
                  validator: _vPhone,
                  onSaved: (v) => _req.phone = (v ?? '').trim(),
                ),
              ]),

              // ── Section 2: request details ──
              _section(p, 'Request details', Icons.edit_note_rounded, [
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DropdownButtonFormField<String>(
                    value: _category,
                    isExpanded: true,
                    autovalidateMode: kAuto,
                    dropdownColor: p.card,
                    borderRadius: BorderRadius.circular(16),
                    decoration: campusDecoration(p, label: 'Service category *', icon: Icons.category_outlined),
                    items: [
                      for (final c in kCategories)
                        DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)),
                    ],
                    validator: (v) => v == null ? 'Select a service category' : null,
                    // Changing the category rebuilds the form to show / hide the extra field.
                    onChanged: (v) => setState(() {
                      _category = v;
                      _extra.clear();
                    }),
                    onSaved: (v) => _req.category = v ?? '',
                  ),
                ),
                // ADVANCED #1: conditional field that depends on the chosen category
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: extra == null
                      ? const SizedBox(width: double.infinity)
                      : CampusTextField(
                    key: ValueKey(_category),
                    controller: _extra,
                    label: '${extra[0]} *',
                    hint: extra[1],
                    icon: Icons.tune_rounded,
                    validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Please enter the ${extra[0].toLowerCase()}' : null,
                    onSaved: (v) {
                      _req.extraLabel = extra[0];
                      _req.extra = v!.trim();
                    },
                  ),
                ),
                CampusTextField(
                  controller: _subject,
                  label: 'Request subject *',
                  hint: 'e.g. Wi-Fi not working in Block C',
                  icon: Icons.title_rounded,
                  caps: TextCapitalization.sentences,
                  validator: _vSubject,
                  onSaved: (v) => _req.subject = v!.trim(),
                ),
                CampusTextField(
                  controller: _details,
                  label: 'Request details *',
                  hint: 'Describe the problem and when it started (20–300 characters)',
                  icon: Icons.notes_rounded,
                  keyboard: TextInputType.multiline,
                  action: TextInputAction.newline,
                  caps: TextCapitalization.sentences,
                  maxLines: 6,
                  maxLength: 300,
                  validator: _vDetails,
                  onSaved: (v) => _req.details = v!.trim(),
                ),
                ChoiceField(
                  label: 'Urgency *',
                  icon: Icons.flag_outlined,
                  options: kUrgency,
                  validator: (v) => v == null ? 'Choose an urgency level' : null,
                  onSaved: (v) => _req.urgency = v ?? '',
                ),
              ]),

              // ── Section 3: preferences ──
              _section(p, 'Preferences', Icons.tune_rounded, [
                ChoiceField(
                  label: 'Preferred contact *',
                  icon: Icons.forum_outlined,
                  options: kContact,
                  validator: (v) => v == null ? 'Choose how we should contact you' : null,
                  onSaved: (v) => _req.contact = v ?? '',
                ),
                DateField(
                  label: 'Preferred response date *',
                  onSaved: (d) => _req.date = d,
                ),
              ]),

              // ── Section 4: confirmation + actions ──
              _section(p, 'Confirmation', Icons.verified_user_outlined, [
                DeclarationField(
                  text: 'I confirm that the information above is correct and I agree to be contacted '
                      'by AVIT staff about this request.',
                  onSaved: (_) {},
                ),
              ]),
              Row(children: [
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: kPri,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: _submit,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.line, width: 1.5),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () => _reset(),
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: const Text('Reset', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}