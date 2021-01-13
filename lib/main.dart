import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart'
    show ArCoreController;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';
import 'components/map_pin_pill.dart';
import 'models/pin_pill_info.dart';
import 'screens/assets_object.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 0;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const double DEFAULT_DISTANCE = 28.08;
const List<String> MODELS = ["toucan", "andy", "artic_fox"];
const int MAXIMUM_MARKERS = 15;

const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

// FIXME: avoid global variable
String selectedModel;
// const LatLng DEST_LOCATION = LatLng(37.335685, -122.0605916);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('ARCORE IS AVAILABLE?');
  print(await ArCoreController.checkArCoreAvailability());
  print('\nAR SERVICES INSTALLED?');
  print(await ArCoreController.checkIsArCoreInstalled());
  // runApp(App());
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MapPage()));
}

class MapPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set<Marker>();
  String googleAPIKey = '<API_KEY>';
// // for my custom marker pins
//   BitmapDescriptor sourceIcon;
//   BitmapDescriptor destinationIcon;
// the user's initial location and current location
// as it moves
  LocationData currentLocation;
// a reference to the destination location
//   LocationData destinationLocation;
// wrapper around the location API
  Location location;
  int markerID = 0;
  double pinPillPosition = -100;
  double distance_accuracy = DEFAULT_DISTANCE;
  TextEditingController _distanceAccuractyController = TextEditingController(text: DEFAULT_DISTANCE.toString());
  TextEditingController _latController = TextEditingController();
  TextEditingController _longController = TextEditingController();
  PinInformation currentlySelectedPin = PinInformation(
      pinPath: '',
      avatarPath: '',
      location: LatLng(0, 0),
      locationName: '',
      labelColor: Colors.grey);

  @override
  void initState() {
    super.initState();

    // create an instance of Location
    location = new Location();

    // subscribe to changes in the user's location
    // by "listening" to the location's onLocationChanged event
    location.onLocationChanged().listen((LocationData cLoc) {
      // cLoc contains the lat and long of the
      // current user's position in real time,
      // so we're holding on to it
      currentLocation = cLoc;
    });
    // set custom marker pins
    // setSourceAndDestinationIcons();
    // set the initial location
    setInitialLocation();
  }

  void setInitialLocation() async {
    // set the initial location by pulling the user's
    // current location from the location's getLocation()
    currentLocation = await location.getLocation();

    addMarker(currentLocation.latitude, currentLocation.longitude, 0);
  }

  @override
  Widget build(BuildContext context) {
    CameraPosition initialCameraPosition = CameraPosition(
        zoom: CAMERA_ZOOM,
        tilt: CAMERA_TILT,
        bearing: CAMERA_BEARING,
        target: SOURCE_LOCATION);
    if (currentLocation != null) {
      initialCameraPosition = CameraPosition(
          target: LatLng(currentLocation.latitude, currentLocation.longitude),
          zoom: CAMERA_ZOOM,
          tilt: CAMERA_TILT,
          bearing: CAMERA_BEARING);
    }
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  width: double.infinity,
                  color: Colors.black38,
                  child: new Row(
                    children: [
                      Expanded(
                        flex: 3, // 60% of space => (6/(6 + 4))
                        child: Text(
                            'Select Model'
                        ),
                      ),
                      Expanded(
                        flex: 4, // 60% of space => (6/(6 + 4))
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: MyDropDownWidget(
                            initList: MODELS,
                          ),
                        )
                      ),
                      Expanded(
                        flex: 3, // 60% of space => (6/(6 + 4))
                        child: OutlineButton(
                          onPressed: () {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => AssetsObject(
                                    initObject: selectedModel + ".sfb",
                                )));
                          },
                          child: Text('SHOW AR'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                child: Container(
                  alignment: Alignment.topLeft,
                  height: 50.0,
                  width: double.infinity,
                  color: Colors.black38,
                  child: new Row(
                    children: [
                      Expanded(
                        flex: 3, // 60% of space => (6/(6 + 4))
                        child: new Text(
                            'GPS Accuracy'
                        ),
                      ),
                      Expanded(
                        flex: 4, // 60% of space => (6/(6 + 4))
                        child: TextField(
                          controller: _distanceAccuractyController,
                        ),
                      ),
                      Expanded(
                        flex: 3, // 60% of space => (6/(6 + 4))
                        child: OutlineButton(
                          onPressed: () {
                            distance_accuracy = double.parse((_distanceAccuractyController.text));
                            print('Received click ' + distance_accuracy.toString());
                          },
                          child: Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                child: Container(
                  alignment: Alignment.topLeft,
                  height: 50.0,
                  width: double.infinity,
                  color: Colors.black38,
                  child: new Row(
                    children: [
                      Expanded(
                        flex: 2, // 60% of space => (6/(6 + 4))
                        child: new Text(
                            'LAT:'
                        ),
                      ),
                      Expanded(
                        flex: 3, // 60% of space => (6/(6 + 4))
                        child: TextField(
                          controller: _latController,
                        ),
                      ),
                      Expanded(
                        flex: 2, // 60% of space => (6/(6 + 4))
                        child: new Text(
                            'LONG:'
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _longController,
                        ),
                      ),
                      Expanded(
                        flex: 3, // 60% of space => (6/(6 + 4))
                        child: OutlineButton(
                          onPressed: () {
                            if (markerID >= MAXIMUM_MARKERS) {
                              markerID = 0;
                            } else {
                              markerID += 1;
                            }
                            addMarker(double.parse(_latController.text.toString()), double.parse(_longController.text.toString()), markerID);
                          },
                          child: Text('PLACE'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  color: Colors.red,
                  child: Stack(
                    children: <Widget>[
                      GoogleMap(
                          myLocationEnabled: true,
                          compassEnabled: true,
                          tiltGesturesEnabled: false,
                          markers: _markers,
                          // polylines: _polylines,
                          mapType: MapType.normal,
                          initialCameraPosition: initialCameraPosition,
                          onTap: (LatLng loc) {
                            pinPillPosition = -100;
                          },
                          onMapCreated: (GoogleMapController controller) {
                            // controller.setMapStyle(Utils.mapStyles);
                            _controller.complete(controller);
                            // my map has completed being created;
                            // i'm ready to show the pins on the map
                          }),
                      MapPinPillComponent(
                          pinPillPosition: pinPillPosition,
                          currentlySelectedPin: currentlySelectedPin)
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      )
    );
  }

  void addMarker(double lat, double long, int id) {
    showNewMarker(lat, long);
    setState(() {
      // updated position
      var pinPosition = LatLng(lat, long);

      // the trick is to remove the marker (by id)
      // and add it again at the updated location

      PinInformation destinationPinInfo;

      destinationPinInfo = PinInformation(
          locationName: "End Location",
          location: pinPosition,
          pinPath: "assets/destination_map_marker.png",
          avatarPath: "assets/friend2.jpg",
          labelColor: Colors.purple);

      _markers.removeWhere((m) => m.markerId.value == 'destPin' + id.toString());
      _markers.add(Marker(
        draggable: true,
        markerId: MarkerId('destPin' + markerID.toString()),
        onTap: () {
          setState(() {
            currentlySelectedPin = destinationPinInfo;
            pinPillPosition = 0;
          });
        },
        onDragEnd: ((newPosition) {
          addMarker(newPosition.latitude, newPosition.longitude, id);
        }),
        position: pinPosition, // updated position
        // icon: sourceIcon
      ));
    });
  }

  void showNewMarker(double lat, double long) async {
    CameraPosition cPosition = CameraPosition(
            zoom: CAMERA_ZOOM,
            tilt: CAMERA_TILT,
            bearing: CAMERA_BEARING,
            target: LatLng(lat, long),
          );
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
  }
}

/// This is the stateful widget that the main application instantiates.
class MyDropDownWidget extends StatefulWidget {
  final List<String> initList;
  MyDropDownWidget({Key key, this.initList}) : super(key: key);

  @override
  _MyDropDownWidget createState() => _MyDropDownWidget();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyDropDownWidget extends State<MyDropDownWidget> {
  String dropdownValue = MODELS[0];

  @override
  void initState() {
    super.initState();
    selectedModel = dropdownValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          dropdownValue = newValue;
          selectedModel = newValue;
        });
      },
      items: widget.initList
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class MyTextFieldWidget extends StatefulWidget {
  MyTextFieldWidget({Key key}) : super(key: key);

  @override
  _MyTextFieldWidget createState() => _MyTextFieldWidget();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MyTextFieldWidget extends State<MyTextFieldWidget> {
  TextEditingController _controller;

  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black38,
            border: InputBorder.none,
          ),
          controller: _controller,
          onSubmitted: (String value) async {

          },
        ),
      ),
    );
  }
}

// class Utils {
//   static String mapStyles = '''[
//   {
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#f5f5f5"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.icon",
//     "stylers": [
//       {
//         "visibility": "off"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#616161"
//       }
//     ]
//   },
//   {
//     "elementType": "labels.text.stroke",
//     "stylers": [
//       {
//         "color": "#f5f5f5"
//       }
//     ]
//   },
//   {
//     "featureType": "administrative.land_parcel",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#bdbdbd"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   },
//   {
//     "featureType": "poi",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#757575"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "poi.park",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },
//   {
//     "featureType": "road",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#ffffff"
//       }
//     ]
//   },
//   {
//     "featureType": "road.arterial",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#757575"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#dadada"
//       }
//     ]
//   },
//   {
//     "featureType": "road.highway",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#616161"
//       }
//     ]
//   },
//   {
//     "featureType": "road.local",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.line",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#e5e5e5"
//       }
//     ]
//   },
//   {
//     "featureType": "transit.station",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#eeeeee"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "geometry",
//     "stylers": [
//       {
//         "color": "#c9c9c9"
//       }
//     ]
//   },
//   {
//     "featureType": "water",
//     "elementType": "labels.text.fill",
//     "stylers": [
//       {
//         "color": "#9e9e9e"
//       }
//     ]
//   }
// ]''';
// }
