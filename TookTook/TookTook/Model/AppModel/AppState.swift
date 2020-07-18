//
//  AppState.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import Foundation

public enum AppState {
  case notStarted, inMapVC, inTimerVC, inLoginVC, inActive, inBackground, inSuspended
}

public enum AuthState {
  case notStarted
  case loginRequired, userLoggedIn
}
