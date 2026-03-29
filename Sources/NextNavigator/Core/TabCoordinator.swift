import UIKit

/// Owns tab-specific navigation controllers and tab switching behavior.
public final class TabCoordinator<Dependencies, Route: Hashable> {
  public weak var tabBarController: UITabBarController?
  public private(set) var tabControllers: [Int: UINavigationController] = [:]
  public private(set) var orderedTags: [Int] = []
  public private(set) var currentTag: Int?

  public init() { }

  /// Returns the navigation controller for the currently selected tab.
  public var currentNavigationController: UINavigationController? {
    if let selected = tabBarController?.selectedViewController as? UINavigationController {
      return selected
    }

    guard let currentTag else { return nil }
    return tabControllers[currentTag]
  }

  /// Creates a navigation controller per tab item and boots each tab with its
  /// initial route.
  public func launch(
    items: [TabNavigationItem<Route>],
    navigator: Navigator<Dependencies, Route>)
    -> [UINavigationController]
  {
    orderedTags = items.map(\.tag)
    currentTag = items.first?.tag
    tabControllers = [:]

    let controllers = items.map { item -> UINavigationController in
      let controller = UINavigationController()
      controller.navigationBar.prefersLargeTitles = item.prefersLargeTitles
      controller.tabBarItem = item.tabBarItem
      controller.setViewControllers(
        navigator.registry.build(
          routes: [item.route],
          navigator: navigator,
          dependencies: navigator.dependencies),
        animated: false)
      tabControllers[item.tag] = controller
      return controller
    }

    return controllers
  }

  /// Switches the active tab. Re-selecting the same tab can optionally pop that
  /// tab back to its root controller.
  public func switchTab(tag: Int, popToRootIfSelected: Bool = true) {
    guard let tabBarController, let controller = tabControllers[tag] else { return }

    if tabBarController.selectedViewController === controller {
      currentTag = tag

      if popToRootIfSelected {
        controller.popToRootViewController(animated: true)
      }
      return
    }

    currentTag = tag
    tabBarController.selectedViewController = controller
  }

  /// Keeps the cached selected tag in sync with the UI layer.
  public func setSelectedTag(_ tag: Int?) {
    currentTag = tag
  }
}
