import UIKit

public struct SingleStackCoordinator<Route: Hashable> {
  public init() { }

  public func currentRoutes(controller: UINavigationController?) -> [AnyHashable] {
    (controller?.viewControllers ?? []).compactMap { ($0 as? AnyRouteIdentifiable)?.anyRoute }
  }

  public func append(
    viewControllers: [UIViewController],
    to controller: UINavigationController?,
    animated: Bool)
  {
    guard let controller else { return }
    controller.setViewControllers(controller.viewControllers + viewControllers, animated: animated)
  }

  public func replace(
    viewControllers: [UIViewController],
    on controller: UINavigationController?,
    animated: Bool)
  {
    controller?.setViewControllers(viewControllers, animated: animated)
  }

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

