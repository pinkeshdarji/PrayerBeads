import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:vibrate/vibrate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(PrayerBeads());
  });
}

class PrayerBeads extends StatefulWidget {
  @override
  _PrayerBeadsState createState() => _PrayerBeadsState();
}

class _PrayerBeadsState extends State<PrayerBeads> {
  final String kBeadsCount = 'beadsCount';
  final String kMalaCount = 'malaCount';
  final String kImagePath = 'imagePath';
  SharedPreferences prefs;
  PageController _controller = PageController(
    viewportFraction: 0.1,
    initialPage: 5,
  );
  int _beadCounter = 0;
  int _malaCounter = 0;
  bool _canVibrate = true;
  String _imagePath = '';
  bool _isDisposed = false;
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        drawer: Drawer(
          child: SafeArea(
              child: Container(
            color: Colors.orangeAccent,
            child: ListView(children: <Widget>[
              ListTile(
                title: Text("Reset everything"),
                trailing: Icon(Icons.refresh),
                onTap: () {
                  _resetEveryThing();
                },
              ),
            ]),
          )),
        ),
        body: GestureDetector(
          onTap: () {
            _clicked();
          },
          onVerticalDragStart: (details) {
            _clicked();
          },
          child: Container(
            color: Colors.deepOrangeAccent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          textDirection: TextDirection.ltr,
                          children: <Widget>[
                            _Counter(
                                counter: _malaCounter, counterName: 'Mala'),
                            _Counter(
                                counter: _beadCounter, counterName: 'Beads'),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            getImage();
                          },
                          child: Container(
                            padding: EdgeInsets.all(30),
                            child: _imagePath.isEmpty
                                ? Container(
                                    padding: EdgeInsets.all(16),
                                    child: Text(
                                      'Set image',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : Card(
                                    child: Image.file(
                                      File(_imagePath),
                                      fit: BoxFit.fill,
                                      height: 300,
                                      width: 200,
                                    ),
                                    elevation: 10,
                                  ),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                  flex: 1,
                  child: Container(
                    child: PageView.builder(
                      reverse: true,
                      physics: NeverScrollableScrollPhysics(),
                      controller: _controller,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, position) {
                        return Container(
                          child: Image.asset(
                            'assets/bead.png',
                          ),
                        );
                      },
                      itemCount: null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadSettings() async {
    prefs = await SharedPreferences.getInstance();
    bool canVibrate = await Vibrate.canVibrate;
    if (!_isDisposed) {
      setState(() {
        _canVibrate = canVibrate;
        _loadData();
      });
    }
  }

  void _loadData() {
    if (!_isDisposed) {
      setState(() {
        _beadCounter = prefs.getInt(kBeadsCount) ?? 0;
        _malaCounter = prefs.getInt(kMalaCount) ?? 0;
        _imagePath = prefs.getString(kImagePath) ?? '';
      });
    }
  }

  void _resetEveryThing() {
    prefs.setInt(kBeadsCount, 0);
    prefs.setInt(kMalaCount, 0);
    prefs.setString(kImagePath, '');
    _loadData();
  }

  void _clicked() {
    if (!_isDisposed) {
      setState(() {
        _beadCounter++;
        if (_beadCounter > 108) {
          _beadCounter = 0;
          _malaCounter++;
          if (_canVibrate) Vibrate.feedback(FeedbackType.warning);
        } else {
          if (_canVibrate) Vibrate.feedback(FeedbackType.success);
        }
      });
    }
    prefs.setInt(kBeadsCount, _beadCounter);
    prefs.setInt(kMalaCount, _malaCounter);
    int nextPage = _controller.page.round() + 1;
    _controller.animateToPage(nextPage,
        duration: Duration(milliseconds: 200), curve: Curves.easeIn);
  }

  void getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    prefs.setString(kImagePath, image.path);
    _loadData();
  }
}

class _Counter extends StatelessWidget {
  _Counter(
      {Key key,
      @required this.counter,
      this.tsCounter = const TextStyle(
          color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
      @required this.counterName,
      this.tsCounterName = const TextStyle(
          color: Colors.white, fontSize: 20, fontStyle: FontStyle.italic)})
      : super(key: key);
  final int counter;
  final TextStyle tsCounter;
  final String counterName;
  final TextStyle tsCounterName;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('$counter', style: tsCounter),
        Text('$counterName', style: tsCounterName)
      ],
    );
  }
}
