//
//  Extensions.swift
//  TookTook
//
//  Created by 정의석 on 2020/08/08.
//  Copyright © 2020 pandaman. All rights reserved.
//

import Foundation

public extension NSObject {
  var theClassName: String {
    return NSStringFromClass(type(of: self))
  }
}
