import UIKit

public final class TabCoordinator<Dependencies, Route: Hashable> {
  public weak var tabBarController: UITabBarController?
  public private(set) var tabControllers: [Int: UINavigationController] = [:]
  public private(set) var orderedTags: [Int] = []
  public private(set) var currentTag: Int?

  public init() { }

  public var currentNavigationController: UINavigationController? {
    if let selected = tabBarController?.selectedViewController as? UINavigationController {
      return selected
    }

    guard let currentTag else { return nil }
    return tabControllers[currentTag]
  }

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

  public func setSelectedTag(_ tag: Int?) {
    currentTag = tag
  }
}
