import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../data/models/admin_model.dart';
import '../../providers/admin_provider.dart';

/// AdminPanelScreen - Comprehensive platform control center
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showBroadcastDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();
    var target = 'all';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.campaign, color: AppTheme.primaryColor),
                SizedBox(width: 8),
                Text('إرسال إشعار عام للمنصة'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الفئة المستهدفة:'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: target,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('جميع المستخدمين 👥')),
                      DropdownMenuItem(value: 'techs', child: Text('الفنيين فقط 🛠️')),
                      DropdownMenuItem(value: 'clients', child: Text('العملاء فقط 🏠')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => target = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'عنوان الإشعار',
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: bodyController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'نص الرسالة أو الإعلان',
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (titleController.text.trim().isEmpty || bodyController.text.trim().isEmpty) {
                    UiHelpers.showErrorToast('يرجى ملء جميع الحقول');
                    return;
                  }
                  final provider = Provider.of<AdminProvider>(context, listen: false);
                  final success = await provider.sendBroadcast(
                    title: titleController.text.trim(),
                    body: bodyController.text.trim(),
                    targetGroup: target,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (success) {
                    UiHelpers.showSuccessToast('تم إرسال الإشعار بنجاح لجميع المشتركين!');
                  }
                },
                icon: const Icon(Icons.send, size: 18),
                label: const Text('إرسال الآن'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCouponDialog() {
    final codeController = TextEditingController();
    final discountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة كوبون خصم جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: 'كود الكوبون (مثال: FIXSY30)',
                  prefixIcon: const Icon(Icons.tag),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: discountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'نسبة الخصم % (مثال: 25)',
                  prefixIcon: const Icon(Icons.percent),
                  filled: true,
                  fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final code = codeController.text.trim();
                final discount = double.tryParse(discountController.text.trim()) ?? 0;
                if (code.isEmpty || discount <= 0) {
                  UiHelpers.showErrorToast('يرجى إدخال كود ونسبة خصم صحيحة');
                  return;
                }
                final provider = Provider.of<AdminProvider>(context, listen: false);
                final ok = await provider.addCoupon(code, discount);
                if (ctx.mounted) Navigator.pop(ctx);
                if (ok) {
                  UiHelpers.showSuccessToast('تم إنشاء الكوبون $code بنجاح!');
                }
              },
              child: const Text('حفظ الكوبون'),
            ),
          ],
        );
      },
    );
  }

  void _showSmartRejectDialog(AdminTechnician tech) {
    var selectedReason = 'صورة بطاقة الرقم القومي غير واضحة';
    final customController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('رفض طلب الفني: ${tech.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حدد سبب الرفض لتوجيهه لإعادة التقديم:', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),
                  ...[
                    'صورة بطاقة الرقم القومي غير واضحة',
                    'الرقم القومي غير مطابق للاسم المكتوب',
                    'شهادات الخبرة أو رخصة مزاولة المهنة مفقودة',
                    'سبب آخر...',
                  ].map((r) {
                    final isSelected = selectedReason == r;
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setModalState(() => selectedReason = r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? AppTheme.primaryColor : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(r, style: const TextStyle(fontSize: 13))),
                          ],
                        ),
                      ),
                    );
                  }),
                  if (selectedReason == 'سبب آخر...') ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customController,
                      decoration: InputDecoration(
                        hintText: 'اكتب سبب الرفض بالتفصيل...',
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final reason = selectedReason == 'سبب آخر...'
                      ? customController.text.trim()
                      : selectedReason;
                  if (reason.isEmpty) {
                    UiHelpers.showErrorToast('يرجى تحديد سبب الرفض');
                    return;
                  }
                  final provider = Provider.of<AdminProvider>(context, listen: false);
                  final ok = await provider.rejectTech(tech.id, reason);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (ok) {
                    UiHelpers.showSuccessToast('تم إرسال إشعار الرفض والسبب للفني');
                  }
                },
                child: const Text('تأكيد الرفض'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = Provider.of<AdminProvider>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        appBar: AppBar(
          title: const Text('لوحة التحكم والإدارة'),
          backgroundColor: isDark ? AppTheme.darkCardColor : Colors.white,
          elevation: 1,
          actions: [
            IconButton(
              tooltip: 'إرسال إشعار عام',
              icon: const Icon(Icons.campaign_outlined, color: AppTheme.primaryColor),
              onPressed: _showBroadcastDialog,
            ),
            IconButton(
              tooltip: 'تحديث البيانات',
              icon: const Icon(Icons.refresh),
              onPressed: () => admin.loadAllData(),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primaryColor,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: isDark ? Colors.white60 : Colors.black54,
            tabs: [
              const Tab(icon: Icon(Icons.analytics_outlined, size: 20), text: 'نظرة عامة'),
              Tab(
                icon: Badge(
                  isLabelVisible: admin.pendingCount > 0,
                  label: Text('${admin.pendingCount}'),
                  child: const Icon(Icons.verified_user_outlined, size: 20),
                ),
                text: 'التوثيق',
              ),
              Tab(
                icon: Badge(
                  isLabelVisible: admin.debtors.isNotEmpty,
                  label: Text('${admin.debtors.length}'),
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.money_off_csred_outlined, size: 20),
                ),
                text: 'المديونيات',
              ),
              const Tab(icon: Icon(Icons.confirmation_number_outlined, size: 20), text: 'الكوبونات'),
              Tab(
                icon: Badge(
                  isLabelVisible: admin.disputes.isNotEmpty,
                  label: Text('${admin.disputes.length}'),
                  backgroundColor: Colors.orange,
                  child: const Icon(Icons.report_problem_outlined, size: 20),
                ),
                text: 'النزاعات',
              ),
            ],
          ),
        ),
        body: admin.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(admin, isDark),
                  _buildVerificationTab(admin, isDark),
                  _buildDebtorsTab(admin, isDark),
                  _buildCouponsTab(admin, isDark),
                  _buildDisputesTab(admin, isDark),
                ],
              ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: OVERVIEW & ANALYTICS
  // -------------------------------------------------------------
  Widget _buildOverviewTab(AdminProvider admin, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                icon: Icons.people_outline,
                label: 'المستخدمين النشطين',
                value: '${admin.stats.totalUsers}',
                color: Colors.blue,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.engineering_outlined,
                label: 'الفنيين المعتمدين',
                value: '${admin.stats.totalTechnicians}',
                color: Colors.orange,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.receipt_long_outlined,
                label: 'إجمالي الحجوزات',
                value: '${admin.stats.totalBookings}',
                color: Colors.green,
                isDark: isDark,
              ),
              _StatCard(
                icon: Icons.account_balance_wallet_outlined,
                label: 'إجمالي الإيرادات',
                value: '${admin.stats.revenue.toInt()} ج.م',
                color: Colors.purple,
                isDark: isDark,
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 24),

          // Chart Section
          Text(
            'حركة الطلبات والإيرادات الأسبوعية',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            ),
            child: BarChart(
              BarChartData(
                barGroups: [
                  _makeBarGroup(0, 20, 15),
                  _makeBarGroup(1, 28, 18),
                  _makeBarGroup(2, 32, 22),
                  _makeBarGroup(3, 25, 20),
                  _makeBarGroup(4, 38, 26),
                  _makeBarGroup(5, 45, 32),
                  _makeBarGroup(6, 30, 24),
                ],
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['س', 'أ', 'إ', 'ث', 'أ', 'خ', 'ج'];
                        final val = value.toInt();
                        if (val >= 0 && val < days.length) {
                          return Text(
                            days[val],
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontSize: 12,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Summary Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.pending_actions, color: Colors.amber, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        '${admin.pendingCount} طلب توثيق',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Text('بانتظار المراجعة', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.money_off, color: Colors.red, size: 28),
                      const SizedBox(height: 6),
                      Text(
                        '${admin.totalDebt.toInt()} ج.م ديون',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const Text('مستحقة للمنصة', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppTheme.primaryColor,
          width: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
        BarChartRodData(
          toY: y2,
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 10,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 2: VERIFICATION
  // -------------------------------------------------------------
  Widget _buildVerificationTab(AdminProvider admin, bool isDark) {
    if (admin.pendingTechs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              'لا توجد طلبات توثيق معلقة!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text('جميع الفنيين المسجلين تم تدقيق بياناتهم', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admin.pendingTechs.length,
      itemBuilder: (context, index) {
        final tech = admin.pendingTechs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      tech.name.isNotEmpty ? tech.name[0] : 'ف',
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tech.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${tech.specialty} • ${tech.experience}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'معلق',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.badge_outlined, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'الرقم القومي: ${tech.nationalId.isNotEmpty ? tech.nationalId : "مرفق بالصورة"}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        final ok = await admin.approveTech(tech.id);
                        if (ok) {
                          UiHelpers.showSuccessToast('تم قبول وتوثيق حساب ${tech.name} بنجاح!');
                        }
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('قبول وتوثيق'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showSmartRejectDialog(tech),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('رفض ذكي'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // TAB 3: DEBTORS
  // -------------------------------------------------------------
  Widget _buildDebtorsTab(AdminProvider admin, bool isDark) {
    if (admin.debtors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sentiment_very_satisfied, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              'لا توجد أي مديونيات متأخرة!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text('جميع الفنيين مسددين لمستحقات المنصة بالكامل', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Debt Summary Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE53935), Color(0xFFC62828)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إجمالي المديونيات المستحقة',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      '${admin.totalDebt.toInt()} ج.م',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${admin.debtors.length} فنيين',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        ...admin.debtors.map((debtor) {
          final isOverLimit = debtor.debt >= 500;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCardColor : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isOverLimit ? Colors.red.withValues(alpha: 0.5) : (isDark ? Colors.white12 : Colors.grey.shade200),
                width: isOverLimit ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debtor.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '${debtor.specialty} • ${debtor.unpaidOrdersCount} طلبات غير مسددة',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${debtor.debt.toInt()} ج.م',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        foregroundColor: Colors.green,
                      ),
                      onPressed: () async {
                        final ok = await admin.settleDebt(debtor.id);
                        if (ok) {
                          UiHelpers.showSuccessToast('تم تسوية مديونية ${debtor.name} بنجاح');
                        }
                      },
                      child: const Text('تسوية الحساب', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 4: COUPONS
  // -------------------------------------------------------------
  Widget _buildCouponsTab(AdminProvider admin, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add Coupon Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _showAddCouponDialog,
          icon: const Icon(Icons.add),
          label: const Text('إضافة كود خصم جديد', style: TextStyle(fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 16),

        if (admin.coupons.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('لا توجد كوبونات مسجلة حالياً', style: TextStyle(color: Colors.grey)),
            ),
          )
        else
          ...admin.coupons.map((coupon) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCardColor : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      coupon.code,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'خصم ${coupon.discount.toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          coupon.isActive ? 'مفعل وشغال ✅' : 'معطل وموقوف ⏸️',
                          style: TextStyle(
                            fontSize: 12,
                            color: coupon.isActive ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: coupon.isActive,
                    activeThumbColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      admin.toggleCoupon(coupon.id, coupon.isActive);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () async {
                      final ok = await admin.deleteCoupon(coupon.id);
                      if (ok) {
                        UiHelpers.showSuccessToast('تم حذف الكوبون بنجاح');
                      }
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  // -------------------------------------------------------------
  // TAB 5: DISPUTES
  // -------------------------------------------------------------
  Widget _buildDisputesTab(AdminProvider admin, bool isDark) {
    if (admin.disputes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_outlined, size: 64, color: Colors.green),
            const SizedBox(height: 12),
            Text(
              'لا توجد أي نزاعات أو شكاوى!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text('جميع الطلبات تسير بسلاسة بين العملاء والفنيين', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: admin.disputes.length,
      itemBuilder: (context, index) {
        final dispute = admin.disputes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkCardColor : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dispute.reqId,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    dispute.date,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'الشاكي: ${dispute.clientEmail}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                dispute.reason,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    final ok = await admin.resolveDispute(dispute.id);
                    if (ok) {
                      UiHelpers.showSuccessToast('تم حل النزاع وإغلاق الشكوى بنجاح');
                    }
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('حل النزاع وإغلاقه'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
