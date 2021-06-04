import 'package:html/parser.dart';

/// class implementing all the parsing/scraping
class TeufelsturmScraper {
  /// parse rocks using DOM
  ///
  /// return in json format
  Future<List<dynamic>> parseRocks(
    String responseRocks, {
    int areaId = -1,
  }) async {
    var allRocks = <dynamic>[];

    // build DOM
    final docRocks = parse(responseRocks);
    // select the table that contains all data
    final tableRocks = docRocks.querySelector(
        'html>body>table>tbody>tr>td>table>tbody>tr>td>div>table>tbody');

    // iterate through each row
    final allRockRows = tableRocks?.querySelectorAll('tr');
    allRockRows?.forEach((rockRow) {
      // retrieve elements with data
      // th is without font
      final rockElements = rockRow.querySelectorAll('td>font');
      // first row is header
      if (rockElements.isNotEmpty) {
        final rockName = formatElement(rockElements.elementAt(1).text);
        final rockNr = rockElements.elementAt(2).text;
        final rockArea = rockElements.elementAt(3).text;
        final rockId = rockElements
            .elementAt(4)
            .firstChild
            ?.attributes['href']
            ?.substring(25);

        // generate List for export
        allRocks.add({
          'id': rockId,
          'nr': rockNr,
          'name': rockName,
          'areaid': areaId,
          'areaName': rockArea,
        });
      }
    });
    return allRocks;
  }

  /// parse routes using DOM
  ///
  /// return in json format
  Future<List<dynamic>> parseRoutes(
    String responseRoutes, {
    int rockId = -1,
    int areaId = -1,
  }) async {
    var allRoutes = <dynamic>[];

    // build DOM
    final docRoutes = parse(responseRoutes);

    // select the table that contains all data
    final tableRoutes = docRoutes.querySelector(
        'html>body>table>tbody>tr>td>table>tbody>tr>td>div>table>tbody');

    // iterate through each row
    final allRouteRows = tableRoutes?.querySelectorAll('tr');
    allRouteRows?.forEach((routeRow) {
      // retrieve elements with data
      // th is without font
      final routeElements = routeRow.querySelectorAll('td>font');
      // first row is header
      if (routeElements.isNotEmpty) {
        var rockName = formatElement(routeElements.elementAt(1).text);
        var routeName = formatElement(routeElements.elementAt(2).text);
        var routeQuality = routeElements
            .elementAt(3)
            .firstChild
            ?.attributes['src']
            ?.substring(19);
        var routeDifficulty = routeElements.elementAt(4).text;
        var area = routeElements.elementAt(5).text;
        var routeId = routeElements
            .elementAt(6)
            .firstChild
            ?.attributes['href']
            ?.substring(36);

        // generate List for export
        allRoutes.add({
          'id': routeId,
          'name': routeName.trim(),
          'average_quality': routeQuality,
          'difficulty': routeDifficulty,
          'rockid': rockId,
          'rockName': rockName,
          'areaid': areaId,
          'areaName': area,
        });
      }
    });
    return allRoutes;
  }

  /// parse routes using DOM
  ///
  /// return in json format
  Future<List<dynamic>> parseRoutesRegEx(
    String responseRoutes, {
    int rockId = -1,
    int areaId = -1,
  }) async {
    var allRoutes = <dynamic>[];

    // match table with routes
    final regexTable = RegExp(
      r'<table border="0" width="100%" cellpadding="1" cellspacing="0" bgcolor="#1A3C64">'
      r'.*?<tr>.*?<td>.*?<div.*?'
      r'<table'
      r'(.*?)</table>',
      multiLine: true,
      dotAll: true,
    );

    final matchTable = regexTable.firstMatch(responseRoutes);

    // match all rows the contain the routes
    final tableRoutes = matchTable?.group(1);
    final tableRoutesRows = RegExp(
      '<tr>(.*?)</tr>',
      multiLine: true,
      dotAll: true,
    ).allMatches(tableRoutes ?? '');

    // iterate through all rows
    tableRoutesRows.forEach((routeRow) {
      // parse the routes
      final routeElements = RegExp(
        r'<td.*?<font.*?>(?<id>.*?)</font>.*?'
        r'<td.*?<font.*?>\s*?(?<rockName>.*?)\s*?</font>.*?'
        r'<td.*?<font.*?<a href=.*?(?<routeId>\d+).*?>\s*?(?<routeName>.*?)\s*?</a>.*?'
        r'<td.*?<font.*?<img.*?/(?<quality>.*?)\.gif.*?</font>.*?'
        r'<td.*?<font.*?>(?<difficulty>.*?)</font>.*?'
        r'<td.*?<font.*?>(?<areaName>.*?)</font>.*?'
        r'<td.*?<font.*?>(?<status>.*?)</font>.*?',
        dotAll: true,
        multiLine: true,
      ).allMatches(routeRow.group(1).toString());
      // first line (Header) will not match
      if (routeElements.isNotEmpty) {
        // generate List for export
        allRoutes.add({
          'id': routeElements.first.namedGroup('routeId') ?? '',
          'name': routeElements.first.namedGroup('routeName') ?? '',
          'average_quality': routeElements.first.namedGroup('quality') ?? '',
          'difficulty': routeElements.first.namedGroup('difficulty') ?? '',
          'rockid': rockId,
          'rockName': routeElements.first.namedGroup('rockName') ?? '',
          'areaid': areaId,
          'areaName': routeElements.first.namedGroup('areaName') ?? '',
        });
      }
    });
    return allRoutes;
  }

  /// parse comments using DOM
  ///
  /// return in json format
  Future<List<dynamic>> parseComments(
    String responseComments, {
    int routeId = -1,
    int rockId = -1,
    int areaId = -1,
  }) async {
    var allComments = <dynamic>[];

    // build DOM
    final docComments = parse(responseComments);

    // select the table that contains all data
    final tableComments = docComments.querySelector(
        'html>body>table>tbody>tr>td>table>tbody>tr>td>table>tbody');

    // iterate through each row
    final allCommentRows = tableComments?.querySelectorAll('tr');
    allCommentRows?.forEach((commentRow) {
      // retrieve elements with data
      // th is without font
      // use font[size="2"] to exclude "zuletzt bearbeitet"
      final commentElements = commentRow.querySelectorAll('td>font[size="2"]');
      // first row is header
      if (commentElements.isNotEmpty) {
        final commentUser = commentElements.elementAt(0).text;
        var commentDate = commentElements.elementAt(0).nextElementSibling?.text;

        final regex = RegExp(r'(\d+\.\d+\.\d+)\s*(\d+\:\d+)');
        final match = regex.firstMatch(commentDate!);
        commentDate = match!.group(1)! + ' ' + match.group(2)!;
        final comment = commentElements.elementAt(1).text.trim();
        final commentQual = commentElements.elementAt(2).text;

        // generate List for export
        allComments.add({
          'routeid': routeId,
          'rockid': rockId,
          'areaid': areaId,
          'user': commentUser,
          'date': commentDate,
          'comment': comment,
          'quality': commentQual,
        });
      }
    });
    return allComments;
  }

  /// parse comments without using DOM
  ///
  /// return in json format
  Future<List<dynamic>> parseCommentsRegEx(
    String responseComments, {
    int routeId = -1,
    int rockId = -1,
    int areaId = -1,
  }) async {
    var allComments = <dynamic>[];

    // match table with comments
    final regexTable = RegExp(
      r'<table border="0" width="100%" cellpadding="1" cellspacing="0" bgcolor="#1A3C64">'
      r'.*?<tr>.*?<td>.*?'
      r'<table border="0" width="100%" cellpadding="4" cellspacing="1">'
      r'(.*?)</table>',
      multiLine: true,
      dotAll: true,
    );
    final matchTable = regexTable.firstMatch(responseComments);

    // match all rows the contain the comments
    final tableComments = matchTable?.group(1);
    final tableCommentsRows = RegExp(
      '<tr>(.*?)</tr>',
      multiLine: true,
      dotAll: true,
    ).allMatches(tableComments ?? '');

    // iterate through all rows
    tableCommentsRows.forEach((commentRow) {
      // parse the comments
      final elements = RegExp(
        r'<td.*?<font.*?><b>(?<user>.*?)</font>.*?'
        r'(?<date>\d+\.\d+\.\d+).*?(?<time>\d+\:\d+).*?'
        r'<td.*?<font.*?>(?<comment>.*?)</font>.*?'
        r'<td.*?<font.*?>(?<quality>.*?)</font>.*?',
        dotAll: true,
        multiLine: true,
      ).allMatches(commentRow.group(1).toString());

      // first line (Header) will not match
      if (elements.isNotEmpty) {
        // add data to jsons map
        allComments.add({
          'routeid': routeId,
          'rockId': rockId,
          'areaid': areaId,
          'user': elements.first.namedGroup('user') ?? '',
          'date': elements.first.namedGroup('date') ??
              '' ' ' + (elements.first.namedGroup('time') ?? ''),
          'comment': elements.first.namedGroup('comment') ?? '',
          'quality': elements.first.namedGroup('quality') ?? '',
        });
      }
    });

    return allComments;
  }

  /// Format Element correctly
  ///
  /// get rid of unnecessary white spaces
  /// if there is a Comma inside - replace names without comma
  String formatElement(String element) {
    element = element.replaceAll(RegExp(r'\s+'), r' ');
    // process Comma stuff
    final split = element.split(', ');
    if (split.length > 1) {
      element = split.last.trim() + ' ' + split.first.trim();
    }
    return element;
  }
}
