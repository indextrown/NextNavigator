// Sample 3
// 화면 진입에 필요한 값이 하나보다 많은 경우
// route가 여러 값을 함께 표현할 수 있는 사례

enum ChatRoute: Hashable {
  case inbox
  case room(roomID: String, highlightMessageID: String?)
}

/*
 사용 예:

 navigator.push(.room(roomID: "room-1", highlightMessageID: nil))
 navigator.push(.room(roomID: "room-1", highlightMessageID: "msg-99"))

 왜 유용한가:

 - 같은 채팅방 화면이어도
   어떤 방인지(`roomID`) 알아야 한다.
 - 경우에 따라 특정 메시지를 강조해서 열고 싶을 수도 있다.
 - 이런 부가 정보도 route에 함께 담을 수 있다.

 핵심:

 - route는 "어느 화면으로 갈지"만이 아니라
   "그 화면을 어떤 상태로 열지"까지 표현할 수 있다.
*/

