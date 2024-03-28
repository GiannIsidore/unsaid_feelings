import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Comment extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comment({
    super.key,
    required this.text,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(4),
      ),
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //user

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user + ":  ",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Container(
                width: 200,
                child: Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                  softWrap: true,
                ),
              ),
            ],
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey[500],
            ),
          )
          //comment
        ],
      ),
    );
  }
}
