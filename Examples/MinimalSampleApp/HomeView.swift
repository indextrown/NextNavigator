import NextNavigator
import SwiftUI

struct HomeView: View {
  let navigator: Navigator<AppDependencies, AppRoute>
  @State private var routeSnapshot = ""

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("Home")
          .font(.title.bold())

        Text("이 화면에서 stack, modal, tab 연산을 직접 눌러볼 수 있다.")
          .foregroundStyle(.secondary)

        section("Stack") {
          demoButton("Push MVVM Sample") {
            navigator.push(.mvvmSample)
          }

          demoButton("Push Detail 42") {
            navigator.push(.detail(id: "42"))
          }

          demoButton("Push Detail 42, 99") {
            navigator.push([.detail(id: "42"), .detail(id: "99")])
          }

          demoButton("Replace With Home -> Detail 77") {
            navigator.replace(with: [.home, .detail(id: "77")])
          }

          demoButton("Back Or Push Settings") {
            navigator.backOrPush(.settings)
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

        section("Modal") {
          demoButton("Present MVVM Sample") {
            navigator.present(.mvvmSample)
          }

          demoButton("Present Settings") {
            navigator.present(.settings)
          }

          demoButton("Present Home -> Detail 200") {
            navigator.present([.home, .detail(id: "200")])
          }

          demoButton("Present Settings Full Screen") {
            navigator.presentFullScreen(.settings)
          }

          demoButton("Dismiss Modal") {
            navigator.dismissModal()
          }

          Text("modal active: \(navigator.isModalActive ? "true" : "false")")
            .font(.footnote.monospaced())
            .foregroundStyle(.secondary)
        } footer: {
            Text("Modal Footer")
        }

        section("Tab") {
          demoButton("Switch To Settings Tab") {
            navigator.switchTab(tag: 1)
          }

          demoButton("Reselect Home Tab And Pop To Root") {
            navigator.switchTab(tag: 0)
          }

          demoButton("Reselect Home Tab Without Pop") {
            navigator.switchTab(tag: 0, popToRootIfSelected: false)
          }
        }
      }
      .padding()
    }
  }

    /*
     section(
       title: "Stack",
       content: {
         View1
         View2
         View3
       }
     )
     
     ->
     
     VStack {
       Text("Stack")

       VStack {   // ← ViewBuilder가 묶어줌
         demoButton(...)
         demoButton(...)
         demoButton(...)
       }
     }
     */
  @ViewBuilder
    private func section<Content: View, Footer: View>(
    _ title: String,
    @ViewBuilder content: () -> Content,
    @ViewBuilder footer: () -> Footer = { EmptyView() }
  ) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title)
        .font(.headline)
      content()
      footer()
    }
  }

  private func demoButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(title, action: action)
      .buttonStyle(.borderedProminent)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
