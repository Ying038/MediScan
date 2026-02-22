import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

class LocationService {
  // Action: Open Google Maps Search for Pharmacies in Malaysia
  static Future<void> searchPharmacy() async {
    // This query triggers a search for "Pharmacy" relative to the user's current GPS
    // The 'q' parameter is the search term, and 'll' would be lat/long (omitted for auto-detect)
    final Uri googleMapsUrl = Uri.parse("https://www.google.com/maps/search/?api=1&query=pharmacy+near+me");

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(
          googleMapsUrl, 
          mode: LaunchMode.externalApplication // Opens the actual Google Maps App
        );
      } else {
        // Fallback: search in browser if app isn't installed
        final Uri webUrl = Uri.parse("https://www.google.com/maps/search/pharmacy");
        await launchUrl(webUrl);
      }
    } catch (e) {
      debugPrint("Error opening maps: $e");
    }
  }

  // Bonus Action: Emergency Dialer for Family/SOS
  static Future<void> openDialer(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint("Could not launch dialer");
    }
  }
}