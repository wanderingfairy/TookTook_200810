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
  let dataModel = DataModel()
  
  private(set) var appState: AppState = .notStarted
  
  
  
}
