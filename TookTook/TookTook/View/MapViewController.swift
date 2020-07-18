//
//  MapViewController.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
  
  var viewModel: MapViewModel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    AppModel.instance.appStart()
    validateAuthState()
    viewModel.checkFunction()
  }
  
  private func validateAuthState() {
    switch AppModel.instance.authState {
    case .loginRequired:
      viewModel.navigateToLoginVC()
    default:
      break
    }
  }
}
