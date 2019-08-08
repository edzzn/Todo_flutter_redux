import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_redux/main.dart';

import 'package:todo_redux/model/model.dart';
import 'package:todo_redux/redux/actions.dart';

void saveToPreferences(AppState state) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String jsonString = json.encode(state.toJson());

  await preferences.setString('itemsState', jsonString);
}

Future<AppState> loadFromPreferences() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  String jsonString = preferences.getString('itemsState');
  if (jsonString != null) {
    Map jsonState = json.decode(jsonString);
    return AppState.fromJson(jsonState);
  }
  return AppState.initialState();
}

void appStateMiddleware(
    Store<AppState> store, action, NextDispatcher next) async {
  next(action);

  if (action is AddItemAction ||
      action is RemoveItemAction ||
      action is RemoveItemsButton) {
    saveToPreferences(store.state);
  }

  if (action is GetItemsAction) {
    await loadFromPreferences().then((state) {
      return store.dispatch(LoadedItemsAction(state.items));
    });
  }
}
