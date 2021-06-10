import 'package:flutter/material.dart' hide Route;
import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Comments.dart';
import 'package:rock_carrot/Baseitems/Rocks.dart';
import 'package:rock_carrot/Baseitems/Routes.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Material/FutureBuilderHelper.dart';

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
    if (comments.isEmpty) {
      return Padding(
          padding: EdgeInsets.all(10),
          child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Center(
                child: Text('no comments available'),
              )));
    }
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Expanded(
            child:
                // enumerate all comments via ListView Builder
                ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: comments.length,
              itemBuilder: (context, i) {
                return commentsItemTile(comments[i]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// comment tile
  ///
  /// How each comment should look like
  Widget commentsItemTile(Comment comment) {
    return Column(children: [
      // status row top
      Row(
        children: [
          Text(
            comment.date + ' UID:' + comment.userId,
            style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
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
          comment.hasQualityRoute ? Text('quality:') : Container(),
          comment.hasQualityRoute
              ? Icon(
                  comment.qualityRouteIcon ?? Icons.minimize,
                  size: 15,
                )
              : Container(),
          comment.hasSafetyRoute ? Text(' | safety:') : Container(),
          comment.hasSafetyRoute
              ? Icon(
                  comment.safetyRouteIcon ?? Icons.minimize,
                  size: 15,
                )
              : Container(),
          comment.hasWetnessRoute ? Text(' | wet:') : Container(),
          comment.hasWetnessRoute
              ? Icon(
                  comment.wetnessRouteIcon ?? Icons.minimize,
                  size: 15,
                )
              : Container(),
          comment.hasDiffucultyRoute
              ? Text(' | grade: ${comment.difficultyRoute}')
              : Container(),
        ]),
      ]),
      Divider(),
    ]);
  }
}
