import 'package:flutter/material.dart';

class FuturesHelper {
  Widget futureBuilderLoadingMessage(AsyncSnapshot snapshot) {
    final message = 'Loading data... ${snapshot.connectionState.toString()}';
    return Column(
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(),
        ),
        Padding(
          padding: EdgeInsets.all(50),
          child: Text(message),
        )
      ],
    );
  }

  Widget futureBuilderErrorMessage(AsyncSnapshot snapshot) {
    print('ERROR' + snapshot.error.toString());
    return Column(children: [
      Icon(
        Icons.error_outline,
        color: Colors.yellow,
        size: 50,
      ),
      Padding(
        padding: EdgeInsets.all(60),
        child: Text(snapshot.error.toString()),
      ),
    ]);
  }
}
