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
import NSObject_Rx

struct DataModel {
  
  var todayCount = BehaviorSubject<Int>(value: 0)
  var inServerCount = BehaviorSubject<Int>(value: 0)
  
  var bag = DisposeBag()
  
  func start() {
    inServerCount
      .subscribe(onNext: {
        self.todayCount.onNext($0)
      })
      .disposed(by: bag)
  }
}
