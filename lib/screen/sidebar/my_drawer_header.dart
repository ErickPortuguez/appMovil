import 'package:flutter/material.dart';

class MyHeaderDrawer extends StatefulWidget {
  final String names;
  final String lastName;
  final String email;

  const MyHeaderDrawer({
    super.key,
    required this.names,
    required this.lastName,
    required this.email,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MyHeaderDrawerState createState() => _MyHeaderDrawerState();
}

class _MyHeaderDrawerState extends State<MyHeaderDrawer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 21, 0, 156),
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            height: 70,
            width: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: Text(
                "${widget.names.substring(0, 1)}${widget.lastName.substring(0, 1)}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          Text(
            "${widget.names} ${widget.lastName}",
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          Text(
            widget.email,
            style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
