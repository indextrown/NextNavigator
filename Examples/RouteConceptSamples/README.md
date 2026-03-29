# Route Concept Samples

이 폴더는 "왜 `.detail(id)` 같은 연관값 route가 필요한가?"를 이해하기 위한 비교용 샘플 모음이다.

## 1. 고정 화면만 있는 경우

파일:

- [01-FixedScreenRoutes.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/01-FixedScreenRoutes.swift)

의미:

- `home`
- `settings`
- `login`

처럼 화면이 하나로 고정되어 있으면 연관값 없는 route만으로 충분하다.

## 2. 상세 대상이 바뀌는 경우

파일:

- [02-DetailRouteWithID.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/02-DetailRouteWithID.swift)

의미:

- `productDetail(id:)`

처럼 같은 종류의 상세 화면이라도 보여줄 대상이 매번 달라지면 `id` 같은 값이 필요하다.

## 3. 여러 값을 함께 넘겨야 하는 경우

파일:

- [03-RouteWithMultipleValues.swift](/Users/kimdonghyeon/2025/개발/오픈소스공식/LinkNavigator-main/NextNavigator/Examples/RouteConceptSamples/03-RouteWithMultipleValues.swift)

의미:

- `room(roomID:highlightMessageID:)`

처럼 화면 진입 시 필요한 상태가 둘 이상이면 route가 그 값을 함께 들고 가는 것이 자연스럽다.

## 한 줄 요약

- 고정 화면: `.home`, `.settings`면 충분하다.
- 대상이 달라지는 화면: `.detail(id:)`가 필요하다.
- 상태가 더 많아지는 화면: route가 값을 더 많이 들고 가면 된다.

