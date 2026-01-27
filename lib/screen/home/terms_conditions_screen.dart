import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Lufga',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Lufga',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
              _buildText(
                'The use of the OneCharge Booking Service mobile application (“App”) and the official website https://onecharge.io/ is governed by the Terms and Conditions set forth below.\n\nPlease read these Terms and Conditions carefully. By accessing or using the App or the website and booking services through them, you agree to be bound by these Terms.',
              ),
              const SizedBox(height: 16),
              _buildText(
                'If you do not agree with these Terms, please discontinue the use of the App and website immediately.',
              ),
              const SizedBox(height: 16),
              _buildText(
                'OneCharge Booking Service reserves the right to modify, update, or change these Terms and Conditions at any time without prior notice.\n\nPlease review these Terms periodically to stay informed of any updates.',
              ),
              const SizedBox(height: 24),
              _buildHeading('Use of the App and Website'),
              _buildText(
                'We provide you access to the OneCharge Booking Service App and the website https://onecharge.io/ along with related services subject to these Terms. As a user, you agree that you will:',
              ),
              const SizedBox(height: 12),
              _buildBulletPoint(
                'Not use the App or website for any illegal or unauthorized purpose and comply with all applicable laws.',
              ),
              _buildBulletPoint(
                'Not upload, transmit, or distribute viruses, malware, trojans, worms, or any harmful code.',
              ),
              _buildBulletPoint(
                'Not interfere with, damage, or disrupt the functionality, security, or performance of the App or website.',
              ),
              _buildBulletPoint(
                'Not infringe upon the rights of any individual or entity, including intellectual property, privacy, or confidentiality rights.',
              ),
              _buildBulletPoint(
                'Not attempt unauthorized access to any part of the App, website, or related systems.',
              ),
              _buildBulletPoint(
                'Ensure that all information provided by you is accurate, current, and complete.',
              ),
              _buildBulletPoint(
                'Not impersonate any person or entity or use any false or unauthorized identity.',
              ),
              const SizedBox(height: 24),
              _buildHeading('Collection and Use of Personal Information'),
              _buildText(
                'OneCharge Booking Service may collect personal information through the App and the website https://onecharge.io/ to provide secure and reliable services. Information collected may include name, phone number, email address, and address.',
              ),
              const SizedBox(height: 12),
              _buildText(
                'We do not sell, rent, or trade your personal information. Your data is shared only with service providers and partners required to fulfill bookings and operate the services.',
              ),
              const SizedBox(height: 24),
              _buildHeading('Information Tracking'),
              _buildText(
                'We may collect non-personal information such as IP address, device details, and usage activity for analytics, security, and service improvement purposes. This information is not linked to personally identifiable data.',
              ),
              const SizedBox(height: 24),
              _buildHeading('Cookies & App Technologies'),
              _buildText(
                'The App and the website https://onecharge.io/ may use cookies or similar technologies to enhance user experience and improve navigation. You may manage these settings through your device or browser preferences.',
              ),
              const SizedBox(height: 24),
              _buildHeading('Further Information'),
              _buildText(
                'For additional information regarding these Terms and Conditions, please visit:',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('🌐 ', style: TextStyle(fontSize: 16)),
                  Text(
                    'https://onecharge.io/',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'Lufga',
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Lufga',
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        fontFamily: 'Lufga',
        color: Color(0xFF636363),
        height: 1.5,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "• ",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'Lufga',
              color: Color(0xFF636363),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Lufga',
                color: Color(0xFF636363),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
