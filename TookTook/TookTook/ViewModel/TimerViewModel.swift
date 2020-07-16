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


struct TimerViewModel: Stepper, ViewModel {
  var steps = PublishRelay<Step>()
  var todayCount = AppModel.instance.dataModel.todayCount
}
