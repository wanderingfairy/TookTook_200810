//
//  AppDelegate.swift
//  TookTook
//
//  Created by 정의석 on 2020/07/16.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow
import RxViewController
import Action
import NSObject_Rx
import Then
import SnapKit
import CoreData
import Tapa
import Firebase
import FirebaseAuth
import GoogleMaps
import GooglePlaces
import SkeletonView

#if DEBUG
import Gedatsu
import FLEX
#endif


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var coordinator = FlowCoordinator()
  let mainService = MainService()
  lazy var mainFlow = {
    return RootFlow(withServices: self.mainService)
  }()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if DEBUG
    Gedatsu.open()
    FLEXManager.shared.showExplorer()
    #endif
    FirebaseApp.configure()
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    // MARK: - init GoogleMaps
    GMSServices.provideAPIKey("AIzaSyCDjp0Ngg-KXturg0zjfkoCOYh9yT98unU")
    GMSPlacesClient.provideAPIKey("AIzaSyCDjp0Ngg-KXturg0zjfkoCOYh9yT98unU")
    
    // MARK: - login Check
    if Auth.auth().currentUser == nil {
      print("Login Is Required")
      AppModel.instance.loginFlowStart()
    } else {
      AppModel.instance.userLoggedIn(uid: Auth.auth().currentUser?.uid ?? "none")
      print("Already Logged in ")
      print("uid is - ", Auth.auth().currentUser?.uid)
    }
    
    // MARK: - tracking navigation action
    self.coordinator.rx.willNavigate.subscribe(onNext: { (flow, step) in
      print("will navigate to flow=\(flow) and step=\(step)")
    }).disposed(by: rx.disposeBag)

    self.coordinator.rx.didNavigate.subscribe(onNext: { (flow, step) in
      print("did navigate to flow=\(flow) and step=\(step)")
    }).disposed(by: rx.disposeBag)
    
    Flows.use(mainFlow, when: .ready) { (root) in
      self.window?.rootViewController = root
      self.window?.makeKeyAndVisible()
    }
    self.coordinator.coordinate(flow: mainFlow, with: OneStepper(withSingleStep: MainStep.tabBarInitIsRequired))
    
    return true
  }

  // MARK: - Core Data stack

  lazy var persistentContainer: NSPersistentContainer = {
      /*
       The persistent container for the application. This implementation
       creates and returns a container, having loaded the store for the
       application to it. This property is optional since there are legitimate
       error conditions that could cause the creation of the store to fail.
      */
      let container = NSPersistentContainer(name: "TookTook")
      container.loadPersistentStores(completionHandler: { (storeDescription, error) in
          if let error = error as NSError? {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
               
              /*
               Typical reasons for an error here include:
               * The parent directory does not exist, cannot be created, or disallows writing.
               * The persistent store is not accessible, due to permissions or data protection when the device is locked.
               * The device is out of space.
               * The store could not be migrated to the current model version.
               Check the error message to determine what the actual problem was.
               */
              fatalError("Unresolved error \(error), \(error.userInfo)")
          }
      })
      return container
  }()

  // MARK: - Core Data Saving support

  func saveContext () {
      let context = persistentContainer.viewContext
      if context.hasChanges {
          do {
              try context.save()
          } catch {
              // Replace this implementation with code to handle the error appropriately.
              // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
              let nserror = error as NSError
              fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
          }
      }
  }

}

