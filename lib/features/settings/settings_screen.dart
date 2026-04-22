import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_config.dart';
import '../../config/theme.dart';
import '../../core/services/printer_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _unlocked = false;
  String _pinInput = '';
  String? _pinError;

  // Settings values
  int _harga = AppConfig.hargaDefault;
  String _adminPin = AppConfig.adminPin;
  bool _btConnecting = false;
  List<dynamic> _btDevices = [];
  bool _scanning = false;
  bool _testPrinting = false;

  final _pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _harga = prefs.getInt('harga') ?? AppConfig.hargaDefault;
      _adminPin = prefs.getString('admin_pin') ?? AppConfig.adminPin;
    });
  }

  Future<void> _saveHarga(int val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('harga', val);
    setState(() => _harga = val);
  }

  Future<void> _savePin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_pin', pin);
    setState(() => _adminPin = pin);
  }

  void _checkPin() {
    if (_pinInput == _adminPin) {
      setState(() { _unlocked = true; _pinError = null; });
      _pinController.clear();
    } else {
      setState(() { _pinError = 'PIN salah. Coba lagi.'; _pinInput = ''; });
      _pinController.clear();
      HapticFeedback.vibrate();
    }
  }

  Future<void> _scanBluetooth() async {
    final pm = context.read<PrinterManager>();
    setState(() { _scanning = true; _btDevices = []; });
    try {
      final devices = await pm.scanBluetooth();
      setState(() { _btDevices = devices; _scanning = false; });
    } catch (e) {
      setState(() => _scanning = false);
    }
  }

  Future<void> _connectDevice(String mac) async {
    final pm = context.read<PrinterManager>();
    setState(() => _btConnecting = true);
    final result = await pm.connectBluetooth(mac);
    setState(() => _btConnecting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result ? 'Terhubung ke printer!' : 'Koneksi gagal'),
        backgroundColor: result ? Colors.green : Colors.redAccent,
      ));
    }
  }

  Future<void> _testPrint() async {
    final pm = context.read<PrinterManager>();
    setState(() => _testPrinting = true);
    final result = await pm.testPrint();
    setState(() => _testPrinting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result ? 'Test print berhasil!' : 'Test print gagal'),
        backgroundColor: result ? Colors.green : Colors.redAccent,
      ));
    }
  }

  void _showChangePinDialog() {
    final newPinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Ganti PIN',
            style: TextStyle(color: AppTheme.textLight)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPinCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'PIN Baru',
                hintStyle: TextStyle(color: AppTheme.textMuted),
              ),
              style: const TextStyle(color: AppTheme.textLight),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Konfirmasi PIN',
                hintStyle: TextStyle(color: AppTheme.textMuted),
              ),
              style: const TextStyle(color: AppTheme.textLight),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPinCtrl.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('PIN minimal 4 digit')));
                return;
              }
              if (newPinCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('PIN tidak cocok')));
                return;
              }
              _savePin(newPinCtrl.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('PIN berhasil diubah'),
                  backgroundColor: Colors.green));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showChangeHargaDialog() {
    final ctrl = TextEditingController(text: _harga.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Atur Harga',
            style: TextStyle(color: AppTheme.textLight)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            prefixText: 'Rp ',
            prefixStyle: TextStyle(color: AppTheme.accent),
            hintText: '15000',
            hintStyle: TextStyle(color: AppTheme.textMuted),
          ),
          style: const TextStyle(
              color: AppTheme.textLight, fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(ctrl.text);
              if (val != null && val > 0) {
                _saveHarga(val);
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) return _buildPinGate();
    return _buildSettings();
  }

  Widget _buildPinGate() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  color: AppTheme.accent, size: 56),
              const SizedBox(height: 20),
              const Text('Admin PIN',
                  style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Masukkan PIN untuk masuk ke pengaturan',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  textAlign: TextAlign.center),
              const SizedBox(height: 32),

              // PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _pinInput.length
                        ? AppTheme.accent
                        : AppTheme.surface,
                    border: Border.all(
                        color: i < _pinInput.length
                            ? AppTheme.accent
                            : AppTheme.textMuted.withOpacity(0.4),
                        width: 2),
                  ),
                )),
              ),

              if (_pinError != null) ...[
                const SizedBox(height: 12),
                Text(_pinError!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ],

              const SizedBox(height: 32),

              // Numpad
              _buildNumpad(),

              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Kembali',
                    style: TextStyle(color: AppTheme.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = ['1','2','3','4','5','6','7','8','9','','0','⌫'];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.0,
      ),
      itemCount: keys.length,
      itemBuilder: (_, i) {
        final key = keys[i];
        if (key.isEmpty) return const SizedBox();
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            if (key == '⌫') {
              if (_pinInput.isNotEmpty) {
                setState(() => _pinInput = _pinInput.substring(0, _pinInput.length - 1));
              }
            } else if (_pinInput.length < 6) {
              setState(() => _pinInput += key);
              if (_pinInput.length >= _adminPin.length) {
                _checkPin();
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(key,
                  style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 22,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettings() {
    final pm = context.watch<PrinterManager>();
    final statusColor = {
      PrinterStatus.connected: Colors.greenAccent,
      PrinterStatus.printing: Colors.blueAccent,
      PrinterStatus.connecting: Colors.orangeAccent,
      PrinterStatus.error: Colors.redAccent,
      PrinterStatus.disconnected: AppTheme.textMuted,
    }[pm.status]!;
    final statusLabel = {
      PrinterStatus.connected: 'Terhubung',
      PrinterStatus.printing: 'Mencetak...',
      PrinterStatus.connecting: 'Menghubungkan...',
      PrinterStatus.error: 'Error',
      PrinterStatus.disconnected: 'Tidak terhubung',
    }[pm.status]!;

    final hargaFormatted = _harga.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.primary,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios_new,
              color: AppTheme.textLight),
        ),
        title: const Text('Pengaturan Admin',
            style: TextStyle(
                color: AppTheme.textLight,
                fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _unlocked = false),
            icon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
            tooltip: 'Kunci',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          // ─── Printer section ───────────────────────────
          _SectionHeader('Printer Bluetooth'),
          Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status
                  Row(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: statusColor),
                      ),
                      const SizedBox(width: 8),
                      Text(statusLabel,
                          style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (pm.status == PrinterStatus.connected)
                        TextButton(
                          onPressed: () async {
                            await pm.disconnect();
                            setState(() {});
                          },
                          child: const Text('Putuskan',
                              style: TextStyle(
                                  color: Colors.redAccent)),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Scan button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _scanning ? null : _scanBluetooth,
                      icon: _scanning
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppTheme.accent))
                          : const Icon(Icons.bluetooth_searching),
                      label: Text(_scanning ? 'Mencari...' : 'Cari Perangkat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accent,
                        side: const BorderSide(color: AppTheme.accent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ),

                  // Device list
                  if (_btDevices.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ..._btDevices.map((d) {
                      final name = d.name ?? 'Unknown';
                      final mac = d.macAdress ?? '';
                      final isXS = name.contains('XS');
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.print,
                            color: isXS
                                ? AppTheme.accent
                                : AppTheme.textMuted),
                        title: Text(name,
                            style: TextStyle(
                                color: isXS
                                    ? AppTheme.textLight
                                    : AppTheme.textMuted,
                                fontWeight: isXS
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        subtitle: Text(mac,
                            style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 11)),
                        trailing: _btConnecting
                            ? const SizedBox(
                                width: 20, height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.accent))
                            : ElevatedButton(
                                onPressed: () => _connectDevice(mac),
                                style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(80, 36)),
                                child: const Text('Hubungkan'),
                              ),
                      );
                    }),
                  ],

                  const SizedBox(height: 12),

                  // Test print
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: pm.status != PrinterStatus.connected || _testPrinting
                          ? null
                          : _testPrint,
                      icon: _testPrinting
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white))
                          : const Icon(Icons.print_outlined),
                      label: Text(_testPrinting ? 'Mencetak...' : 'Test Print'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─── Harga section ─────────────────────────────
          _SectionHeader('Harga & Transaksi'),
          Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(Icons.payments_outlined,
                  color: AppTheme.accent),
              title: const Text('Harga per Sesi',
                  style: TextStyle(color: AppTheme.textLight)),
              subtitle: Text('Rp $hargaFormatted',
                  style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              trailing: IconButton(
                onPressed: _showChangeHargaDialog,
                icon: const Icon(Icons.edit_outlined,
                    color: AppTheme.textMuted),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ─── Security section ──────────────────────────
          _SectionHeader('Keamanan'),
          Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: const Icon(Icons.pin_outlined,
                  color: AppTheme.accent),
              title: const Text('Ganti Admin PIN',
                  style: TextStyle(color: AppTheme.textLight)),
              subtitle: const Text('PIN saat ini: ****',
                  style: TextStyle(color: AppTheme.textMuted)),
              trailing: const Icon(Icons.chevron_right,
                  color: AppTheme.textMuted),
              onTap: _showChangePinDialog,
            ),
          ),

          const SizedBox(height: 20),

          // ─── Info section ──────────────────────────────
          _SectionHeader('Informasi'),
          Card(
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                _InfoTile('Versi App', '1.0.0'),
                const Divider(color: AppTheme.background, height: 1),
                _InfoTile('Lebar Cetak', '${AppConfig.printWidthDots} dots (80mm)'),
                const Divider(color: AppTheme.background, height: 1),
                _InfoTile('Chunk Size', '${AppConfig.printerChunkSize} bytes'),
                const Divider(color: AppTheme.background, height: 1),
                _InfoTile('Server', AppConfig.baseUrl),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  const _InfoTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 13)),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
