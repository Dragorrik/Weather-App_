import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:weather_app/additional_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/secrets.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    weather=getCurrentWeather();
  }
  late Future<Map<String,dynamic>> weather;
  Future<Map<String,dynamic>> getCurrentWeather()async{
    try {
      String cityName = 'Rajshahi,Bangladesh';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName,uk&APPID=$openWeatherAPIKey',
        ),
      );
      final data=jsonDecode(res.body);
      if(data["cod"]!='200'){
        throw "An unexpected error occurred!!!!";
      }

      return data;

    }catch(e){
      throw e.toString();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather App"),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {setState(() {
            weather=getCurrentWeather();
          });}, icon: const Icon(Icons.refresh))
        ],
      ),
      body: FutureBuilder(
        future: weather,
        builder: (context,snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if(snapshot.hasError){
            return Center(child: Text(snapshot.error.toString()));
          }

          final data=snapshot.data!;

          final currentWeatherData=data['list'][0];
          final currentTemp=currentWeatherData['main']['temp'];
          final currentWeatherSky=currentWeatherData['weather'][0]['main'];
          final currentPressure=currentWeatherData['main']['pressure'];
          final currentWindSpeed=currentWeatherData['wind']['speed'];
          final currentHumidity=currentWeatherData['main']['humidity'];

          return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child:  Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "$currentTemp K",
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Icon(
                              currentWeatherSky=='Clouds' || currentWeatherSky=='Rain' ? Icons.cloud : Icons.sunny,
                              size: 64,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text(
                              currentWeatherSky,
                              style: const TextStyle(fontSize: 20),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Weather Forecast",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 20,
              ),
              //  SingleChildScrollView(
              //   scrollDirection: Axis.horizontal,
              //   child: Row(
              //     children: [
              //       for(int i=0;i<5;i++)
              //         HourlyForecastItem(
              //         time: data["list"][i+1]["dt"].toString(),
              //         icon: data["list"][i+1]['weather'][0]['main']=="Clouds" || data["list"][i+1]['weather'][0]['main']=="Rain" ? Icons.cloud : Icons.sunny,
              //         temperature: data["list"][i+1]["main"]["temp"].toString(),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context,index){
                      final hourlyForecast=data["list"][index+1];
                      final time=DateTime.parse(hourlyForecast['dt_txt']);
                  return HourlyForecastItem(
                      time: DateFormat.j().format(time),
                      icon: hourlyForecast['weather'][0]['main']=="Clouds" || hourlyForecast['weather'][0]['main']=="Rain" ?Icons.cloud : Icons.sunny,
                      temperature: hourlyForecast['main']['temp'].toString()
                  );
                }
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Additional Information",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 16,
              ),
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AdditionalInfoItem(
                    icon: Icons.water_drop,
                    label: "Humidity",
                    value: currentHumidity.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.air,
                    label: "Wind Speed",
                    value: currentWindSpeed.toString(),
                  ),
                  AdditionalInfoItem(
                    icon: Icons.beach_access,
                    label: "Pressure",
                    value: currentPressure.toString(),
                  ),
                ],
              )
            ],
          ),
        );
        },
      ),
    );
  }
}





