# Weather App

Weather app made using the Flutter framework. Uses the geolocator package to get precise location information for http requests to the OpenWeather API for general weather information, and the NIWA api for UV index information. Used the shared_preferences package to persist data, so the app didn't make unnecessary API calls. This consisted of persisting time data, and including logic so the API calls would not be made every single time a page was built (20 minutes for general weather, 3 hours for UV forecast). Also included a manual refresh button, for on-demand updated information.

Also note: The app was designed for use on SM G991B.

<p align="center">
  <img src="https://i.imgur.com/Xn71cJz.jpg" alt="Weather" width="300"/>
  <img src="https://i.imgur.com/bLWlp2E.png" alt="UV" width="300"/>
</p>

## Setup Instructions

1. **Rename `.env_PLACEHOLDER` to `.env` and input your OpenWeather and NIWA API keys.**

2. **In Console:**
   ```bash
   flutter pub get
   flutter run
