import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'models/person.dart';
import 'package:flutter_svg/flutter_svg.dart';

const primaryColor = Color(0xff7f39fb);
const buttonColor = Color(0xfff2e7fe);
void main() async {
  var uuid = const Uuid();
  WidgetsFlutterBinding.ensureInitialized();
  final database =
      openDatabase(join(await getDatabasesPath(), 'person_database.db'),
          onCreate: (db, version) {
    return db.execute(
        'CREATE TABLE person(uuid STRING PRIMARY KEY, timestamp DATETIME)');
  }, version: 1);

  // Define a function that inserts dogs into the database
  Future<void> insertPerson(Person person) async {
    // Get a reference to the database.
    final db = await database;

    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    await db.insert(
      'person',
      person.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // A method that retrieves all the dogs from the dogs table.
  Future<List<Person>> persons() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('person');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return Person(
          id: maps[i]['id'],
          location: maps[i]['location'],
          uuid: maps[i]['uuid'],
          timestamp: maps[i]['timestamp'],
          gender: maps[i]['gender'],
          child: maps[i]['child'],
          pregnantwoman: maps[i]['pregnantwoman']);
    });
  }

  Future<int> getPersonCount() async {
    final db = await database;

    var query = await db.rawQuery('SELECT COUNT(*) FROM person');
    int count = Sqflite.firstIntValue(query)!;
    return count;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Countr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: primaryColor,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(onPrimary: primaryColor)),
          fontFamily: 'DM Sans',
          appBarTheme:
              AppBarTheme(backgroundColor: Colors.transparent, elevation: 0)),
      home: const MyHomePage(title: 'Countr homepage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Person>> futurePersons;
  int count = 0;

  @override
  void initState() {
    super.initState();
    futurePersons = fetchRecordsFromRemote();
  }

  Future<List<Person>> fetchRecordsFromRemote() async {
    final response =
        await http.get(Uri.parse('http://192.168.28.15:5000/records'));

    if (response.statusCode == 200) {
      var jsonPersons = json.decode(response.body);
      return jsonPersons.map<Person>((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception("Failed to get person.");
    }
  }

  Future pushToCloud(BuildContext context) async {
    final response =
        await http.get(Uri.parse('http://192.168.28.15:5000/pushToCloud'));
    if (response.statusCode == 200) {
      _showToast(context);
    } else {
      print("error");
    }
  }

  void _showToast(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: const Text("Succesfully pushed to cloud!"),
        action: SnackBarAction(
            label: 'UNDO', onPressed: scaffold.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                print("update pressed.");
                setState(() {
                  futurePersons = fetchRecordsFromRemote();
                });
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            const Image(
              image: AssetImage('images/msf_transparent.png'),
              height: 80.0,
            ),
            const SizedBox(height: 80.0),
            const Text("Today is Saturday",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: buttonColor)),
            const Text("30th of October 2021",
                style: TextStyle(fontSize: 24.0, color: buttonColor)),
            const SizedBox(height: 30.0),
            FutureBuilder<List<Person>>(
                future: futurePersons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.none) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: buttonColor,
                    ));
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return createStatsView(context, snapshot);
                  }
                }),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.place,
                  color: buttonColor,
                ),
                const Text("Nairobi, Kenya",
                    style: TextStyle(color: buttonColor, fontSize: 16.0))
              ],
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const QRViewExample(),
                  ));
                },
                child: const Text('Scan'),
                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                )),
            SizedBox(height: 10.0),
            ElevatedButton(
                onPressed: () {
                  pushToCloud(context);
                },
                child: const Text('Upload to cloud'),
                style: ElevatedButton.styleFrom(
                  primary: buttonColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor),
                )),
          ],
        ),
      ),
    );
  }

  Widget createStatsView(
      BuildContext context, AsyncSnapshot<List<Person>> snapshot) {
    const double _iconSize = 64.0;
    const double _fontSize = 24.0;
    const TextStyle _primaryNumbersStyle = TextStyle(
      color: buttonColor,
      fontSize: _fontSize,
      fontWeight: FontWeight.w500,
    );

    const int menCountYesterday = 362;
    const int womenCountYesterday = 301;
    const int childCountYesterday = 70;

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              SvgPicture.asset(
                'icons/man.svg',
                width: _iconSize,
                height: _iconSize,
                color: buttonColor,
              ),
              SizedBox(height: 5.0),
              Text(
                  snapshot.data!
                      .where((element) => element.gender == 'male')
                      .length
                      .toString(),
                  style: _primaryNumbersStyle),
              DifferenceCount(
                  snapshot.data!
                      .where((element) => element.gender == 'male')
                      .length,
                  menCountYesterday)
            ],
          ),
          Column(
            children: [
              SvgPicture.asset(
                'icons/woman.svg',
                width: _iconSize,
                height: _iconSize,
                color: buttonColor,
              ),
              SizedBox(height: 5.0),
              Text(
                  snapshot.data!
                      .where((element) => element.gender == 'female')
                      .length
                      .toString(),
                  style: _primaryNumbersStyle),
              DifferenceCount(
                  snapshot.data!
                      .where((element) => element.gender == 'female')
                      .length,
                  womenCountYesterday)
            ],
          ),
          Column(
            children: [
              SvgPicture.asset(
                'icons/baby.svg',
                width: _iconSize - 14,
                height: _iconSize - 14,
                color: buttonColor,
              ),
              SizedBox(height: 20.0),
              Text(
                  snapshot.data!
                      .where((element) => element.child == 1)
                      .length
                      .toString(),
                  style: _primaryNumbersStyle),
              DifferenceCount(
                  snapshot.data!.where((element) => element.child == 1).length,
                  childCountYesterday)
            ],
          )
        ],
      ),
      SizedBox(height: 20.0),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Total: " + snapshot.data!.length.toString(),
              style: TextStyle(
                color: buttonColor,
                fontSize: _fontSize + 8,
                fontWeight: FontWeight.bold,
              )),
          DifferenceCountTotal(snapshot.data!.length,
              menCountYesterday + womenCountYesterday + childCountYesterday)
        ],
      )
    ]);
  }

  DifferenceCount(int length, int menCountYesterday) {
    double fontsize = 18.0;
    if (length >= menCountYesterday) {
      return Text("+${length - menCountYesterday}",
          style: TextStyle(color: Colors.green[300], fontSize: fontsize));
    } else {
      return Text(
        "${length - menCountYesterday}",
        style: TextStyle(color: Colors.red[300], fontSize: fontsize),
      );
    }
  }

  DifferenceCountTotal(int length, int totalCountYesterday) {
    double fontsize = 22.0;
    if (length >= totalCountYesterday) {
      return Text("  (+${length - totalCountYesterday})",
          style: TextStyle(color: Colors.green[300], fontSize: fontsize));
    } else {
      return Text(
        "  (${length - totalCountYesterday})",
        style: TextStyle(color: Colors.red[300], fontSize: fontsize),
      );
    }
  }
}

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
          Expanded(
              flex: 1,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        if (result != null)
                          Text(
                            result!.code,
                            style: TextStyle(color: buttonColor),
                          )
                        else
                          const Text('Scan a code',
                              style: TextStyle(color: buttonColor))
                      ])))
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: const Color(0xff7f39fb),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
