import SwiftUI
import UIKit

public struct TabNavigationHost<Dependencies, Route: Hashable>: UIViewControllerRepresentable {
  public let navigator: Navigator<Dependencies, Route>
  public let items: [TabNavigationItem<Route>]
  public let isTabBarHidden: Bool

  public init(
    navigator: Navigator<Dependencies, Route>,
    items: [TabNavigationItem<Route>],
    isTabBarHidden: Bool = false)
  {
    self.navigator = navigator
    self.items = items
    self.isTabBarHidden = isTabBarHidden
  }

  public func makeUIViewController(context: Context) -> UITabBarController {
    let controller = UITabBarController()
    let navigationControllers = navigator.tabCoordinator.launch(items: items, navigator: navigator)
    controller.setViewControllers(navigationControllers, animated: false)
    controller.selectedIndex = 0
    controller.tabBar.isHidden = isTabBarHidden
    navigator.tabCoordinator.tabBarController = controller
    return controller
  }

  public func updateUIViewController(_ uiViewController: UITabBarController, context: Context) {
    navigator.tabCoordinator.tabBarController = uiViewController
    if let selectedIndex = uiViewController.viewControllers?.firstIndex(where: { $0 === uiViewController.selectedViewController }),
       selectedIndex < items.count
    {
      navigator.tabCoordinator.setSelectedTag(items[selectedIndex].tag)
    }
    uiViewController.tabBar.isHidden = isTabBarHidden
  }
}
