//
//  MapFlow.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxFlow

class TimerFlow: Flow {
  
  var root: Presentable {
    return self.timerNavigationController
  }
  
  private let timerNavigationController = UINavigationController()
  private let service: MainService
  
  init(withService service: MainService) {
    self.service = service
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MainStep else { return .none}
    
    switch step {
    case .timerVCInitIsRequired:
      return timerVCInit()
    default:
      return .none
    }
  }
}

extension TimerFlow {
  private func timerVCInit() -> FlowContributors {
    let vc = TimerViewController()
    
    vc.title = "Timer"
    vc.viewModel = TimerViewModel()
    
    self.timerNavigationController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vc.viewModel))
  }
}
