import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  runApp(const PaymentApp());
}

// --- Global States ---
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
ValueNotifier<Locale> localeNotifier = ValueNotifier(const Locale('uz'));

enum CardType { visa, mastercard, humo, uzcard, unknown }

class UserData {
  String name;
  String phone;
  UserData({required this.name, required this.phone});
}

ValueNotifier<UserData> userNotifier = ValueNotifier(UserData(name: "Diyor", phone: "+998 90 123 45 67"));

// --- Extended Translation System ---
class Tran {
  static final Map<String, Map<String, String>> _data = {
    'uz': {
      'welcome': 'Xush kelibsiz',
      'enter_pin': 'PIN-kodni kiriting',
      'home': 'Asosiy',
      'payments': 'To\'lovlar',
      'history': 'Tarix',
      'profile': 'Profil',
      'transfer': 'O\'tkazma',
      'qr_pay': 'QR To\'lov',
      'edit_profile': 'Profilni tahrirlash',
      'dark_mode': 'Tungi rejim',
      'language': 'Ilova tili',
      'logout': 'Chiqish',
      'save': 'Saqlash',
      'scan_qr': 'QR kodni skanerlang',
      'recent': 'So\'nggi amallar',
      'hello': 'Salom!',
      'services': 'Xizmatlar',
      'more': 'Yana',
      'today': 'Bugun',
      'yesterday': 'Kecha',
      'security': 'Xavfsizlik',
      'edit': 'Tahrirlash',
      'name_hint': 'Ism Familiya',
      'phone_hint': 'Telefon raqam',
      'amount': 'To\'lov miqdori',
      'card_number': 'Karta raqami',
      'holder': 'Karta egasi',
      'done': 'Bajarildi!',
      'back_home': 'Asosiyga qaytish',
      'communal': 'Kommunal',
      'mobile': 'Mobil aloqa',
      'internet': 'Internet',
      'gov': 'Davlat',
      'search': 'Qidirish...',
      'on': 'Yoqilgan',
      'off': 'O\'chirilgan',
      'send': 'Yuborish',
      'to_whom': 'Kimga?',
      'how_much': 'Qancha?',
    },
    'ru': {
      'welcome': 'Добро пожаловать',
      'enter_pin': 'Введите ПИН-код',
      'home': 'Главная',
      'payments': 'Платежи',
      'history': 'История',
      'profile': 'Профиль',
      'transfer': 'Перевод',
      'qr_pay': 'QR Оплата',
      'edit_profile': 'Изменить профиль',
      'dark_mode': 'Темный режим',
      'language': 'Язык приложения',
      'logout': 'Выйти',
      'save': 'Сохранить',
      'scan_qr': 'Сканируйте QR код',
      'recent': 'Последние операции',
      'hello': 'Привет!',
      'services': 'Сервисы',
      'more': 'Еще',
      'today': 'Сегодня',
      'yesterday': 'Вчера',
      'security': 'Безопасность',
      'edit': 'Изменить',
      'name_hint': 'Имя Фамилия',
      'phone_hint': 'Номер телефона',
      'amount': 'Сумма оплаты',
      'card_number': 'Номер карты',
      'holder': 'Владелец карты',
      'done': 'Готово!',
      'back_home': 'На главную',
      'communal': 'Коммунальные',
      'mobile': 'Мобильная связь',
      'internet': 'Интернет',
      'gov': 'Госуслуги',
      'search': 'Поиск...',
      'on': 'Вкл',
      'off': 'Выкл',
      'send': 'Отправить',
      'to_whom': 'Кому?',
      'how_much': 'Сколько?',
    },
    'en': {
      'welcome': 'Welcome',
      'enter_pin': 'Enter PIN code',
      'home': 'Home',
      'payments': 'Payments',
      'history': 'History',
      'profile': 'Profile',
      'transfer': 'Transfer',
      'qr_pay': 'QR Pay',
      'edit_profile': 'Edit Profile',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'logout': 'Logout',
      'save': 'Save',
      'scan_qr': 'Scan QR Code',
      'recent': 'Recent actions',
      'hello': 'Hello!',
      'services': 'Services',
      'more': 'More',
      'today': 'Today',
      'yesterday': 'Yesterday',
      'security': 'Security',
      'edit': 'Edit',
      'name_hint': 'Full Name',
      'phone_hint': 'Phone Number',
      'amount': 'Payment amount',
      'card_number': 'Card number',
      'holder': 'Card holder',
      'done': 'Done!',
      'back_home': 'Back to home',
      'communal': 'Communal',
      'mobile': 'Mobile',
      'internet': 'Internet',
      'gov': 'Government',
      'search': 'Search...',
      'on': 'On',
      'off': 'Off',
      'send': 'Send',
      'to_whom': 'To whom?',
      'how_much': 'How much?',
    }
  };

  static String get(String key) {
    return _data[localeNotifier.value.languageCode]?[key] ?? key;
  }
}

// --- Animation Wrapper ---
class BounceWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const BounceWrapper({super.key, required this.child, required this.onTap});
  @override State<BounceWrapper> createState() => _BounceWrapperState();
}

class _BounceWrapperState extends State<BounceWrapper> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override void initState() {
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), lowerBound: 0.0, upperBound: 0.05)..addListener(() => setState(() {}));
    super.initState();
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) { _controller.reverse(); widget.onTap(); },
      onTapCancel: () => _controller.reverse(),
      child: Transform.scale(scale: 1 - _controller.value, child: widget.child),
    );
  }
}

class PaymentApp extends StatelessWidget {
  const PaymentApp({super.key});
  @override Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) => ValueListenableBuilder<Locale>(
        valueListenable: localeNotifier,
        builder: (_, locale, __) => MaterialApp(
          locale: locale,
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(useMaterial3: true, brightness: Brightness.light, colorSchemeSeed: const Color(0xFF3B82F6), scaffoldBackgroundColor: const Color(0xFFF8FAFC), textTheme: GoogleFonts.plusJakartaSansTextTheme()),
          darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark, colorSchemeSeed: const Color(0xFF3B82F6), scaffoldBackgroundColor: const Color(0xFF0F172A), textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme)),
          home: const LoginScreen(),
        ),
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
  String _enteredPin = "";
  void _onNumberPress(String n) {
    if (_enteredPin.length < 4) {
      setState(() => _enteredPin += n);
      if (_enteredPin.length == 4) Future.delayed(const Duration(milliseconds: 300), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigationScreen())));
    }
  }
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Theme.of(context).primaryColor.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.lock_person_rounded, size: 64, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 24),
          Text(Tran.get('welcome'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          Text(Tran.get('enter_pin'), style: const TextStyle(color: Color(0xFF64748B))),
          const SizedBox(height: 48),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i) => Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: i < _enteredPin.length ? Theme.of(context).primaryColor : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)))))),
          const Spacer(),
          _buildKeypad(isDark),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
  Widget _buildKeypad(bool d) => Column(children: [for (var r in [['1','2','3'],['4','5','6'],['7','8','9']]) Row(mainAxisAlignment: MainAxisAlignment.center, children: r.map((n) => _buildKey(n, d)).toList()), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const SizedBox(width: 100), _buildKey('0', d), _buildKey('del', d, icon: Icons.backspace_outlined)])]);
  Widget _buildKey(String v, bool d, {IconData? icon}) => Padding(padding: const EdgeInsets.all(10), child: BounceWrapper(onTap: () => v == 'del' ? setState(() => _enteredPin = _enteredPin.isNotEmpty ? _enteredPin.substring(0,_enteredPin.length-1) : "") : _onNumberPress(v), child: Container(width: 80, height: 80, alignment: Alignment.center, child: icon != null ? Icon(icon, size: 28) : Text(v, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w600)))));
}

// --- Main Navigation ---
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});
  @override State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}
class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _curr = 0;
  final List<Widget> _pages = [const HomeScreen(), const PaymentsScreen(), const HistoryScreen(), const ProfileScreen()];
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_curr],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.grid_view_rounded, Tran.get('home'), 0),
            _navItem(Icons.account_balance_wallet_rounded, Tran.get('payments'), 1),
            const SizedBox(width: 40),
            _navItem(Icons.analytics_rounded, Tran.get('history'), 2),
            _navItem(Icons.person_2_rounded, Tran.get('profile'), 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen())),
        backgroundColor: const Color(0xFF3B82F6), shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
  Widget _navItem(IconData i, String l, int index) => InkWell(onTap: () => setState(() => _curr = index), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(i, color: _curr == index ? const Color(0xFF3B82F6) : Colors.grey), Text(l, style: TextStyle(fontSize: 10, color: _curr == index ? const Color(0xFF3B82F6) : Colors.grey, fontWeight: FontWeight.bold))]));
}

// --- Home Screen ---
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: ValueListenableBuilder<UserData>(valueListenable: userNotifier, builder: (context, user, _) => Row(children: [CircleAvatar(radius: 20, backgroundColor: const Color(0xFF3B82F6), child: Text(user.name[0])), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(Tran.get('hello'), style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(user.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))])])), actions: [IconButton(onPressed: (){}, icon: const Icon(Icons.notifications_none_rounded))]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const VisualCreditCard(cardNumber: "8600 **** **** 4582", expiryDate: "12/28", cardHolder: "DIYOR", cardType: CardType.uzcard),
        const SizedBox(height: 32),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _action(context, Icons.swap_horiz_rounded, Tran.get('transfer'), Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferMoneyScreen()))),
          _action(context, Icons.qr_code_2_rounded, Tran.get('qr_pay'), Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScannerScreen()))),
          _action(context, Icons.receipt_long_rounded, Tran.get('services'), Colors.green, (){}),
          _action(context, Icons.more_horiz_rounded, Tran.get('more'), Colors.purple, (){}),
        ]),
        const SizedBox(height: 32),
        Text(Tran.get('recent'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _hist("Artel Servis", Tran.get('today') + ", 14:30", "- 150,000", Icons.bolt_rounded, Colors.orange),
        _hist("Korzinka.uz", Tran.get('yesterday') + ", 18:20", "- 84,500", Icons.shopping_basket_rounded, Colors.red),
      ])),
    );
  }
  Widget _action(context, i, l, c, onTap) => BounceWrapper(onTap: onTap, child: Column(children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Icon(i, color: c)), const SizedBox(height: 8), Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]));
  Widget _hist(t, ti, a, i, c) => Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))), child: Row(children: [CircleAvatar(backgroundColor: c.withOpacity(0.1), child: Icon(i, color: c, size: 20)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), Text(ti, style: const TextStyle(color: Colors.grey, fontSize: 12))])), Text("$a UZS", style: const TextStyle(fontWeight: FontWeight.bold))]));
}

// --- Real QR Scanner ---
class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Tran.get('qr_pay')), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => QRPaymentAmountScreen(merchantName: barcodes.first.rawValue ?? "Unknown Merchant")));
              }
            },
          ),
          Center(child: Container(width: 200, height: 200, decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 2), borderRadius: BorderRadius.circular(20)))),
          Positioned(bottom: 50, left: 0, right: 0, child: Center(child: Text(Tran.get('scan_qr'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
}

class QRPaymentAmountScreen extends StatelessWidget {
  final String merchantName;
  const QRPaymentAmountScreen({super.key, required this.merchantName});
  @override Widget build(BuildContext context) {
    final c = TextEditingController();
    return Scaffold(appBar: PaymentAppBar(title: Tran.get('qr_pay')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [RecipientCard(name: merchantName, id: "QR Merchant", icon: Icons.store_rounded), const SizedBox(height: 24), AmountInputSection(controller: c), const Spacer(), CheckoutButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep())), label: Tran.get('qr_pay'))])));
  }
}

// --- Profile & Multi-language ---
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: PaymentAppBar(title: Tran.get('profile')),
      body: ValueListenableBuilder<UserData>(
        valueListenable: userNotifier,
        builder: (context, user, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(child: Column(children: [CircleAvatar(radius: 40, backgroundColor: const Color(0xFF3B82F6), child: Text(user.name[0], style: const TextStyle(fontSize: 24, color: Colors.white))), const SizedBox(height: 12), Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), Text(user.phone, style: const TextStyle(color: Colors.grey))])),
            const SizedBox(height: 32),
            _opt(context, Icons.edit_rounded, Tran.get('edit_profile'), "", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
            _opt(context, Icons.dark_mode_rounded, Tran.get('dark_mode'), isDark ? Tran.get('on') : Tran.get('off'), trailing: Switch(value: isDark, onChanged: (v) => themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light)),
            _opt(context, Icons.language_rounded, Tran.get('language'), localeNotifier.value.languageCode.toUpperCase(), onTap: () => _showLang(context)),
            _opt(context, Icons.security_rounded, Tran.get('security'), ""),
            const SizedBox(height: 40),
            CheckoutButton(onPressed: () => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false), label: Tran.get('logout'), isSecondary: true),
          ],
        ),
      ),
    );
  }
  Widget _opt(context, i, t, s, {Widget? trailing, VoidCallback? onTap}) => ListTile(onTap: onTap, leading: Icon(i, color: const Color(0xFF3B82F6)), title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), trailing: trailing ?? Text(s, style: const TextStyle(color: Colors.grey)));
  void _showLang(context) => showModalBottomSheet(context: context, builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [ListTile(title: const Text("O'zbek tili"), onTap: () { localeNotifier.value = const Locale('uz'); Navigator.pop(context); }), ListTile(title: const Text("Русский язык"), onTap: () { localeNotifier.value = const Locale('ru'); Navigator.pop(context); }), ListTile(title: const Text("English"), onTap: () { localeNotifier.value = const Locale('en'); Navigator.pop(context); })]));
}

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});
  @override Widget build(BuildContext context) {
    final n = TextEditingController(text: userNotifier.value.name), p = TextEditingController(text: userNotifier.value.phone);
    return Scaffold(appBar: PaymentAppBar(title: Tran.get('edit')), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [CustomInputField(hint: Tran.get('name_hint'), controller: n), const SizedBox(height: 16), CustomInputField(hint: Tran.get('phone_hint'), controller: p), const Spacer(), CheckoutButton(onPressed: () { userNotifier.value = UserData(name: n.text, phone: p.text); Navigator.pop(context); }, label: Tran.get('save'))])));
  }
}

// --- Shared Widgets ---
class VisualCreditCard extends StatelessWidget {
  final String cardNumber, expiryDate, cardHolder; final CardType cardType;
  const VisualCreditCard({super.key, required this.cardNumber, required this.expiryDate, required this.cardHolder, this.cardType = CardType.unknown});
  @override Widget build(BuildContext context) => Container(width: double.infinity, height: 210, decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), gradient: const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]), padding: const EdgeInsets.all(25), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Icon(Icons.contactless, color: Colors.white, size: 32), Text(cardType.name.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))]), const Spacer(), Text(cardNumber, style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 22, letterSpacing: 2)), const SizedBox(height: 20), Text(cardHolder, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]));
}
class CustomInputField extends StatelessWidget {
  final String hint; final TextEditingController? controller; final TextInputType keyboardType; final List<TextInputFormatter>? inputFormatters; final Function(String)? onChanged;
  const CustomInputField({super.key, required this.hint, this.controller, this.keyboardType = TextInputType.text, this.inputFormatters, this.onChanged});
  @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF1F5F9))), child: TextField(controller: controller, keyboardType: keyboardType, inputFormatters: inputFormatters, onChanged: onChanged, decoration: InputDecoration(hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.all(15))));
}
class AmountInputSection extends StatelessWidget {
  final TextEditingController controller;
  const AmountInputSection({super.key, required this.controller});
  @override build(BuildContext context) => Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: TextField(controller: controller, textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue), decoration: const InputDecoration(border: InputBorder.none, suffixText: " UZS")));
}
class CheckoutButton extends StatelessWidget {
  final VoidCallback onPressed; final String label; final bool isLoading, isSecondary;
  const CheckoutButton({super.key, required this.onPressed, required this.label, this.isLoading = false, this.isSecondary = false});
  @override build(BuildContext context) => BounceWrapper(onTap: onPressed, child: Container(height: 60, decoration: BoxDecoration(color: isSecondary ? Colors.red.withOpacity(0.1) : const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20)), child: Center(child: isLoading ? const CircularProgressIndicator() : Text(label, style: TextStyle(color: isSecondary ? Colors.red : Colors.white, fontWeight: FontWeight.bold)))));
}
class PaymentAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; final VoidCallback? onBack;
  const PaymentAppBar({super.key, required this.title, this.onBack});
  @override build(BuildContext context) => AppBar(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, leading: onBack != null ? IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: onBack) : null);
  @override Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
class RecipientCard extends StatelessWidget {
  final String name, id; final IconData icon;
  const RecipientCard({super.key, required this.name, required this.id, required this.icon});
  @override build(BuildContext context) => Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Row(children: [Icon(icon, color: Colors.blue), const SizedBox(width: 15), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), Text(id, style: const TextStyle(color: Colors.grey, fontSize: 12))])]));
}

// --- Other Screens ---
class PaymentsScreen extends StatelessWidget { const PaymentsScreen({super.key}); @override build(context) => Scaffold(appBar: PaymentAppBar(title: Tran.get('payments')), body: GridView.count(padding: const EdgeInsets.all(20), crossAxisCount: 2, mainAxisSpacing: 15, crossAxisSpacing: 15, children: [_item(context, Tran.get('communal'), Icons.home, Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentFlowScreen()))), _item(context, Tran.get('mobile'), Icons.phone_android, Colors.green, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MobilePaymentScreen()))), _item(context, Tran.get('internet'), Icons.wifi, Colors.purple, () {}), _item(context, Tran.get('gov'), Icons.account_balance, Colors.orange, () {})])); Widget _item(context, t, i, c, onTap) => BounceWrapper(onTap: onTap, child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(i, color: c, size: 30), const SizedBox(height: 10), Text(t, style: const TextStyle(fontWeight: FontWeight.bold))]))); }
class HistoryScreen extends StatelessWidget { const HistoryScreen({super.key}); @override build(context) => Scaffold(appBar: PaymentAppBar(title: Tran.get('history')), body: const Center(child: Text("History"))); }
class TransferMoneyScreen extends StatefulWidget { const TransferMoneyScreen({super.key}); @override State<TransferMoneyScreen> createState() => _TransferMoneyScreenState(); }
class _TransferMoneyScreenState extends State<TransferMoneyScreen> { final _card = TextEditingController(), _amt = TextEditingController(); @override build(context) => Scaffold(appBar: PaymentAppBar(title: Tran.get('transfer')), body: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionHeader(title: Tran.get('to_whom')), const SizedBox(height: 12), CustomInputField(hint: Tran.get('card_number'), controller: _card), const SizedBox(height: 24), SectionHeader(title: Tran.get('how_much')), const SizedBox(height: 12), AmountInputSection(controller: _amt), const Spacer(), CheckoutButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep())), label: Tran.get('send'))]))); }
class SuccessReceiptStep extends StatelessWidget { const SuccessReceiptStep({super.key}); @override build(context) => Scaffold(body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.check_circle, color: Colors.green, size: 80), const SizedBox(height: 20), Text(Tran.get('done'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const SizedBox(height: 40), Padding(padding: const EdgeInsets.all(20), child: CheckoutButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), label: Tran.get('back_home')))]))); }
class CardNumberFormatter extends TextInputFormatter { @override TextEditingValue formatEditUpdate(o, n) { var t = n.text.replaceAll(' ', ''); var b = StringBuffer(); for (var i = 0; i < t.length; i++) { b.write(t[i]); if ((i + 1) % 4 == 0 && (i + 1) != t.length) b.write(' '); } return n.copyWith(text: b.toString(), selection: TextSelection.collapsed(offset: b.length)); } }
class CardExpiryFormatter extends TextInputFormatter { @override TextEditingValue formatEditUpdate(o, n) { var t = n.text.replaceAll('/', ''); var b = StringBuffer(); for (var i = 0; i < t.length; i++) { b.write(t[i]); if ((i + 1) % 2 == 0 && (i + 1) != t.length) b.write('/'); } return n.copyWith(text: b.toString(), selection: TextSelection.collapsed(offset: b.length)); } }
class PaymentFlowScreen extends StatelessWidget { const PaymentFlowScreen({super.key}); @override build(context) => Scaffold(appBar: PaymentAppBar(title: Tran.get('communal')), body: Center(child: Column(children: [const RecipientCard(name: "Artel Servis", id: "ID: 123", icon: Icons.bolt), const Spacer(), CheckoutButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep())), label: Tran.get('save')), const SizedBox(height: 20)]))); }
class MobilePaymentScreen extends StatelessWidget { const MobilePaymentScreen({super.key}); @override build(context) => Scaffold(appBar: PaymentAppBar(title: Tran.get('mobile')), body: Center(child: Column(children: [const RecipientCard(name: "Beeline", id: "+998 90", icon: Icons.phone_android), const Spacer(), CheckoutButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuccessReceiptStep())), label: Tran.get('payments')), const SizedBox(height: 20)]))); }
class SectionHeader extends StatelessWidget { final String title; const SectionHeader({super.key, required this.title}); @override build(context) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)); }
