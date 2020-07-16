//
//  TimerViewControllerTests.swift
//  TookTookTests
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import XCTest
@testable import TookTook

class TimerViewControllerTests: XCTestCase {

  var sut: TimerViewController!

    override func setUp() {
      super.setUp()
      let rootTabBarController = loadRootTabBarController()
      sut = rootTabBarController.timerController
    }
    
    override func tearDown() {
      sut = nil
      super.tearDown()
    }
  
  // MARK: - Created TimerVC
  
  func testTimerVC_whenNavigatedToTimerVC_appStateIsInTimerVC() {
    //when
    sut.viewDidLoad()
    //then
    XCTAssertEqual(AppModel.instance.appState, AppState.inTimerVC)
  }

}
