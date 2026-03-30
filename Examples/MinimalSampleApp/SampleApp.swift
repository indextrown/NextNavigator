import NextNavigator
import SwiftUI
import UIKit

@main
struct SampleApp: App {
  private let navigator = AppRouter.buildNavigator()

  var body: some Scene {
    WindowGroup {
      TabNavigationHost(
        navigator: navigator,
        items: [
          .init(
            tag: 0,
            route: .home,
            tabBarItem: UITabBarItem(title: "Home", image: nil, tag: 0),
            prefersLargeTitles: true),
          .init(
            tag: 1,
            route: .settings,
            tabBarItem: UITabBarItem(title: "Settings", image: nil, tag: 1),
            prefersLargeTitles: true)
        ])
      .onOpenURL { url in
        navigator.handle(url: url, parser: AppDeepLinkParser())
      }
      .ignoresSafeArea()
    }
  }
}
