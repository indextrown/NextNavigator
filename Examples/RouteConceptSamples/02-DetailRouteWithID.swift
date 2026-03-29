// Sample 2
// 같은 종류의 상세 화면이 여러 대상을 표시해야 하는 경우
// 연관값 route가 필요한 대표 사례

enum ProductRoute: Hashable {
  case productList
  case productDetail(id: String)
}

/*
 사용 예:

 navigator.push(.productDetail(id: "P-100"))
 navigator.push(.productDetail(id: "P-200"))

 왜 필요한가:

 - productDetail 화면 모양은 같아도,
   어떤 상품을 보여줄지는 매번 다르다.
 - `.productDetail`만 있으면
   "어느 상품 상세인지"를 알 수 없다.
 - 그래서 route 자체가 id를 같이 들고 간다.

 이해 포인트:

 - `productList`는 고정 화면
 - `productDetail(id:)`는 대상이 달라지는 화면
*/

