// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool verify = true;
  double oldX = -1.0;
  double oldZ = -1.0;
  int oc = 0;
  int tur = 0;

  void _incrementCounter() {
    setState(() {
      if (oc == 0) {
        oc = 1;
        print('açık');
      } else if (oc == 1) {
        print('kapali');
        print('${arraylist.length}');
        tur = findPeakUtil(arraylist);
        oc = 2;
        //arraylist.clear();
      } else {
        oc = 0;
        arraylist.clear();
        gyrox.clear();
        gyroy.clear();
      }
    });
  }

  int findPeakUtil(List<dynamic> array) {
    if (array == null || array.isEmpty) {
      return null;
    }

    int n = array.length;

    int tur = 0;
    int end = n - 1;
    int counter = 0;
    int c = 0;

    //Üst peak elemanları bulma
    while (2 < end + 1) {
      if ((array[end - 1] > array[end - 2]) && (array[end - 1] > array[end])) {
        if (array[end - 1] > 9.9) counter++;
        end--;
      } else if (end > 1) {
        end--;
      }
      print('accz ${array[end - 1]}');
    }

    //Alt peak elemanları bulma
    end = n - 1;
    while (2 < end + 1) {
      if ((array[end - 1] < array[end - 2]) && (array[end - 1] < array[end])) {
        if (array[end - 1] < -8) c++;
        end--;
      } else if (end > 1) {
        end--;
      }
    }

    end = n - 1;
    while (2 < end + 1) {
      end--;
      print('accx ${gyrox[end - 1]}');
    }

    end = n - 1;
    while (2 < end + 1) {
      end--;
      print('accy ${gyroy[end - 1]}');
    }

    if (counter > c) {
      tur = c;
    } else if (counter == c) {
      tur = c - 1;
    } else
      tur = null;
    print('$counter');
    print('$c');

    return tur;
  }

  List<double> _accelerometerValues;
  List<double> _userAccelerometerValues;
  List<double> _gyroscopeValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];
  List<dynamic> arraylist = <dynamic>[];
  List<dynamic> gyrox = <dynamic>[];
  List<dynamic> gyroy = <dynamic>[];

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1))?.toList();
    final List<String> userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        ?.toList();

    if (oc == 0) {
      gyrox.add(_accelerometerValues[0]);
      gyroy.add(_accelerometerValues[1]);
      arraylist.add(_accelerometerValues[2]);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Text('ACCX: ${gyrox.toString()} '),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
              ),
              Padding(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Text('ACCY: ${gyroy.toString()}'),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
              ),
              Padding(
                child: Wrap(
                  direction: Axis.horizontal,
                  children: <Widget>[
                    Text('ACCZ: ${arraylist.toString()}'),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions
        .add(userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _userAccelerometerValues = <double>[event.x, event.y, event.z];
      });
    }));
  }
}
