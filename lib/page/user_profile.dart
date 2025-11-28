import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/services/profile_service_fixed.dart';
import 'package:intl/intl.dart'; // Tambahkan di pubspec.yaml: intl: ^0.18.0

class UserProfileScreen extends StatefulWidget {
  final int userId;
  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);
  
  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isLoading = false;

  // --- ASET DESAIN ---
  static const Color _backgroundColor = Color(0xFFAEB8AF);
  static const Color _buttonColor = Color(0xFF549E61);
  static const Color _textFieldFillColor = Color(0x51D1D1D1);
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _dividerColor = Color(0xFF000000);

  static final TextStyle _subtitleStyle = GoogleFonts.inter(
    fontSize: 28.12, fontWeight: FontWeight.w500, color: _textColorBlack,
  );
  static final TextStyle _bodyStyle = GoogleFonts.inter(
    fontSize: 18.62, fontWeight: FontWeight.w200, color: _textColorBlack,
  );
  static final TextStyle _headingStyle = GoogleFonts.inter(
    fontSize: 24, fontWeight: FontWeight.w700, color: _textColorBlack,
  );
  static final TextStyle _labelStyle = GoogleFonts.inter(
    fontSize: 17.88, fontWeight: FontWeight.w300, color: _textColorBlack,
  );
  static final TextStyle _valueTextStyle = GoogleFonts.inter(
    fontSize: 24.23, fontWeight: FontWeight.w400, color: _textColorBlack,
  );
  static final TextStyle _buttonTextStyle = GoogleFonts.inter(
    fontSize: 24.23, fontWeight: FontWeight.w400, color: _textColorBlack,
  );
  static final TextStyle _timeTextStyle = GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w600, color: _buttonColor,
  );
  
  static const double _sidePadding = 32.0;
  static const double _fieldHeight = 60.0;
  static const double _fieldRadius = 10.0; 
  static const double _buttonHeight = 60.0;
  static const double _buttonRadius = 10.0;

  // --- STATE DATA FISIK ---
  DateTime? _tanggalLahir; // Ganti dari String _usia
  int _usia = 0; // Computed dari tanggal lahir
  String _berat = "65.5";   
  String _tinggi = "175";   
  String _username = "User";

  // --- State Checkbox Riwayat Kesehatan (Tambah Hipertensi) ---
  bool _diabetesChecked = false;
  bool _kolesterolChecked = false;
  bool _hipertensiChecked = false; // BARU

  // --- STATE BARU: Bahan yang Dihindari (Gunakan TextField) ---
  final TextEditingController _bahanDihindariController = TextEditingController();
  List<String> _bahanDihindariList = []; // List bahan yang sudah dinormalisasi

  // --- STATE NOTIFIKASI MAKAN ---
  bool _notifSarapan = true;
  TimeOfDay _waktuSarapan = const TimeOfDay(hour: 7, minute: 0);
  bool _notifSiang = true;
  TimeOfDay _waktuSiang = const TimeOfDay(hour: 12, minute: 30);
  bool _notifMalam = true;
  TimeOfDay _waktuMalam = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _bahanDihindariController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final profile = await ProfileService.getProfile(widget.userId);
    
    if (profile != null) {
      setState(() {
        // Load tanggal lahir dan hitung umur
        _tanggalLahir = ProfileService.parseBirthDate(profile['tanggal_lahir']);
        if (_tanggalLahir != null) {
          _usia = ProfileService.calculateAge(_tanggalLahir!);
        }
        
        _berat = profile['berat_badan']?.toString() ?? "65.5";
        _tinggi = profile['tinggi_badan']?.toString() ?? "175";
        _diabetesChecked = profile['riwayat_diabetes'] == 1;
        _kolesterolChecked = profile['riwayat_kolesterol'] == 1;
        _hipertensiChecked = profile['riwayat_hipertensi'] == 1; // BARU
        _username = profile['nama_lengkap']?.toString() ?? "User";
        
        // Load bahan yang dihindari
        if (profile['bahan_dihindari'] != null && profile['bahan_dihindari'].isNotEmpty) {
          _bahanDihindariList = _normalizeBahanList(profile['bahan_dihindari']);
          _bahanDihindariController.text = _bahanDihindariList.join(', ');
        }
        
        // Load waktu notifikasi jika ada
        if (profile['waktu_sarapan'] != null) {
          _waktuSarapan = _parseTimeString(profile['waktu_sarapan']);
        }
        if (profile['waktu_siang'] != null) {
          _waktuSiang = _parseTimeString(profile['waktu_siang']);
        }
        if (profile['waktu_malam'] != null) {
          _waktuMalam = _parseTimeString(profile['waktu_malam']);
        }
        
        _notifSarapan = profile['notif_sarapan_aktif'] == 1;
        _notifSiang = profile['notif_siang_aktif'] == 1;
        _notifMalam = profile['notif_malam_aktif'] == 1;
      });
    }
    
    setState(() => _isLoading = false);
  }

  // Helper untuk parse string waktu "HH:mm:ss" ke TimeOfDay
  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  // Normalisasi list bahan (lowercase, trim, remove duplicates)
  List<String> _normalizeBahanList(String input) {
    return input
        .split(',')
        .map((e) => e.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet() // Remove duplicates
        .toList();
  }

  // Fungsi untuk cek apakah bahan ada dalam list (case insensitive)
  bool _isBahanDihindari(String bahan, List<String> bahanList) {
    String normalizedBahan = bahan.trim().toLowerCase();
    return bahanList.any((item) => item.contains(normalizedBahan) || normalizedBahan.contains(item));
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    
    // Normalisasi input bahan yang dihindari
    _bahanDihindariList = _normalizeBahanList(_bahanDihindariController.text);
    
    final profileData = {
      'nama_lengkap': _username,
      'tanggal_lahir': _tanggalLahir?.toIso8601String().split('T')[0], // Format: YYYY-MM-DD
      'berat_badan': double.tryParse(_berat),
      'tinggi_badan': double.tryParse(_tinggi),
      'riwayat_diabetes': _diabetesChecked ? 1 : 0,
      'riwayat_kolesterol': _kolesterolChecked ? 1 : 0,
      'riwayat_hipertensi': _hipertensiChecked ? 1 : 0, // BARU
      'bahan_dihindari': _bahanDihindariList.join(','), // Simpan sebagai CSV
      'waktu_sarapan': ProfileService.timeOfDayToString(
        _waktuSarapan.hour, 
        _waktuSarapan.minute
      ),
      'waktu_siang': ProfileService.timeOfDayToString(
        _waktuSiang.hour, 
        _waktuSiang.minute
      ),
      'waktu_malam': ProfileService.timeOfDayToString(
        _waktuMalam.hour, 
        _waktuMalam.minute
      ),
      'notif_sarapan_aktif': _notifSarapan ? 1 : 0,
      'notif_siang_aktif': _notifSiang ? 1 : 0,
      'notif_malam_aktif': _notifMalam ? 1 : 0,
    };
    
    final success = await ProfileService.saveProfile(widget.userId, profileData);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile berhasil disimpan!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profile')),
      );
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _textColorBlack, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: _sidePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('User Profile', style: _subtitleStyle),
              const SizedBox(height: 8),
              Text('Hi, $_username', style: _bodyStyle),
              const SizedBox(height: 40),

              // --- DATA FISIK ---
              Text('Data Fisik', style: _headingStyle),
              const SizedBox(height: 16),
              
              // Tanggal Lahir (Ganti dari Usia)
              _buildDateRow(
                label: "Tanggal Lahir",
                date: _tanggalLahir,
                onEdit: () => _showDatePicker(),
              ),
              const SizedBox(height: 12),
              
              // Tampilkan umur (read-only, computed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(_fieldRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.cake, color: _buttonColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Usia: $_usia tahun',
                      style: _labelStyle.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildEditableRow(
                label: "Berat Badan", value: _berat, unit: "kg",
                onEdit: () => _showEditDialog("Berat Badan", _berat, (val) => setState(() => _berat = val)),
              ),
              const SizedBox(height: 16),
              _buildEditableRow(
                label: "Tinggi Badan", value: _tinggi, unit: "cm",
                onEdit: () => _showEditDialog("Tinggi Badan", _tinggi, (val) => setState(() => _tinggi = val)),
              ),
              const SizedBox(height: 40),

              // --- RIWAYAT KESEHATAN (Tambah Hipertensi) ---
              Text('Riwayat Kesehatan', style: _headingStyle),
              const SizedBox(height: 16),
              _buildCheckbox(
                label: 'Riwayat Diabetes',
                value: _diabetesChecked,
                onChanged: (val) => setState(() => _diabetesChecked = val ?? false)
              ),
              _buildCheckbox(
                label: 'Riwayat Kolesterol',
                value: _kolesterolChecked,
                onChanged: (val) => setState(() => _kolesterolChecked = val ?? false)
              ),
              _buildCheckbox(
                label: 'Riwayat Hipertensi', // BARU
                value: _hipertensiChecked,
                onChanged: (val) => setState(() => _hipertensiChecked = val ?? false)
              ),
              const SizedBox(height: 40),

              // --- BAHAN YANG DIHINDARI (TextField) ---
              Text('Bahan yang Dihindari', style: _headingStyle),
              const SizedBox(height: 8),
              Text(
                'Pisahkan dengan koma (,) untuk beberapa bahan',
                style: _labelStyle.copyWith(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bahanDihindariController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Contoh: gluten, kacang, telur, susu',
                  hintStyle: GoogleFonts.inter(color: Colors.grey),
                  filled: true,
                  fillColor: _textFieldFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    borderSide: const BorderSide(color: _dividerColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    borderSide: const BorderSide(color: _dividerColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(_fieldRadius),
                    borderSide: const BorderSide(color: _buttonColor, width: 2),
                  ),
                ),
                style: _labelStyle,
              ),
              const SizedBox(height: 40),

              // --- JADWAL MAKAN ---
              Text('Jadwal Makan', style: _headingStyle),
              const SizedBox(height: 16),
              
              _buildNotificationRow(
                label: "Sarapan",
                isActive: _notifSarapan,
                time: _waktuSarapan,
                onSwitchChanged: (val) => setState(() => _notifSarapan = val),
                onTimeTap: () => _selectTime(_waktuSarapan, (picked) => setState(() => _waktuSarapan = picked)),
              ),
              const SizedBox(height: 12),
              
              _buildNotificationRow(
                label: "Makan Siang",
                isActive: _notifSiang,
                time: _waktuSiang,
                onSwitchChanged: (val) => setState(() => _notifSiang = val),
                onTimeTap: () => _selectTime(_waktuSiang, (picked) => setState(() => _waktuSiang = picked)),
              ),
              const SizedBox(height: 12),
              
              _buildNotificationRow(
                label: "Makan Malam",
                isActive: _notifMalam,
                time: _waktuMalam,
                onSwitchChanged: (val) => setState(() => _notifMalam = val),
                onTimeTap: () => _selectTime(_waktuMalam, (picked) => setState(() => _waktuMalam = picked)),
              ),

              const SizedBox(height: 48),

              // --- TOMBOL SAVE ---
              ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                  minimumSize: const Size(double.infinity, _buttonHeight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
                  elevation: 0,
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Simpan', style: _buttonTextStyle),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildDateRow({
    required String label,
    required DateTime? date,
    required VoidCallback onEdit,
  }) {
    String displayText = date != null 
        ? DateFormat('dd MMMM yyyy', 'id_ID').format(date)
        : 'Belum diisi';
    
    return Container(
      height: _fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _textFieldFillColor,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(width: 1.0, color: _dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: _buttonColor, size: 20),
              const SizedBox(width: 12),
              Text("$label: $displayText", style: _valueTextStyle.copyWith(fontSize: 18)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: _textColorBlack),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _buttonColor,
              onPrimary: Colors.white,
              onSurface: _textColorBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _tanggalLahir = picked;
        _usia = ProfileService.calculateAge(picked);
      });
    }
  }

  Widget _buildEditableRow({
    required String label,
    required String value,
    required String unit,
    required VoidCallback onEdit
  }) {
    return Container(
      height: _fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _textFieldFillColor,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(width: 1.0, color: _dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$label: $value $unit", style: _valueTextStyle),
          IconButton(
            icon: const Icon(Icons.edit, color: _textColorBlack),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationRow({
    required String label,
    required bool isActive,
    required TimeOfDay time,
    required ValueChanged<bool> onSwitchChanged,
    required VoidCallback onTimeTap,
  }) {
    return Container(
      height: _fieldHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _textFieldFillColor,
        borderRadius: BorderRadius.circular(_fieldRadius),
        border: Border.all(width: 1.0, color: _dividerColor),
      ),
      child: Row(
        children: [
          Switch(
            value: isActive,
            onChanged: onSwitchChanged,
            activeColor: _buttonColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: _labelStyle.copyWith(
                color: isActive ? _textColorBlack : _textColorBlack.withOpacity(0.5),
              ),
            ),
          ),
          InkWell(
            onTap: isActive ? onTimeTap : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.5) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time.format(context),
                style: _timeTextStyle.copyWith(
                  color: isActive ? _buttonColor : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(TimeOfDay initial, Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _buttonColor,
              onPrimary: Colors.white,
              onSurface: _textColorBlack,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onSelected(picked);
    }
  }

  void _showEditDialog(String title, String currentValue, Function(String) onSave) {
    TextEditingController controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _backgroundColor,
        title: Text("Edit $title", style: _headingStyle),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: _valueTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _buttonColor),
            onPressed: () {
              if (controller.text.isNotEmpty) onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged
  }) {
    return CheckboxListTile(
      title: Text(label, style: _labelStyle),
      value: value,
      onChanged: onChanged,
      activeColor: _buttonColor,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}