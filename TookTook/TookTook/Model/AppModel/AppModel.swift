//
//  AppModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import Foundation

class AppModel {
  static let instance = AppModel()
  var dataModel = DataModel()
  
  private(set) var appState: AppState = .notStarted
  private(set) var authState: AuthState = .notStarted
  
  // AppFlow
  func appStart() {
    appState = .inMapVC
    dataModel.start()
  }
  
  func timerVCStart() {
    appState = .inTimerVC
  }
  func loginVCStart() {
    appState = .inLoginVC
  }
  
  //AuthFlow
  func loginFlowStart() {
    authState = .loginRequired
  }
  func userLoggedIn(uid: String) {
    authState = .userLoggedIn
    UserModel.instance.settingUID(withUID: uid)
  }
}
