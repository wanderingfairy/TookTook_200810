//
//  RootFlow.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxFlow

class RootFlow: Flow {
  
  var root: Presentable {
    return self.rootViewController
  }
  
  let rootViewController = UITabBarController()
  private let services: MainService
  
  init(withServices services: MainService) {
    self.services = services
  }
  
  deinit {
    print("\(type(of: self)): \(#function)")
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MainStep else { return .none}
    switch step {
    case .tabBarInitIsRequired:
      return tabBarInit()
    default:
      return .none
    }
  }
  
}

extension RootFlow {
  func tabBarInit() -> FlowContributors {
//    let mainStepper = MainViewModel()
    let mapStepper = MapViewModel()
    let timerStepper = TimerViewModel()
    
    let mapFlow = MapFlow(withService: self.services)
    let timerFlow = TimerFlow(withService: self.services)
    
    Flows.use(mapFlow, timerFlow, when: .ready) {
      [unowned self] (root1: UINavigationController, root2: UINavigationController) in
      
      let tabBarItem1 = UITabBarItem(title: "Map", image: nil, selectedImage: nil)
      let tabBarItem2 = UITabBarItem(title: "Timer", image: nil, selectedImage: nil)
      root1.tabBarItem = tabBarItem1
      root1.title = "Map"
      root2.tabBarItem = tabBarItem2
      root2.title = "Timer"
      self.rootViewController.setViewControllers([root1, root2], animated: false)
    }
    
    return .multiple(flowContributors: [
      .contribute(withNextPresentable: mapFlow,
                  withNextStepper: CompositeStepper(steppers: [OneStepper(withSingleStep: MainStep.mapVCInitIsRequired), mapStepper])),
      .contribute(withNextPresentable: timerFlow,
                  withNextStepper: CompositeStepper(steppers: [OneStepper(withSingleStep: MainStep.timerVCInitIsRequired), timerStepper]))
    ])
  }
}
