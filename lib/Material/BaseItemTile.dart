import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:rock_carrot/Baseitems/Areas.dart';
import 'package:rock_carrot/Baseitems/BaseItems.dart';
import 'package:rock_carrot/Baseitems/Subareas.dart';
import 'package:rock_carrot/Baseitems/cubit/update_cubit.dart';
import 'package:rock_carrot/Material/ProgressNotifier.dart';
import 'package:rock_carrot/Material/Snackbar.dart';
import 'package:rock_carrot/Web/Teufelsturm.dart';

class BaseItemTile extends StatefulWidget {
  final BaseItem _baseitem;

  /// function that updates data from the web
  final Function? _updateFunction;
  final Function? _updateAllFunction;
  final Function? _deleteFunction;

  /// Constructor
  ///
  /// [updateFunction] Function to update data
  /// [updateAllFunction] Only relevant for update Area!! and SubArea
  /// for Subarea its the link to update TT comments
  /// [deleteFunction] -> might be replace by favorites in future
  BaseItemTile(
    this._baseitem, {
    Function? updateFunction,
    Function? updateAllFunction,
    Function? deleteFunction,
  })  : _updateFunction = updateFunction,
        _updateAllFunction = updateAllFunction,
        _deleteFunction = deleteFunction;

  @override
  _BaseItemTileState createState() => _BaseItemTileState(
        _baseitem,
      );
}

class _BaseItemTileState extends State<BaseItemTile>
    with AutomaticKeepAliveClientMixin {
  final BaseItem _baseitem;

  /// notifier to update progress
  final ProgressNotifier progressNotifier;

  /// keep the Tile alive as long as Progress is done
  @override
  bool get wantKeepAlive {
    // TODO: only keep alive, when update is in progress
    // seems to be a sync/async issue
    return true;
    //progressNotifier.isInProgress; // doesn't seem to work with progressNotifier
  }

  _BaseItemTileState(
    this._baseitem,
  ) :
        // init progress notifier with STATIC Childcount (no progress)
        progressNotifier =
            ProgressNotifier(ProgressStruct(_baseitem.childCountInt));

  @override
  Widget build(BuildContext context) {
    // call automaticKeepAlive Superclass
    super.build(context);

    return _customCountryTileSlide(context);
  }

  Widget _customCountryTileSlide(BuildContext context) {
    List<Widget>? primarySlideActions = [];
    List<Widget>? secondarySlideActions = [];
    // implement update /delete is supplied
    if (widget._updateFunction != null) {
      secondarySlideActions.add(IconSlideAction(
        caption: 'Update',
        color: Colors.green,
        icon: Icons.update,
        onTap: () async {
          if (progressNotifier.isInProgress) {
            ScaffoldMessenger.of(context)
                .showSnackBar(ErrorSnack('Update already in progress'));
            return;
          }
          progressNotifier.updatePercentage(0);

          int records;
          try {
            records = await widget._updateFunction!(_baseitem) as int;
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(ErrorSnack(e.toString()));
            print(e.toString());
            records = 0;
          }
          // update Cubit to current Value
          context.read<UpdateCubit>().callGetValueAsync(_baseitem);

          progressNotifier.setStaticValue(records);
        },
      ));
    }
    // Add UpdateAll possibility (ony if baseitem is Area)
    if (widget._updateAllFunction != null && _baseitem is Area) {
      secondarySlideActions.add(IconSlideAction(
        caption: 'Update All',
        color: Colors.greenAccent,
        icon: Icons.system_update_rounded,
        onTap: () async {
          if (progressNotifier.isInProgress) {
            ScaffoldMessenger.of(context)
                .showSnackBar(ErrorSnack('Update already in progress'));
            return;
          }
          // clear number for update
          progressNotifier.updatePercentage(0);

          int records;
          try {
            records =
                await widget._updateAllFunction!(_baseitem, progressNotifier)
                    as int;
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(ErrorSnack(e.toString()));
            print(e.toString());
            records = 0;
          }

          // update Cubit to current Value
          context.read<UpdateCubit>().callGetValueAsync(_baseitem);
          progressNotifier.setStaticValue(records);
        },
      ));
    }
    // Add UpdateTT Comments possibility (ony if baseitem is Subarea & in Sächsische Schweiz)
    if (widget._updateAllFunction != null &&
        _baseitem is Subarea &&
        sandsteinNameTeufelsturmAreaIdMap.keys.contains(_baseitem.name)) {
      secondarySlideActions.add(IconSlideAction(
        caption: 'Scrape TT',
        color: Colors.greenAccent,
        icon: Icons.cloud_download,
        onTap: () async {
          if (progressNotifier.isInProgress) {
            ScaffoldMessenger.of(context)
                .showSnackBar(ErrorSnack('Update already in progress'));
            return;
          }

          // start update
          progressNotifier.updatePercentage(0);

          int records;
          try {
            // first perform update of area
            // otherwise the caching of data will result in 0 values
            records = await widget._updateFunction!(_baseitem) as int;

            // now perform the scraping
            await widget._updateAllFunction!(_baseitem, progressNotifier)
                as int;
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(ErrorSnack(e.toString()));
            print(e.toString());
            records = 0;
          }

          // set Results
          progressNotifier.setStaticValue(records);
          // update Cubit to current Value
          context.read<UpdateCubit>().callGetValueAsync(_baseitem);
        },
      ));
    }
    if (widget._deleteFunction != null) {
      primarySlideActions.add(IconSlideAction(
        caption: 'Delete',
        color: Colors.red,
        icon: Icons.delete,
        onTap: () async {
          await widget._deleteFunction!(_baseitem);
          progressNotifier.setStaticValue(0);
        },
      ));
    }
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actions: primarySlideActions,
      secondaryActions: secondarySlideActions,
      child: _customBaseItemTileTap(context),
    );
  }

  /// makeing the custom tile tapable
  Widget _customBaseItemTileTap(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/' + _baseitem.runtimeType.toString(),
          arguments: [
            _baseitem,
            progressNotifier,
            context.read<UpdateCubit>(),
          ], // parent item
        );
      },
      child: _customBaseItemTileContent(context),
    );
  }

  /// the actual Content of the Tile
  Widget _customBaseItemTileContent(BuildContext context) {
    /// set progressnotifier to child count, if no update is in process
    progressNotifier.setStaticValue(_baseitem.childCountInt);
    // update current UpdateValue
    context.read<UpdateCubit>().callGetValueAsync(_baseitem);

    return ListTile(
      title: _baseitem.nr != 0
          ? // if there is a reference number for the rock
          Text(_baseitem.nr.toString() + ' ' + _baseitem.name)
          : //concat number and name
          Text(_baseitem.name), // else show only name
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _baseitem.nameCZ != '2nd Language Name'
              ? Text(_baseitem.nameCZ)
              : Container(), //if second language set, show it, else don't
        ],
      ),
      trailing: Container(
        width: 80,
        child:
            // TODO: maybe later replace ValueListenableNotidier wie Cubit
            Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ValueListenableBuilder<ProgressStruct>(
                valueListenable: progressNotifier,
                builder: (context, progress, child) => Text(progress.Text)),
            // Display update status data
            // update data available
            BlocBuilder<UpdateCubit, UpdateState>(
              builder: (context, state) {
                if (state is UpdateInitial) {
                  return Text('init');
                } else if (state is UpdateLoaded) {
                  return Text(
                    state.timestamp,
                    textScaleFactor: 0.7,
                  );
                } else if (state is UpdateLoadedInclTT) {
                  return Text(
                    state.timestamp,
                    textScaleFactor: 0.7,
                  );
                } else if (state is UpdateNoData) {
                  return Text('N/A');
                } else {
                  return Text('else');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// futureBuilder for receiving Update Data
  Widget buildSubtitle(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      String? data = snapshot.data;
      return data == null
          ? Container()
          : Text(
              data,
              textScaleFactor: 0.7,
            );
    }
    // futurebuilder not yet finished
    return Text('N/A');
  }
}
