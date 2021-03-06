/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The scene delegate for iOS.
*/

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView().environmentObject(KeyTest()))
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

