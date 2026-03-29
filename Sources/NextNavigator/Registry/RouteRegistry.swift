import UIKit

public struct RouteRegistry<Dependencies, Route: Hashable> {
  private var builders: [RouteBuilder<Dependencies, Route>]

  public init(builders: [RouteBuilder<Dependencies, Route>] = []) {
    self.builders = builders
  }

  public func registering(_ builder: RouteBuilder<Dependencies, Route>) -> Self {
    var copied = self
    copied.builders.append(builder)
    return copied
  }

  public func registering(
    matching matches: @escaping (Route) -> Bool,
    build: @escaping (RouteContext<Dependencies, Route>) -> RouteViewController?)
    -> Self
  {
    registering(.matching(matches, build: build))
  }

  public func registering<Value>(
    extracting extract: @escaping (Route) -> Value?,
    build: @escaping (RouteContext<Dependencies, Route>, Value) -> RouteViewController?)
    -> Self
  {
    registering(.extracting(extract, build: build))
  }

  public func build(
    route: Route,
    navigator: Navigator<Dependencies, Route>,
    dependencies: Dependencies)
    -> RouteViewController?
  {
    let context = RouteContext(
      navigator: navigator,
      route: route,
      dependencies: dependencies)

    return builders
      .first(where: { $0.matches(route) })?
      .build(context)
  }

  public func build(
    routes: [Route],
    navigator: Navigator<Dependencies, Route>,
    dependencies: Dependencies)
    -> [UIViewController]
  {
    routes.compactMap {
      build(
        route: $0,
        navigator: navigator,
        dependencies: dependencies)
    }
  }
}

extension RouteRegistry where Route: Equatable {
  public func registering(
    _ route: Route,
    build: @escaping (RouteContext<Dependencies, Route>) -> RouteViewController?)
    -> Self
  {
    registering(.exact(route, build: build))
  }
}
