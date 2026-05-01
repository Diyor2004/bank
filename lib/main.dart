import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('transactions');
  
  final prefs = await SharedPreferences.getInstance();
  final langCode = prefs.getString('language_code') ?? 'uz';
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(langCode)),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: const PaymentApp(),
    ),
  );
}


// --- Models ---
class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final bool isIncome;
  final String status;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.isIncome,
    this.status = 'Muvaffaqiyatli',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'amount': amount,
    'date': date.millisecondsSinceEpoch, 'isIncome': isIncome, 'status': status,
  };

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) => TransactionModel(
    id: map['id'], title: map['title'], amount: map['amount'],
    date: DateTime.fromMillisecondsSinceEpoch(map['date']),
    isIncome: map['isIncome'], status: map['status'] ?? 'Muvaffaqiyatli',
  );
}

// --- Providers ---
class TransactionProvider extends ChangeNotifier {
  final _box = Hive.box('transactions');
  List<TransactionModel> _items = [];
  List<TransactionModel> get items => _items;

  TransactionProvider() {
    _load();
  }

  void _load() {
    _items = _box.values.map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e))).toList();
    _items.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel tx) async {
    await _box.add(tx.toMap());
    _load();
  }
}

// --- Locale Provider (Best Practice) ---
class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('uz');
  Locale get locale => _locale;

  LocaleProvider(String langCode) {
    _locale = Locale(langCode);
  }

  void setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners(); // This triggers Global Rebuild
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
  }
}

// --- Global States ---
final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

enum CardType { visa, mastercard, humo, uzcard, unknown }

class UserData {
  final String name;
  final String phone;
  const UserData({required this.name, required this.phone});
}

final userNotifier = ValueNotifier<UserData>(const UserData(name: "Diyor", phone: "+998 90 123 45 67"));

// --- Global Keys ---
final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

// --- Translation System ---
class Tran {
  static final Map<String, Map<String, String>> _data = {
    'uz': {
      'welcome': 'Xush kelibsiz', 'enter_pin': 'PIN-kodni kiriting', 'set_pin': 'Yangi PIN-kod o\'rnating',
      'confirm_pin': 'PIN-kodni tasdiqlang', 'wrong_pin': 'PIN-kod noto\'g\'ri!', 'mismatch_pin': 'Kodlar mos kelmadi!',
      'home': 'Asosiy', 'payments': 'To\'lovlar', 'history': 'Tarix', 'profile': 'Profil', 'transfer': 'O\'tkazma',
      'qr_pay': 'QR To\'lov', 'edit_profile': 'Profilni tahrirlash', 'language': 'Ilova tili',
      'logout': 'Chiqish', 'save': 'Saqlash', 'scan_qr': 'QR kodni skanerlang', 'recent': 'So\'nggi amallar',
      'hello': 'Salom!', 'services': 'Xizmatlar', 'more': 'Yana', 'today': 'Bugun', 'yesterday': 'Kecha',
      'security': 'Xavfsizlik', 'edit': 'Tahrirlash', 'name_hint': 'Ism Familiya', 'phone_hint': 'Telefon raqam',
      'amount': 'To\'lov miqdori', 'card_number': 'Karta raqami', 'holder': 'Karta egasi', 'done': 'Bajarildi!',
      'back_home': 'Asosiyga qaytish', 'communal': 'Kommunal', 'mobile': 'Mobil aloqa', 'internet': 'Internet',
      'gov': 'Davlat', 'search': 'Qidirish...', 'on': 'Yoqilgan', 'off': 'O\'chirilgan', 'send': 'Yuborish',
      'to_whom': 'Kimga?', 'how_much': 'Qancha?',
      'support': "Qo'llab-quvvatlash tizimi", 'fines': 'Jarimalar haqida xabarnoma', 'theme': 'Mavzu',
      'light_mode': 'Kunduzgi rejim', 'dark_mode': 'Tungi rejim', 'call_support': "1350 ga qo'ng'iroq qilish",
      'chat_expert': 'Mutaxassis bilan chat', 'write_us': 'Bizga yozing', 'chat': 'Chat',
      'chat_welcome': 'Assalomu alaykum! Sizga qanday yordam bera olamiz?', 'type_message': 'Xabar yozing...',
      'biometric_login': 'Biometrika orqali kirish', 'biometric_desc': 'Barmoq izi yoki Yuz orqali',
      'change_pin': "PIN kodni o'zgartirish", 'no_biometric': 'Qurilmada biometrika mavjud emas',
      'enter_new_pin': 'Yangi PIN kodni kiriting', 'repeat_new_pin': 'PIN kodni takrorlang',
      'pin_changed': "PIN kod muvaffaqiyatli o'zgartirildi!",
      'no_fines': "Sizda hozircha jarimalar yo'q",
      'connecting_expert': 'Tez orada mutaxassis ulanadi...',
      'phone_error': 'Telefon oynasini ochib bo\'lmadi',
      'sms_error': 'SMS oynasini ochib bo\'lmadi',
      'gov_services': 'Davlat xizmatlari',
    },
    'ru': {
      'welcome': 'Добро пожаловать', 'enter_pin': 'Введите ПИН-код', 'set_pin': 'Установите новый ПИН-код',
      'confirm_pin': 'Подтвердите ПИН-код', 'wrong_pin': 'Неверный ПИН-код!', 'mismatch_pin': 'Коды не совпадают!',
      'home': 'Главная', 'payments': 'Платежи', 'history': 'История', 'profile': 'Профиль', 'transfer': 'Перевод',
      'qr_pay': 'QR Оплата', 'edit_profile': 'Изменить профиль', 'language': 'Язык приложения',
      'logout': 'Выйти', 'save': 'Сохранить', 'scan_qr': 'Сканируйте QR код', 'recent': 'Последние операции',
      'hello': 'Привет!', 'services': 'Сервисы', 'more': 'Еще', 'today': 'Сегодня', 'yesterday': 'Вчера',
      'security': 'Безопасность', 'edit': 'Изменить', 'name_hint': 'Имя Фамилия', 'phone_hint': 'Номер телефона',
      'amount': 'Сумма оплаты', 'card_number': 'Номер карты', 'holder': 'Владелец карты', 'done': 'Готово!',
      'back_home': 'На главную', 'communal': 'Коммунальные', 'mobile': 'Мобильная связь', 'internet': 'Интернет',
      'gov': 'Госуслуги', 'search': 'Поиск...', 'on': 'Вкл', 'off': 'Выкл', 'send': 'Отправить', 'to_whom': 'Кому?',
      'how_much': 'Сколько?',
      'support': 'Система поддержки', 'fines': 'Уведомления о штрафах', 'theme': 'Тема',
      'light_mode': 'Дневной режим', 'dark_mode': 'Ночной режим', 'call_support': 'Позвонить на 1350',
      'chat_expert': 'Чат со специалистом', 'write_us': 'Напишите нам', 'chat': 'Chat',
      'chat_welcome': 'Здравствуйте! Чем мы можем вам помочь?', 'type_message': 'Введите сообщение...',
      'biometric_login': 'Вход по биометрии', 'biometric_desc': 'Отпечаток пальца или лицо',
      'change_pin': 'Изменить ПИН-код', 'no_biometric': 'Биометрия недоступна на устройстве',
      'enter_new_pin': 'Введите новый ПИН-код', 'repeat_new_pin': 'Повторите новый ПИН-код',
      'pin_changed': 'ПИН-код успешно изменен!',
      'no_fines': 'У вас пока нет штрафов',
      'connecting_expert': 'Специалист скоро подключится...',
      'phone_error': 'Не удалось открыть приложение телефона',
      'sms_error': 'Не удалось открыть приложение SMS',
    },
    'en': {
      'welcome': 'Welcome', 'enter_pin': 'Enter PIN code', 'set_pin': 'Set new PIN code',
      'confirm_pin': 'Confirm PIN code', 'wrong_pin': 'Incorrect PIN code!', 'mismatch_pin': 'PINs do not match!',
      'home': 'Home', 'payments': 'Payments', 'history': 'History', 'profile': 'Profile', 'transfer': 'Transfer',
      'qr_pay': 'QR Pay', 'edit_profile': 'Edit Profile', 'language': 'Language',
      'logout': 'Logout', 'save': 'Save', 'scan_qr': 'Scan QR Code', 'recent': 'Recent actions', 'hello': 'Hello!',
      'services': 'Services', 'more': 'More', 'today': 'Today', 'yesterday': 'Yesterday', 'security': 'Security',
      'edit': 'Edit', 'name_hint': 'Full Name', 'phone_hint': 'Phone Number', 'amount': 'Payment amount',
      'card_number': 'Card number', 'holder': 'Card holder', 'done': 'Done!', 'back_home': 'Back to home',
      'communal': 'Communal', 'mobile': 'Mobile', 'internet': 'Internet', 'gov': 'Government', 'search': 'Search...',
      'on': 'On', 'off': 'Off', 'send': 'Send', 'to_whom': 'To whom?', 'how_much': 'How much?',
      'support': 'Support System', 'fines': 'Fine Notifications', 'theme': 'Theme',
      'light_mode': 'Light Mode', 'dark_mode': 'Dark Mode', 'call_support': 'Call 1350',
      'chat_expert': 'Chat with Expert', 'write_us': 'Write to us', 'chat': 'Chat',
      'chat_welcome': 'Hello! How can we help you?', 'type_message': 'Type a message...',
      'biometric_login': 'Biometric Login', 'biometric_desc': 'Fingerprint or Face',
      'change_pin': 'Change PIN Code', 'no_biometric': 'Biometrics not available on device',
      'enter_new_pin': 'Enter new PIN code', 'repeat_new_pin': 'Repeat new PIN code',
      'pin_changed': 'PIN code changed successfully!',
      'no_fines': 'You have no fines yet',
      'connecting_expert': 'An expert will connect soon...',
      'phone_error': 'Could not open the phone app',
      'sms_error': 'Could not open the SMS app',
    }
  };
  static String get(String key, BuildContext context) {
    final locale = Provider.of<LocaleProvider>(context).locale;
    return _data[locale.languageCode]?[key] ?? key;
  }
}

// --- Common UI Components ---
class BounceWrapper extends StatefulWidget {
  final Widget child; final VoidCallback onTap;
  const BounceWrapper({super.key, required this.child, required this.onTap});
  @override State<BounceWrapper> createState() => _BounceWrapperState();
}
class _BounceWrapperState extends State<BounceWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override void initState() { _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.05); super.initState(); }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) => GestureDetector(behavior: HitTestBehavior.opaque, onTapDown: (_) => _controller.forward(), onTapUp: (_) { _controller.reverse(); widget.onTap(); }, onTapCancel: () => _controller.reverse(), child: AnimatedBuilder(animation: _controller, builder: (context, child) => Transform.scale(scale: 1 - _controller.value, child: child!), child: widget.child));
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});
  @override Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, child) => MaterialApp(
        locale: localeProvider.locale, // Reacts immediately to Provider change
        debugShowCheckedModeBanner: false,
        themeMode: mode,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: const Color(0xFF3B82F6), scaffoldBackgroundColor: const Color(0xFFF8FAFC), textTheme: GoogleFonts.plusJakartaSansTextTheme()),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: const Color(0xFF3B82F6), scaffoldBackgroundColor: const Color(0xFF0F172A), textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)),
        home: const LoginScreen()
      ),
    );
  }
}

// --- Login Screen ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _pin = ValueNotifier<String>(""), _error = ValueNotifier<bool>(false), _confirm = ValueNotifier<bool>(false);
  String _firstEntry = ""; String? _stored;
  @override void initState() { super.initState(); _load(); }
  void _load() async { final p = await SharedPreferences.getInstance(); if (mounted) setState(() => _stored = p.getString('user_pin')); }
  void _handle(String n) async {
    if (n == 'del') { if (_pin.value.isNotEmpty) { _pin.value = _pin.value.substring(0, _pin.value.length - 1); _error.value = false; } return; }
    if (_pin.value.length < 4) {
      _pin.value += n; _error.value = false;
      if (_pin.value.length == 4) {
        final ent = _pin.value;
        if (_stored == null) {
          if (!_confirm.value) { _firstEntry = ent; _pin.value = ""; _confirm.value = true; }
          else if (ent == _firstEntry) { final p = await SharedPreferences.getInstance(); await p.setString('user_pin', ent); if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen())); }
          else { _error.value = true; _pin.value = ""; HapticFeedback.vibrate(); }
        } else if (ent == _stored) { if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen())); }
        else { _error.value = true; _pin.value = ""; HapticFeedback.vibrate(); }
      }
    }
  }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(body: Column(children: [const Spacer(), ValueListenableBuilder<bool>(valueListenable: _error, builder: (c, e, _) => RepaintBoundary(child: Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: e ? Colors.red.withValues(alpha: 0.1) : Theme.of(c).primaryColor.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(e ? Icons.lock_outline_rounded : Icons.lock_person_rounded, size: 64, color: e ? Colors.red : Theme.of(c).primaryColor)))), const SizedBox(height: 24), ValueListenableBuilder2<bool, bool>(first: _confirm, second: _error, builder: (c, con, e, _) { String k = _stored == null ? (con ? 'confirm_pin' : 'set_pin') : 'welcome'; if (e) k = _stored == null ? 'mismatch_pin' : 'wrong_pin'; return Text(Tran.get(k, c), style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: e ? Colors.red : null)); }), if (_stored != null) Text(Tran.get('enter_pin', context), style: const TextStyle(color: Color(0xFF64748B))), const SizedBox(height: 48), RepaintBoundary(child: ValueListenableBuilder2<String, bool>(first: _pin, second: _error, builder: (c, p, e, _) => Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: i < p.length ? (e ? Colors.red : Theme.of(c).primaryColor) : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)))))))), const Spacer(), RepaintBoundary(child: PinKeypad(onKeyPress: _handle, isDark: isDark)), const SizedBox(height: 48)]));
  }
}

class PinKeypad extends StatelessWidget {
  final Function(String) onKeyPress; final bool isDark;
  const PinKeypad({super.key, required this.onKeyPress, required this.isDark});
  @override Widget build(BuildContext context) => Column(children: [for (var r in [['1','2','3'],['4','5','6'],['7','8','9']]) Row(mainAxisAlignment: MainAxisAlignment.center, children: r.map((n) => PinKey(value: n, onKeyPress: onKeyPress, isDark: isDark)).toList()), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 100), PinKey(value: '0', onKeyPress: onKeyPress, isDark: isDark), PinKey(value: 'del', onKeyPress: onKeyPress, isDark: isDark, icon: Icons.backspace_outlined)])]);
}

class PinKey extends StatelessWidget {
  final String value; final Function(String) onKeyPress; final bool isDark; final IconData? icon;
  const PinKey({super.key, required this.value, required this.onKeyPress, required this.isDark, this.icon});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.all(10), child: BounceWrapper(onTap: () => onKeyPress(value), child: Container(width: 80, height: 80, alignment: Alignment.center, decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.02), shape: BoxShape.circle), child: icon != null ? Icon(icon, size: 28) : Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600)))));
}

class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first; final ValueListenable<B> second; final Widget Function(BuildContext, A, B, Widget?) builder; final Widget? child;
  const ValueListenableBuilder2({super.key, required this.first, required this.second, required this.builder, this.child});
  @override Widget build(BuildContext context) => ValueListenableBuilder<A>(valueListenable: first, builder: (context, a, _) => ValueListenableBuilder<B>(valueListenable: second, builder: (context, b, _) => builder(context, a, b, child)));
}

// --- Main Navigation & Drawer ---
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _curr = 0;
  final List<Widget> _pages = const [HomeScreen(), PaymentsScreen(), ServicesPage(), HistoryScreen()];

  Future<void> _showExitDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text('Ilovadan chiqish'),
          ],
        ),
        content: const Text('Rostdan ham ilovadan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Ha', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog();
      },
      child: Scaffold(
        key: scaffoldKey, drawerEnableOpenDragGesture: false, drawer: const AppDrawer(),
        body: IndexedStack(index: _curr, children: _pages),
        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavItem(icon: Icons.grid_view_rounded, label: Tran.get('home', context), isSelected: _curr == 0, onTap: () => setState(() => _curr = 0)),
              NavItem(icon: Icons.account_balance_wallet_rounded, label: Tran.get('payments', context), isSelected: _curr == 1, onTap: () => setState(() => _curr = 1)),
              const SizedBox(width: 40),
              NavItem(icon: Icons.dashboard_rounded, label: Tran.get('services', context), isSelected: _curr == 2, onTap: () => setState(() => _curr = 2)),
              NavItem(icon: Icons.analytics_rounded, label: Tran.get('history', context), isSelected: _curr == 3, onTap: () => setState(() => _curr = 3)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen())), backgroundColor: const Color(0xFF3B82F6), shape: const CircleBorder(), child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}

class NavItem extends StatelessWidget {
  final IconData icon; final String label; final bool isSelected; final VoidCallback onTap;
  const NavItem({super.key, required this.icon, required this.label, required this.isSelected, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isSelected ? const Color(0xFF3B82F6) : Colors.grey), Text(label, style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFF3B82F6) : Colors.grey, fontWeight: FontWeight.bold))]));
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Drawer(backgroundColor: Theme.of(context).scaffoldBackgroundColor, child: SafeArea(child: Column(children: [ValueListenableBuilder<UserData>(valueListenable: userNotifier, builder: (c, u, _) => Container(padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24), child: Column(children: [CircleAvatar(radius: 45, backgroundColor: const Color(0xFF3B82F6), child: Text(u.name[0], style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold))), const SizedBox(height: 16), Text(u.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const SizedBox(height: 8), TextButton(onPressed: () { Navigator.pop(c); Navigator.push(c, MaterialPageRoute(builder: (_) => const EditProfileScreen())); }, style: TextButton.styleFrom(foregroundColor: const Color(0xFF3B82F6)), child: Text(Tran.get('edit_profile', context), style: const TextStyle(fontWeight: FontWeight.bold)))]))), const Divider(height: 1), Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), children: [_drawerItem(icon: Icons.notifications_active_rounded, title: Tran.get('fines', context), hasBadge: true, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinesPage()))), _drawerItem(icon: Icons.language_rounded, title: Tran.get('language', context), onTap: () => _showLang(context)), _drawerItem(icon: Icons.security_rounded, title: Tran.get('security', context), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityPage()))), _drawerItem(icon: Icons.support_agent_rounded, title: Tran.get('support', context), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage()))), const SizedBox(height: 8), Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(leading: const Icon(Icons.palette_rounded, color: Color(0xFF3B82F6)), title: Text(Tran.get('theme', context), style: const TextStyle(fontWeight: FontWeight.w600)), childrenPadding: const EdgeInsets.only(left: 16), children: [ListTile(leading: const Icon(Icons.light_mode_rounded, size: 20), title: Text(Tran.get('light_mode', context)), onTap: () => themeNotifier.value = ThemeMode.light, trailing: !isDark ? const Icon(Icons.check, color: Color(0xFF3B82F6), size: 20) : null), ListTile(leading: const Icon(Icons.dark_mode_rounded, size: 20), title: Text(Tran.get('dark_mode', context)), onTap: () => themeNotifier.value = ThemeMode.dark, trailing: isDark ? const Icon(Icons.check, color: Color(0xFF3B82F6), size: 20) : null)]))])), Padding(padding: const EdgeInsets.all(16.0), child: CheckoutButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false), label: Tran.get('logout', context), isSecondary: true))])));
  }
  Widget _drawerItem({required IconData icon, required String title, bool hasBadge = false, required VoidCallback onTap}) => ListTile(leading: Icon(icon, color: const Color(0xFF3B82F6)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: hasBadge ? Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)) : const Icon(Icons.chevron_right_rounded, size: 20), onTap: onTap);
  void _showLang(BuildContext context) {
    final lp = Provider.of<LocaleProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text("O'zbek tili"), onTap: () { lp.setLocale(const Locale('uz')); Navigator.pop(c); }),
          ListTile(title: const Text("Русский язык"), onTap: () { lp.setLocale(const Locale('ru')); Navigator.pop(c); }),
          ListTile(title: const Text("English"), onTap: () { lp.setLocale(const Locale('en')); Navigator.pop(c); }),
        ],
      ),
    );
  }
}

// --- Screens ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  void _showMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 25),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              children: [
                _moreItem(context, icon: Icons.currency_exchange_rounded, labelKey: 'rates', color: Colors.blue),
                _moreItem(context, icon: Icons.location_on_rounded, labelKey: 'atms', color: Colors.green),
                _moreItem(context, icon: Icons.card_giftcard_rounded, labelKey: 'cashback', color: Colors.orange),
                _moreItem(context, icon: Icons.settings_rounded, labelKey: 'settings', color: Colors.purple),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _moreItem(BuildContext context, {required IconData icon, required String labelKey, required Color color}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(Tran.get(labelKey, context), textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final recentTxs = txProvider.items.take(2).toList();
    
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Bank App', style: TextStyle(fontWeight: FontWeight.bold)), actions: [ValueListenableBuilder<UserData>(valueListenable: userNotifier, builder: (c, u, _) => Padding(padding: const EdgeInsets.only(right: 12), child: IconButton(onPressed: () => scaffoldKey.currentState?.openDrawer(), icon: CircleAvatar(radius: 18, backgroundColor: const Color(0xFF3B82F6), child: Text(u.name[0], style: const TextStyle(color: Colors.white, fontSize: 14))))))]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const RepaintBoundary(child: VisualCreditCard(cardNumber: "8600 **** **** 4582", expiryDate: "12/28", cardHolder: "DIYOR", cardType: CardType.uzcard)),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HomeActionItem(icon: Icons.swap_horiz_rounded, labelKey: 'transfer', color: Colors.blue, screen: TransferMoneyScreen()),
                const HomeActionItem(icon: Icons.qr_code_2_rounded, labelKey: 'qr_pay', color: Colors.orange, screen: QRScannerScreen()),
                HomeActionItem(icon: Icons.receipt_long_rounded, labelKey: 'services', color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicesPage()))),
                HomeActionItem(icon: Icons.more_horiz_rounded, labelKey: 'more', color: Colors.purple, onTap: () => _showMoreSheet(context)),
              ],
            ),
            const SizedBox(height: 32),
            Text(Tran.get('recent', context), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (recentTxs.isEmpty)
              const Center(child: Text("Hozircha amallar yo'q", style: TextStyle(color: Colors.grey)))
            else
              ...recentTxs.map((tx) => TransactionHistoryItem(
                title: tx.title,
                time: DateFormat('dd MMM, HH:mm').format(tx.date),
                amount: "${tx.isIncome ? '+' : '-'} ${NumberFormat.decimalPattern().format(tx.amount).replaceAll(',', ' ')}",
                icon: tx.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                color: tx.isIncome ? Colors.green : Colors.red,
              )),
          ],
        ),
      ),
    );
  }
}

class HomeActionItem extends StatelessWidget {
  final IconData icon; final String labelKey; final Color color; final Widget? screen; final VoidCallback? onTap;
  const HomeActionItem({super.key, required this.icon, required this.labelKey, required this.color, this.screen, this.onTap});
  @override Widget build(BuildContext context) => BounceWrapper(onTap: () {
    if (onTap != null) {
      onTap!();
    } else if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }, child: Column(children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), child: Icon(icon, color: color)), const SizedBox(height: 8), Text(Tran.get(labelKey, context), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]));
}

class TransactionHistoryItem extends StatelessWidget {
  final String title, time, amount; final IconData icon; final Color color;
  const TransactionHistoryItem({super.key, required this.title, required this.time, required this.amount, required this.icon, required this.color});
  @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))), child: Row(children: [CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(icon, color: color, size: 20)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12))])), Text("$amount UZS", style: TextStyle(fontWeight: FontWeight.bold, color: color))]));
}

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    appBar: PaymentAppBar(title: Tran.get('payments', context)),
    body: GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        PaymentCategoryItem(titleKey: 'communal', icon: Icons.home, color: Colors.blue, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentFlowScreen()))),
        PaymentCategoryItem(titleKey: 'mobile', icon: Icons.phone_android, color: Colors.green, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobilePaymentScreen()))),
        PaymentCategoryItem(titleKey: 'internet', icon: Icons.wifi, color: Colors.purple, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InternetProvidersPage()))),
        PaymentCategoryItem(titleKey: 'gov', icon: Icons.account_balance, color: Colors.orange, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GovServicesPage()))),
      ]
    )
  );
}

class PaymentCategoryItem extends StatelessWidget {
  final String titleKey; final IconData icon; final Color color; final VoidCallback onTap;
  const PaymentCategoryItem({super.key, required this.titleKey, required this.icon, required this.color, required this.onTap});
  @override build(BuildContext context) => BounceWrapper(onTap: onTap, child: Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 30), const SizedBox(height: 10), Text(Tran.get(titleKey, context), style: const TextStyle(fontWeight: FontWeight.bold))])));
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final items = txProvider.items;

    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('history', context)),
      body: items.isEmpty
          ? const Center(child: Text("Tarix bo'sh", style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final tx = items[i];
                final dateStr = DateFormat('dd MMM, HH:mm').format(tx.date);
                final amountStr = NumberFormat.decimalPattern().format(tx.amount).replaceAll(',', ' ');
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: (tx.isIncome ? Colors.green : Colors.red).withValues(alpha: 0.1),
                        child: Icon(tx.isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: tx.isIncome ? Colors.green : Colors.red, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(tx.status, style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "${tx.isIncome ? '+' : '-'} $amountStr UZS",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: tx.isIncome ? Colors.green : Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final n = TextEditingController(text: userNotifier.value.name), p = TextEditingController(text: userNotifier.value.phone);
    return Scaffold(appBar: PaymentAppBar(title: Tran.get('edit', context)), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [CustomInputField(hint: Tran.get('name_hint', context), controller: n), const SizedBox(height: 16), CustomInputField(hint: Tran.get('phone_hint', context), controller: p), const Spacer(), CheckoutButton(onPressed: () { userNotifier.value = UserData(name: n.text, phone: p.text); Navigator.pop(context); }, label: Tran.get('save', context))])));
  }
}

// --- Formatters ---
class CardNumberFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    var t = newV.text.replaceAll(' ', ''); if (t.length > 16) t = t.substring(0, 16);
    var b = StringBuffer(); for (int i = 0; i < t.length; i++) { b.write(t[i]); if ((i + 1) % 4 == 0 && (i + 1) != t.length) b.write(' '); }
    final s = b.toString(); return TextEditingValue(text: s, selection: TextSelection.collapsed(offset: s.length));
  }
}
class AmountFormatter extends TextInputFormatter {
  @override TextEditingValue formatEditUpdate(TextEditingValue oldV, TextEditingValue newV) {
    if (newV.text.isEmpty) return newV.copyWith(text: '');
    String t = newV.text.replaceAll(RegExp(r'[^0-9]'), ''), f = '';
    for (int i = 0; i < t.length; i++) { if ((t.length - i) % 3 == 0 && i != 0) f += ' '; f += t[i]; }
    return TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

// --- Common UI ---
class VisualCreditCard extends StatelessWidget {
  final String cardNumber, expiryDate, cardHolder; final CardType cardType;
  const VisualCreditCard({super.key, required this.cardNumber, required this.expiryDate, required this.cardHolder, this.cardType = CardType.unknown});
  @override Widget build(BuildContext context) => Container(width: double.infinity, height: 210, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))]), padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Icon(Icons.contactless, color: Colors.white, size: 32), Text(cardType.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))]), const Spacer(), Text(cardNumber, style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 22, letterSpacing: 2)), const SizedBox(height: 20), Text(cardHolder, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]));
}
class CustomInputField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  const CustomInputField({
    super.key,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(15),
          ),
        ),
      );
}

class AmountInputSection extends StatelessWidget {
  final TextEditingController controller;
  const AmountInputSection({super.key, required this.controller});
  @override build(c) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(c).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: Theme.of(c).dividerColor.withValues(alpha: 0.1))), child: TextField(controller: controller, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue), keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, AmountFormatter()], decoration: const InputDecoration(border: InputBorder.none, suffixText: " UZS")));
}

class CheckoutButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading, isSecondary;
  const CheckoutButton({super.key, required this.onPressed, required this.label, this.isLoading = false, this.isSecondary = false});
  @override
  build(c) => BounceWrapper(
      onTap: onPressed,
      child: Container(
          height: 60,
          decoration: BoxDecoration(color: isSecondary ? Colors.red.withValues(alpha: 0.1) : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20), border: isSecondary ? Border.all(color: Colors.red.withValues(alpha: 0.2)) : null),
          child: Center(child: isLoading ? const CircularProgressIndicator() : Text(label, style: TextStyle(color: isSecondary ? Colors.red : Colors.white, fontWeight: FontWeight.bold)))));
}

class PaymentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  const PaymentAppBar({super.key, required this.title, this.onBack});
  @override
  build(c) => AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, leading: onBack != null ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: onBack) : null);
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class RecipientCard extends StatelessWidget {
  final String name, id;
  final IconData icon;
  const RecipientCard({super.key, required this.name, required this.id, required this.icon});
  @override
  build(c) => Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Theme.of(c).cardColor, borderRadius: BorderRadius.circular(15), border: Border.all(color: Theme.of(c).dividerColor.withValues(alpha: 0.1))),
      child: Row(children: [Icon(icon, color: Colors.blue), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12))])]));
}

class SectionHeader extends StatelessWidget {
  final String titleKey;
  const SectionHeader({super.key, required this.titleKey});
  @override
  build(c) => Text(Tran.get(titleKey, c), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));
}

// --- Flow Screens ---
class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: Text(Tran.get('qr_pay', context)), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Stack(children: [
        MobileScanner(onDetect: (cap) {
          if (cap.barcodes.isNotEmpty) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QRPaymentAmountScreen(merchantName: cap.barcodes.first.rawValue ?? "Unknown Merchant")));
        }),
        Center(child: Container(width: 200, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(20)))),
        Positioned(bottom: 50, left: 0, right: 0, child: Center(child: Text(Tran.get('scan_qr', context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))
      ]));
}

class QRPaymentAmountScreen extends StatelessWidget {
  final String merchantName;
  const QRPaymentAmountScreen({super.key, required this.merchantName});
  @override
  Widget build(BuildContext context) {
    final c = TextEditingController();
    return Scaffold(
        appBar: PaymentAppBar(title: Tran.get('qr_pay', context)),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              RecipientCard(name: merchantName, id: 'QR Merchant', icon: Icons.store_rounded),
              const SizedBox(height: 24),
              AmountInputSection(controller: c),
              const Spacer(),
              CheckoutButton(
                  onPressed: () {
                    final amount = double.tryParse(c.text.replaceAll(' ', '')) ?? 0;
                    if (amount > 0) {
                      Provider.of<TransactionProvider>(context, listen: false).addTransaction(TransactionModel(
                        id: DateTime.now().toIso8601String(),
                        title: merchantName,
                        amount: amount,
                        date: DateTime.now(),
                        isIncome: false,
                      ));
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep()));
                    }
                  },
                  label: Tran.get('qr_pay', context))
            ])));
  }
}

class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({super.key});
  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  final _card = TextEditingController(), _amt = TextEditingController();
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: PaymentAppBar(title: Tran.get('transfer', context), onBack: () => Navigator.pop(context)),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionHeader(titleKey: 'to_whom'),
            const SizedBox(height: 12),
            CustomInputField(hint: Tran.get('card_number', context), controller: _card, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberFormatter()]),
            const SizedBox(height: 24),
            const SectionHeader(titleKey: 'how_much'),
            const SizedBox(height: 12),
            AmountInputSection(controller: _amt),
            const Spacer(),
            CheckoutButton(
                onPressed: () {
                  final amount = double.tryParse(_amt.text.replaceAll(' ', '')) ?? 0;
                  if (amount > 0 && _card.text.isNotEmpty) {
                    Provider.of<TransactionProvider>(context, listen: false).addTransaction(TransactionModel(
                      id: DateTime.now().toIso8601String(),
                      title: _card.text,
                      amount: amount,
                      date: DateTime.now(),
                      isIncome: false,
                    ));
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep()));
                  }
                },
                label: Tran.get('send', context))
          ])));
}

class SuccessReceiptStep extends StatelessWidget {
  const SuccessReceiptStep({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green, size: 80), const SizedBox(height: 20), Text(Tran.get('done', context), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 40), Padding(padding: const EdgeInsets.all(20), child: CheckoutButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), label: Tran.get('back_home', context)))])));
}

class PaymentFlowScreen extends StatelessWidget {
  const PaymentFlowScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: PaymentAppBar(title: Tran.get('communal', context), onBack: () => Navigator.pop(context)), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const RecipientCard(name: 'Artel Servis', id: 'ID: 12345678', icon: Icons.bolt), const Spacer(), CheckoutButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep())), label: Tran.get('save', context)), const SizedBox(height: 20)])));
}

class MobilePaymentScreen extends StatelessWidget {
  const MobilePaymentScreen({super.key});
  @override
  build(c) => Scaffold(appBar: PaymentAppBar(title: Tran.get('mobile', c), onBack: () => Navigator.pop(c)), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [const RecipientCard(name: 'Beeline', id: '+998 90 123 45 67', icon: Icons.phone_android), const Spacer(), CheckoutButton(onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => const SuccessReceiptStep())), label: Tran.get('payments', c)), const SizedBox(height: 20)])));
}

// --- Support & Security Screens ---

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  void _showPayLater(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.speed_rounded, size: 64, color: Colors.orange),
            const SizedBox(height: 24),
            const Text(
              "200 000 so'mgacha limit oling",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            CheckoutButton(onPressed: () => Navigator.pop(context), label: "Tushunarli"),
          ],
        ),
      ),
    );
  }

  void _showTickets(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Bank Tickets"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Kino chiptasini biz to'lab beramiz!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 12),
            Text(
              "To'lovni 10 kun ichida komissiyasiz qaytarishingiz mumkin",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Yopish")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('services', context)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _serviceItem(
            context,
            icon: Icons.directions_bus_rounded,
            title: "Metro va avtobus",
            subtitle: "Transport kartalarini to'ldirish",
            color: Colors.blue,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransportPage())),
          ),
          _serviceItem(
            context,
            icon: Icons.access_time_rounded,
            title: "Keyinroq to'lash",
            subtitle: "Muddatli to'lov xizmatlari",
            color: Colors.orange,
            onTap: () => _showPayLater(context),
          ),
          _serviceItem(
            context,
            icon: Icons.shield_outlined,
            title: "MIB jarimalari",
            subtitle: "Ma'muriy jarimalarni tekshirish",
            color: Colors.red,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MIBFinesPage())),
          ),
          _serviceItem(
            context,
            icon: Icons.confirmation_num_rounded,
            title: "Bank tickets",
            subtitle: "Navbat uchun elektron chiptalar",
            color: Colors.green,
            onTap: () => _showTickets(context),
          ),
          _serviceItem(
            context,
            icon: Icons.account_balance_wallet_rounded,
            title: "Hisob raqamiga to'lov",
            subtitle: "Bank rekvizitlari orqali o'tkazma",
            color: Colors.purple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Bizda hozircha unday xususiyat yo'q")),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _serviceItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

class FinesPage extends StatelessWidget {
  const FinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('fines', context)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline_rounded, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            Text(
              Tran.get('no_fines', context),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});
  
  Future<void> _makeCall(BuildContext context) async {
    final Uri url = Uri.parse('tel:1350');
    try {
      // launchUrl with tel: scheme directly
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Tran.get('phone_error', context))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('support', context)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _supportItem(
            icon: Icons.phone_rounded,
            title: Tran.get('call_support', context),
            onTap: () => _makeCall(context),
          ),
          const SizedBox(height: 12),
          _supportItem(
            icon: Icons.headset_mic_rounded,
            title: Tran.get('chat_expert', context),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveChatPage())),
          ),
          const SizedBox(height: 12),
          _supportItem(
            icon: Icons.sms_rounded,
            title: Tran.get('write_us', context),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatPage())),
          ),
        ],
      ),
    );
  }

  Widget _supportItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return BounceWrapper(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: Icon(icon, color: Colors.blue, size: 20),
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class LiveChatPage extends StatelessWidget {
  const LiveChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('chat_expert', context)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              Tran.get('connecting_expert', context),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _messages.add({
        "text": Tran.get("chat_welcome", context),
        "isMe": false,
        "time": DateFormat('HH:mm').format(DateTime.now()),
      });
      _isInit = true;
    }
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        "text": _controller.text.trim(),
        "isMe": true,
        "time": DateFormat('HH:mm').format(DateTime.now()),
      });
      _controller.clear();
    });
    
    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFE7EBF3),
      appBar: PaymentAppBar(
        title: Tran.get('chat', context),
        onBack: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isMe = msg["isMe"];
                
                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe 
                          ? const Color(0xFF3B82F6) 
                          : (isDark ? const Color(0xFF1E293B) : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isMe ? 18 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 18),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg["text"],
                          style: TextStyle(
                            color: isMe ? Colors.white : (isDark ? Colors.white : Colors.black87),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg["time"],
                          style: TextStyle(
                            color: isMe 
                                ? Colors.white.withValues(alpha: 0.7) 
                                : Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(
              left: 12, 
              right: 12, 
              top: 10, 
              bottom: MediaQuery.of(context).padding.bottom + 10
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: Tran.get('type_message', context),
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                BounceWrapper(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});
  @override State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _useBiometric = false;
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _useBiometric = p.getBool('use_biometric') ?? false);
  }

  void _toggleBiometric(bool val) async {
    if (val) {
      bool canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Tran.get('no_biometric', context))));
        return;
      }
    }
    final p = await SharedPreferences.getInstance();
    await p.setBool('use_biometric', val);
    setState(() => _useBiometric = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('security', context)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              leading: const Icon(Icons.fingerprint_rounded, color: Colors.blue),
              title: Text(Tran.get('biometric_login', context)),
              subtitle: Text(Tran.get('biometric_desc', context)),
              trailing: Switch(value: _useBiometric, onChanged: _toggleBiometric),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              leading: const Icon(Icons.password_rounded, color: Colors.blue),
              title: Text(Tran.get('change_pin', context)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePinScreen())),
            ),
          ),
        ],
      ),
    );
  }
}

class TransportPage extends StatelessWidget {
  const TransportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Transport", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Metro", icon: Icon(Icons.subway_rounded)),
              Tab(text: "Avtobus", icon: Icon(Icons.directions_bus_rounded)),
            ],
            indicatorColor: Color(0xFF3B82F6),
            labelColor: Color(0xFF3B82F6),
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: const TabBarView(
          children: [
            MetroStationList(),
            BusQRScanner(),
          ],
        ),
      ),
    );
  }
}

class MetroStationList extends StatefulWidget {
  const MetroStationList({super.key});

  @override
  State<MetroStationList> createState() => _MetroStationListState();
}

class _MetroStationListState extends State<MetroStationList> {
  final List<String> _stations = [
    "Alisher Navoiy", "Chilonzor", "Novza", "Milliy bog'", "Xalqlar do'stligi",
    "Poytaxt", "Mustaqillik maydoni", "Amir Temur xiyoboni", "Hamid Olimjon", "Pushkin",
    "Buyuk Ipak yo'li", "G'afur G'ulom", "Beruniy", "Tinchlik", "Chorsu", "Kosmonavtlar",
    "Oybek", "Toshkent", "Mashinasozlar", "Do'stlik", "O'zbekiston", "Tinchlik"
  ];
  List<String> _filteredStations = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredStations = _stations;
  }

  void _filter(String query) {
    setState(() {
      _filteredStations = _stations
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: CustomInputField(
            hint: "Bekatni qidiring...",
            controller: _searchController,
            onChanged: _filter,
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _filteredStations.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                child: const Icon(Icons.subway_rounded, color: Colors.blue, size: 20),
              ),
              title: Text(_filteredStations[index], style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class BusQRScanner extends StatelessWidget {
  const BusQRScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.qr_code_scanner_rounded, size: 100, color: Colors.blue.withValues(alpha: 0.2)),
          const SizedBox(height: 24),
          const Text(
            "Avtobus QR kodini skanerlang",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            "To'lovni amalga oshirish uchun kamerani oching",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: 200,
            child: CheckoutButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ScannerPage())),
              label: "Kamerani ochish",
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Skaner", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final code = barcodes.first.rawValue ?? "Noma'lum";
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Skanerlandi: $code")),
                );
              }
            },
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "QR kodni kvadrat ichiga joylashtiring",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MIBFinesPage extends StatelessWidget {
  const MIBFinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PaymentAppBar(title: "MIB Jarimalari"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "SADULLAYEV DIYORBEK",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1.2),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green),
                  SizedBox(width: 12),
                  Text(
                    "Jarimalar yo'q",
                    style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InternetProvidersPage extends StatelessWidget {
  const InternetProvidersPage({super.key});

  static const List<Map<String, dynamic>> providers = [
    {'name': 'Uzonline', 'icon': Icons.wifi_rounded},
    {'name': 'Turon Telecom', 'icon': Icons.wifi_rounded},
    {'name': 'Sarkor Telecom', 'icon': Icons.wifi_rounded},
    {'name': 'TPS', 'icon': Icons.wifi_rounded},
    {'name': 'Comnet', 'icon': Icons.wifi_rounded},
    {'name': 'EVO', 'icon': Icons.wifi_rounded},
    {'name': 'Netcity', 'icon': Icons.wifi_rounded},
    {'name': 'FiberNet', 'icon': Icons.wifi_rounded},
    {'name': 'Istv', 'icon': Icons.wifi_rounded},
    {'name': 'Gals Telecom', 'icon': Icons.wifi_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('internet', context)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: providers.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final provider = providers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple.withValues(alpha: 0.1),
              child: Icon(provider['icon'], color: Colors.purple, size: 20),
            ),
            title: Text(provider['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class GovServicesPage extends StatelessWidget {
  const GovServicesPage({super.key});

  static const List<Map<String, dynamic>> services = [
    {'name': 'my.gov.uz portali xizmatlari', 'icon': Icons.account_balance_rounded},
    {'name': 'YHXBB (GAI) jarimalari', 'icon': Icons.gavel_rounded},
    {'name': 'Soliq qo\'mitasi (Soliqlar)', 'icon': Icons.account_balance_rounded},
    {'name': 'Bilimni baholash agentligi (DTM)', 'icon': Icons.school_rounded},
    {'name': 'Davlat xizmatlari markazi (DXM)', 'icon': Icons.home_work_rounded},
    {'name': 'Notarius xizmatlari', 'icon': Icons.edit_document},
    {'name': 'Kadastr to\'lovlari', 'icon': Icons.map_rounded},
    {'name': 'FHDYO (ZAGS)', 'icon': Icons.favorite_rounded},
    {'name': 'E-auksion', 'icon': Icons.gavel_rounded},
    {'name': 'MIB qarzlari', 'icon': Icons.shield_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('gov_services', context)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: services.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
        itemBuilder: (context, index) {
          final service = services[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withValues(alpha: 0.1),
              child: Icon(service['icon'], color: Colors.orange, size: 20),
            ),
            title: Text(service['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
            onTap: () {},
          );
        },
      ),
    );
  }
}

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});
  @override State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _pin = ValueNotifier<String>(""), _error = ValueNotifier<bool>(false), _confirm = ValueNotifier<bool>(false);
  String _firstEntry = "";

  void _handle(String n) async {
    if (n == 'del') { if (_pin.value.isNotEmpty) _pin.value = _pin.value.substring(0, _pin.value.length - 1); return; }
    if (_pin.value.length < 4) {
      _pin.value += n;
      if (_pin.value.length == 4) {
        final ent = _pin.value;
        if (!_confirm.value) {
          _firstEntry = ent;
          _pin.value = "";
          _confirm.value = true;
        } else if (ent == _firstEntry) {
          final p = await SharedPreferences.getInstance();
          await p.setString('user_pin', ent);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Tran.get('pin_changed', context))));
            Navigator.pop(context);
          }
        } else {
          _error.value = true;
          _pin.value = "";
          HapticFeedback.vibrate();
          Future.delayed(const Duration(seconds: 1), () => _error.value = false);
        }
      }
    }
  }

  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('change_pin', context)),
      body: Column(
        children: [
          const SizedBox(height: 48),
          ValueListenableBuilder2<bool, bool>(
            first: _confirm, second: _error,
            builder: (c, con, e, _) => Text(
              e ? Tran.get('mismatch_pin', context) : (con ? Tran.get('repeat_new_pin', context) : Tran.get('enter_new_pin', context)),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: e ? Colors.red : null),
            ),
          ),
          const SizedBox(height: 48),
          ValueListenableBuilder2<String, bool>(
            first: _pin, second: _error,
            builder: (c, p, e, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                width: 18, height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < p.length ? (e ? Colors.red : Colors.blue) : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.1)),
                ),
              )),
            ),
          ),
          const Spacer(),
          PinKeypad(onKeyPress: _handle, isDark: isDark),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

