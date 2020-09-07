//
//  LoginViewController.swift
//  TookTook
//
//  Created by 정의석 on 2020/03/03.
//  Copyright © 2020 pandaman. All rights reserved.
//

import UIKit
import AuthenticationServices
import Firebase
import FirebaseUI
import CryptoKit
import GoogleSignIn
import SnapKit

class LoginViewController: UIViewController{
  
  var viewModel: LoginViewModel!
  
  let appNameLabel = UILabel()
  let subtitleLabel = UILabel()
  let appleLoginView = UIView()
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(named: "grayBackgroundColor")
    print("LoginVC viewdidloaded")
    setupUI()
    
    
    // Do any additional setup after loading the view.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(true)
    AppModel.instance.loginVCStart()
    self.tabBarController?.tabBar.isHidden = true
  }
  
  private func setupUI() {
    
    appNameLabel.text = "Took Took"
    appNameLabel.font = UIFont(name: "NotoSans-Medium", size: dynamicFontSize(64))
    
    subtitleLabel.text = "Find smoking zones,\nCheck your smoking habits"
    subtitleLabel.textAlignment = .center
    subtitleLabel.numberOfLines = 0
    subtitleLabel.font = UIFont(name: "NotoSans-Regular", size: dynamicFontSize(28))
    
    view.addSubview(appNameLabel)
    view.addSubview(subtitleLabel)
    view.addSubview(appleLoginView)
    setupConstraints()
    addButtton()
  }
  private func setupConstraints() {
    
    appNameLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview().multipliedBy(0.3)
      $0.centerX.equalToSuperview()
    }
    subtitleLabel.snp.makeConstraints {
      $0.centerY.equalToSuperview().multipliedBy(0.6)
      $0.centerX.equalToSuperview()
    }
    
    appleLoginView.snp.makeConstraints {
      $0.centerY.equalToSuperview().multipliedBy(1.2)
      $0.centerX.equalToSuperview()
      $0.width.equalToSuperview().multipliedBy(0.7)
      $0.height.equalToSuperview().multipliedBy(0.07)
    }
  }
  
  func addButtton() {
    
    if self.traitCollection.userInterfaceStyle == .dark {
      let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .white)
      
      button.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
      appleLoginView.addSubview(button)
      button.snp.makeConstraints {
        $0.top.leading.bottom.trailing.equalToSuperview()
      }
    } else {
      let button = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn, authorizationButtonStyle: .black)
      
      button.addTarget(self, action: #selector(startSignInWithAppleFlow), for: .touchUpInside)
      appleLoginView.addSubview(button)
      button.snp.makeConstraints {
        $0.top.leading.bottom.trailing.equalToSuperview()
      }
    }
  }
  
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        return random
      }
      
      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }
        
        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }
    
    return result
  }
  
  fileprivate var currentNonce: String?
  
  @objc @available(iOS 13, *)
  func startSignInWithAppleFlow() {
    let nonce = randomNonceString()
    currentNonce = nonce
    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    request.requestedScopes = [.fullName, .email]
    request.nonce = sha256(nonce)
    
    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self as? ASAuthorizationControllerPresentationContextProviding
    authorizationController.performRequests()
  }
  
  @available(iOS 13, *)
  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      return String(format: "%02x", $0)
    }.joined()
    
    return hashString
  }
  
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return
      }
      
      // Initialize a Firebase credential.
      let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
      // Sign in with Firebase.
      Auth.auth().signIn(with: credential) { (authResult, error) in
        if (error != nil) {
          // Error. If error.code == .MissingOrInvalidNonce, make sure
          // you're sending the SHA256-hashed nonce as a hex string with
          // your request to Apple.
          print(error?.localizedDescription)
          return
        }
        
        AppModel.instance.userLoggedIn(uid: Auth.auth().currentUser?.uid ?? "none")
        self.viewModel.back()
        // User is signed in to Firebase with Apple.
        // ...
      }
    }
  }
  
  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }
}

func dynamicFontSize(_ size: CGFloat) -> CGFloat {
  let bounds = UIScreen.main.bounds
  let height = bounds.size.height
  
  switch height {
  case 480.0: //Iphone 3,4S => 3.5 inch
    return size * 0.535
  case 568.0: //iphone 5, SE => 4 inch
    return size * 0.74
  case 667.0: //iphone 6, 6s, 7, 8 => 4.7 inch
    return size * 0.92
  case 736.0: //iphone 6s+ 6+, 7+, 8+ => 5.5 inch
    return size * 0.82
  case 812.0: //iphone X, XS => 5.8 inch
    return size * 0.9
  case 896.0: //iphone XR => 6.1 inch  // iphone XS MAX => 6.5 inch
    return size
  default:
    return size
  }
}
