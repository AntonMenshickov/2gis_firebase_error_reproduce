import 'package:flutter/material.dart';
import 'package:dgis_mobile_sdk_full/dgis.dart' as sdk;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final sdk.Context _mapContext;
  final _mapWidgetController = sdk.MapWidgetController();
  late final sdk.MapObjectManager _mapObjectManager;
  late final sdk.ImageLoader _loader;
  late final sdk.Image _pointImage;
  late final List<sdk.Marker> _markers;

  @override
  void initState() {
    _markers = [];
    _mapContext = sdk.DGis.initialize(
      logOptions: const sdk.LogOptions(
        customLogLevel: sdk.LogLevel.error,
        logLevel: sdk.LogLevel.error,
      ),
      httpOptions: const sdk.HttpOptions(
        timeout: Duration(seconds: 5),
      ),
    );
    _loader = sdk.ImageLoader(_mapContext);
    _mapWidgetController.getMapAsync(_onMapReady);
    super.initState();
  }

  _onMapReady(sdk.Map map) async {
    _mapObjectManager = sdk.MapObjectManager(map);
    _pointImage =
        await _loader.loadPngFromAsset('assets/point_grey.png', 100, 100);
    _testPoint();
  }

  _testPoint() async {
    _markers.clear();
    print('adding 100 markers to map');
    for (int i = 0; i < 100; i++) {
      _markers.add(sdk.Marker(
        sdk.MarkerOptions(
            icon: _pointImage,
            position: sdk.GeoPointWithElevation(
              latitude: sdk.Latitude(58.2855 + i * 0.01),
              longitude: sdk.Longitude(104.2890 + i * 0.01),
            ),
            userData: i.toString(),
            zIndex: sdk.ZIndex(i),
            iconWidth: const sdk.LogicalPixel(1.0)),
      ));
      _mapObjectManager.addObject(_markers[i]);
    }
    print('waiting 5 seconds...');

    await Future.delayed(const Duration(seconds: 5));
    print('removing add markers');
    for (var marker in _markers) {
      _mapObjectManager.removeObject(marker);
    }
    _markers.clear();
    print('done.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: sdk.MapWidget(
        sdkContext: _mapContext,
        mapOptions: sdk.MapOptions(
          position: const sdk.CameraPosition(
              point: sdk.GeoPoint(
                latitude: sdk.Latitude(58.2855),
                longitude: sdk.Longitude(104.2890),
              ),
              zoom: sdk.Zoom(15.0)),
        ),
        controller: _mapWidgetController,
      ),
    );
  }
}
