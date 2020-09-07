//
//  MapFlow.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxFlow
import GoogleMaps

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
    case .check:
      return mapCheck()
    case .loginIsRequired:
      return navigateToLoginVC()
    case .navigateToAddMarkerVC(mapViewModel: let vm, mapView: let mapView):
      return navigateToAddMarkerVC(viewModel: vm, mapView: mapView)
    case .back:
      return back()
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
    print(#function)
    self.mapNavigationController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vc.viewModel))
  }
  
  private func mapCheck() -> FlowContributors {
//    print(#function, "check")
    return .none
  }
  
  private func navigateToLoginVC() -> FlowContributors {
    let vc = LoginViewController()
    vc.title = "Login"
    vc.viewModel = LoginViewModel()
    print(#function)
    self.mapNavigationController.pushViewController(vc, animated: true)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vc.viewModel))
  }
  
  private func navigateToAddMarkerVC(viewModel: MapViewModel, mapView: GMSMapView) -> FlowContributors {
    let vc = AddMarkerViewController()
    vc.title = "Add"
    vc.viewModel = viewModel
    vc.mapView = mapView
    self.mapNavigationController.present(vc, animated: true, completion: nil)
    return .one(flowContributor: .contribute(withNextPresentable: vc, withNextStepper: vc.viewModel))
  }
  
  private func back() -> FlowContributors {
    self.mapNavigationController.popViewController(animated: true)
    print(#function)
    return .none
  }
}
