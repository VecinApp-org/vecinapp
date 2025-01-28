class GeocodingException implements Exception {
  final String message;
  const GeocodingException({this.message = 'Error de geocoding'});
}

class ChannelErrorGeocodingException extends GeocodingException {
  ChannelErrorGeocodingException() : super(message: 'Dejaste algo vacío');
}

class NoValidAddressFoundGeocodingException extends GeocodingException {
  NoValidAddressFoundGeocodingException()
      : super(message: 'No se encontraron resultados');
}

class GenericGeocodingException extends GeocodingException {
  GenericGeocodingException() : super(message: 'Error de geocoding');
}
