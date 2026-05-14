import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:travelsphere/app/theme.dart';
import 'package:travelsphere/widgets/common/glass_container.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Main Help & Support dialog
// ─────────────────────────────────────────────────────────────────────────────
class HelpSupportDialog extends StatelessWidget {
  const HelpSupportDialog({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@travelsphere.app',
      query: 'subject=Support%20Request%20-%20TravelSphere',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not open email client. Please email support@travelsphere.app'),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.help_outline, color: AppTheme.primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            const Text('Help & Support',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 20),

          _tile(
            context,
            icon: Icons.email_outlined,
            iconColor: AppTheme.primaryBlue,
            title: 'Contact Support',
            subtitle: 'support@travelsphere.app',
            onTap: () => _launchEmail(context),
          ),
          _tile(
            context,
            icon: Icons.help_center_outlined,
            iconColor: Colors.orangeAccent,
            title: 'FAQs',
            subtitle: 'Answers to common questions',
            onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => const FaqDialog());
            },
          ),
          _tile(
            context,
            icon: Icons.article_outlined,
            iconColor: Colors.cyanAccent,
            title: 'Terms & Conditions',
            subtitle: 'Usage policies and agreements',
            onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (_) => const TermsDialog());
            },
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(color: Colors.white.withValues(alpha: 0.7))),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _tile(BuildContext context, {required IconData icon, required Color iconColor,
      required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
        trailing: Icon(Icons.arrow_forward_ios, size: 14,
            color: Colors.white.withValues(alpha: 0.3)),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FAQ Dialog
// ─────────────────────────────────────────────────────────────────────────────
class FaqDialog extends StatelessWidget {
  const FaqDialog({super.key});

  static const _faqs = [
    ('How do I book a travel package?',
     'Browse packages on the Home screen, tap a package to view details, then tap "Book Now". You\'ll be guided through the checkout process.'),
    ('Can I cancel a booking?',
     'Yes. Go to My Trips, select your trip, and tap "Cancel Booking". Cancellations made 7+ days before departure receive a full refund.'),
    ('How do I generate an itinerary?',
     'Open the Trip Planner from the bottom navigation bar. Enter your destination, duration, and budget, then tap "Generate Itinerary".'),
    ('Is my payment information secure?',
     'Absolutely. TravelSphere uses industry-standard encryption. We never store raw card data — all payments are processed via certified gateways.'),
    ('How do I update my profile picture?',
     'Go to Profile → tap the camera icon on your avatar → select a photo from your gallery. It uploads instantly.'),
    ('What happens if a package price changes?',
     'Your booked price is locked in at the time of booking. Price changes after booking do not affect your reservation.'),
    ('Can I travel with a group?',
     'Yes! Many packages support group bookings. On the package details page, select the number of travellers before proceeding to checkout.'),
    ('How do I contact support?',
     'Tap Help & Support → Contact Support. This will open your email client with a pre-filled support address. Alternatively, email support@travelsphere.app directly.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(0),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.help_center_outlined, color: Colors.orangeAccent, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Frequently Asked Questions',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.6)),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _faqs.map((faq) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    collapsedIconColor: AppTheme.primaryBlue,
                    iconColor: AppTheme.primaryBlue,
                    title: Text(faq.$1,
                        style: const TextStyle(color: Colors.white, fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    children: [
                      Text(faq.$2,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13, height: 1.6)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Terms & Conditions Dialog
// ─────────────────────────────────────────────────────────────────────────────
class TermsDialog extends StatelessWidget {
  const TermsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(0),
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.article_outlined, color: Colors.cyanAccent, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Terms & Conditions',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.6)),
                onPressed: () => Navigator.pop(context),
              ),
            ]),
          ),
          const Divider(color: Colors.white12, height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section('1. Acceptance of Terms',
                      'By accessing and using TravelSphere, you agree to be bound by these Terms and Conditions. If you disagree with any part of these terms, you may not use our service.'),
                  _section('2. Use of the Service',
                      'TravelSphere provides a platform to discover, plan, and book travel packages. You agree to use the service only for lawful purposes and in a manner consistent with all applicable local, national, and international laws.'),
                  _section('3. Account Responsibility',
                      'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorised use.'),
                  _section('4. Bookings & Payments',
                      'All bookings are subject to availability. Prices are displayed in Indian Rupees (INR) and are inclusive of applicable taxes unless stated otherwise. Payment is required at the time of booking to confirm your reservation.'),
                  _section('5. Cancellation & Refund Policy',
                      'Cancellations made 7 or more days before the departure date are eligible for a full refund. Cancellations within 3-7 days receive a 50% refund. No refund is provided for cancellations within 72 hours of departure.'),
                  _section('6. Limitation of Liability',
                      'TravelSphere acts as an intermediary between travellers and service providers. We are not liable for any loss, injury, or damage arising from the services provided by third-party travel partners.'),
                  _section('7. Privacy Policy',
                      'Your personal data is collected and processed in accordance with our Privacy Policy. We use your information solely to provide and improve the TravelSphere service.'),
                  _section('8. Intellectual Property',
                      'All content on TravelSphere, including text, images, and branding, is the intellectual property of TravelSphere and may not be reproduced without prior written consent.'),
                  _section('9. Changes to Terms',
                      'We reserve the right to modify these Terms at any time. Continued use of the service after changes constitutes your acceptance of the new Terms.'),
                  _section('10. Contact',
                      'For questions regarding these Terms, contact us at legal@travelsphere.app.'),
                  const SizedBox(height: 8),
                  Text('Last updated: May 2026',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('I Understand',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(body, style: TextStyle(
            color: Colors.white.withValues(alpha: 0.65), fontSize: 13, height: 1.65)),
      ]),
    );
  }
}
