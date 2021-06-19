part of 'update_cubit.dart';

@immutable
abstract class UpdateState extends Equatable {
  // ensure that Cubit is only called if not equal to previous value
  @override
  List<Object> get props => [];
}

class UpdateInitial extends UpdateState {}

class UpdateLoading extends UpdateState {}

class UpdateNoData extends UpdateState {}

class UpdateLoaded extends UpdateState {
  final UpdateStatus _state;
  UpdateLoaded(this._state);
  String get timestamp {
    return DateFormat('dd.MM.yy').format(_state.timestamp).toString();
  }

  @override
  List<Object> get props => [_state];
}

class UpdateLoadedInclTT extends UpdateState {
  final UpdateStatus _state;
  final UpdateStatus _stateTT;
  UpdateLoadedInclTT(this._state, this._stateTT);
  String get timestamp {
    return ' ' +
        DateFormat('dd.MM.yy').format(_state.timestamp).toString() +
        '\n' +
        '(' +
        DateFormat('dd.MM.yy').format(_stateTT.timestamp).toString() +
        ')';
  }

  @override
  List<Object> get props => [_state, _stateTT];
}
