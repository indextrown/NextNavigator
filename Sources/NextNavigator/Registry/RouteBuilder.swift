import UIKit

public struct RouteBuilder<Dependencies, Route: Hashable> {
  public let matches: (Route) -> Bool
  public let build: (RouteContext<Dependencies, Route>) -> RouteViewController?

  public init(
    matches: @escaping (Route) -> Bool,
    build: @escaping (RouteContext<Dependencies, Route>) -> RouteViewController?)
  {
    self.matches = matches
    self.build = build
  }
}

extension RouteBuilder {
  public static func matching(
    _ matches: @escaping (Route) -> Bool,
    build: @escaping (RouteContext<Dependencies, Route>) -> RouteViewController?)
    -> Self
  {
    .init(matches: matches, build: build)
  }

  public static func extracting<Value>(
    _ extract: @escaping (Route) -> Value?,
    build: @escaping (RouteContext<Dependencies, Route>, Value) -> RouteViewController?)
    -> Self
  {
    .init(
      matches: { extract($0) != nil },
      build: { context in
        guard let value = extract(context.route) else { return nil }
        return build(context, value)
      })
  }
}

extension RouteBuilder where Route: Equatable {
  public static func exact(
    _ route: Route,
    build: @escaping (RouteContext<Dependencies, Route>) -> RouteViewController?)
    -> Self
  {
    .init(matches: { $0 == route }, build: build)
  }
}
