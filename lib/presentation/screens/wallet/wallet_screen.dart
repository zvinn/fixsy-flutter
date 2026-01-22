import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_theme.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Mock Data
  final double balance = 1250.0;
  final List<Transaction> transactions = [
    Transaction(
      id: '1',
      description: 'خدمة سباكة - أحمد',
      amount: 350.0,
      type: TransactionType.earning,
      date: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Transaction(
      id: '2',
      description: 'سحب إلى البنك',
      amount: -500.0,
      type: TransactionType.withdrawal,
      date: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Transaction(
      id: '3',
      description: 'خدمة كهرباء - محمد',
      amount: 450.0,
      type: TransactionType.earning,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Transaction(
      id: '4',
      description: 'خدمة نجارة - علي',
      amount: 600.0,
      type: TransactionType.earning,
      date: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحفظة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance Card
            _buildBalanceCard(),
            const SizedBox(height: 24),

            // Chart Section
            _buildChartSection(),
            const SizedBox(height: 24),

            // Transactions
            _buildTransactionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'الرصيد الحالي',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance.toStringAsFixed(0)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showWithdrawDialog,
            icon: const Icon(Icons.arrow_upward),
            label: const Text('سحب الأموال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: Colors.white.withOpacity(0.3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, color: AppTheme.successColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'نظرة عامة على الأرباح',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 200,
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
                        const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو'];
                        if (value.toInt() < months.length) {
                          return Text(
                            months[value.toInt()],
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
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
                    spots: const [
                      FlSpot(0, 400),
                      FlSpot(1, 300),
                      FlSpot(2, 600),
                      FlSpot(3, 450),
                      FlSpot(4, 800),
                      FlSpot(5, 650),
                    ],
                    isCurved: true,
                    color: AppTheme.successColor,
                    barWidth: 3,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.successColor.withOpacity(0.1),
                    ),
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'سجل المعاملات (${transactions.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...transactions.map((txn) => _buildTransactionCard(txn)).toList(),
      ],
    );
  }

  Widget _buildTransactionCard(Transaction txn) {
    final isEarning = txn.type == TransactionType.earning;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          right: BorderSide(
            color: isEarning ? AppTheme.successColor : AppTheme.errorColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
              color: isEarning
                  ? AppTheme.successColor.withOpacity(0.1)
                  : AppTheme.errorColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEarning ? Icons.trending_up : Icons.trending_down,
              color: isEarning ? AppTheme.successColor : AppTheme.errorColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  txn.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(txn.date),
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isEarning ? '+' : ''}${txn.amount.toStringAsFixed(0)} ج.م',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isEarning ? AppTheme.successColor : AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showWithdrawDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سحب الأموال', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${balance.toStringAsFixed(0)} ج.م',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم إرسال طلب السحب بنجاح!')),
              );
            },
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

// Models
enum TransactionType { earning, withdrawal, payment }

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.date,
  });
}
