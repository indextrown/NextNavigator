import Foundation

/// Converts an incoming URL into a typed deep link understood by the app.
public protocol DeepLinkParser<Route> {
  associatedtype Route: Hashable

  func parse(url: URL) -> DeepLink<Route>?
}
