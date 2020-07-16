//
//  MapViewControllerTests.swift
//  TookTookTests
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import XCTest
@testable import TookTook

class MapViewControllerTests: XCTestCase {
  
  var sut: MapViewController!

    override func setUp() {
      super.setUp()
      let rootTabBarController = loadRootTabBarController()
      sut = rootTabBarController.mapController
    }
    
    override func tearDown() {
      
      super.tearDown()
    }

}
