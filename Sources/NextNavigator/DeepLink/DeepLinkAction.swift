import Foundation

/// Describes how a resolved deep link should be applied to the navigator.
public enum DeepLinkAction {
  case push
  case replace
  case present(style: ModalPresentationStyle = .automatic)
}
