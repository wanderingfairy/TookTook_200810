//
//  MainViewModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxFlow
import RxCocoa
import Action

protocol ViewModel {
}

struct MainViewModel: Stepper, ViewModel {
  let steps = PublishRelay<Step>()
  private let mainService: MainService
  private let disposeBag = DisposeBag()
  
  init() {
    self.mainService = MainService()
  }
}

extension MainViewModel {
  public func tabBarInit() {
    self.steps.accept(MainStep.tabBarInitIsRequired)
    //사용안되고잇는중
  }
}
