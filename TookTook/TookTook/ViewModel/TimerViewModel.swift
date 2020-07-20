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
  var weeklyAverage = BehaviorSubject<Int>(value: 0)
  
  func timerStart() {
    stopWatch
      .observeOn(MainScheduler.instance)
      .subscribe(onNext: { value in
        self.timerData
          .observeOn(MainScheduler.instance)
          .debounce(.milliseconds(998), scheduler: MainScheduler.instance)
          .subscribe(onNext: {
            let nextSecondModel = self.timeModelSelfCycle(oldTime: $0)
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
  
  func loadWeekAverage() {
    APIManager().getWeekCounts { (avg) in
      print(#function, avg)
      self.weeklyAverage.onNext(avg)
    }
  }
  
  private func timeModelSelfCycle(oldTime: TimeModel) -> TimeModel {
    
    oldTime.second == 59 ? TimeModel(day: oldTime.day, hour: oldTime.hour, minute: oldTime.minute + 1, second: 0) :
    oldTime.minute == 59 ? TimeModel(day: oldTime.day, hour: oldTime.hour + 1, minute: 0, second: 0) :
    oldTime.hour == 23 ? TimeModel(day: oldTime.day + 1, hour: 0, minute: 0, second: 0) :
      TimeModel(day: oldTime.day, hour: oldTime.hour, minute: oldTime.minute, second: oldTime.second + 1)
  }
}

struct TimeModel {
  var day = 0
  var hour = 0
  var minute = 0
  var second = 0
}
