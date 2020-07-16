//
//  MainStep.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import Foundation
import RxFlow

enum MainStep: Step {
  // Global
  case tabBarInitIsRequired
  case mapVCInitIsRequired
  case timerVCInitIsRequired
  
  // Login
  case loginIsRequired
  case userIsLoggedIn
  
  // API Key
  case apiKeyIsRequired
  case apiKeyIsFilledIn
  
  
}
