import 'dart:math' as math;
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

// ═════════════════════════ IDENTITY + THEME ═════════════════════════
// App identity: name, tagline and a crimson + ink + paper palette with serif headings
// (inspired by the restrained look of traditional university websites).
const kAppName = 'AVIT Compass';
const kTagline = 'Find your way around campus';

final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

const kPri = Color(0xFFA51C30); // crimson: the single accent colour
const kInk = Color(0xFF1A1A1A);

class Pal {
  final bool dark;
  const Pal(this.dark);
  static Pal of(BuildContext c) => Pal(Theme.of(c).brightness == Brightness.dark);
  Color get bg => dark ? const Color(0xFF111112) : const Color(0xFFF6F5F2);
  Color get card => dark ? const Color(0xFF1B1B1D) : Colors.white;
  Color get text => dark ? const Color(0xFFF2F2F2) : kInk;
  Color get sub => dark ? const Color(0xFFA3A3A9) : const Color(0xFF5E5E63);
  Color get line => dark ? const Color(0xFF303034) : const Color(0xFFDEDBD5);
  Color get soft => dark ? const Color(0xFF242427) : const Color(0xFFF1EFEA);
  Color get accent => dark ? const Color(0xFFE5566B) : kPri; // lighter crimson for dark mode contrast
}

// One ThemeData for every route (light + dark) - screens never restyle themselves.
ThemeData buildTheme(bool dark) {
  final p = Pal(dark);
  final b = dark ? Brightness.dark : Brightness.light;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    colorScheme: ColorScheme.fromSeed(seedColor: kPri, brightness: b).copyWith(primary: p.accent, surface: p.card),
    scaffoldBackgroundColor: p.bg,
    dividerColor: p.line,
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.card,
      surfaceTintColor: Colors.transparent,
      indicatorColor: kPri.withOpacity(dark ? .35 : .10),
      height: 66,
    ),
  );
}

/// Serif heading style (Georgia, falling back to the device serif font).
TextStyle serif(double size, {FontWeight w = FontWeight.w700, Color? color, double? height}) => TextStyle(
  fontFamily: 'Georgia',
  fontFamilyFallback: const ['Times New Roman', 'serif'],
  fontSize: size,
  fontWeight: w,
  color: color,
  height: height,
);

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: themeMode,
    builder: (_, m, __) => MaterialApp(
      title: kAppName,
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
      // A custom PageRouteBuilder gives it a gentle fade + slide-up transition (extension).
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.serviceDetail) {
          final args = settings.arguments;
          if (args is CampusService) {
            return PageRouteBuilder<dynamic>(
              settings: settings,
              transitionDuration: const Duration(milliseconds: 380),
              reverseTransitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => ServiceDetailScreen(service: args),
              transitionsBuilder: (_, anim, __, child) {
                final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
                return FadeTransition(
                  opacity: curved,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero).animate(curved),
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
    showToast(context, '${s.action}: request sent to ${s.name}.');
  }
}

/// Opens a named route once; the guard stops double taps from stacking duplicates.
Future<void> openRoute(BuildContext context, String name) async {
  if (_navBusy) return;
  _navBusy = true;
  await Navigator.pushNamed(context, name);
  _navBusy = false;
}

/// Direct Navigator.push + MaterialPageRoute (event details). Returns true when
/// the student registered on the details screen.
Future<bool> openEventDetail(BuildContext context, int i, {bool registered = false}) async {
  if (_navBusy) return false;
  _navBusy = true;
  final result = await Navigator.push<String>(
    context,
    MaterialPageRoute(builder: (_) => EventDetailScreen(event: events[i], registered: registered)),
  );
  _navBusy = false;
  return result == 'registered';
}

void showToast(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: kInk,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      content: Text(msg, style: const TextStyle(color: Colors.white)),
    ));
}

/// Extra space for the back button when a page is shown as a pushed route.
double backGap(BuildContext c) => (ModalRoute.of(c)?.canPop ?? false) ? 52 : 0;

// ═════════════════════════ BASIC BUILDING BLOCKS ═════════════════════════

/// Small uppercase label with letter spacing.
class Eyebrow extends StatelessWidget {
  final String text;
  final Color? color;
  const Eyebrow(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
        fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: color ?? Pal.of(context).sub),
  );
}

/// Flat content card: white surface, hairline border, small radius, no shadow.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.radius = 8});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.line),
      ),
      child: child,
    );
  }
}

/// Panel with a crimson bar on its left edge (used for "next" and reminder items).
class BarPanel extends StatelessWidget {
  final Widget child;
  final bool active;
  final EdgeInsetsGeometry padding;
  const BarPanel({super.key, required this.child, this.active = true, this.padding = const EdgeInsets.all(16)});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Panel(
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(width: 4, color: active ? kPri : p.line),
          Expanded(child: Padding(padding: padding, child: child)),
        ]),
      ),
    );
  }
}

/// Network photo with a plain dark-to-crimson fallback when offline.
class NetImage extends StatelessWidget {
  final String url;
  const NetImage(this.url, {super.key});
  @override
  Widget build(BuildContext context) {
    const fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [kInk, kPri], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: SizedBox.expand(),
    );
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (_, child, prog) => prog == null ? child : fallback,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

/// Photo header: one flat dark overlay so white text stays readable, then a crimson rule.
class PhotoBackdrop extends StatelessWidget {
  final String url;
  final Widget child;
  const PhotoBackdrop({super.key, required this.url, required this.child});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Stack(children: [
      Positioned.fill(child: NetImage(url)),
      const Positioned.fill(child: ColoredBox(color: Color(0x9E101010))),
      child,
    ]),
    Container(height: 4, color: kPri),
  ]);
}

/// Gentle fade + small slide-up entrance.
class Reveal extends StatelessWidget {
  final Widget child;
  final int index;
  const Reveal({super.key, required this.child, this.index = 0});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 350 + index * 60),
    curve: Curves.easeOut,
    builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: c)),
    child: child,
  );
}

/// Tap target with a visible pressed state (fades slightly) and a screen-reader label.
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
      child: AnimatedOpacity(
        opacity: down ? .65 : 1,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    ),
  );
}

/// Main action button: solid crimson, square-ish corners.
class PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onTap;
  const PrimaryButton(this.text, this.icon, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) => Tap(
    label: text,
    onTap: onTap,
    child: Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: kPri, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w700)),
      ]),
    ),
  );
}

/// Secondary button: outline only.
class OutlineBtn extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const OutlineBtn(this.text, this.onTap, {super.key});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Tap(
      label: text,
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: p.sub.withOpacity(.5), width: 1.2),
        ),
        child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Round back button for photo headers. Uses Navigator.canPop so it never shows on the first route.
class BackBtn extends StatelessWidget {
  const BackBtn({super.key});
  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Tap(
        label: 'Go back',
        onTap: () => Navigator.maybePop(context), // pops the current route; never pushes Home again
        child: Container(
          width: 46,
          height: 46,
          decoration: const BoxDecoration(color: Color(0x80000000), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

/// Wraps a page so it can be opened as its own route: background + back button.
class PushedScreen extends StatelessWidget {
  final Widget child;
  const PushedScreen({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Pal.of(context).bg,
    body: Stack(fit: StackFit.expand, children: [
      Positioned.fill(child: child),
      const SafeArea(child: Align(alignment: Alignment.topLeft, child: BackBtn())),
    ]),
  );
}

/// Crimson monogram used as the app logo.
class Monogram extends StatelessWidget {
  final double size;
  const Monogram(this.size, {super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(color: kPri, borderRadius: BorderRadius.circular(4)),
    child: Text('A', style: serif(size * .56, color: Colors.white)),
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
      color: kPri,
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(kName[0], style: serif(size * .42, color: Colors.white)),
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
      color: onDark ? Colors.white.withOpacity(.16) : color.withOpacity(.10),
      borderRadius: BorderRadius.circular(4),
      border: onDark ? Border.all(color: Colors.white.withOpacity(.4)) : null,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      if (icon != null) ...[Icon(icon, size: 14, color: onDark ? Colors.white : color), const SizedBox(width: 5)],
      Flexible(
        child: Text(text,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: onDark ? Colors.white : color)),
      ),
    ]),
  );
}

/// Serif section heading with a short crimson rule underneath.
class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;
  const SectionTitle(this.title, {super.key, this.action, this.onTap});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 32, 0, 16),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: serif(23)),
            const SizedBox(height: 8),
            Container(width: 36, height: 3, color: kPri),
          ]),
        ),
        if (action != null)
          Tap(
            label: action,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('${action!.toUpperCase()}  →',
                  style: TextStyle(color: p.accent, fontWeight: FontWeight.w700, fontSize: 12, letterSpacing: 1)),
            ),
          ),
      ]),
    );
  }
}

/// Card with a photo on top and a caption below (navigation tiles, services, events).
class PhotoCard extends StatelessWidget {
  final String img, label;
  final double imgHeight;
  final Widget caption;
  final String? heroTag;
  final VoidCallback onTap;
  const PhotoCard({
    super.key,
    required this.img,
    required this.label,
    required this.caption,
    required this.onTap,
    this.imgHeight = 100,
    this.heroTag,
  });
  @override
  Widget build(BuildContext context) => Tap(
    label: label,
    onTap: onTap,
    child: Panel(
      padding: EdgeInsets.zero,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: imgHeight,
          width: double.infinity,
          child: heroTag == null ? NetImage(img) : Hero(tag: heroTag!, child: NetImage(img)),
        ),
        Container(height: 3, color: kPri),
        Padding(padding: const EdgeInsets.all(14), child: caption),
      ]),
    ),
  );
}

class ClassCard extends StatelessWidget {
  final Slot s;
  final int index;
  final bool highlight; // the next class gets a crimson bar and a label
  const ClassCard(this.s, this.index, {super.key, this.highlight = false});
  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    return Reveal(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: BarPanel(
          active: highlight,
          child: Row(children: [
            SizedBox(
              width: 50,
              child: Column(children: [
                Text(s.start, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 2),
                Text(s.end, style: TextStyle(color: p.sub, fontSize: 12.5)),
              ]),
            ),
            Container(width: 1, height: 52, margin: const EdgeInsets.symmetric(horizontal: 14), color: p.line),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (highlight) ...[Eyebrow('Next class', color: p.accent), const SizedBox(height: 3)],
                Text(s.name, style: serif(17)),
                const SizedBox(height: 4),
                Text('${s.code} • ${s.who}', style: TextStyle(color: p.sub, fontSize: 13)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.place_outlined, size: 15, color: p.sub),
                  const SizedBox(width: 4),
                  Text(s.room, style: TextStyle(color: p.sub, fontSize: 13)),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Icon + label + value row used on the detail screens and profile.
Widget detailRow(Pal p, IconData icon, String label, String value, {VoidCallback? onTap}) => Tap(
  label: '$label: $value',
  onTap: onTap,
  child: Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(children: [
      Icon(icon, color: p.accent, size: 22),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Eyebrow(label),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        ]),
      ),
      if (onTap != null) Icon(Icons.copy_rounded, size: 18, color: p.sub),
    ]),
  ),
);

/// Full-width photo at the top of a detail screen, followed by the crimson rule.
Widget detailHero(String img, {String? tag}) => Column(mainAxisSize: MainAxisSize.min, children: [
  SizedBox(
    height: 280,
    width: double.infinity,
    child: Stack(fit: StackFit.expand, children: [
      tag == null ? NetImage(img) : Hero(tag: tag, child: NetImage(img)),
      const ColoredBox(color: Color(0x40000000)),
    ]),
  ),
  Container(height: 4, color: kPri),
]);

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
        ListView(padding: EdgeInsets.zero, children: [
          detailHero(s.img, tag: 'svc-img-${s.name}'),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Eyebrow('${s.sub}  •  ${s.status}', color: p.accent),
              const SizedBox(height: 8),
              Text(s.name, style: serif(34)),
              const SizedBox(height: 14),
              Container(width: 36, height: 3, color: kPri),
              const SizedBox(height: 16),
              Text(s.info, style: TextStyle(color: p.sub, fontSize: 16, height: 1.55)),
              const SizedBox(height: 24),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  detailRow(p, Icons.location_on_outlined, 'Location', s.location),
                  Divider(height: 1, color: p.line),
                  detailRow(p, Icons.access_time_rounded, 'Opening hours', s.hours),
                  Divider(height: 1, color: p.line),
                  detailRow(p, Icons.mail_outline_rounded, 'Contact', s.contact, onTap: () {
                    Clipboard.setData(ClipboardData(text: s.contact));
                    showToast(context, 'Contact copied: ${s.contact}');
                  }),
                ]),
              ),
              const SizedBox(height: 28),
              // Returned result: the previous route receives 'requested' and shows a confirmation.
              PrimaryButton(s.action, Icons.send_rounded, () => Navigator.pop(context, 'requested')),
              const SizedBox(height: 12),
              OutlineBtn('Return', () => Navigator.pop(context)), // plain pop: no result
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
  final bool registered;
  const EventDetailScreen({super.key, required this.event, required this.registered});

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final e = event;
    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(fit: StackFit.expand, children: [
        ListView(padding: EdgeInsets.zero, children: [
          detailHero(e.img),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Eyebrow(e.cat, color: p.accent),
              const SizedBox(height: 8),
              Text(e.title, style: serif(32, height: 1.15)),
              const SizedBox(height: 14),
              Container(width: 36, height: 3, color: kPri),
              const SizedBox(height: 16),
              Text(e.about, style: TextStyle(color: p.sub, fontSize: 16, height: 1.55)),
              const SizedBox(height: 24),
              Panel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  detailRow(p, Icons.event_rounded, 'Date & time', e.date),
                  Divider(height: 1, color: p.line),
                  detailRow(p, Icons.place_outlined, 'Venue', e.venue),
                  Divider(height: 1, color: p.line),
                  detailRow(p, Icons.groups_rounded, 'Attendance', e.going),
                ]),
              ),
              const SizedBox(height: 28),
              if (registered)
                Container(
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kSuccess.withOpacity(.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: kSuccess),
                  ),
                  child: const Text('✓ You are registered',
                      style: TextStyle(color: kSuccess, fontSize: 15.5, fontWeight: FontWeight.w800)),
                )
              else
                PrimaryButton('Register now', Icons.how_to_reg_rounded, () => Navigator.pop(context, 'registered')),
              const SizedBox(height: 12),
              OutlineBtn('Return', () => Navigator.pop(context)),
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('404', style: serif(88, color: p.accent, height: 1)),
              const SizedBox(height: 10),
              Container(width: 36, height: 3, color: kPri),
              const SizedBox(height: 18),
              Text('This page does not exist', style: serif(22)),
              const SizedBox(height: 12),
              Pill(routeName, kPri, icon: Icons.link_off_rounded),
              const SizedBox(height: 12),
              Text('The app could not open this route. Go back and try another option.',
                  textAlign: TextAlign.center, style: TextStyle(color: p.sub, height: 1.5)),
              const SizedBox(height: 28),
              SizedBox(width: 220, child: PrimaryButton('Go back', Icons.arrow_back_rounded, () => Navigator.maybePop(context))),
            ]),
          ),
        ),
      ),
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
    [Icons.home_outlined, 'Home'],
    [Icons.calendar_month_outlined, 'Schedule'],
    [Icons.edit_note_rounded, 'Request'],
    [Icons.grid_view_rounded, 'Services'],
    [Icons.person_outline_rounded, 'Profile'],
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(index: i, children: [
      HomePage(go: (n) => setState(() => i = n)),
      const SchedulePage(),
      const RequestPage(),
      const ServicesPage(),
      const ProfilePage(),
    ]),
    bottomNavigationBar: NavigationBar(
      selectedIndex: i,
      onDestinationSelected: (n) => setState(() => i = n),
      destinations: [
        for (final it in items) NavigationDestination(icon: Icon(it[0] as IconData), label: it[1] as String),
      ],
    ),
  );
}

// ═════════════════════════ HOME (DASHBOARD) ═════════════════════════
class HomePage extends StatelessWidget {
  final void Function(int) go;
  const HomePage({super.key, required this.go});

  Widget _stat(Pal p, String v, String l) => Expanded(
    child: Column(children: [
      Text(v, style: serif(26, color: p.accent)),
      const SizedBox(height: 2),
      Text(l, style: TextStyle(color: p.sub, fontSize: 12.5)),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final hr = DateTime.now().hour;
    final greet = hr < 12 ? 'Good morning' : hr < 18 ? 'Good afternoon' : 'Good evening';
    final today = classes.where((c) => c.day == todayIdx()).toList();
    final next = today.isNotEmpty ? today.first : classes.first;

    return ListView(padding: EdgeInsets.zero, children: [
      // ── Header: photo, app identity, greeting and the next class ──
      PhotoBackdrop(
        url: kImgCampus,
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Monogram(40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(kAppName, style: serif(19, color: Colors.white)),
                      const Text(kTagline, style: TextStyle(color: Colors.white70, fontSize: 12.5)),
                    ]),
                  ),
                  Tap(
                    label: 'Notifications',
                    onTap: () => showToast(context, 'You have 3 new announcements.'),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54)),
                      child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
                    ),
                  ),
                ]),
                const SizedBox(height: 34),
                Eyebrow(greet, color: Colors.white70),
                const SizedBox(height: 6),
                Text(kName, style: serif(36, color: Colors.white)),
                const SizedBox(height: 4),
                const Text(kProgram, style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                const SizedBox(height: 22),
                Tap(
                  label: 'Next class: ${next.name}. Open timetable',
                  onTap: () => openRoute(context, AppRoutes.timetable),
                  child: BarPanel(
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Eyebrow('Next class', color: p.accent),
                          const SizedBox(height: 4),
                          Text(next.name, style: serif(20)),
                          const SizedBox(height: 4),
                          Text('${next.start} – ${next.end}  •  ${next.room}  •  ${next.who}',
                              style: TextStyle(color: p.sub, fontSize: 13)),
                        ]),
                      ),
                      Icon(Icons.arrow_forward_rounded, color: p.accent),
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
          // ── Reminder ──
          const SizedBox(height: 22),
          Tap(
            label: 'Reminder: 2 library books due in 3 days',
            onTap: () => openService(context, services[0]),
            child: BarPanel(
              child: Row(children: [
                Icon(Icons.alarm_rounded, color: p.accent),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('2 library books due in 3 days', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    SizedBox(height: 2),
                    Text('Tap to renew or reserve a study room', style: TextStyle(fontSize: 12.5)),
                  ]),
                ),
                Icon(Icons.chevron_right_rounded, color: p.sub),
              ]),
            ),
          ),

          // ── Navigation cards (each opens a NAMED route with Navigator.pushNamed) ──
          const SectionTitle('Explore'),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: PhotoCard(
                img: kImgClass,
                label: 'Open Timetable',
                imgHeight: 92,
                onTap: () => openRoute(context, AppRoutes.timetable),
                caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Timetable', style: serif(17)),
                  const SizedBox(height: 2),
                  Text('10 classes this week', style: TextStyle(color: p.sub, fontSize: 12.5)),
                ]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PhotoCard(
                img: kImgLibrary,
                label: 'Open Services',
                imgHeight: 92,
                onTap: () => openRoute(context, AppRoutes.services),
                caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Services', style: serif(17)),
                  const SizedBox(height: 2),
                  Text('8 campus services', style: TextStyle(color: p.sub, fontSize: 12.5)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: PhotoCard(
                img: kImgStudents,
                label: 'Open Events',
                imgHeight: 92,
                onTap: () => openRoute(context, AppRoutes.events),
                caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Events', style: serif(17)),
                  const SizedBox(height: 2),
                  Text('5 happening soon', style: TextStyle(color: p.sub, fontSize: 12.5)),
                ]),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: PhotoCard(
                img: kImgGrad,
                label: 'Open Profile',
                imgHeight: 92,
                onTap: () => openRoute(context, AppRoutes.profile),
                caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Profile', style: serif(17)),
                  const SizedBox(height: 2),
                  Text(kId, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.sub, fontSize: 12.5)),
                ]),
              ),
            ),
          ]),

          // ── Academic overview ──
          const SectionTitle('Academic overview'),
          Panel(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Row(children: [
                _stat(p, '92%', 'Attendance'),
                Container(width: 1, height: 40, color: p.line),
                _stat(p, '3.55', 'CGPA'),
                Container(width: 1, height: 40, color: p.line),
                _stat(p, '84', 'Credits'),
              ]),
              const SizedBox(height: 20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Degree progress', style: TextStyle(color: p.sub, fontSize: 13, fontWeight: FontWeight.w600)),
                const Text('84 / 120 credits', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(value: .7, minHeight: 6, color: p.accent, backgroundColor: p.line),
              ),
            ]),
          ),

          // ── Today ──
          SectionTitle("Today's classes", action: 'See all', onTap: () => go(1)),
          if (today.isEmpty)
            Text('No classes today', style: TextStyle(color: p.sub))
          else
            for (int k = 0; k < today.length; k++) ClassCard(today[k], k, highlight: k == 0),

          SectionTitle('Popular services', action: 'View all', onTap: () => openRoute(context, AppRoutes.services)),
        ]),
      ),
      SizedBox(
        height: 196,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, k) {
            final s = services[k];
            return SizedBox(
              width: 170,
              child: PhotoCard(
                img: s.img,
                label: 'Open ${s.name}',
                imgHeight: 104,
                onTap: () => openService(context, s),
                caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, style: serif(16)),
                  const SizedBox(height: 2),
                  Text(s.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.sub, fontSize: 12.5)),
                ]),
              ),
            );
          },
        ),
      ),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SectionTitle('Upcoming events', action: 'View all', onTap: () => openRoute(context, AppRoutes.events)),
      ),
      SizedBox(
        height: 222,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          scrollDirection: Axis.horizontal,
          itemCount: events.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, i) => SizedBox(
            width: 260,
            child: PhotoCard(
              img: events[i].img,
              label: 'Open ${events[i].title}',
              imgHeight: 112,
              onTap: () async {
                final reg = await openEventDetail(context, i);
                if (reg && context.mounted) showToast(context, 'Registered for ${events[i].title}');
              },
              caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Eyebrow('${events[i].cat}  •  ${events[i].date}', color: p.accent),
                const SizedBox(height: 6),
                Text(events[i].title, maxLines: 1, overflow: TextOverflow.ellipsis, style: serif(17)),
                const SizedBox(height: 3),
                Text(events[i].venue, style: TextStyle(color: p.sub, fontSize: 12.5)),
              ]),
            ),
          ),
        ),
      ),

      // ── Notices: simple text list separated by hairlines ──
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionTitle('Announcements'),
          Divider(height: 1, color: p.line),
          for (final n in notices) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Eyebrow('${n[1]}  •  ${n[2]}', color: p.accent),
                const SizedBox(height: 6),
                Text(n[0], style: serif(17, w: FontWeight.w600, height: 1.3)),
              ]),
            ),
            Divider(height: 1, color: p.line),
          ],
        ]),
      ),
    ]);
  }
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
      PageHeader('Schedule', '${months[now.month - 1]} ${now.year}', kImgClass),
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
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: sel ? kPri : p.card,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sel ? kPri : p.line),
                  ),
                  child: Column(children: [
                    Text(names[i],
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 1, color: sel ? Colors.white70 : p.sub)),
                    const SizedBox(height: 5),
                    Text('${d.day}', style: serif(20, color: sel ? Colors.white : p.text)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
      Expanded(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: ListView(
            key: ValueKey(day),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: list.isEmpty
                ? [Padding(padding: const EdgeInsets.only(top: 60), child: Center(child: Text('No classes', style: TextStyle(color: p.sub, fontSize: 16))))]
                : [for (int k = 0; k < list.length; k++) ClassCard(list[k], k, highlight: day == todayIdx() && k == 0)],
          ),
        ),
      ),
    ]);
  }
}

class PageHeader extends StatelessWidget {
  final String title, sub, img;
  final Widget? extra;
  const PageHeader(this.title, this.sub, this.img, {super.key, this.extra});
  @override
  Widget build(BuildContext context) => PhotoBackdrop(
    url: img,
    child: SizedBox(
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 26),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: backGap(context)),
            Text(title, style: serif(34, color: Colors.white)),
            const SizedBox(height: 6),
            Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 14.5)),
            if (extra != null) ...[const SizedBox(height: 18), extra!],
          ]),
        ),
      ),
    ),
  );
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
    if (going.contains(i)) showToast(context, 'Registered for ${events[i].title}');
  }

  Future<void> _open(int i) async {
    final reg = await openEventDetail(context, i, registered: going.contains(i));
    if (!mounted) return;
    if (reg) {
      setState(() => going.add(i));
      showToast(context, 'Registered for ${events[i].title}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Pal.of(context);
    final cats = ['All', ...{for (final e in events) e.cat}];
    return Column(children: [
      PageHeader('Events', "What's happening at $kCollege", kImgGrad),
      SizedBox(
        height: 68,
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: sel ? kPri : p.card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: sel ? kPri : p.line),
                ),
                child: Text(cats[i], style: TextStyle(fontWeight: FontWeight.w700, color: sel ? Colors.white : p.sub)),
              ),
            );
          },
        ),
      ),
      Expanded(
        child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
          for (int i = 0; i < events.length; i++)
            if (filter == 'All' || events[i].cat == filter)
              Reveal(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Tap(
                    label: 'Open ${events[i].title}',
                    onTap: () => _open(i), // direct Navigator.push to the event details route
                    child: Panel(
                      padding: EdgeInsets.zero,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(height: 170, width: double.infinity, child: NetImage(events[i].img)),
                        Container(height: 3, color: kPri),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Eyebrow('${events[i].cat}  •  ${events[i].date}', color: p.accent),
                            const SizedBox(height: 8),
                            Text(events[i].title, style: serif(22, height: 1.2)),
                            const SizedBox(height: 8),
                            Row(children: [
                              Icon(Icons.place_outlined, size: 16, color: p.sub),
                              const SizedBox(width: 5),
                              Expanded(child: Text(events[i].venue, style: TextStyle(color: p.sub, fontSize: 13.5))),
                            ]),
                            const SizedBox(height: 14),
                            Row(children: [
                              Text(events[i].going, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Tap(
                                label: going.contains(i) ? 'Registered' : 'Register for ${events[i].title}',
                                onTap: () => _toggle(i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: going.contains(i) ? Colors.transparent : kPri,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: going.contains(i) ? kSuccess : kPri),
                                  ),
                                  child: Text(going.contains(i) ? '✓ Going' : 'Register',
                                      style: TextStyle(fontWeight: FontWeight.w800, color: going.contains(i) ? kSuccess : Colors.white)),
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
        'Everything you need, in one place',
        kImgLibrary,
        extra: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
          child: Row(children: [
            const Icon(Icons.search_rounded, color: Color(0xFF5E5E63)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => q = v),
                cursorColor: kPri,
                style: const TextStyle(color: kInk, fontSize: 15.5),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search services',
                  hintStyle: TextStyle(color: Color(0xFF6E6E73)),
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
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: list.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: .86),
          itemBuilder: (_, i) {
            final s = list[i];
            return Reveal(
              index: i,
              // Selected CampusService travels to the details route as an argument.
              child: PhotoCard(
                img: s.img,
                heroTag: 'svc-img-${s.name}',
                label: 'Open ${s.name}',
                imgHeight: 104,
                onTap: () => openService(context, s),
                caption: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: serif(17)),
                  const SizedBox(height: 2),
                  Text(s.sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: p.sub, fontSize: 12.5)),
                ]),
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

  Widget _tile(Pal p, IconData i, String t, Widget trailing, {VoidCallback? onTap}) => Tap(
    label: t,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Row(children: [
        Icon(i, color: p.accent, size: 22),
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
        child: SizedBox(
          width: double.infinity,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: Column(children: [
                SizedBox(height: backGap(context) * .6),
                const Avatar(88),
                const SizedBox(height: 14),
                Text(kName, style: serif(28, color: Colors.white)),
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Panel(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(children: [
              detailRow(p, Icons.school_outlined, 'Programme', 'B.Sc. Computer Science, Year 2'),
              Divider(height: 1, color: p.line),
              detailRow(p, Icons.mail_outline_rounded, 'Campus email', kEmail),
              Divider(height: 1, color: p.line),
              detailRow(p, Icons.badge_outlined, 'Student ID', kId),
            ]),
          ),
          const SectionTitle('Campus moments'),
          SizedBox(
            height: 112,
            child: ListView(
              scrollDirection: Axis.horizontal,
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
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(fit: StackFit.expand, children: [
                          NetImage(m[0]),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.center,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Color(0xB3000000)],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 10,
                            child: Text(m[1], style: serif(15, color: Colors.white)),
                          ),
                        ]),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SectionTitle('Settings'),
          Panel(
            padding: EdgeInsets.zero,
            child: Column(children: [
              _tile(p, Icons.person_outline_rounded, 'Edit profile', chevron,
                  onTap: () => showToast(context, 'Profile editing is coming soon.')),
              Divider(height: 1, color: p.line),
              _tile(p, Icons.edit_note_rounded, 'Raise a service request', chevron,
                  onTap: () => openRoute(context, AppRoutes.request)),
              Divider(height: 1, color: p.line),
              _tile(p, Icons.notifications_none_rounded, 'Notifications', chevron,
                  onTap: () => showToast(context, 'Notifications are switched on.')),
              Divider(height: 1, color: p.line),
              _tile(
                p,
                Icons.dark_mode_outlined,
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
              _tile(p, Icons.language_rounded, 'Language',
                  Text('English', style: TextStyle(color: p.sub, fontWeight: FontWeight.w600)),
                  onTap: () => showToast(context, 'English is the only language available.')),
              Divider(height: 1, color: p.line),
              _tile(p, Icons.help_outline_rounded, 'Help & support', chevron,
                  onTap: () => openService(context, services[7])),
              Divider(height: 1, color: p.line),
              // Test hook for the unknown-route fallback (test case T8).
              _tile(p, Icons.link_off_rounded, 'Test unknown route', chevron,
                  onTap: () => Navigator.pushNamed(context, '/does-not-exist')),
            ]),
          ),
        ]),
      ),
    ]);
  }
}

// ═════════════════════════ SERVICE REQUEST FORM ═════════════════════════
// Colour system: primary kPri (crimson), field fill = Pal.soft, error / success below.
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
      borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon, color: p.accent),
    filled: true,
    fillColor: p.soft,
    labelStyle: TextStyle(color: p.sub, fontSize: 15),
    hintStyle: TextStyle(color: p.sub.withOpacity(.7)),
    errorMaxLines: 2,
    errorStyle: const TextStyle(color: kError, fontWeight: FontWeight.w600, fontSize: 12.5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(p.line),
    enabledBorder: border(p.line),
    focusedBorder: border(p.accent, 2),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
    child: Panel(
      radius: 8,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: kPri.withOpacity(.10),
              borderRadius: BorderRadius.circular(6),
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
            child: SizedBox(
              width: double.infinity,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(height: backGap(context)),
                    Row(children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.16),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(.4)),
                        ),
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
                            fontFamily: 'Georgia', fontFamilyFallback: ['Times New Roman', 'serif'], color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
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
                  child: PrimaryButton('Submit request', Icons.send_rounded, _submit),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p.text,
                      side: BorderSide(color: p.line, width: 1.5),
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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