//
//  MapFlow.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxFlow

class MapFlow: Flow {
  
  var root: Presentable {
    return self.mapNavigationController
  }
  
  private let mapNavigationController = UINavigationController()
  private let service: MainService
  
  init(withService service: MainService) {
    self.service = service
  }
  
  func navigate(to step: Step) -> FlowContributors {
    guard let step = step as? MainStep else { return .none}
    
    switch step {
    case .mapVCInitIsRequired:
      return mapVCInit()
    default:
      return .none
    }
  }
}

extension MapFlow {
  private func mapVCInit() -> FlowContributors {
    let vc = MapViewController()
    vc.title = "Map"
    vc.viewModel = MapViewModel()
    
    self.mapNavigationController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vc.viewModel))
  }
}
