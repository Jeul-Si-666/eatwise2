import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eatwise2/services/profile_service.dart';


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

  // Text Styles (Sama seperti sebelumnya)
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
  // Style khusus untuk Jam
  static final TextStyle _timeTextStyle = GoogleFonts.inter(
    fontSize: 20, fontWeight: FontWeight.w600, color: _buttonColor,
  );

  static const double _sidePadding = 32.0;
  static const double _fieldHeight = 60.0;
  static const double _fieldRadius = 10.0; 
  static const double _buttonHeight = 60.0;
  static const double _buttonRadius = 10.0;

  // --- STATE DATA FISIK ---
  String _usia = "20";      
  String _berat = "65.5";   
  String _tinggi = "175";   

  // --- State Checkbox ---
  bool _diabetesChecked = false;
  bool _kolesterolChecked = false;
  bool _hindariGluten = false;
  bool _hindariKacang = false;
  bool _hindariTelur = false;

  // --- STATE BARU: NOTIFIKASI MAKAN ---
  bool _notifSarapan = true;
  TimeOfDay _waktuSarapan = const TimeOfDay(hour: 7, minute: 0);

  bool _notifSiang = true;
  TimeOfDay _waktuSiang = const TimeOfDay(hour: 12, minute: 30);

  bool _notifMalam = true;
  TimeOfDay _waktuMalam = const TimeOfDay(hour: 19, minute: 0);

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
              Text('Hi, Zelcy', style: _bodyStyle),
              const SizedBox(height: 40),

              // --- DATA FISIK ---
              Text('Data Fisik', style: _headingStyle),
              const SizedBox(height: 16),
              _buildEditableRow(
                label: "Usia", value: _usia, unit: "tahun",
                onEdit: () => _showEditDialog("Usia", _usia, (val) => setState(() => _usia = val)),
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

              // --- RIWAYAT KESEHATAN ---
              Text('Riwayat Kesehatan', style: _headingStyle),
              const SizedBox(height: 16),
              _buildCheckbox(label: 'Riwayat Diabetes', value: _diabetesChecked, onChanged: (val) => setState(() => _diabetesChecked = val ?? false)),
              _buildCheckbox(label: 'Riwayat Kolesterol', value: _kolesterolChecked, onChanged: (val) => setState(() => _kolesterolChecked = val ?? false)),
              const SizedBox(height: 40),

              // --- BAHAN DIHINDARI ---
              Text('Bahan yang Dihindari:', style: _headingStyle),
              const SizedBox(height: 16),
              _buildCheckbox(label: 'Gluten', value: _hindariGluten, onChanged: (val) => setState(() => _hindariGluten = val ?? false)),
              _buildCheckbox(label: 'Kacang', value: _hindariKacang, onChanged: (val) => setState(() => _hindariKacang = val ?? false)),
              _buildCheckbox(label: 'Telur', value: _hindariTelur, onChanged: (val) => setState(() => _hindariTelur = val ?? false)),
              const SizedBox(height: 40),

              // --- SECTION BARU: PENGATURAN NOTIFIKASI ---
              Text('Jadwal Makan:', style: _headingStyle),
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
                // onPressed: () {
                //   print("Saved!");
                //   // Format jam untuk dikirim ke database bisa pakai: _waktuSarapan.format(context)
                // },
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

  // 1. Row Data Fisik (Sudah ada)
  Widget _buildEditableRow({required String label, required String value, required String unit, required VoidCallback onEdit}) {
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

  // 2. Row Notifikasi (BARU)
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
          // Switch On/Off
          Switch(
            value: isActive,
            onChanged: onSwitchChanged,
            activeColor: _buttonColor,
          ),
          const SizedBox(width: 8),
          
          // Label (Sarapan/Siang/Malam)
          Expanded(
            child: Text(
              label,
              style: _labelStyle.copyWith(
                color: isActive ? _textColorBlack : _textColorBlack.withOpacity(0.5),
              ),
            ),
          ),
          
          // Tampilan Jam (Bisa diklik)
          InkWell(
            onTap: isActive ? onTimeTap : null, // Hanya bisa diklik kalau aktif
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white.withOpacity(0.5) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                time.format(context), // Format otomatis (misal 7:00 AM)
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

  // 3. Fungsi Buka Jam (BARU)
  Future<void> _selectTime(TimeOfDay initial, Function(TimeOfDay) onSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: _buttonColor, // Warna header jam sesuai tema
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

  // 4. Dialog Edit Angka (Sudah ada)
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
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal", style: TextStyle(color: Colors.black))),
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

      @override
  void initState() {
    super.initState();
    _loadProfile();
  }
Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    
    final profile = await ProfileService.getProfile(widget.userId);
    
    if (profile != null) {
      setState(() {
        _usia = profile['usia']?.toString() ?? "20";
        _berat = profile['berat_badan']?.toString() ?? "65.5";
        _tinggi = profile['tinggi_badan']?.toString() ?? "175";
        _diabetesChecked = profile['riwayat_diabetes'] == 1;
        _kolesterolChecked = profile['riwayat_kolesterol'] == 1;
        _hindariGluten = profile['alergi_gluten'] == 1;
        _hindariKacang = profile['alergi_kacang'] == 1;
        _hindariTelur = profile['alergi_telur'] == 1;
        // ... load data lainnya ...
      });
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);
    
    final profileData = {
      'usia': int.tryParse(_usia),
      'berat_badan': double.tryParse(_berat),
      'tinggi_badan': double.tryParse(_tinggi),
      'riwayat_diabetes': _diabetesChecked ? 1 : 0,
      'riwayat_kolesterol': _kolesterolChecked ? 1 : 0,
      'alergi_gluten': _hindariGluten ? 1 : 0,
      'alergi_kacang': _hindariKacang ? 1 : 0,
      'alergi_telur': _hindariTelur ? 1 : 0,
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
      Navigator.pop(context, true); // Return true untuk reload di home
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menyimpan profile')),
      );
    }
    
    setState(() => _isLoading = false);
  }

  // 5. Checkbox (Sudah ada)
  Widget _buildCheckbox({required String label, required bool value, required ValueChanged<bool?> onChanged}) {
    
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