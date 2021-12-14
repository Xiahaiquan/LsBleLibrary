//
//  Storyboarable.swift
//  CitySearch
//
//  Created by guotonglin on 2020/12/2.
//  Copyright © 2020 guotonglin. All rights reserved.
//

import Foundation
import UIKit

protocol Storyboardable {
    static func instantiate(_ stroyboardName: String) -> Self
}

extension Storyboardable where Self: UIViewController {
    static func instantiate (_ stroyboardName: String = "Main") -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: stroyboardName, bundle: Bundle.main)
        if #available(iOS 13.0, *) {
            return storyboard.instantiateViewController(identifier: className)
        } else {
            return storyboard.instantiateViewController(withIdentifier: className) as! Self
        }
    }
}
