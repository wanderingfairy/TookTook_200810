//
//  MapViewModel.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow
import Action
import GoogleMaps
import GooglePlaces
import CoreLocation

struct MapViewModel: Stepper, ViewModel {
  var steps = PublishRelay<Step>()
  
  var camera: GMSCameraPosition!
  let locationManager = CLLocationManager()
  
  let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
  
  var defaultLocationCoordinate = CLLocationCoordinate2D(latitude: 37.482755, longitude: 126.795643)
  
  var currentUserLocation: CLLocationCoordinate2D!
  
  var currentCameraPosition: BehaviorSubject<CLLocationCoordinate2D>!
  
  var addMarkerPosition = PublishSubject<GMSMarker>()
  
  var myLocationButtonFrame = CGRect(x: 0, y: 0, width: 0, height: 0)
  
  var bag = DisposeBag()
  
  func validateAuthState() {
    switch AppModel.instance.authState {
    case .loginRequired:
      navigateToLoginVC()
    default:
      break
    }
  }
  
  func validateLocationPermission() {
    switch status {
    case .notDetermined:
      locationManager.requestAlwaysAuthorization()
    case .restricted:
      locationManager.requestAlwaysAuthorization()
    case .denied:
      locationManager.requestAlwaysAuthorization()
    case .authorizedAlways:
      break
    case .authorizedWhenInUse:
      break
    @unknown default: break
    }
  }
  
  mutating func mapStart() {
    currentUserLocation = defaultLocationCoordinate
    if let currentLocation = locationManager.location?.coordinate {
    currentUserLocation = currentLocation
    }
    camera = GMSCameraPosition.camera(withLatitude: currentUserLocation.latitude, longitude: currentUserLocation.longitude, zoom: 17.0)
    currentCameraPosition = BehaviorSubject<CLLocationCoordinate2D>(value: camera.target)
  }
  
  mutating func findMyLocationButton(subviews: [UIView], addMarkerButton: UIButton) {
    for object in subviews {
      if(object.theClassName == "GMSUISettingsPaddingView"){
        print("find success -- GMSUISettingsPaddingView")
        for view in object.subviews{
          if(view.theClassName == "GMSUISettingsView"){
            print("find success -- GMSUISettingsView")
            for btn in view.subviews{
              if(btn.theClassName == "GMSx_MDCFloatingButton"){
                print("find success -- GMSx_MDCFloatingButton")
                myLocationButtonFrame = btn.frame
                print(#function, myLocationButtonFrame)
                addMarkerButton.snp.remakeConstraints {
                  $0.size.equalTo(btn)
                  $0.centerX.equalTo(btn)
                  $0.bottom.equalTo(btn.snp.top).offset(-10)
                }
              }
            }
          }
        }
      }
    }
  }
  
}

extension MapViewModel {
  public func checkFunction() {
    self.steps.accept(MainStep.check)
    print(#function)
  }
  
  public func navigateToLoginVC() {
    self.steps.accept(MainStep.loginIsRequired)
    print(#function)
  }
  
  public func navigateToAddMarkerVC(mapViewModel: MapViewModel, mapView: GMSMapView) {
    self.steps.accept(MainStep.navigateToAddMarkerVC(mapViewModel: mapViewModel, mapView: mapView))
    print(#function)
  }
}
