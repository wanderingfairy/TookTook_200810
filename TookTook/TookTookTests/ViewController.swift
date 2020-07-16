//
//  ViewController.swift
//  TookTookTests
//
//  Created by 정의석 on 2020/07/17.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
@testable import TookTook

func loadRootTabBarController() -> UITabBarController {
  let window = UIApplication.shared.windows[0]
  return window.rootViewController as! UITabBarController
}

extension UITabBarController {
  var mapController: MapViewController {
    return (viewControllers?.first { $0 is UINavigationController } as! UINavigationController).viewControllers.first { $0 is MapViewController } as! MapViewController
  }
  
  var timerController: TimerViewController {
    return (viewControllers?.last { $0 is UINavigationController } as! UINavigationController).viewControllers.first { $0 is TimerViewController } as! TimerViewController
  }
}
