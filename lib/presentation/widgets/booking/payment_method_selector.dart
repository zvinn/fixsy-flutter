import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/l10n/app_localizations.dart';

enum PaymentMethodType {
  cash,
  card,
  wallet,
}

class PaymentMethodSelector extends StatelessWidget {
  final PaymentMethodType selectedMethod;
  final Function(PaymentMethodType) onMethodChanged;
  final double walletBalance;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
    this.walletBalance = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t('paymentMethod'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 12),
        
        // Cash Option
        _buildPaymentOption(
          context,
          type: PaymentMethodType.cash,
          icon: Icons.money,
          title: context.t('cash'),
          subtitle: null,
        ),
        
        const SizedBox(height: 12),
        
        // Wallet Option
        _buildPaymentOption(
          context,
          type: PaymentMethodType.wallet,
          icon: Icons.account_balance_wallet,
          title: context.t('walletPay'),
          subtitle: '${context.t('availableBalance')}: $walletBalance ${context.t('currency')}',
          isDisabled: walletBalance <= 0,
        ),
        
        const SizedBox(height: 12),
        
        // Card Option (Visa/Mastercard)
        _buildPaymentOption(
          context,
          type: PaymentMethodType.card,
          icon: Icons.credit_card,
          title: context.t('visa'),
          subtitle: '**** **** **** 1234', // Mocked for now
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required PaymentMethodType type,
    required IconData icon,
    required String title,
    String? subtitle,
    bool isDisabled = false,
  }) {
    final isSelected = selectedMethod == type;
    
    return InkWell(
      onTap: isDisabled ? null : () => onMethodChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.primaryColor.withOpacity(0.05) 
              : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDisabled ? Colors.grey : AppTheme.textPrimaryColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDisabled ? Colors.grey[400] : AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
