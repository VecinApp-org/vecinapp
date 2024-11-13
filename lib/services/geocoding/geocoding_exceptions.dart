class GeocodingException implements Exception {
  const GeocodingException();
}

class ChannelErrorGeocodingException extends GeocodingException {}

class NoValidAddressFoundGeocodingException extends GeocodingException {}

class GenericGeocodingException extends GeocodingException {}
