import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:weather_app/consts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WeatherFactory _weatherFactory = WeatherFactory(OPENWEATHER_API_KEY);

  Future<Weather>? _weather;
  String? _lastUpdated;
  static const String _city = "Delhi";

  @override
  void initState() {
    super.initState();
    // _weatherFactory.currentWeatherByCityName(_city).then((weather) {
    _weather = Future<Weather>(
      () {
        debugPrint("initState(): updating weather data");
        _lastUpdated = DateTime.now().toString();
        return _weatherFactory.currentWeatherByCityName(_city);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _weather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            // display data
            return buildWeatherUI(snapshot.data);
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasError) {
            // show error
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Error!",
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("${snapshot.error}")
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildWeatherUI(Weather? weather) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(weather),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
          _dateTimeInfo(weather),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _weatherIcon(weather),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTemp(weather),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("last updated: $_lastUpdated"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationHeader(Weather? weather) {
    return Text(
      weather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _dateTimeInfo(Weather? weather) {
    if (weather != null && weather.date != null) {
      DateTime now = weather.date!;
      String time = DateFormat("Hm").format(now);
      String weekday = DateFormat("EEEE").format(now);
      String date = DateFormat("d MMM y").format(now);
      return Column(
        children: [
          Text(
            time,
            style: const TextStyle(
              fontSize: 35,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                weekday,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text("  "),
              Text(
                date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          )
        ],
      );
    } else {
      debugPrint("_dateTimeInfo: null");
      return const Text("");
    }
  }

  Widget _weatherIcon(Weather? weather) {
    String? weatherIcon = weather?.weatherIcon;
    debugPrint("_weatherIcon: $weatherIcon");
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "http://openweathermap.org/img/wn/$weatherIcon@4x.png"))),
        ),
        Text(
          weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        )
      ],
    );
  }

  _currentTemp(Weather? weather) {
    String currentTemp =
        "${weather?.temperature?.celsius?.toStringAsFixed(0)}°C";
    String feelsLike =
        "${weather?.tempFeelsLike?.celsius?.toStringAsFixed(0)}°C";
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          currentTemp,
          style: const TextStyle(
              color: Colors.black, fontSize: 90, fontWeight: FontWeight.w500),
        ),
        Text("Feels like $feelsLike"),
      ],
    );
  }

  void debugPrint(String msg) {
    if (kDebugMode) print("[HomePage] $msg");
  }
}
