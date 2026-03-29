import UIKit

/// Handles read/write operations for a single `UINavigationController` stack.
public struct SingleStackCoordinator<Route: Hashable> {
  public init() { }

  /// Returns the routes currently represented by the controller stack.
  public func currentRoutes(controller: UINavigationController?) -> [AnyHashable] {
    (controller?.viewControllers ?? []).compactMap { ($0 as? AnyRouteIdentifiable)?.anyRoute }
  }

  /// Appends new controllers to the current stack.
  public func append(
    viewControllers: [UIViewController],
    to controller: UINavigationController?,
    animated: Bool)
  {
    guard let controller else { return }
    controller.setViewControllers(controller.viewControllers + viewControllers, animated: animated)
  }

  /// Replaces the entire stack with the provided controllers.
  public func replace(
    viewControllers: [UIViewController],
    on controller: UINavigationController?,
    animated: Bool)
  {
    controller?.setViewControllers(viewControllers, animated: animated)
  }

  /// Finds the last view controller in the stack that matches the given route.
  public func lastMatchedViewController(
    route: Route,
    in controller: UINavigationController?)
    -> UIViewController?
  {
    let target = AnyHashable(route)
    return controller?.viewControllers.last(where: {
      ($0 as? AnyRouteIdentifiable)?.anyRoute == target
    })
  }
}
