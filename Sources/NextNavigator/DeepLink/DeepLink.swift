import Foundation

/// A typed deep link payload containing the routes to open and the action that
/// should be used when applying them.
public struct DeepLink<Route: Hashable> {
  public let routes: [Route]
  public let action: DeepLinkAction

  public init(routes: [Route], action: DeepLinkAction) {
    self.routes = routes
    self.action = action
  }

  public init(route: Route, action: DeepLinkAction) {
    self.init(routes: [route], action: action)
  }
}
