import 'dart:convert';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart';

import './hourly_forecast_item.dart';
import './additional_info_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  late Future<Map<String,dynamic>> weather;

  Future<Map<String,dynamic>> getCurrentWeather() async {
    try{
      String cityname = 'London';
      final res= await http.get(
      Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityname,uk&APPID=$openWeatherAPIKey')
    );
    
    
    final data =await jsonDecode(res.body);

    if(data['cod']!='200'){
      throw 'An unexpected error occurred';
    }

    return data;
    } 
    catch (e){
      throw e.toString();
    }
  }

  @override
  void initState(){
    super.initState();
    weather = getCurrentWeather();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
        style: TextStyle(
          fontWeight: FontWeight.bold ),
      ),
      centerTitle: true,
      actions:  [
        IconButton(
          onPressed: (){
            setState(() {
              weather = getCurrentWeather();
            });
          },
          icon: Icon(Icons.refresh))
      ],
    ),

    body: FutureBuilder(
      future: weather,
      builder: (context, snapshot) {
        if(snapshot.connectionState ==ConnectionState.waiting){
          return const Center(child:  CircularProgressIndicator.adaptive());
        }

        if(snapshot.hasError){
          return Text(snapshot.error.toString());
        }

        final data = snapshot.data!;

        final currentTemp =  data['list'][0]['main']['temp'];
        final currentSky = data['list'][0]['weather'][0]['main'];
        final currentPressure = data['list'][0]['main']['pressure'];
        final currentWindSpeed = data['list'][0]['wind']['speed'];
        final currentHumidity = data['list'][0]['main']['humidity'];

        return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10,sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0), //gap between text n cloud
                      child: Column(
                        children: [
                          Text('$currentTemp K',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          currentSky == 'Rain' ?
                            Icons.cloudy_snowing : currentSky == 'Clouds' ?
                            Icons.cloud : Icons.sunny,
                        size: 64,
                        ),
                        const SizedBox(height: 16,),
                        Text(currentSky,
                        style: TextStyle(fontSize: 20),),
                                  
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        
      
            const SizedBox(height: 20),
            const Text("Hourly Forecast",
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold) ,),
            const SizedBox(height: 8),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     children: [
            //       for(int i=0;i<39;i++)
                  
            //       HourlyForecastItem(
            //         time:data['list'][i+1]['dt'].toString() ,
            //         icon: data['list'][i+1]['weather'][0]['main'] == 'Rain' ?
            //                 Icons.cloudy_snowing : data['list'][i+1]['weather'][0]['main'] == 'Clouds' ?
            //                 Icons.cloud : Icons.sunny ,
            //         value: '${data['list'][i+1]['main']['temp']} K'),
                  
            //     ],
            //   ),
            // ),

            SizedBox(
              height: 120,
              child: ListView.builder(
                itemCount: 5,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                  final hourlyForecast= data['list'][index+1] ;
                  final time = DateTime.parse(hourlyForecast['dt_txt']);
                  return HourlyForecastItem(
                    icon: hourlyForecast['weather'][0]['main'] == 'Rain' ?
                              Icons.cloudy_snowing : hourlyForecast['weather'][0]['main'] == 'Clouds' ?
                              Icons.cloud : Icons.sunny,
                    value: '${hourlyForecast['main']['temp']} K',
                    time: DateFormat.j().format(time));
                }),
            ),
      
        
      
            const SizedBox(height: 20),
            const Text("Additional Information",
            style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold) ,),
            const SizedBox(height: 8),
      
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                AdditionalInfoItem(icon: Icons.water_drop,label: "Humidity",value: currentHumidity.toString(),),
                AdditionalInfoItem(icon: Icons.air,label: "Air",value: currentWindSpeed.toString(),),
                AdditionalInfoItem(icon: Icons.play_for_work_outlined,label: "Pressure",value: currentPressure.toString()),
      
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



