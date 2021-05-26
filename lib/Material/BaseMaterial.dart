import 'package:flutter/material.dart';

abstract class BaseItemsMaterialStatefulState<T extends StatefulWidget>
    extends State<T> {
  // abstract function to get futures to concrete data
  Widget buildItemList(AsyncSnapshot snapshot);

  /// futureBuilder for receiving SQL Data
  Widget futureBuildItemList(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      return buildItemList(snapshot);
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  /// Loading message for Futures
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

  /// Error Message for futures
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
