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
    AppModel.instance.appStart()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
        viewModel.checkFunction()
  }
  
}
