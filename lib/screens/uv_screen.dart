import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/get_data.dart';
import 'package:weather_app/screens/bottom_navbar.dart';
import 'package:weather_app/screens/home_screen.dart';

class UvScreen extends StatefulWidget {
  const UvScreen({super.key});

  @override
  State<UvScreen> createState() => _UvScreenState();
}

class _UvScreenState extends State<UvScreen> {
  int pageIndex = 2;
  GetData data = GetData();
  Uint8List? img;
  bool isLoading = true;
  bool hasError = false;
  bool manualReload = false;
  final int timeBuffer = 3 * 60 * 60 * 1000; // 3 Hours

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lastFetchTime = prefs.getInt('lastFetchTimeChart');
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (lastFetchTime != null &&
        ((currentTime - lastFetchTime) < timeBuffer) &&
        !manualReload) {
      // Load cached data
      String? imgString = prefs.getString('cachedImage');
      if (imgString != null) {
        setState(() {
          img = Uint8List.fromList(imgString.codeUnits);
          isLoading = false;
        });
      }
    } else {
      // Fetch new data and cache it
      try {
        Uint8List newImg = await data.fetchImage();
        prefs.setInt('lastFetchTimeChart', currentTime);
        prefs.setString('cachedImage', String.fromCharCodes(newImg));
        setState(() {
          img = newImg;
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

  @override
  Widget build(BuildContext context) {
    // Make top status bar icons white
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    double statusBar = MediaQuery.of(context).padding.top;

    if (pageIndex == 2) {
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
                      child: const Column(
                        children: [
                          Text(
                            'UV Forecast',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 30,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 10),
                      child: img != null
                          ? Image.memory(img!)
                          : const Text('Image could not be loaded'),
                    ),
                  ],
                ),
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
              case 0:
                setState(() {
                  pageIndex = 0;
                });
              default:
            }
          },
        ),
      );
    } else if (pageIndex == 0) {
      return const HomeScreen();
    } else {
      return const Placeholder();
    }
  }
}
