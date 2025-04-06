import 'dart:developer';

import 'package:ebroker/utils/Login/lib/payloads.dart';
import 'package:ebroker/utils/login/lib/login_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class LoginSystem {
  BuildContext? context;
  setContext(BuildContext context) {
    this.context = context;
  }

  List<Function(MLoginState fn)> listeners = [];
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  //This is abstract method it will be called when state of login change it means when emit method will be called it will called
  void onEvent(MLoginState state);

  ///This emit method will change state of login and notify all listeners and call onEvent method
  void emit(MLoginState state) {
    ///Loop through all listeners and call them
    for (final i in listeners) {
      i.call(state);
    }
    onEvent(state);
  }

  Future<void> requestVerification() async {
    emit(MVerificationPending());
  }

  LoginPayload? payload;

  //This will set login payload it means it will set necessary data while login like its email , password or anything else
  Future<void> setPayload(LoginPayload payload) async {
    this.payload = payload;
  }

  ///This method will be called when initialize this
  void init() {}

  ///Here will be implementation of the main login method, it will return userCredentials
  Future<UserCredential?> login();
}

///From this we will be able to use this login . [this is for single authentication . if you use this you must have to create instance of every login system individually]
class MAuthentication {
  MAuthentication(this.system, {this.payload});
  LoginPayload? payload;
  final LoginSystem system;

  //This will call login system's init method
  void init() {
    system.init();
  }

  ///this login call will execute login method of login system which is being assigned
  Future<UserCredential?>? login() async {
    //assign payload to system from constructor
    system.payload = payload;

    final credential = await system.login();
    //Return its response
    return credential;
  }
}

///This is used for multiple authentication system like you do not have to create all system's instance again and again
class MMultiAuthentication {
  MMultiAuthentication(
    this.systems, {
    this.payload,
  });
  MultiLoginPayload? payload;
  Map<String, LoginSystem> systems;
  String? _selectedLoginSystem;
  void setContext(BuildContext context) {
    for (final element in systems.values) {
      element.setContext(context);
    }
  }

  ///This init will call all login system's init method by loop
  void init() {
    for (final loginSystem in systems.values) {
      loginSystem.init();
    }
  }

  void requestVerification() {
    systems.forEach((String key, LoginSystem value) async {
      //like assign the particular payload if key is matching to selected login system
      LoginSystem? selectedSystem;
      if (_selectedLoginSystem == key) {
        selectedSystem = systems[key];
        selectedSystem?.payload = payload?.payloads[key];
        await selectedSystem?.requestVerification();
      }
    });
  }

  ///This method ensures which login system is active
  Future<void> setActive(String key) async {
    _selectedLoginSystem = key;
  }

  ///This will listen changes in state
  void listen(Function(MLoginState state) fn) {
    systems.forEach((String key, LoginSystem value) async {
      // if (_selectedLoginSystem == key) {
      // systems[key]?.payload = payload?.payloads[key];
      systems[key]?.listeners.add(fn);
      // }
    });
  }

  ///This method will called for login
  Future<UserCredential?>? login() async {
    if (_selectedLoginSystem == '' || _selectedLoginSystem == null) {
      log('Please select login system using setActive method');
    }
    LoginSystem? selectedSystem;

    //assign payload and login system
    systems.forEach((String key, LoginSystem value) async {
      //like assign the particular payload if key is matching to selected login system
      if (_selectedLoginSystem == key) {
        systems[key]?.payload = payload?.payloads[key];
        selectedSystem = systems[key];
      }
    });

    UserCredential? credential;
    if (selectedSystem != null) {
      credential = await selectedSystem?.login();
    }

    return credential;
  }
}
