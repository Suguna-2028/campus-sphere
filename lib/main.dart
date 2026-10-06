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

// ═════════════════════════ ROUTE NAMES ═════════════════════════
// Route names are defined ONCE here and reused for registration and navigation,
// so a typo can never create a route that does not exist.
class AppRoutes {
  static const home = '/';
  static const timetable = '/timetable';
  static const services = '/services';
  static const events = '/events';
  static const profile = '/profile';
  static const request = '/request';
  static const serviceDetail = '/service-detail';
}

// ═════════════════════════ THEME ═════════════════════════
final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

const kPri = Color(0xFF4F46E5);
const kPri2 = Color(0xFF7C3AED);
const kDeep = Color(0xFF1E1B4B);
const kPink = Color(0xFFEC4899);
const kCyan = Color(0xFF06B6D4);

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

// One ThemeData for every route (light + dark) - screens never restyle themselves.
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
      // The dashboard is registered ONCE (initialRoute + routes map, no `home:`).
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const Shell(),
        AppRoutes.timetable: (_) => const TimetableScreen(),
        AppRoutes.services: (_) => const ServicesScreen(),
        AppRoutes.events: (_) => const EventsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.request: (_) => const RequestScreen(),
      },
      // Service Details needs an argument, so it is built here (cast + validate).
      // A custom PageRouteBuilder gives it a fade + slide-up transition (extension).
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.serviceDetail) {
          final args = settings.arguments;
          if (args is CampusService) {
            return PageRouteBuilder<dynamic>(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 450),
              reverseTransitionDuration: const Duration(milliseconds: 350),
              pageBuilder: (_, __, ___) => ServiceDetailScreen(service: args),
              transitionsBuilder: (_, anim, __, child) {
                final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .06), end: Offset.zero).animate(curved),
                    child: child,
                  ),
                );
              },
            );
          }
        }
        return null; // falls through to onUnknownRoute
      },
      // 404-style fallback that shows the route name that could not be opened.
      onUnknownRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => UnknownRouteScreen(routeName: settings.name ?? 'unknown'),
      ),
    ),
  );
}

// ═════════════════════════ DATA ═════════════════════════
const kName = 'Suguna';
const kCollege = 'AVIT';
const kId = 'AVIT2024-1082';
const kEmail = 'suguna@avit.edu';
const kProgram = 'B.Sc. Computer Science • Year 2 • AVIT';

// Photos load from the internet. If offline / blocked, the generated artwork is shown instead.
String _u(String id) => 'https://images.unsplash.com/photo-$id?auto=format&fit=crop&w=900&q=70';
final kImgCampus = _u('1541339907198-e08756dedf3f');
final kImgGrad = _u('1523050854058-8df90110c9f1');
final kImgClass = _u('1524178232363-1fb2b075b655');
final kImgLibrary = _u('1562774053-701939374585');
final kImgStudents = _u('1522202176988-66273c2fd55f');

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

class CampusEvent {
  final String title, date, venue, cat, going, img, about;
  final IconData icon;
  const CampusEvent(this.title, this.date, this.venue, this.cat, this.going, this.icon, this.img, this.about);
}

/// Model passed to the Service Details route through route arguments.
class CampusService {
  final String name, sub, info, location, hours, contact, status, action, img;
  final IconData icon;
  final Color color;
  const CampusService({
    required this.name,
    required this.sub,
    required this.icon,
    required this.color,
    required this.info,
    required this.location,
    required this.hours,
    required this.contact,
    required this.status,
    required this.action,
    required this.img,
  });
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

final events = <CampusEvent>[
  CampusEvent('Annual Tech Fest 2026', '12 Oct • 9:00 AM', 'Main Auditorium', 'Tech', '248 going', Icons.memory,
      _u('1518770660439-4636190af475'),
      'Robotics demos, a 24-hour hackathon, project showcases and talks from industry engineers. Open to every department.'),
  CampusEvent('Global Career Fair', '18 Oct • 10:00 AM', 'Sports Complex', 'Career', '412 going', Icons.work_outline,
      _u('1521737604893-d14cc237f11d'),
      'Meet 60+ recruiters, join CV clinics and attend mock-interview booths. Bring printed copies of your CV.'),
  CampusEvent('Inter-Faculty Football', '21 Oct • 4:30 PM', 'Main Field', 'Sports', '176 going', Icons.sports_soccer,
      _u('1461896836934-ffe607ba8211'),
      'The knock-out finals between faculty teams. Cheer for your department with banners, music and food stalls.'),
  CampusEvent('International Cultural Night', '25 Oct • 7:00 PM', 'Open Air Theatre', 'Culture', '530 going',
      Icons.music_note, _u('1514525253161-7a46d19cd819'),
      'An evening of music, dance and cuisine from across the student community, performed under the lights.'),
  CampusEvent('Wellness Workshop', '30 Oct • 2:00 PM', 'Student Centre', 'Wellness', '64 going',
      Icons.self_improvement, _u('1506126613408-eca07ce68773'),
      'A relaxed session on stress management, mindful study habits and healthy routines for exam season.'),
];

final services = <CampusService>[
  CampusService(
    name: 'Library',
    sub: 'Books & study rooms',
    icon: Icons.local_library_rounded,
    color: const Color(0xFF4F46E5),
    info: 'Silent floors, group study rooms and 24/7 e-resources. You have 2 books due in 3 days.',
    location: 'Central Block, Levels 1–3',
    hours: '8:00 AM – 10:00 PM',
    contact: 'library@avit.edu',
    status: 'Open now',
    action: 'Reserve a study room',
    img: _u('1481627834876-b7833e8f5570'),
  ),
  CampusService(
    name: 'Canteen',
    sub: "Today's menu",
    icon: Icons.restaurant_rounded,
    color: const Color(0xFFF59E0B),
    info: 'Today: Nasi Lemak, Pasta, Veg Curry and fresh juices. Vegetarian and halal options every day.',
    location: 'Food Court, Ground Floor',
    hours: '7:30 AM – 8:00 PM',
    contact: 'canteen@avit.edu',
    status: 'Open now',
    action: 'Pre-order a meal',
    img: _u('1567620905732-2d1ec7ab7445'),
  ),
  CampusService(
    name: 'Transport',
    sub: 'Campus shuttle',
    icon: Icons.directions_bus_rounded,
    color: const Color(0xFF10B981),
    info: 'The campus shuttle runs every 15 minutes. Next bus at 10:25 AM from Gate A.',
    location: 'Gate A Shuttle Bay',
    hours: '7:00 AM – 7:00 PM',
    contact: 'transport@avit.edu',
    status: 'Running',
    action: 'Request a bus pass',
    img: _u('1544620347-c4fd4a3d5957'),
  ),
  CampusService(
    name: 'Results',
    sub: 'Grades & GPA',
    icon: Icons.assignment_rounded,
    color: const Color(0xFFEC4899),
    info: 'Semester 3 GPA: 3.62. Cumulative CGPA: 3.55. Transcripts can be requested at the Admin Block.',
    location: 'Admin Block, Level 2',
    hours: '9:00 AM – 4:30 PM',
    contact: 'exams@avit.edu',
    status: 'GPA 3.62',
    action: 'Request a transcript',
    img: _u('1434030216411-0b793f4b4173'),
  ),
  CampusService(
    name: 'Fees',
    sub: 'Payments',
    icon: Icons.account_balance_wallet_rounded,
    color: const Color(0xFF06B6D4),
    info: 'No outstanding balance. Next payment is due on 5 January. Receipts are issued instantly.',
    location: 'Admin Block, Level 1',
    hours: '9:00 AM – 4:00 PM',
    contact: 'fees@avit.edu',
    status: 'No dues',
    action: 'Request a fee receipt',
    img: _u('1554224155-6726b3ff858f'),
  ),
  CampusService(
    name: 'Hostel',
    sub: 'Room & requests',
    icon: Icons.apartment_rounded,
    color: const Color(0xFF8B5CF6),
    info: 'Block C, Room 214. Laundry is on level 2. You have no open maintenance requests.',
    location: 'Block C, Warden Office',
    hours: 'Open 24 hours',
    contact: 'hostel@avit.edu',
    status: 'No open requests',
    action: 'Raise a maintenance request',
    img: _u('1555854877-bab0e564b8d5'),
  ),
  CampusService(
    name: 'Sports',
    sub: 'Gym & courts',
    icon: Icons.sports_basketball_rounded,
    color: const Color(0xFFEF4444),
    info: 'Gym, pool, football field and courts. Book a slot online or at the front desk.',
    location: 'Sports Complex',
    hours: '6:00 AM – 10:00 PM',
    contact: 'sports@avit.edu',
    status: 'Open now',
    action: 'Book a court slot',
    img: _u('1571019613454-1cb2f99b2d8b'),
  ),
  CampusService(
    name: 'Helpdesk',
    sub: 'Get support',
    icon: Icons.support_agent_rounded,
    color: const Color(0xFF64748B),
    info: 'Visit the Admin Block, email us, or send a request from the Request tab. We reply within 2 working days.',
    location: 'Admin Block, Level 1',
    hours: '9:00 AM – 5:00 PM',
    contact: 'help@avit.edu',
    status: 'Online',
    action: 'Request an appointment',
    img: _u('1553877522-43269d4ea984'),
  ),
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

// ═════════════════════════ NAVIGATION HELPERS ═════════════════════════
bool _navBusy = false; // blocks rapid repeated taps from pushing duplicate routes

/// Opens Service Details with the selected service as the route argument,
/// waits for the result and shows visible confirmation on the previous screen.
Future<void> openService(BuildContext context, CampusService s) async {
  if (_navBusy) return;
  _navBusy = true;
  final result = await Navigator.pushNamed(context, AppRoutes.serviceDetail, arguments: s);
  _navBusy = false;
  if (!context.mounted) return; // never use a context after an await without checking
  if (result == 'requested') {
    showToast(context, '${s.action}: request sent to ${s.name}.', icon: Icons.check_circle_rounded);
  }
}

/// Direct Navigator.push + MaterialPageRoute (event details). Returns true when
/// the student registered on the details screen.
Future<bool> openEventDetail(BuildContext context, int i, {bool registered = false}) async {
  if (_navBusy) return false;
  _navBusy = true;
  final result = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => EventDetailScreen(event: events[i], index: i, registered: registered)),
  );
  _navBusy = false;
  return result == 'registered';
}

void showToast(BuildContext context, String msg, {IconData icon = Icons.info_outline_rounded}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kDeep,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Row(children: [
        Icon(icon, color: const Color(0xFF34D399)),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
    ));
}

/// Extra space for the back button when a page is shown as a pushed route.
double backGap(BuildContext c) => (ModalRoute.of(c)?.canPop ?? false) ? 52 : 0;

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

/// Standard content card, glass style.
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
                    child: blob(380, kPink, a * .8)),
                Positioned(
                    right: -150 + math.sin(t) * 60,
                    top: h * .72 - math.cos(t) * 70,
                    child: blob(400, kCyan, a * .8)),
                Positioned(
                    right: -90 + math.cos(t) * 40,
                    top: h * .30 + math.sin(t) * 50,
                    child: blob(260, const Color(0xFFF59E0B), a * .45)),
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

/// Photo header with a deep-blue colour wash and coloured light leaks so white text stays readable.
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
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [kDeep.withOpacity(.86), kPri.withOpacity(.74), kPri2.withOpacity(.66)],
            ),
          ),
        ),
      ),
      // Light leaks: a pink glow top-right and a cyan glow bottom-left.
      Positioned(
        right: -70,
        top: -70,
        child: IgnorePointer(
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x66EC4899), Color(0x00EC4899)]),
            ),
          ),
        ),
      ),
      Positioned(
        left: -80,
        bottom: -90,
        child: IgnorePointer(
          child: Container(
            width: 260,
            height: 260,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0x5522D3EE), Color(0x0022D3EE)]),
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
  final CampusEvent e;
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
                  colors: [g[0].withOpacity(.18), Colors.black.withOpacity(.66)],
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

/// Press-to-shrink tap feedback (visible pressed state) with a screen-reader label.
class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? label;
  const Tap({super.key, required this.child, this.onTap, this.label});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool down = false;
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: widget.label,
    child: GestureDetector(
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
    ),
  );
}

/// Primary call-to-action button: gradient fill + coloured glow.
class GradientButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> colors;
  const GradientButton(this.text, this.icon, this.onTap, {super.key, this.colors = const [kPri, kPri2]});
  @override
  Widget build(BuildContext context) => Tap(
    label: text,
    onTap: onTap,
    child: Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: colors[0].withOpacity(.45), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
      ]),
    ),
  );
}

/// Round glass back button. Uses Navigator.canPop so it never shows on the first route.
class BackBtn extends StatelessWidget {
  const BackBtn({super.key});
  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Tap(
        label: 'Go back',
        onTap: () => Navigator.maybePop(context), // pops the current route; never pushes Home again
        child: const Glass(
          radius: 24,
          width: 48,
          height: 48,
          opacity: .26,
          child: Center(child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18)),
        ),
      ),
    );
  }
}

/// Wraps a page so it can be opened as its own route: aurora background + back button.
class PushedScreen extends StatelessWidget {
  final Widget child;
  const PushedScreen({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: Aurora()),
        child,
        const SafeArea(child: Align(alignment: Alignment.topLeft, child: BackBtn())),
      ]),
    );
  }
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
            SizedBox(height: backGap(context)),
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
      gradient: const LinearGradient(
          colors: [Color(0xFF22D3EE), kPri2, kPink], begin: Alignment.topLeft, end: Alignment.bottomRight),
      border: Border.all(color: Colors.white.withOpacity(.8), width: 2),
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

/// Section heading with a gradient accent bar.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 28, 0, 14),
    child: Row(children: [
      Container(
        width: 5,
        height: 22,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kPri, kPink], begin: Alignment.topCenter, end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      Expanded(
          child: Text(title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.3))),
      if (action != null)
        Tap(
          label: action,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(action!, style: const TextStyle(color: kPri, fontWeight: FontWeight.w700)),
          ),
        ),
    ]),
  );
}

/// Photo navigation card used on the dashboard (opens a named route).
class NavCard extends StatelessWidget {
  final String title, sub, img;
  final IconData icon;
  final List<Color> grad;
  final int seed;
  final VoidCallback onTap;
  const NavCard({
    super.key,
    required this.title,
    required this.sub,
    required this.img,
    required this.icon,
    required this.grad,
    required this.seed,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Tap(
    label: 'Open $title',
    onTap: onTap,
    child: Container(
      height: 124,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: grad[0].withOpacity(.38), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(children: [
          Positioned.fill(child: NetImage(img, grad, seed)),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [grad[0].withOpacity(.86), grad[1].withOpacity(.58)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Glass(
                radius: 14,
                width: 40,
                height: 40,
                opacity: .22,
                child: Center(child: Icon(icon, color: Colors.white, size: 22)),
              ),
              const Spacer(),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
        ]),
      ),
    ),
  );
}

/// Service card with a photo (shared Hero image with the details route).
class ServiceCard extends StatelessWidget {
  final CampusService s;
  const ServiceCard(this.s, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return GlassCard(
      radius: 22,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: 5,
            child: Stack(fit: StackFit.expand, children: [
              Hero(tag: 'svc-img-${s.name}', child: NetImage(s.img, [s.color, kDeep], s.name.length)),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, s.color.withOpacity(.62)],
                  ),
                ),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [s.color, s.color.withOpacity(.7)]),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [BoxShadow(color: s.color.withOpacity(.55), blurRadius: 14)],
                  ),
                  child: Icon(s.icon, color: Colors.white, size: 21),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(s.sub, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: p.sub, fontSize: 12.5)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class ClassCard extends StatelessWidget {
  final Slot s;
  final int index;
  final bool highlight; // the next class gets a gradient border + glow
  const ClassCard(this.s, this.index, {super.key, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final card = GlassCard(
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
            Wrap(spacing: 6, runSpacing: 6, children: [
              Pill(s.room, s.color, icon: Icons.place_outlined),
              if (highlight) const Pill('NEXT UP', kPri, icon: Icons.bolt_rounded),
            ]),
          ]),
        ),
      ]),
    );
    return Reveal(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: highlight
            ? Container(
          padding: const EdgeInsets.all(1.8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(colors: [kPri, kPri2, kPink]),
            boxShadow: [BoxShadow(color: kPri.withOpacity(.4), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: card,
        )
            : card,
      ),
    );
  }
}

// ═════════════════════════ ROUTE SCREENS (each one is its own class) ═════════════════════════
class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});
  @override
  Widget build(BuildContext context) => const PushedScreen(child: SchedulePage());
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});
  @override
  Widget build(BuildContext context) => const PushedScreen(child: ServicesPage());
}

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});
  @override
  Widget build(BuildContext context) => const PushedScreen(child: EventsPage());
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const PushedScreen(child: ProfilePage());
}

class RequestScreen extends StatelessWidget {
  const RequestScreen({super.key});
  @override
  Widget build(BuildContext context) => const PushedScreen(child: RequestPage());
}

/// Info row used on the detail routes.
Widget detailRow(Pal p, IconData icon, Color c, String label, String value, {VoidCallback? onTap}) => Tap(
  label: '$label: $value',
  onTap: onTap,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: c.withOpacity(.14), borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: c, size: 21),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: p.sub, fontSize: 12.5)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ]),
      ),
      if (onTap != null) Icon(Icons.copy_rounded, size: 18, color: p.sub),
    ]),
  ),
);

/// Service Details: receives a CampusService, returns 'requested' with Navigator.pop.
class ServiceDetailScreen extends StatelessWidget {
  final CampusService service;
  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final s = service;
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: Aurora()),
        ListView(padding: EdgeInsets.zero, children: [
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
              child: Stack(fit: StackFit.expand, children: [
                Hero(tag: 'svc-img-${s.name}', child: NetImage(s.img, [s.color, kDeep], s.name.length)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(.18), s.color.withOpacity(.35), kDeep.withOpacity(.92)],
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 24,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [s.color, s.color.withOpacity(.7)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: s.color.withOpacity(.6), blurRadius: 22)],
                      ),
                      child: Icon(s.icon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(s.name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                    const SizedBox(height: 4),
                    Text(s.sub, style: const TextStyle(color: Colors.white70, fontSize: 15)),
                    const SizedBox(height: 12),
                    Pill(s.status, Colors.white, icon: Icons.circle, onDark: true),
                  ]),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Reveal(
                child: GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('About', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(s.info, style: TextStyle(color: p.sub, fontSize: 15, height: 1.5)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Reveal(
                index: 1,
                child: GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                  child: Column(children: [
                    detailRow(p, Icons.location_on_outlined, kPri, 'Location', s.location),
                    Divider(height: 1, color: p.line),
                    detailRow(p, Icons.access_time_rounded, const Color(0xFFF59E0B), 'Opening hours', s.hours),
                    Divider(height: 1, color: p.line),
                    detailRow(p, Icons.mail_outline_rounded, const Color(0xFF10B981), 'Contact', s.contact,
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: s.contact));
                          showToast(context, 'Contact copied: ${s.contact}', icon: Icons.copy_rounded);
                        }),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              // Returned result: the previous route receives 'requested' and shows a confirmation.
              GradientButton(s.action, Icons.send_rounded, () => Navigator.pop(context, 'requested'),
                  colors: [s.color, kPri2]),
              const SizedBox(height: 12),
              Tap(
                label: 'Return to services',
                onTap: () => Navigator.pop(context), // plain pop: previous route revealed, no result
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line, width: 1.5),
                  ),
                  child: const Text('Return', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ]),
        const SafeArea(child: Align(alignment: Alignment.topLeft, child: BackBtn())),
      ]),
    );
  }
}

/// Event Details (opened with a direct Navigator.push + MaterialPageRoute).
class EventDetailScreen extends StatelessWidget {
  final CampusEvent event;
  final int index;
  final bool registered;
  const EventDetailScreen({super.key, required this.event, required this.index, required this.registered});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final e = event;
    final g = kGrads[index % kGrads.length];
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: Aurora()),
        ListView(padding: EdgeInsets.zero, children: [
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(36)),
              child: Stack(fit: StackFit.expand, children: [
                NetImage(e.img, g, index + 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [g[0].withOpacity(.2), Colors.black.withOpacity(.78)],
                    ),
                  ),
                ),
                Positioned(
                  left: 22,
                  right: 22,
                  bottom: 24,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Pill(e.cat, Colors.white, icon: e.icon, onDark: true),
                    const SizedBox(height: 12),
                    Text(e.title,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -.5)),
                  ]),
                ),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Reveal(
                child: GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('About this event', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(e.about, style: TextStyle(color: p.sub, fontSize: 15, height: 1.5)),
                  ]),
                ),
              ),
              const SizedBox(height: 16),
              Reveal(
                index: 1,
                child: GlassCard(
                  radius: 22,
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
                  child: Column(children: [
                    detailRow(p, Icons.event_rounded, g[0], 'Date & time', e.date),
                    Divider(height: 1, color: p.line),
                    detailRow(p, Icons.place_outlined, const Color(0xFFF59E0B), 'Venue', e.venue),
                    Divider(height: 1, color: p.line),
                    detailRow(p, Icons.groups_rounded, const Color(0xFF10B981), 'Attendance', e.going),
                  ]),
                ),
              ),
              const SizedBox(height: 24),
              if (registered)
                Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withOpacity(.16),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF22C55E)),
                  ),
                  child: const Text('✓ You are registered',
                      style: TextStyle(color: Color(0xFF16A34A), fontSize: 16, fontWeight: FontWeight.w800)),
                )
              else
                GradientButton('Register now', Icons.how_to_reg_rounded,
                        () => Navigator.pop(context, 'registered'), colors: g),
              const SizedBox(height: 12),
              Tap(
                label: 'Return to events',
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: p.line, width: 1.5),
                  ),
                  child: const Text('Return', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ]),
        const SafeArea(child: Align(alignment: Alignment.topLeft, child: BackBtn())),
      ]),
    );
  }
}

/// 404-style screen shown by onUnknownRoute.
class UnknownRouteScreen extends StatelessWidget {
  final String routeName;
  const UnknownRouteScreen({super.key, required this.routeName});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        const Positioned.fill(child: Aurora()),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [kPri, kPink]),
                    boxShadow: [BoxShadow(color: kPri.withOpacity(.5), blurRadius: 30)],
                  ),
                  child: const Icon(Icons.explore_off_rounded, color: Colors.white, size: 46),
                ),
                const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(colors: [kPri, kPink]).createShader(r),
                  child: const Text('404',
                      style: TextStyle(fontSize: 84, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                ),
                const SizedBox(height: 8),
                const Text('This route does not exist', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Pill(routeName, kPri, icon: Icons.link_off_rounded),
                const SizedBox(height: 12),
                Text('The app could not open this page. Go back and try another option.',
                    textAlign: TextAlign.center, style: TextStyle(color: p.sub, height: 1.5)),
                const SizedBox(height: 28),
                SizedBox(
                  width: 240,
                  child: GradientButton('Go back', Icons.arrow_back_rounded, () => Navigator.maybePop(context)),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
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
                Semantics(
                  button: true,
                  selected: i == n,
                  label: '${items[n][1]} tab',
                  child: GestureDetector(
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
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════ HOME (DASHBOARD) ═════════════════════════
class _RingPainter extends CustomPainter {
  final double v;
  final Color color, track;
  _RingPainter(this.v, this.color, this.track);
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 7;
    final rect = Rect.fromCircle(center: c, radius: r);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawCircle(c, r, paint);
    // Gradient arc for the progress ring.
    paint.shader = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [color, kPink, color],
      transform: const GradientRotation(-math.pi / 2),
    ).createShader(rect);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * v, false, paint);
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
                  Tap(
                    label: 'Notifications',
                    onTap: () => showToast(context, 'You have 3 new announcements.', icon: Icons.campaign_rounded),
                    child: Glass(
                      radius: 24,
                      width: 48,
                      height: 48,
                      opacity: .18,
                      child: Stack(alignment: Alignment.center, children: [
                        const Icon(Icons.notifications_none_rounded, color: Colors.white),
                        Positioned(
                          top: 11,
                          right: 12,
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
                  ),
                ]),
                const SizedBox(height: 20),
                Tap(
                  label: 'Search services',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.services),
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
                  label: 'Next class: ${next.name}. Open timetable',
                  onTap: () => Navigator.pushNamed(context, AppRoutes.timetable),
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
                        width: 44,
                        height: 44,
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
          // ── Reminder banner ──
          const SizedBox(height: 22),
          Reveal(
            child: Tap(
              label: 'Reminder: 2 library books due in 3 days',
              onTap: () => openService(context, services[0]),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                      colors: [Color(0xFFF97316), kPink, kPri2], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  boxShadow: [BoxShadow(color: kPink.withOpacity(.4), blurRadius: 22, offset: const Offset(0, 10))],
                ),
                child: Row(children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(.22), borderRadius: BorderRadius.circular(15)),
                    child: const Icon(Icons.alarm_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('2 library books due in 3 days',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5)),
                      SizedBox(height: 2),
                      Text('Tap to renew or reserve a study room',
                          style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    ]),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white),
                ]),
              ),
            ),
          ),

          // ── Navigation cards (each opens a NAMED route with Navigator.pushNamed) ──
          const SectionTitle('Quick access'),
          Reveal(
            index: 1,
            child: Column(children: [
              Row(children: [
                Expanded(
                  child: NavCard(
                    title: 'Timetable',
                    sub: '10 classes this week',
                    img: kImgClass,
                    icon: Icons.calendar_month_rounded,
                    grad: kGrads[0],
                    seed: 1,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.timetable),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: NavCard(
                    title: 'Services',
                    sub: '8 campus services',
                    img: kImgLibrary,
                    icon: Icons.grid_view_rounded,
                    grad: kGrads[2],
                    seed: 2,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.services),
                  ),
                ),
              ]),
              const SizedBox(height: 14),
              Row(children: [
                Expanded(
                  child: NavCard(
                    title: 'Events',
                    sub: '5 happening soon',
                    img: kImgStudents,
                    icon: Icons.celebration_rounded,
                    grad: kGrads[3],
                    seed: 3,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.events),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: NavCard(
                    title: 'Profile',
                    sub: kId,
                    img: kImgGrad,
                    icon: Icons.person_rounded,
                    grad: kGrads[4],
                    seed: 4,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
                  ),
                ),
              ]),
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
            for (int k = 0; k < today.length; k++) ClassCard(today[k], k, highlight: k == 0),

          // ── Popular services (photo carousel) ──
          SectionTitle('Popular services', action: 'View all', onTap: () => Navigator.pushNamed(context, AppRoutes.services)),
        ]),
      ),
      SizedBox(
        height: 168,
        child: ListView.separated(
          clipBehavior: Clip.none,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, k) {
            final s = services[k];
            return Tap(
              label: 'Open ${s.name}',
              onTap: () => openService(context, s),
              child: Container(
                width: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: s.color.withOpacity(.35), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(fit: StackFit.expand, children: [
                    NetImage(s.img, [s.color, kDeep], k + 40),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [s.color.withOpacity(.12), kDeep.withOpacity(.85)],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: s.color,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: s.color.withOpacity(.6), blurRadius: 12)],
                          ),
                          child: Icon(s.icon, color: Colors.white, size: 20),
                        ),
                        const Spacer(),
                        Text(s.name,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                        Text(s.sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ]),
                    ),
                  ]),
                ),
              ),
            );
          },
        ),
      ),

      // ── Events ──
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SectionTitle('Upcoming events', action: 'View all', onTap: () => Navigator.pushNamed(context, AppRoutes.events)),
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
            label: 'Open ${events[i].title}',
            onTap: () async {
              final reg = await openEventDetail(context, i);
              if (reg && context.mounted) {
                showToast(context, 'Registered for ${events[i].title}', icon: Icons.check_circle_rounded);
              }
            },
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
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [kGrads[k][0].withOpacity(.2), kGrads[k][1].withOpacity(.12)]),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.campaign_rounded, color: kGrads[k][0]),
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
                label: '${names[i]} ${d.day}',
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
                : [for (int k = 0; k < list.length; k++) ClassCard(list[k], k, highlight: day == todayIdx() && k == 0)],
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

  void _toggle(int i) {
    setState(() => going.contains(i) ? going.remove(i) : going.add(i));
    if (going.contains(i)) {
      showToast(context, 'Registered for ${events[i].title}', icon: Icons.check_circle_rounded);
    }
  }

  Future<void> _open(int i) async {
    final reg = await openEventDetail(context, i, registered: going.contains(i));
    if (!mounted) return;
    if (reg) {
      setState(() => going.add(i));
      showToast(context, 'Registered for ${events[i].title}', icon: Icons.check_circle_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final cats = ['All', ...{for (final e in events) e.cat}];
    return Column(children: [
      PageHeader('Events', "Discover what's happening at AVIT", kImgGrad, seed: 9),
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
              label: 'Filter ${cats[i]}',
              onTap: () => setState(() => filter = cats[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: sel ? const LinearGradient(colors: [kPri, kPri2]) : null,
                  color: sel ? null : p.card.withOpacity(p.dark ? .5 : .7),
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
                child: Tap(
                  label: 'Open ${events[i].title}',
                  onTap: () => _open(i), // direct Navigator.push to the event details route
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
                              child: Center(child: Icon(events[i].icon, color: Colors.white, size: 20)),
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
                                  label: going.contains(i) ? 'Registered' : 'Register for ${events[i].title}',
                                  onTap: () => _toggle(i),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        child: list.isEmpty
            ? Center(child: Text('No services match "$q"', style: TextStyle(color: p.sub, fontSize: 16)))
            : GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .9),
          itemBuilder: (_, i) {
            final s = list[i];
            return Reveal(
              index: i,
              child: Tap(
                label: 'Open ${s.name}',
                // Selected CampusService travels to the details route as an argument.
                onTap: () => openService(context, s),
                child: ServiceCard(s),
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

  Widget _stat(Pal p, String v, String l, List<Color> g) => Expanded(
    child: GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(children: [
        ShaderMask(
          shaderCallback: (r) => LinearGradient(colors: g).createShader(r),
          child: Text(v, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
        const SizedBox(height: 2),
        Text(l, style: TextStyle(color: p.sub, fontSize: 12.5)),
      ]),
    ),
  );

  Widget _tile(Pal p, IconData i, Color c, String t, Widget trailing, {VoidCallback? onTap}) => Tap(
    label: t,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: c.withOpacity(.13), borderRadius: BorderRadius.circular(13)),
          child: Icon(i, color: c, size: 21),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15))),
        trailing,
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final chevron = Icon(Icons.chevron_right_rounded, color: p.sub);
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
                SizedBox(height: backGap(context) * .6),
                const Avatar(92),
                const SizedBox(height: 14),
                const Text(kName, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text(kProgram, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                const Pill(kId, Colors.white, icon: Icons.badge_outlined, onDark: true),
              ]),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Reveal(
            child: Row(children: [
              _stat(p, '3.55', 'CGPA', const [kPri, kPri2]),
              const SizedBox(width: 12),
              _stat(p, '92%', 'Attendance', const [Color(0xFF10B981), kCyan]),
              const SizedBox(width: 12),
              _stat(p, '84', 'Credits', const [Color(0xFFF59E0B), kPink]),
            ]),
          ),
          const SizedBox(height: 16),
          Reveal(
            index: 1,
            child: GlassCard(
              radius: 22,
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
              child: Column(children: [
                detailRow(p, Icons.school_outlined, kPri, 'Programme', 'B.Sc. Computer Science, Year 2'),
                Divider(height: 1, color: p.line),
                detailRow(p, Icons.mail_outline_rounded, const Color(0xFF10B981), 'Campus email', kEmail),
              ]),
            ),
          ),
          const SectionTitle('Campus moments'),
          SizedBox(
            height: 118,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final m in [
                  [kImgCampus, 'Campus'],
                  [kImgClass, 'Classes'],
                  [kImgLibrary, 'Library'],
                  [kImgStudents, 'Friends'],
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(fit: StackFit.expand, children: [
                          NetImage(m[0], const [kPri, kPri2], m[1].length),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, kDeep.withOpacity(.85)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 10,
                            child: Text(m[1],
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                          ),
                        ]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Settings'),
          Reveal(
            index: 2,
            child: GlassCard(
              padding: EdgeInsets.zero,
              radius: 22,
              child: Column(children: [
                _tile(p, Icons.person_outline_rounded, kPri, 'Edit profile', chevron,
                    onTap: () => showToast(context, 'Profile editing is coming soon.')),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.edit_note_rounded, kPink, 'Raise a service request', chevron,
                    onTap: () => Navigator.pushNamed(context, AppRoutes.request)),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.notifications_none_rounded, const Color(0xFFF59E0B), 'Notifications', chevron,
                    onTap: () => showToast(context, 'Notifications are switched on.', icon: Icons.notifications_active_rounded)),
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
                  onTap: () => themeMode.value = themeMode.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                ),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.language_rounded, kCyan, 'Language',
                    Text('English', style: TextStyle(color: p.sub, fontWeight: FontWeight.w600)),
                    onTap: () => showToast(context, 'English is the only language available.')),
                Divider(height: 1, color: p.line),
                _tile(p, Icons.help_outline_rounded, const Color(0xFF10B981), 'Help & support', chevron,
                    onTap: () => openService(context, services[7])),
                Divider(height: 1, color: p.line),
                // Test hook for the unknown-route fallback (test case T8).
                _tile(p, Icons.link_off_rounded, const Color(0xFFEF4444), 'Test unknown route', chevron,
                    onTap: () => Navigator.pushNamed(context, '/does-not-exist')),
              ]),
            ),
          ),
        ]),
      ),
    ]);
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
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kPri.withOpacity(.2), kPri2.withOpacity(.12)]),
              borderRadius: BorderRadius.circular(12),
            ),
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
                    SizedBox(height: backGap(context)),
                    Row(children: [
                      Glass(
                        radius: 16,
                        width: 48,
                        height: 48,
                        opacity: .2,
                        child: const Center(child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 26)),
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
                  child: GradientButton('Submit request', Icons.send_rounded, _submit),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.line, width: 1.5),
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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