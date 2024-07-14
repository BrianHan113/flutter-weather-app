import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/get_data.dart';
import 'package:weather_app/models/weather_data.dart';
import 'package:weather_app/screens/bottom_navbar.dart';
import 'package:weather_app/screens/uv_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? iconNum;
  GetData data = GetData();
  WeatherData? weatherData;
  int pageIndex = 0;
  bool isLoading = true;
  bool hasError = false;
  bool manualReload = false;
  final int timeBuffer = 20 * 60 * 1000; // 20 Minutes

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastFetchTime = prefs.getInt('lastFetchTimeWeather');
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lastFetchTime != null &&
        ((currentTime - lastFetchTime) < timeBuffer) &&
        !manualReload) {
      String? jsonString = prefs.getString('cachedWeatherData');
      if (jsonString != null) {
        Map<String, dynamic> jsonMap = await jsonDecode(jsonString);
        WeatherData loadedData = WeatherData.fromJson(jsonMap);
        setState(() {
          weatherData = loadedData;
          isLoading = false;
        });
      }
      // Load cached data
    } else {
      // Fetch new data and cache it
      try {
        WeatherData newWeatherData = await data.getData();
        String jsonString = jsonEncode(newWeatherData.toJson());
        prefs.setInt('lastFetchTimeWeather', currentTime);
        prefs.setString('cachedWeatherData', jsonString);
        setState(() {
          weatherData = newWeatherData;
          isLoading = false;
          manualReload = false;
        });
      } catch (e) {
        setState(() {
          isLoading = false;
          hasError = true;
          manualReload = false;
        });
      }
    }
  }

  DateTime epochToHuman(epoch) {
    DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(epoch * 1000, isUtc: true);

    return dateTime;
  }

  String updateImg(weatherCode) {
    switch (weatherCode) {
      // Thunder
      case >= 200 && < 300:
        return '1';
      // Drizzle
      case >= 300 && < 400:
        return '2';
      // Rain
      case >= 500 && < 600:
        return '3';
      // Snow
      case >= 600 && < 700:
        return '4';
      // Clear
      case 800:
        return '6';
      // Clouds
      case 801:
        return '7';
      case 802:
        return '8';
      case 803:
        return '5';
      case 804:
        return '5';
      // Otherwise:
      default:
        return '1';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Make top status bar icons white
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    double statusBar = MediaQuery.of(context).padding.top;

    if (pageIndex == 0) {
      Widget bodyContent;

      if (isLoading) {
        bodyContent = const Center(child: CircularProgressIndicator());
      } else if (hasError) {
        bodyContent = const Center(child: Text('Error loading data'));
      } else {
        bodyContent = Column(
          children: [
            Expanded(
              child: Align(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: statusBar + 50),
                      child: Column(
                        children: [
                          Text(
                            weatherData!.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                            ),
                          ),
                          Text(
                            weatherData!.weatherDescription.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Image.asset(
                        './assets/${updateImg(weatherData!.weatherCode)}.png',
                        scale: 2.5,
                      ),
                    ),
                    Text(
                      '${weatherData!.temp.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 50,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Feels Like ${weatherData!.tempFeelsLike.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE dd/MM • HH:mm')
                          .format(epochToHuman(weatherData!.date).toLocal()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 0, 40, 25),
              child: Column(
                children: [
                  Row(children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            './assets/11.png',
                            scale: 8,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sunrise',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm').format(
                                    epochToHuman(weatherData!.sunrise)
                                        .toLocal()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            './assets/12.png',
                            scale: 8,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Sunset',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                DateFormat('HH:mm').format(
                                    epochToHuman(weatherData!.sunset)
                                        .toLocal()),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ]),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.0),
                    child: Divider(
                      color: Color.fromARGB(255, 92, 92, 92),
                    ),
                  ),
                  Row(children: [
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            './assets/14.png',
                            scale: 8,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Humidity',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                '${weatherData!.humidity}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Image.asset(
                            './assets/9.png',
                            scale: 8,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Wind',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                '${(weatherData!.windSpeed * 3.6).toStringAsFixed(1)} km/h',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        );
      }

      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 15, 15, 15),
        body: bodyContent,
        bottomNavigationBar: CustomNavbar(
          currentIndex: pageIndex,
          onTap: (int value) {
            switch (value) {
              case 1:
                setState(() {
                  manualReload = true;
                  loadData();
                });
                break;
              case 2:
                setState(() {
                  pageIndex = 2;
                });
              default:
            }
          },
        ),
      );
    } else if (pageIndex == 2) {
      return const UvScreen();
    } else {
      return const Placeholder();
    }
  }
}
