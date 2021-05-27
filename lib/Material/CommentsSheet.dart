import 'package:flutter/material.dart' hide Route;
import 'package:yacguide_flutter/Baseitems/Areas.dart';
import 'package:yacguide_flutter/Baseitems/BaseItems.dart';
import 'package:yacguide_flutter/Baseitems/Comments.dart';
import 'package:yacguide_flutter/Baseitems/Rocks.dart';
import 'package:yacguide_flutter/Baseitems/Routes.dart';
import 'package:yacguide_flutter/Baseitems/Subareas.dart';
import 'package:yacguide_flutter/Material/FutureBuilderHelper.dart';

class CommentsSheet with Comments, FutureBuilderHelper {
  Future<void> showCommentsSheet(
    BuildContext context,
    BaseItem commentItem,
  ) {
    Function commentFunction;
    int commentSearchId;
    if (commentItem is Area) {
      commentFunction = getAreaComments;
      commentSearchId = commentItem.areaId;
    } else if (commentItem is Subarea) {
      commentFunction = getSubareaComments;
      commentSearchId = commentItem.subareaId;
    } else if (commentItem is Rock) {
      commentFunction = getRockComments;
      commentSearchId = commentItem.rockId;
    } else if (commentItem is Route) {
      commentFunction = getRouteComments;
      commentSearchId = commentItem.routeId;
    } else {
      return Future.value();
    }
    return showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
        ),
        builder: (BuildContext context) {
          return FutureBuilder<List<Comment>>(
            future: commentFunction(commentSearchId),
            builder: routeInformationBuilder,
          );
        });
  }

  Widget routeInformationBuilder(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return futureBuilderErrorMessage(snapshot);
    }

    if (snapshot.connectionState == ConnectionState.done) {
      List<Comment> comments = snapshot.data;
      return buildModalComments(comments);
    }

    return futureBuilderLoadingMessage(snapshot);
  }

  /// actual design of the Modal dialog
  ///
  /// if no data is available - it shows: no data
  /// otherwise multiple comments are shown
  Widget buildModalComments(List<Comment> comments) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: comments.isEmpty
            // no comments available
            ? Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text('no comments available'),
                ))
            // enumerate all comments
            : SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  // iterating through all available comments
                  children: comments.map((comment) {
                    return Column(children: [
                      // status row top
                      Row(children: [
                        Text(
                          comment.date + ' UID:' + comment.userId,
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ]),
                      // actual comment
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          comment.comment,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      // statusrow bottom
                      Column(children: [
                        Row(children: [
                          Text('qual:' + comment.quality),
                          Icon(Icons.thumb_up),
                          Text(' | sicher:' + comment.safety),
                          Text(' | nass:' + comment.wetness),
                        ]),
                        Row(
                          children: [
                            Text('schwer:' + comment.difficulty),
                            Text(' | geklettert:' + comment.climbed),
                            Text(' | begehung:' + comment.climb),
                          ],
                        )
                      ]),
                    ]);
                  }).toList(),
                ),
              ));
  }
}
