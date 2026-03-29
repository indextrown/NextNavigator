import UIKit

public protocol AnyRouteIdentifiable {
  var anyRoute: AnyHashable { get }
}

public typealias RouteViewController = UIViewController & AnyRouteIdentifiable

