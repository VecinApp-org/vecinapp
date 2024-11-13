import 'package:vecinapp/services/geocoding/address.dart';
import 'package:vecinapp/services/geocoding/geocoding_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as devtools show log;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:vecinapp/services/geocoding/geocoding_exceptions.dart';

class OpenCageGeocodingProvider implements GeocodingProvider {
  @override
  Future<List<Address>> getValidAddress({
    required String country,
    required String state,
    required String municipality,
    required String neighborhood,
    required String street,
    required String houseNumber,
    required String postalCode,
    required String? interior,
    required double? latitude,
    required double? longitude,
  }) async {
    //check if fields are empty
    if (street.trim().isEmpty ||
        municipality.trim().isEmpty ||
        state.trim().isEmpty ||
        country.trim().isEmpty ||
        postalCode.trim().isEmpty ||
        houseNumber.trim().isEmpty) {
      throw ChannelErrorGeocodingException();
    }
    final String addressLine1 = '${street.trim()} ${houseNumber.trim()}'.trim();
    final String fullAddress =
        '$addressLine1, ${neighborhood.trim()}, ${postalCode.trim()} ${municipality.trim()}, ${state.trim()}, ${country.trim()}';
    //request geocoding results
    final url = Uri.https('api.opencagedata.com', '/geocode/v1/json', {
      'q': fullAddress,
      'key': dotenv.get('GEOCODER_APIKEY'),
      'address_only': '1',
      'abbrv': '1',
      'countrycode:': 'mx',
      'no_annotations': '1',
      'pretty': '1',
    });
    final response = await http.get(url);
    //check if the request was successful
    if (response.statusCode != 200) {
      throw GenericGeocodingException();
    }
    //parse the response
    final List<dynamic> results = await jsonDecode(response.body)['results'];
    if (results.isEmpty) {
      throw GenericGeocodingException();
    }
    //filter the results
    results
        .removeWhere((result) => result['components']['house_number'] == null);
    results.removeWhere((result) => result['components']['road'] == null);
    results.removeWhere((result) => result['components']['country'] == null);
    results.removeWhere((result) => result['components']['postcode'] == null);
    results.removeWhere((result) => result['components']['county'] == null);
    results.removeWhere((result) => result['components']['state'] == null);
    results.removeWhere((result) => result['geometry'] == null);
    results.removeWhere((result) => result['formatted'] == null);

    if (results.isEmpty) {
      throw NoValidAddressFoundGeocodingException();
    }

    final addresses = results
        .map((result) => Address.fromOpenCageJson(
              json: result,
              interior: interior,
            ))
        .toList();
    devtools.log('Filtered Results: ${addresses.toString()}');
    return addresses;
  }
}
