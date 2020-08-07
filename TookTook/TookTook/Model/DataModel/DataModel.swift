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
import CoreLocation

struct DataModel {
  
  var todayCount = BehaviorSubject<Int>(value: 0)
  var inServerCount = BehaviorSubject<Int>(value: 0)
  
  var bag = DisposeBag()
  
  func start() {
    getServerCount()
  }
  
  func getServerCount() {
    APIManager().getServerCount { (serverCount) in
      self.inServerCount.onNext(serverCount)
      self.inServerCount
        .subscribe(onNext: {
          self.todayCount.onNext($0)
          self.bindCountWithServer()
        })
        .disposed(by: self.bag)
    }
  }
  
  func  bindCountWithServer(){
    todayCount
      .subscribe(onNext: {
        APIManager().postUpdateCountInServer(currentCount: $0) {
          print(#function)
        }
      })
      .disposed(by: bag)
  }
}
