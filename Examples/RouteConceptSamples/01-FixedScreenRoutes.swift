// Sample 1
// `home` / `settings` 같이 화면이 하나로 고정된 경우
// 연관값 없는 route만으로 충분한 사례

enum FixedScreenRoute: Hashable {
  case home
  case settings
  case login
}

/*
 사용 예:

 navigator.push(.home)
 navigator.push(.settings)
 navigator.push(.login)

 왜 충분한가:

 - home 화면은 하나뿐이다.
 - settings 화면도 하나뿐이다.
 - login 화면도 보통 하나뿐이다.

 즉 "어떤 home인지", "어떤 settings인지"를 추가로 구분할 필요가 없다.
*/

