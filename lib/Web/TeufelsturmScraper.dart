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
      final commentElements = commentRow.querySelectorAll('td>font');
      // first row is header
      if (commentElements.isNotEmpty) {
        final commentUser = commentElements.elementAt(0).text;
        var commentDate = commentElements.elementAt(0).nextElementSibling?.text;

        final regex = RegExp(r'(\d+\.\d+\.\d+)\s*(\d+\:\d+)');
        final match = regex.firstMatch(commentDate!);
        commentDate = match!.group(1)! + ' ' + match.group(2)!;
        final comment = commentElements.elementAt(1).text;
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
    final regexTable = RegExp(
      r'<table border="0" width="100%" cellpadding="1" cellspacing="0" bgcolor="#1A3C64">'
      r'.*?<tr>.*?<td>.*?'
      r'<table border="0" width="100%" cellpadding="4" cellspacing="1">'
      r'(.*?)</table>',
      multiLine: true,
      dotAll: true,
    );
    final matchTable = regexTable.firstMatch(responseComments);
    final tableComments = matchTable?.group(1);
    final tableCommentsRows = RegExp(
      '<tr>(.*?)</tr>',
      multiLine: true,
      dotAll: true,
    ).allMatches(tableComments ?? '');
    tableCommentsRows.forEach((commentRow) {
      final elements = RegExp(
        r'<td.*?<font.*?><b>(?<user>.*?)</font>.*?'
        r'(?<date>\d+\.\d+\.\d+).*?(?<time>\d+\:\d+).*?'
        r'<font.*?>(?<comment>.*?)</font>.*?'
        r'<font.*?>(?<quality>.*?)</font>.*?',
        dotAll: true,
        multiLine: true,
      ).allMatches(commentRow.group(1).toString());
      if (elements.isNotEmpty) {
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
