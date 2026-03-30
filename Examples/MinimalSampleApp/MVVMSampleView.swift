import NextNavigator
import SwiftUI

final class MVVMSampleViewModel: ObservableObject {
  @Published private(set) var count = 0
  @Published private(set) var eventLog: [String] = ["MVVM sample loaded"]

  private let navigator: Navigator<AppDependencies, AppRoute>
  private let analytics: AnalyticsClient
  private let userRepository: UserRepository

  init(
    navigator: Navigator<AppDependencies, AppRoute>,
    analytics: AnalyticsClient,
    userRepository: UserRepository
  ) {
    self.navigator = navigator
    self.analytics = analytics
    self.userRepository = userRepository
  }

  var summaryText: String {
    "count: \(count) | preview user: \(userRepository.displayName(for: "42"))"
  }

  func increase() {
    count += 1
    track("increase")
  }

  func decrease() {
    count -= 1
    track("decrease")
  }

  func reset() {
    count = 0
    track("reset")
  }

  func pushDetail() {
    track("push_detail_\(count)")
    navigator.push(.detail(id: "\(max(count, 0))"))
  }

  func presentSettings() {
    track("present_settings")
    navigator.present(.settings)
  }

  func replaceWithHome() {
    track("replace_with_home")
    navigator.replace(with: [.home])
  }

  func goBack() {
    track("back")
    navigator.back()
  }

  private func track(_ event: String) {
    analytics.track("mvvm_sample_\(event)")
    eventLog.insert(event, at: 0)
  }
}

struct MVVMSampleView: View {
  @StateObject private var viewModel: MVVMSampleViewModel

  init(viewModel: MVVMSampleViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 20) {
        Text("MVVM Sample")
          .font(.title.bold())

        Text("이 화면은 ViewModel이 상태와 네비게이션 액션을 함께 관리하는 예제다.")
          .foregroundStyle(.secondary)

        VStack(alignment: .leading, spacing: 8) {
          Text("Counter")
            .font(.headline)
          Text("\(viewModel.count)")
            .font(.system(size: 40, weight: .bold, design: .rounded))
          Text(viewModel.summaryText)
            .font(.footnote.monospaced())
            .foregroundStyle(.secondary)
        }

        section("State") {
          demoButton("Increase") {
            viewModel.increase()
          }

          demoButton("Decrease") {
            viewModel.decrease()
          }

          demoButton("Reset") {
            viewModel.reset()
          }
        }

        section("Navigation By ViewModel") {
          demoButton("Push Detail Using Count") {
            viewModel.pushDetail()
          }

          demoButton("Present Settings") {
            viewModel.presentSettings()
          }

          demoButton("Replace With Home") {
            viewModel.replaceWithHome()
          }

          demoButton("Back") {
            viewModel.goBack()
          }
        }

        section("Event Log") {
          ForEach(Array(viewModel.eventLog.prefix(6).enumerated()), id: \.offset) { _, item in
            Text(item)
              .font(.footnote.monospaced())
              .foregroundStyle(.secondary)
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
      .buttonStyle(.borderedProminent)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
}
