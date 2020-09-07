//
//  MainStep.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import Foundation
import RxFlow
import GoogleMaps

enum MainStep: Step {
  // Global
  case tabBarInitIsRequired
  case mapVCInitIsRequired
  case timerVCInitIsRequired
  
  // Login
  case loginIsRequired
  case userIsLoggedIn
  
  // API Key
  case apiKeyIsRequired
  case apiKeyIsFilledIn
  
  // For debug
  case check
  
  // For back
  case back
  
  // For MapVC
  case navigateToAddMarkerVC(mapViewModel: MapViewModel, mapView: GMSMapView)
}
