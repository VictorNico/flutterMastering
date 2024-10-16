import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        // appBar: AppBar(
        //   title: Text(
        //     'Welcome to ',
        //     style: TextStyle(color: Colors.white),
        //   ),
        //   backgroundColor: Colors.blueAccent,
        //   leading: Image.asset('images/TAKENCO.png'),
        // ),
        backgroundColor: Colors.teal,
        body: SafeArea(
            child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 45.0,
                backgroundImage: AssetImage('images/TAKENCO.png'),
              ),
              Text(
                'Victor DJIEMBOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Pacifico',
                ),
              ),
              Text(
                'FLUTTER DEVELOPER',
                style: TextStyle(
                  color: Colors.white60,
                  fontWeight: FontWeight.bold,
                  // fontStyle: FontStyle.italic,
                  fontFamily: 'Source Code Pro',
                  letterSpacing: 2.5,
                  fontSize: 25.0,
                ),
              ),
              Divider(
                height: 20,
                thickness: 2,
                indent: 130,
                endIndent: 130,
                color: Colors.white24,
              ),
              Card(
                margin: EdgeInsets.only(
                  left: 50.0,
                  right: 50.0,
                ),
                // padding: const EdgeInsets.only(
                // left: 20.0, right: 10.0, top: 10.0, bottom: 10.0),
                color: Colors.white,
                child: ListTile(
                  leading: Icon(
                    Icons.phone,
                    color: Colors.teal,
                    size: 24.0,
                    semanticLabel: 'Phone number',
                  ),
                  title: Text(
                    '+237 673 634 375',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontFamily: 'Source Code Pro',
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Card(
                  margin: EdgeInsets.only(
                    left: 50.0,
                    right: 50.0,
                  ),
                  // padding: const EdgeInsets.only(
                  // left: 20.0, right: 10.0, top: 10.0, bottom: 10.0),
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(
                      Icons.email,
                      color: Colors.teal,
                      size: 24.0,
                      semanticLabel: 'Email address',
                    ),
                    title: Text(
                      'victor@takenco.com',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontFamily: 'Source Code Pro',
                        color: Colors.teal,
                      ),
                    ),
                  ))
              // TextField(
              //   decoration: InputDecoration(
              //     icon: Icon(Icons.phone),
              //     hintText: '00237 673 634 375',
              //     // helperText: 'Phone number',
              //     // counterText: '',
              //     // border: OutlineInputBorder(),
              //   ),
              // ),
              // TextField(
              //   decoration: InputDecoration(
              //     icon: Icon(Icons.email),
              //     hintText: 'victor@takenco.com',
              //     // helperText: 'Phone number',
              //     // counterText: '',
              //     // border: OutlineInputBorder(),
              //   ),
              // )
            ],
          ),
        )),
      ),
    );
  }
}
