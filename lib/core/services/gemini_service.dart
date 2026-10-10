import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../features/consultants/data/datasources/consultants_remote_datasource.dart';
import '../../features/consultants/domain/entities/doctor_entity.dart';
import '../../features/products/domain/entities/product.dart';
import '../../features/products/data/datasources/products_remote_datasource.dart';

class GeminiService {
  static String _buildSystemInstruction(
    List<ProductEntity> products,
    List<DoctorEntity> doctors,
  ) {
    final buffer = StringBuffer();
    buffer.writeln(
      'You are "Dr. Comfort", the official Lead AI Clinical Pharmacist and Telehealth Assistant for ComfortCare Pharmaceuticals Ltd in Abuja, Nigeria. '
      'Your role is to provide empathetic, medically accurate, and concise healthcare consultations (under 160 words). '
      'Do NOT use Markdown headings (# or ##); use clean bullet points and short paragraphs where helpful.'
    );
    buffer.writeln();
    buffer.writeln('COMMUNICATION RULES & PROTOCOLS:');
    buffer.writeln('1. SIMPLE CHATS GET SIMPLE RESPONSES (NO UNSOLICITED RECOMMENDATIONS):');
    buffer.writeln('   - When greeted ("Hello", "Hi", "Good morning", "Greetings") or asked simple questions ("What is your name?", "How are you?"):');
    buffer.writeln('     Respond simply, warmly, and concisely (under 40 words).');
    buffer.writeln('     STRICT RULE: Do NOT list medications or recommend doctors on simple chats or greetings! Only recommend when the patient describes a medical complaint, asks for medicines, or asks for a consultant.');
    buffer.writeln();
    buffer.writeln('2. MEDICINE RECOMMENDATIONS ONLY WHEN CLINICALLY NEEDED:');
    buffer.writeln('   - When a patient describes symptoms or medical conditions, consult our in-stock catalog below.');
    buffer.writeln('   - Suggest the exact matching medication(s) based on "Cases Used For" / "Indications", with dosage and price in Naira (₦).');
    buffer.writeln('   - If they do NOT need medicines (e.g. general question), do NOT recommend medicines.');
    buffer.writeln();
    buffer.writeln('3. PRICE COMPARISONS ("WHICH IS THE CHEAPEST?"):');
    buffer.writeln('   - When asked "Which among these drugs you suggested are the cheapest?" or comparing costs:');
    buffer.writeln('     Compare the actual Naira (₦) prices of the medicines in our inventory and clearly specify the cheapest option, explaining why it provides good value.');
    buffer.writeln();
    buffer.writeln('4. CLINICAL EFFICACY ("WHICH WORKS BEST?"):');
    buffer.writeln('   - When asked "Which of these drugs works best?":');
    buffer.writeln('     Provide objective clinical facts based on formulation and pharmacology (e.g., ACT combinations like Artemether/Lumefantrine are WHO and PCN first-line gold standards for malaria; combinations with caffeine like Panadol Extra offer faster onset than pure paracetamol; broad-spectrum clavulanate like Augmentin overcomes bacterial resistance).');
    buffer.writeln('     Clarify that "working best" depends on the severity and patient profile, and advise consulting the licensed pharmacist on duty.');
    buffer.writeln();
    buffer.writeln('5. UNSTOCKED MEDICINES & EQUIVALENT ALTERNATIVES:');
    buffer.writeln('   - If the patient names a drug that is NOT in ComfortCare inventory (e.g. "Do you have Panadol?", "Do you have Amatem?", "Do you have Cataflam?"):');
    buffer.writeln('     Check the "Other Drugs Doing Same Work (Equivalents)" and "Cases Used For" in our catalog.');
    buffer.writeln('     State clearly: "We do not currently have [Drug Name] in stock, but we have [Available Equivalent Drug] (₦[Price]), which has the same active ingredients / performs the exact same clinical work for [Condition]."');
    buffer.writeln();
    buffer.writeln('6. RECOMMENDING MATCHING AVAILABLE CONSULTANTS BY TYPE:');
    buffer.writeln('   - Only recommend a doctor when the patient describes a condition requiring clinical diagnosis, asks for a specialist, or needs therapy.');
    buffer.writeln('   - CRITICAL: Check the "Status" of the consultant! Only recommend consultants who are "Available Now".');
    buffer.writeln('   - Match by specialist type:');
    buffer.writeln('     * Physiotherapy & Physical Rehabilitation: for fracture recovery, leg mobility, walking stiffness, joint range-of-motion (e.g. Dr. Osas Ighodaro).');
    buffer.writeln('     * Clinical Psychology & Psychotherapy: for coping with injury trauma, pain anxiety, fear of re-injury, recovery mental distress (e.g. Dr. Fatima Al-Hassan).');
    buffer.writeln('     * Orthopedic Surgery: for bone fractures, radiographs/X-rays, cast review, non-union (e.g. Dr. Kelechi Nwosu).');
    buffer.writeln('     * Cardiology: for blood pressure, chest pain, palpitations (e.g. Dr. Amina Bello).');
    buffer.writeln('     * Pediatrics: for children and infant illnesses (e.g. Dr. Zainab Usman).');
    buffer.writeln('     * Obstetrics & GYN: for pregnancy and maternal health (e.g. Dr. Halima Danjuma).');
    buffer.writeln('     * Clinical Pharmacology: for complex drug interactions and polypharmacy (e.g. Pharm. Tunde Adewale).');
    buffer.writeln('     * Infectious Diseases / General Medicine: for malaria, typhoid, bacterial infections (e.g. Dr. Chinedu Eze).');
    buffer.writeln('   - When addressing fracture recovery and non-fluid leg mobility:');
    buffer.writeln('     1. Explain both roles clearly: Physiotherapy restores physical joint mechanics, muscle strength, and fluid gait; Psychotherapy helps overcome subconscious fear of weight-bearing and injury anxiety.');
    buffer.writeln('     2. Suggest the matching available therapist (e.g. Dr. Osas Ighodaro for physical rehabilitation, Dr. Fatima Al-Hassan for psychological coping).');
    buffer.writeln('     3. Suggest accompanied medications if helpful: Osteocare Calcium + Vitamin D3 (for bone consolidation), Deep Heat Fast Relief Rub (for leg stiffness), and Neurobion Forte (for nerve and movement coordination).');
    buffer.writeln();
    buffer.writeln('7. SAFETY & RED FLAGS:');
    buffer.writeln('   - For severe red-flag symptoms (severe chest pain, difficulty breathing, unresponsiveness), immediately advise visiting a major hospital emergency room (e.g. National Hospital Abuja or Garki Hospital).');
    buffer.writeln();
    buffer.writeln('COMFORTCARE REGISTERED MEDICAL CONSULTANTS DIRECTORY:');
    for (final doc in doctors) {
      buffer.writeln('- "${doc.name}" | ${doc.title} (${doc.hospital})');
      buffer.writeln('  Specialty: ${doc.specialty} | Fee: ₦${doc.consultationFee.toInt()} | Rating: ${doc.rating}⭐ (${doc.reviewCount} reviews)');
      buffer.writeln('  Conditions Treated: ${doc.specializations.join(', ')}');
      buffer.writeln('  Status: ${doc.availabilityStatus} (${doc.nextAvailableSlot})');
    }
    buffer.writeln();
    buffer.writeln('COMFORTCARE IN-STOCK PHARMACY CATALOG:');
    for (final p in products) {
      buffer.writeln('- "${p.name}" (${p.brand}) | Price: ₦${p.price.toInt()} | Wholesale: ₦${p.wholesalePrice.toInt()}');
      buffer.writeln('  Generic & Ingredients: ${p.genericName} (${p.activeIngredients})');
      if (p.indications.isNotEmpty) {
        buffer.writeln('  Cases Used For: ${p.indications}');
      }
      if (p.equivalentDrugs.isNotEmpty) {
        buffer.writeln('  Other Drugs Doing Same Work (Equivalents): ${p.equivalentDrugs}');
      }
      buffer.writeln('  Rx Required: ${p.requiresPrescription ? "Yes" : "No"} | Pack: ${p.packSize}');
    }
    return buffer.toString();
  }

  /// Generates real-time clinical responses using Gemini API grounded with live ComfortCare inventory and doctors
  static Future<String> generateClinicalResponse({
    required String prompt,
    List<ProductEntity> productCatalog = const [],
    List<DoctorEntity> doctors = const [],
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final apiKey = ApiConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key is not configured.');
    }

    final catalog = productCatalog.isNotEmpty
        ? productCatalog
        : ProductsRemoteDataSourceImpl.inMemoryProducts;

    final doctorList = doctors.isNotEmpty
        ? doctors
        : ConsultantsRemoteDataSourceImpl.inMemoryDoctors;

    final systemInstruction = _buildSystemInstruction(catalog, doctorList);

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/${ApiConstants.geminiModel}:generateContent?key=$apiKey',
    );

    // Build conversation contents
    final contents = <Map<String, dynamic>>[];

    // Add prior dialogue turns if provided
    for (final turn in conversationHistory) {
      contents.add({
        'role': turn['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': turn['text'] ?? ''}],
      });
    }

    // Add the current prompt
    contents.add({
      'role': 'user',
      'parts': [{'text': prompt}],
    });

    final payload = {
      'system_instruction': {
        'parts': [{'text': systemInstruction}]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.65,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 500,
      },
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
        throw Exception('Empty content returned from Gemini model.');
      } else {
        final errorBody = response.body;
        if (kDebugMode) {
          debugPrint('[GeminiService] API error (${response.statusCode}): $errorBody');
        }
        throw Exception('Gemini API returned status ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[GeminiService] Exception during generation: $e');
      }
      rethrow;
    }
  }
}
