import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: MyHomePage(title: 'Stopwatch App'),
    );
  }
}


class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({ Key? key, required this.title }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int milliseconds = 0;
  int seconds = 0;
  int minutes = 0;

  @override
  void initState() {
    super.initState();
  }

  String getParsedTime(String time) {
    if(time.length <= 1) return '0$time';
    return time;
  }

  Stream<int> stopWatchStream() {

    late StreamController<int> streamController;
    Timer? timer;
    Duration timeInterval = Duration(milliseconds: 10);
    int milliseconds = 0;

    void tick(_) {
      milliseconds += 10;
      streamController.add(milliseconds);
    }

    void start() {
      print('Start!');
      timer = Timer.periodic(timeInterval, tick);
    }

    void stop() {
      print('Stop!');
      if(timer != null) {
        timer!.cancel();
      }
    }
    
    void reset() {
      print('Reset!');
      if(timer != null) {
        timer!.cancel();
        milliseconds = 0;
        streamController.close();
      }
    }

    streamController = StreamController<int>(
      onListen: () => start(),
      onCancel: () => reset(),
      onPause: () => stop(),
      onResume: () => start(),
    );

    return streamController.stream;

  }

  StreamSubscription? timerSub;
  Stream<int>? timerStream;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(this.widget.title),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              getParsedTime(minutes.toString()) + ':' + getParsedTime(seconds.toString()) + '.' + getParsedTime(milliseconds.toString()),
              style: GoogleFonts.dosis(
                textStyle: TextStyle(
                  fontSize: 76,
                  color: Colors.pinkAccent,
                )
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.greenAccent,
                      elevation: 0,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24)
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      if(timerStream == null) {
                        timerStream = stopWatchStream();
                        timerSub = timerStream!.listen((int event) {
                          setState(() {
                            minutes = Duration(milliseconds: event).inMinutes;
                            seconds = Duration(milliseconds: event).inSeconds;
                            if(milliseconds >= 100) milliseconds = 0;
                            milliseconds += 1;
                          });
                        });
                      } else {
                        timerSub!.resume();
                      }
                    }
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.redAccent,
                      elevation: 0,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24)
                    ),
                    child: Text(
                      'Stop',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                        timerSub!.pause();
                    }
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.orangeAccent,
                      elevation: 0,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(24)
                    ),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      print('Reset Timer!');
                      timerSub!.cancel();
                      timerStream = null;
                      setState(() {
                        milliseconds = 0;
                        seconds = 0;
                        minutes = 0;
                      });
                    }
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}