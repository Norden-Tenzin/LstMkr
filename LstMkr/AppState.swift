//
//  AppState.swift
//  LstMkr
//
//  Created by Tenzin Norden on 10/3/23.
//

import Foundation
import SwiftUI

@Observable
class AppState {
    var navigationPath = NavigationPath()
    var currentRoute: String = "check"
}


