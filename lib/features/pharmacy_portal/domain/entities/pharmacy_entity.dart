import 'dart:math' as math;
import 'package:equatable/equatable.dart';

/// Represents a licensed community pharmacy registered on ComfortCare.
/// Functions as a physical decentralized micro-fulfillment dispensary.
class CommunityPharmacyEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String lga;
  final String? landmark;
  final double latitude;
  final double longitude;
  final String phone;
  final String whatsapp;
  final String licenseNumber;
  final String pharmacistInCharge;
  final bool isOpen;
  final double rating;
  final Map<String, int> stockLevels; // drug_name or drug_id -> quantity in stock

  const CommunityPharmacyEntity({
    required this.id,
    required this.name,
    required this.address,
    this.city = 'Abuja',
    this.state = 'Federal Capital Territory',
    this.lga = 'Abuja Municipal (AMAC)',
    this.landmark,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.whatsapp,
    required this.licenseNumber,
    required this.pharmacistInCharge,
    this.isOpen = true,
    this.rating = 4.9,
    this.stockLevels = const {},
  });

  /// Checks if this pharmacy has a specific drug in stock with enough quantity
  bool hasStock(String drugName, int requiredQuantity) {
    if (!isOpen) return false;
    return stockFor(drugName) >= requiredQuantity;
  }

  /// Returns current stock level for a drug
  int stockFor(String drugName) {
    final lowerName = drugName.toLowerCase().trim();
    for (final entry in stockLevels.entries) {
      final key = entry.key.toLowerCase().trim();
      if (lowerName.contains(key) || key.contains(lowerName)) {
        return entry.value;
      }
    }
    return 0;
  }

  /// Calculates straight-line distance in kilometers using the Haversine formula
  double distanceTo(double destLat, double destLng) {
    const earthRadiusKm = 6371.0;
    final dLat = (destLat - latitude) * (math.pi / 180.0);
    final dLng = (destLng - longitude) * (math.pi / 180.0);
    final lat1 = latitude * (math.pi / 180.0);
    final lat2 = destLat * (math.pi / 180.0);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLng / 2) * math.sin(dLng / 2) * math.cos(lat1) * math.cos(lat2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Computes estimated courier arrival time in minutes to destination coordinates
  /// (2.2 mins/km transit speed + 6 minutes dispensary prep buffer)
  int etaMinutesTo(double destLat, double destLng) {
    final distKm = distanceTo(destLat, destLng);
    return (distKm * 2.2).ceil() + 6;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        state,
        lga,
        landmark,
        latitude,
        longitude,
        phone,
        whatsapp,
        licenseNumber,
        pharmacistInCharge,
        isOpen,
        stockLevels,
      ];
}
