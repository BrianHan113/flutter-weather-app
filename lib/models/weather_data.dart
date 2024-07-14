class WeatherData {
  final int weatherCode;
  final String weatherDescription;
  final double temp;
  final double tempFeelsLike;
  final double minTemp;
  final double maxTemp;
  final int humidity;
  final int visibility;
  final double windSpeed; // m/s
  final int cloudiness; // %
  final int sunrise;
  final int sunset;
  final String location;
  final int date;

  WeatherData({
    required this.weatherCode,
    required this.weatherDescription,
    required this.temp,
    required this.tempFeelsLike,
    required this.minTemp,
    required this.maxTemp,
    required this.humidity,
    required this.visibility,
    required this.windSpeed,
    required this.cloudiness,
    required this.sunrise,
    required this.sunset,
    required this.location,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      weatherCode: json['weather'][0]['id'],
      weatherDescription: json['weather'][0]['description'],
      temp: json['main']['temp'],
      tempFeelsLike: json['main']['feels_like'],
      minTemp: json['main']['temp_min'],
      maxTemp: json['main']['temp_max'],
      humidity: json['main']['humidity'],
      visibility: json['visibility'],
      windSpeed: json['wind']['speed'],
      cloudiness: json['clouds']['all'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      location: json['name'],
      date: json['dt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weather': [
        {
          'id': weatherCode,
          'description': weatherDescription,
        }
      ],
      'main': {
        'temp': temp,
        'feels_like': tempFeelsLike,
        'temp_min': minTemp,
        'temp_max': maxTemp,
        'humidity': humidity,
      },
      'visibility': visibility,
      'wind': {
        'speed': windSpeed,
      },
      'clouds': {
        'all': cloudiness,
      },
      'sys': {
        'sunrise': sunrise,
        'sunset': sunset,
      },
      'name': location,
      'dt': date,
    };
  }
}
