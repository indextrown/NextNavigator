import Foundation

public extension Navigator {
  /// Applies a typed deep link using the action declared by the deep link.
  func handle(_ deepLink: DeepLink<Route>, animated: Bool = true) {
    switch deepLink.action {
    case .push:
      push(deepLink.routes, animated: animated)
    case .replace:
      replace(with: deepLink.routes, animated: animated)
    case let .present(style):
      present(deepLink.routes, animated: animated, style: style)
    }
  }

  /// Parses the incoming URL and applies the resulting deep link if parsing
  /// succeeds.
  func handle<Parser: DeepLinkParser>(
    url: URL,
    parser: Parser,
    animated: Bool = true)
    where Parser.Route == Route
  {
    guard let deepLink = parser.parse(url: url) else { return }
    handle(deepLink, animated: animated)
  }
}
