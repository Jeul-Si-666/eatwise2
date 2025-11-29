import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:eatwise2/page/user_profile.dart';
import 'package:eatwise2/page/scan_page.dart';
import 'package:eatwise2/services/profile_service_fixed.dart';
import 'package:eatwise2/services/history_service.dart';
import 'package:eatwise2/util/session.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  // --- ASET DESAIN ---
  static const Color _backgroundColor = Color.fromARGB(255, 170, 184, 171);
  static const Color _cardColor = Color.fromARGB(255, 230, 238, 230);
  static const Color _scanButtonColor = Color.fromARGB(255, 230, 238, 230);
  static const Color _textColorBlack = Color(0xFF000000);
  static const Color _textColorWhite = Color(0xFFFFFFFF);
  static const Color _brandColorGreen = Color(0xFF13721C);
  static const Color _antiDesignAccentColor = Color(0xFF000000);

  static const LinearGradient _headerGradient = LinearGradient(
    colors: [Color(0xFF388E3C), Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient _bottomBarGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static final TextStyle _titleStyle = GoogleFonts.padauk(
    fontSize: 65,
    fontWeight: FontWeight.w900,
    color: _textColorWhite,
    letterSpacing: 2,
  );

  static final TextStyle _subtitleStyle = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w500,
    color: _textColorWhite,
    height: 1.5,
  );

  static final TextStyle _cardTextStyle = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: _textColorBlack,
  );

  static final TextStyle _calorieNumStyle = GoogleFonts.inter(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: _brandColorGreen,
    letterSpacing: -0.5,
  );

  static final TextStyle _calorieLabelStyle = GoogleFonts.inter(
    fontSize: 38,
    fontWeight: FontWeight.w500,
    color: _textColorBlack,
  );

  static const double _sidePadding = 20.0;
  static const double _cardRadius = 10.0;
  static const double _barRadius = 50.0;
  static const double _iconSizeLarge = 80.0;
  static const double _iconSizeMedium = 50.0;

  // --- STATE VARIABLES ---
  bool _isLoading = true;
  String _userName = "User";
  int _currentCalories = 0;
  int _targetCalories = 2000;
  double _calorieProgress = 0.0;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ============================================
  // LOAD DATA FROM API
  // ============================================
  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Ambil user_id dari session
      final prefs = await SharedPreferences.getInstance();
      String? uIdString = prefs.getString('user_id');
      final userId = int.tryParse(uIdString ?? '');
      
      if (userId == null) {
        // User belum login, redirect ke login
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      setState(() => _userId = userId);


      // Load profile
      final profile = await ProfileService.getProfile(userId);
      
      if (profile != null) {
        // Profile ditemukan
        setState(() {
          _userName = profile['nama_lengkap'] ?? profile['username'] ?? 'User';
          _currentCalories = profile['kalori_terkonsumsi_hari_ini'] ?? 0;
          _targetCalories = profile['target_kalori_harian'] ?? 2000;
          _calorieProgress = (_currentCalories / _targetCalories).clamp(0.0, 1.0);
        });
      } else {
        // Profile belum ada, buat default
        setState(() {
          _userName = prefs.getString('username') ?? 'AHok';
        });
      }
    } catch (e) {
      print('Error loading data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_brandColorGreen),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: _brandColorGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(_sidePadding, 30, _sidePadding, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildClickableCard(
                        context: context,
                        widthFactor: 0.9,
                        height: 180,
                        icon: Icons.person_outline_sharp,
                        iconColor: _antiDesignAccentColor,
                        label: 'Profil',
                        labelStyle: _cardTextStyle.copyWith(color: _antiDesignAccentColor),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfileScreen(userId: _userId!),
                            ),
                          );
                          // Reload data setelah kembali dari profile
                          if (result == true) {
                            _loadData();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 65),
                    Transform.translate(
                      offset: const Offset(0, 0),
                      child: _buildClickableCalorieCard(
                        context: context,
                        widthFactor: 1.0,
                        height: 180,
                        calorieValue: _currentCalories,
                        targetCalorie: _targetCalories,
                        progress: _calorieProgress,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodHistoryScreen(userId: _userId!),
                            ),
                          ).then((_) => _loadData());
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildScanButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 80,
        bottom: 50,
        left: _sidePadding,
        right: _sidePadding,
      ),
      decoration: const BoxDecoration(
        gradient: _headerGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_barRadius),
          bottomRight: Radius.circular(_barRadius),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('EATWISE', textAlign: TextAlign.center, style: _titleStyle),
          const SizedBox(height: 15),
          Text(
            'Hai,' + _userName,
            textAlign: TextAlign.center,
            style: _subtitleStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildClickableCard({
    required BuildContext context,
    required double widthFactor,
    required double height,
    required IconData icon,
    required Color iconColor,
    required String label,
    required TextStyle labelStyle,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0x66000000),
                blurRadius: 8,
                offset: const Offset(5, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: _iconSizeLarge, color: iconColor),
              const SizedBox(height: 15),
              Text(label, style: labelStyle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCalorieCard({
    required BuildContext context,
    required double widthFactor,
    required double height,
    required int calorieValue,
    required int targetCalorie,
    required double progress,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor,
      height: height,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: [
              BoxShadow(
                color: const Color(0x66000000),
                blurRadius: 8,
                offset: const Offset(5, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('$calorieValue', style: _calorieNumStyle),
                  Text('/ $targetCalorie kal', style: _calorieLabelStyle.copyWith(fontSize: 20)),
                ],
              ),
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 1.0,
                      color: _brandColorGreen.withOpacity(0.3),
                      strokeWidth: 15,
                    ),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationY(math.pi),
                      child: CircularProgressIndicator(
                        value: progress,
                        color: _brandColorGreen,
                        strokeWidth: 15,
                        strokeCap: StrokeCap.square,
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.local_fire_department,
                        color: _brandColorGreen,
                        size: _iconSizeMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 75,
          height: 75,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ScanPage()),
              ).then((_) => _loadData());
            },
            backgroundColor: _scanButtonColor,
            elevation: 8.0,
            shape: const CircleBorder(
              side: BorderSide(color: _brandColorGreen, width: 4),
            ),
            child: const Icon(
              Icons.qr_code_scanner,
              size: 27,
              color: _brandColorGreen,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        gradient: _bottomBarGradient,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_barRadius),
          topRight: Radius.circular(_barRadius),
        ),
      ),
      child: Center(
        child: Text(
          'EATWISE 2025',
          style: _subtitleStyle.copyWith(fontSize: 25, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

// ============================================
// FOOD HISTORY SCREEN
// ============================================
class FoodHistoryScreen extends StatefulWidget {
  final int userId;
  
  const FoodHistoryScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<FoodHistoryScreen> createState() => _FoodHistoryScreenState();
}

class _FoodHistoryScreenState extends State<FoodHistoryScreen> {
  bool _isLoading = true;
  List<dynamic> _historyItems = [];
  int _totalKalori = 0;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);

    try {
      final result = await HistoryService.getTodayHistory(widget.userId);
      
      if (result != null) {
        setState(() {
          _historyItems = result['data'] ?? [];
          _totalKalori = result['summary']['total_kalori'] ?? 0;
        });
      }
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Makanan Hari Ini'),
        backgroundColor:  Color.fromARGB(255, 170, 184, 171),  
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyItems.isEmpty
              ? const Center(child: Text('Belum ada makanan yang dikonsumsi hari ini'))
              : RefreshIndicator(
                  onRefresh: _loadHistory,
                  child: ListView.builder(
                    itemCount: _historyItems.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          color: Colors.green.shade100,
                          child: Text(
                            'Total Kalori Hari Ini: $_totalKalori kal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      
                      final item = _historyItems[index - 1];
                      return ListTile(
                        leading: item['image_url'] != null
                            ? Image.network(item['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.fastfood),
                        title: Text(item['nama_produk'] ?? 'Unknown'),
                        subtitle: Text('${item['kalori_dikonsumsi']} kal • ${item['waktu']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Item'),
                                content: const Text('Yakin ingin menghapus item ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              final success = await HistoryService.deleteHistoryItem(
                                item['id'],
                                widget.userId,
                              );
                              
                              if (success) {
                                _loadHistory();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Item berhasil dihapus')),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
