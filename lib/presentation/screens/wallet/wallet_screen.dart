import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/auth_provider.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Local fallback state if WalletProvider is not in tree (e.g. simple widget test)
  double _localBalance = 1250.0;
  int _selectedFilterIndex = 0; // 0: All, 1: Inflow (topUp/earning/reward), 2: Outflow (withdrawal/payment)
  late List<TransactionModel> _localTransactions;

  @override
  void initState() {
    super.initState();
    _localTransactions = [
      TransactionModel(
        id: '1',
        userId: 'demo',
        description: 'شحن رصيد - فودافون كاش',
        amount: 500.0,
        type: TransactionType.topUp,
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      TransactionModel(
        id: '2',
        userId: 'demo',
        description: 'خدمة سباكة - كود حجز #8291',
        amount: -350.0,
        type: TransactionType.payment,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      TransactionModel(
        id: '3',
        userId: 'demo',
        description: 'مكافأة ترحيبية - كود FIXSY50',
        amount: 50.0,
        type: TransactionType.reward,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      TransactionModel(
        id: '4',
        userId: 'demo',
        description: 'سحب إلى الحساب البنكي',
        amount: -500.0,
        type: TransactionType.withdrawal,
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: '5',
        userId: 'demo',
        description: 'خدمة صيانة تكييف - علي حسن',
        amount: 450.0,
        type: TransactionType.earning,
        date: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initProviderUser();
    });
  }

  void _initProviderUser() {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final user = authProvider.currentUser;
      final userId = user?.email.isNotEmpty == true ? user!.email : user?.id;
      if (userId != null) {
        walletProvider.initUser(userId);
      }
    } catch (_) {
      // Ignored if providers not mounted
    }
  }

  WalletProvider? _getWalletProvider(BuildContext context) {
    try {
      return Provider.of<WalletProvider>(context);
    } catch (_) {
      return null;
    }
  }

  double _getBalance(WalletProvider? provider) {
    if (provider != null) return provider.balance;
    return _localBalance;
  }

  List<TransactionModel> _getFilteredTransactions(WalletProvider? provider) {
    if (provider != null) {
      return provider.getFilteredTransactions(_selectedFilterIndex);
    }
    if (_selectedFilterIndex == 1) {
      return _localTransactions.where((t) => t.amount > 0).toList();
    } else if (_selectedFilterIndex == 2) {
      return _localTransactions.where((t) => t.amount < 0).toList();
    }
    return _localTransactions;
  }

  double _getTotalInflow(WalletProvider? provider) {
    if (provider != null) return provider.totalInflow;
    return _localTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (acc, t) => acc + t.amount);
  }

  double _getTotalOutflow(WalletProvider? provider) {
    if (provider != null) return provider.totalOutflow;
    return _localTransactions
        .where((t) => t.amount < 0)
        .fold(0.0, (acc, t) => acc + t.amount.abs());
  }

  List<FlSpot> _getChartSpots(WalletProvider? provider) {
    if (provider != null) {
      return provider.getChartSpots();
    }
    return const [
      FlSpot(0, 400),
      FlSpot(1, 650),
      FlSpot(2, 500),
      FlSpot(3, 850),
      FlSpot(4, 950),
      FlSpot(5, 1250),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = _getWalletProvider(context);
    final currentBalance = _getBalance(walletProvider);
    final totalInflow = _getTotalInflow(walletProvider);
    final totalOutflow = _getTotalOutflow(walletProvider);
    final filteredList = _getFilteredTransactions(walletProvider);
    final totalTransactionsCount = walletProvider != null
        ? walletProvider.transactions.length
        : _localTransactions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة الرقمية'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'مسح كود الدفع',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ماسح كود QR للمدفوعات السريعة قيد التطوير')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(currentBalance).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
            const SizedBox(height: 16),

            // Quick Stats
            _buildQuickStats(totalInflow, totalOutflow).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 20),

            // Action Buttons
            _buildActionButtons(currentBalance).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 24),

            // Analytics Chart
            _buildChartSection(walletProvider).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 24),

            // Transactions Header & Filters
            _buildTransactionsHeader(filteredList.length, totalTransactionsCount),
            const SizedBox(height: 12),

            // Transaction List
            _buildTransactionsList(filteredList),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Colors.amber, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'رصيد Fixsy Pay',
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: AppTheme.successColor, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'نشط ومحمي',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${balance.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'متاح للدفع الفوري وحجز الخدمات وسحب الأرباح',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(double inflow, double outflow) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward, color: AppTheme.successColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي الوارد',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '+${inflow.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.errorColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, color: AppTheme.errorColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي المنصرف',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '-${outflow.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          color: AppTheme.errorColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(double balance) {
    return Row(
      children: [
        // Top Up Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _showTopUpModal,
            icon: const Icon(Icons.add_circle_outline, size: 18),
            label: const Text('شحن المحفظة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Withdraw Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showWithdrawDialog(balance),
            icon: const Icon(Icons.outbox, size: 18),
            label: const Text('سحب الأموال'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Promo / Voucher Button
        IconButton(
          tooltip: 'استخدام كود خصم أو هدية',
          onPressed: _showVoucherDialog,
          icon: const Icon(Icons.card_giftcard),
          style: IconButton.styleFrom(
            backgroundColor: Colors.amber.shade50,
            foregroundColor: Colors.amber.shade900,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.amber.shade300),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartSection(WalletProvider? provider) {
    final spots = _getChartSpots(provider);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.show_chart, color: AppTheme.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حركة الرصيد الشهرية',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'آخر 6 أشهر',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 250,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const months = ['أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر'];
                        if (value.toInt() >= 0 && value.toInt() < months.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              months[value.toInt()],
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.35,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.primaryColor.withValues(alpha: 0.12),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3.5,
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsHeader(int filteredCount, int totalCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'سجل المعاملات ($filteredCount)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'الإجمالي: $totalCount',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('الكل', 0),
              const SizedBox(width: 8),
              _buildFilterChip('الوارد والشحن', 1),
              const SizedBox(width: 8),
              _buildFilterChip('المدفوعات والسحب', 2),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilterIndex = index;
          });
        }
      },
      selectedColor: AppTheme.primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade800,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.grey.shade100,
    );
  }

  Widget _buildTransactionsList(List<TransactionModel> list) {
    if (list.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'لا توجد معاملات مسجلة في هذا القسم',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final txn = list[index];
        return _buildTransactionCard(txn);
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel txn) {
    final isPositive = txn.amount > 0;
    final color = isPositive ? AppTheme.successColor : AppTheme.errorColor;

    IconData icon;
    switch (txn.type) {
      case TransactionType.topUp:
        icon = Icons.add_circle;
        break;
      case TransactionType.earning:
        icon = Icons.trending_up;
        break;
      case TransactionType.reward:
        icon = Icons.card_giftcard;
        break;
      case TransactionType.withdrawal:
        icon = Icons.account_balance;
        break;
      case TransactionType.payment:
        icon = Icons.shopping_bag;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          right: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(txn.date),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${txn.amount.toStringAsFixed(0)} ج.م',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24 && difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showTopUpModal() {
    var selectedAmount = 250.0;
    var selectedMethod = 'instapay';
    final customAmountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'شحن رصيد المحفظة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اختر المبلغ وطريقة الدفع المفضلة للشحن الفوري',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 18),

                  // Quick amounts
                  const Text('المبلغ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [100.0, 250.0, 500.0, 1000.0].map((amt) {
                      final isSelected = selectedAmount == amt && customAmountController.text.isEmpty;
                      return ChoiceChip(
                        label: Text('${amt.toStringAsFixed(0)} ج.م'),
                        selected: isSelected,
                        onSelected: (val) {
                          setModalState(() {
                            selectedAmount = amt;
                            customAmountController.clear();
                          });
                        },
                        selectedColor: AppTheme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: customAmountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'أو اكتب مبلغاً مخصصاً (ج.م)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onChanged: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null && parsed > 0) {
                        setModalState(() {
                          selectedAmount = parsed;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 18),

                  // Payment Method
                  const Text('طريقة الدفع:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  _buildPaymentOption(
                    title: 'انستاباي (InstaPay)',
                    subtitle: 'تحويل لحظي مباشر بدون أي رسوم',
                    icon: Icons.flash_on,
                    value: 'instapay',
                    groupValue: selectedMethod,
                    onTap: () => setModalState(() => selectedMethod = 'instapay'),
                  ),
                  _buildPaymentOption(
                    title: 'فودافون كاش ومحافظ المحمول',
                    subtitle: 'أورانج كاش، وي باي، إتصالات كاش',
                    icon: Icons.phone_android,
                    value: 'wallet',
                    groupValue: selectedMethod,
                    onTap: () => setModalState(() => selectedMethod = 'wallet'),
                  ),
                  _buildPaymentOption(
                    title: 'بطاقة بنكية (فيزا / ماستركارد / ميزة)',
                    subtitle: 'دفع آمن ومحمي بأحدث معايير التشفير',
                    icon: Icons.credit_card,
                    value: 'card',
                    groupValue: selectedMethod,
                    onTap: () => setModalState(() => selectedMethod = 'card'),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _executeTopUp(selectedAmount, selectedMethod);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'تأكيد شحن ${selectedAmount.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.05) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                ],
              ),
            ),
            // ignore: deprecated_member_use
            Radio<String>(
              value: value,
              // ignore: deprecated_member_use
              groupValue: groupValue,
              // ignore: deprecated_member_use
              onChanged: (_) => onTap(),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  void _executeTopUp(double amount, String method) {
    final walletProvider = _getWalletProvider(context);
    if (walletProvider != null) {
      walletProvider.topUp(amount: amount, method: method);
    } else {
      final methodLabel = method == 'instapay' ? 'انستاباي' : (method == 'wallet' ? 'فودافون كاش' : 'البطاقة البنكية');
      setState(() {
        _localBalance += amount;
        _localTransactions.insert(
          0,
          TransactionModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: 'demo',
            description: 'شحن رصيد - $methodLabel',
            amount: amount,
            type: TransactionType.topUp,
            date: DateTime.now(),
          ),
        );
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.successColor,
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('تم شحن ${amount.toStringAsFixed(0)} ج.م بنجاح إلى محفظتك!'),
          ],
        ),
      ),
    );
  }

  void _showWithdrawDialog(double availableBalance) {
    final controller = TextEditingController();
    var destinationType = 'wallet';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('سحب الأموال من المحفظة', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'الرصيد المتاح: ${availableBalance.toStringAsFixed(0)} ج.م',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'المبلغ المطلوب سحبه (ج.م)',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    controller.text = availableBalance.toStringAsFixed(0);
                  },
                  child: const Text('سحب الرصيد كاملاً', style: TextStyle(fontSize: 12)),
                ),
              ),
              const Text('جهة التحويل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('محفظة هاتف'),
                    selected: destinationType == 'wallet',
                    onSelected: (val) => setDialogState(() => destinationType = 'wallet'),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('حساب بنكي / IBAN'),
                    selected: destinationType == 'bank',
                    onSelected: (val) => setDialogState(() => destinationType = 'bank'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text) ?? 0.0;
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
                  );
                  return;
                }
                if (amount > availableBalance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('المبلغ المطلوب أكبر من الرصيد المتاح!')),
                  );
                  return;
                }

                Navigator.pop(ctx);
                final walletProvider = _getWalletProvider(context);
                if (walletProvider != null) {
                  walletProvider.requestWithdrawal(amount: amount, destinationType: destinationType);
                } else {
                  setState(() {
                    _localBalance -= amount;
                    _localTransactions.insert(
                      0,
                      TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: 'demo',
                        description: destinationType == 'bank'
                            ? 'طلب سحب إلى الحساب البنكي'
                            : 'طلب سحب إلى محفظة الهاتف',
                        amount: -amount,
                        type: TransactionType.withdrawal,
                        date: DateTime.now(),
                      ),
                    );
                  });
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppTheme.primaryColor,
                    content: Text('تم تسجيل طلب سحب ${amount.toStringAsFixed(0)} ج.م وجاري المعالجة بنجاح!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
              child: const Text('تأكيد السحب', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showVoucherDialog() {
    final voucherController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, color: Colors.amber),
            SizedBox(width: 8),
            Text('كوبون أو كود هدية', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'أدخل الكود الترويجي لشحن رصيد مجاني في محفظتك فوراً',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: voucherController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'كود الكوبون (مثال: FIXSY50)',
                prefixIcon: const Icon(Icons.confirmation_number_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = voucherController.text.trim().toUpperCase();
              if (code.isEmpty) return;

              final walletProvider = _getWalletProvider(context);
              if (walletProvider != null) {
                final navigator = Navigator.of(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final txn = await walletProvider.redeemVoucher(code);
                if (txn != null) {
                  navigator.pop();
                  messenger.showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.successColor,
                      content: Text('مبروك! تم إضافة ${txn.amount.toStringAsFixed(0)} ج.م إلى محفظتك بنجاح 🎉'),
                    ),
                  );
                } else {
                  messenger.showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.errorColor,
                      content: Text('الكود المدخل غير صالح أو منتهي الصلاحية'),
                    ),
                  );
                }
              } else {
                var bonus = 0.0;
                if (code == 'FIXSY50') {
                  bonus = 50.0;
                } else if (code == 'WELCOME2026') {
                  bonus = 100.0;
                } else if (code == 'BONUS20') {
                  bonus = 20.0;
                }

                if (bonus > 0) {
                  Navigator.pop(ctx);
                  setState(() {
                    _localBalance += bonus;
                    _localTransactions.insert(
                      0,
                      TransactionModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        userId: 'demo',
                        description: 'كوبون هدية - $code',
                        amount: bonus,
                        type: TransactionType.reward,
                        date: DateTime.now(),
                      ),
                    );
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppTheme.successColor,
                      content: Text('مبروك! تم إضافة $bonus ج.م إلى محفظتك بنجاح 🎉'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppTheme.errorColor,
                      content: Text('الكود المدخل غير صالح أو منتهي الصلاحية'),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: const Text('تطبيق الكود', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
