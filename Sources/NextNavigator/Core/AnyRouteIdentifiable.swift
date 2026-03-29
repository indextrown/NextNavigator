import UIKit

/// A lightweight protocol used to recover the originating route from a view
/// controller that is already inside a navigation stack.
public protocol AnyRouteIdentifiable {
  var anyRoute: AnyHashable { get }
}

/// A convenience alias for UIKit screens that can expose their route identity.
public typealias RouteViewController = UIViewController & AnyRouteIdentifiable
