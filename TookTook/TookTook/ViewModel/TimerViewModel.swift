//
//  TimerViewModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow
import Action
import NSObject_Rx


struct TimerViewModel: Stepper, ViewModel {
  var steps = PublishRelay<Step>()
  
  var bag = DisposeBag()
  var todayCount = AppModel.instance.dataModel.todayCount
  var serverCount = AppModel.instance.dataModel.inServerCount
  var timerData = BehaviorSubject<TimeModel>(value: TimeModel())
  var stopWatch = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
  
  func timerStart() {
    stopWatch
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { value in
        self.timerData
          .observeOn(MainScheduler.instance)
          .debounce(.milliseconds(998), scheduler: MainScheduler.instance)
          .subscribe(onNext: {
            let nextSecondModel = TimeModel(day: $0.day, hour: $0.hour, minute: $0.minute, second: $0.second + 1)
            self.timerData.onNext(nextSecondModel)
          })
          .disposed(by: self.bag)
      })
      .disposed(by: bag)
  }
  
  func setTimer() {
    APIManager().getServerTimer { timeModel in
      self.timerData.onNext(timeModel)
    }
  }
  
  func timerInitInServer() {
    APIManager().postInitialServerTimer {
      self.setTimer()
    }
  }
  
  
}

struct TimeModel {
  var day = 0
  var hour = 0 {
    didSet {
      if oldValue == 23 {
        day += 1
        hour = 0
      }
    }
  }
  var minute = 0 {
    didSet {
      if oldValue == 59 {
        self.hour += 1
        minute = 0
      }
    }
  }
  var second = 0  {
     didSet {
      if oldValue == 59 {
        self.minute += 1
        second = 0
      }
     }
   }
}
