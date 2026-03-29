import NextNavigator
import SwiftUI

struct DetailView: View {
  let userID: String
  let repository: UserRepository
  let navigator: Navigator<AppDependencies, AppRoute>
  @State private var routeSnapshot = ""

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("Detail")
          .font(.title.bold())

        Text("userID: \(userID)")
        Text("displayName: \(repository.displayName(for: userID))")

        section("Stack") {
          demoButton("Push Detail 88") {
            navigator.push(.detail(id: "88"))
          }

          demoButton("Back") {
            navigator.back()
          }

          demoButton("Back To Home") {
            navigator.backTo(.home)
          }

          demoButton("Back Or Push Settings") {
            navigator.backOrPush(.settings)
          }

          demoButton("Replace With Home -> Detail 555") {
            navigator.replace(with: [.home, .detail(id: "555")])
          }

          demoButton("Show Current Routes") {
            routeSnapshot = navigator.currentRoutes()
              .map { String(describing: $0) }
              .joined(separator: " -> ")
          }

          if !routeSnapshot.isEmpty {
            Text(routeSnapshot)
              .font(.footnote.monospaced())
              .foregroundStyle(.secondary)
          }
        }

        section("Modal / Tab") {
          demoButton("Present Settings Modal") {
            navigator.present(.settings)
          }

          demoButton("Dismiss Modal") {
            navigator.dismissModal()
          }

          demoButton("Switch To Settings Tab") {
            navigator.switchTab(tag: 1)
          }
        }
      }
      .padding()
    }
  }

  @ViewBuilder
  private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
      content()
    }
  }

  private func demoButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(title, action: action)
      .buttonStyle(.bordered)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
