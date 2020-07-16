//
//  DataModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

struct DataModel {
  
  var todayCount = BehaviorSubject<Int>(value: 0)
  var inServerCount: Int?
  
  func start() {
    guard let serverCount = self.inServerCount else { todayCount.onNext(0); return }
    todayCount.onNext(serverCount)
  }
    
}
