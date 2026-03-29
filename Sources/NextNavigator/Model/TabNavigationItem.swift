import UIKit

public struct TabNavigationItem<Route: Hashable> {
  public let tag: Int
  public let route: Route
  public let tabBarItem: UITabBarItem?
  public let prefersLargeTitles: Bool

  public init(
    tag: Int,
    route: Route,
    tabBarItem: UITabBarItem? = nil,
    prefersLargeTitles: Bool = false)
  {
    self.tag = tag
    self.route = route
    self.tabBarItem = tabBarItem
    self.prefersLargeTitles = prefersLargeTitles
  }
}

