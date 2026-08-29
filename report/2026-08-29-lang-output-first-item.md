# 2026-08-29 — Language 5개 페이지 1번 항목을 출력(Output)으로 교체

사용자 지시: "language 들의 상세 페이지에서 첫번째 항목을 'Output' 관련 내용으로 채운다. console 출력 함수인 print 관련 함수들이다."

## 체크리스트

- [x] 사용자의 `CLAUDE.md` 수정분 확인 (`ACCOUNT_COST.md` 제1원칙 편입) 및 개수·파일명 표기 정정
- [x] 5개 페이지의 기존 1번 카드 내용 확인
- [x] `src/lang-{cp,jv,py,js,dt}.html` 1번 카드 제목·요약·상세 교체
- [x] 카드 수(12)·번호(1~12)·"전체 12건" 표기 유지 확인
- [x] 헤드리스 Chrome으로 5개 페이지 렌더링 검증
- [x] `CLAUDE.md`에 "1번 항목은 항상 출력(Output)" 규칙 기록
- [x] `DEVLOG.md` 기록, 보고서 작성, 커밋·푸시

## 1. 무엇을 바꿨나

5개 페이지 모두 1번 카드가 **"OT — {언어별 실행 모델}"** 이었다. 이를 각 언어의 **콘솔 출력 함수**로 교체했다.

| 페이지 | 기존 1번 (제거) | 새 1번 |
| --- | --- | --- |
| `lang-cp.html` | OT — C 언어와 메모리 모델 이해 | **출력(Output) — printf와 std::cout** |
| `lang-jv.html` | OT — Java와 JVM 실행 모델 이해 | **출력(Output) — System.out.println과 printf** |
| `lang-py.html` | OT — Python 철학과 인터프리터 동작 방식 | **출력(Output) — print() 함수 제대로 쓰기** |
| `lang-js.html` | OT — JS 실행 환경과 이벤트 루프 | **출력(Output) — console.log와 개발자 도구** |
| `lang-dt.html` | OT — Dart와 Flutter 렌더링 파이프라인 | **출력(Output) — print()와 debugPrint()** |

각 카드는 기존 형식(제목 + 항상 보이는 요약 + 클릭 시 펼쳐지는 상세) 그대로이고, 세 부분을 모두 새로 썼다. 담은 내용:

- **C/C++** — `printf`는 서식 지정자와 인자 타입을 컴파일러가 강제로 맞춰주지 않는다는 점(경고를 켜야 잡힌다), 타입을 알아서 처리하는 `std::cout <<`와의 대비, `\n`과 `std::endl`의 차이(버퍼 즉시 비움 여부), 오류는 `stderr`로 분리.
- **Java** — `println`/`print`/`printf` 세 가지의 차이, `System.out`과 `System.err`이 다른 스트림이라 출력 순서가 뒤섞일 수 있다는 점, `String.format`, 문자열 `+` 연결 비용.
- **Python** — `print()`가 사실 `sep`·`end`·`file`·`flush` 네 옵션을 가진 함수라는 것, 하나씩 바꿔가며 결과 비교, f-string과 `format()`.
- **JavaScript** — `console.log`/`error`/`warn`/`table`을 개발자 도구에서 비교, 템플릿 리터럴, 브라우저의 `console.log`와 대비되는 Node의 `process.stdout.write`.
- **Dart** — `print()`의 출력 위치, `dart:io`의 `stdout.write`/`writeln`, Flutter에서 로그캣이 긴 로그를 잘라버려 `debugPrint()`를 쓰는 이유, 릴리스 빌드에 디버그 출력이 남지 않게 하는 습관.

## 2. 유지한 것

**카드 수 12개, 번호 1~12, "전체 12건" 표기는 그대로다** — 항목을 추가한 게 아니라 1번의 내용만 교체했으므로 나머지 11개 카드와 번호는 손대지 않았다. 5개 파일 전부에서 카드 12개·번호 1~12·건수 표기 12를 재확인했다.

## 3. 검증

로컬 서버(`python3 -m http.server 8765`)를 띄우고 헤드리스 Chrome `--dump-dom`으로 5개 페이지의 실제 렌더링 DOM을 받아 확인했다.

| 확인 항목 | 결과 |
| --- | --- |
| 1번 카드 제목이 "1. 출력(Output) —"으로 시작 | 5/5 PASS |
| 제목·요약·상세 3단 구조 유지 | 5/5 |
| 아코디언 속성(`aria-expanded="false"`, `.curriculum-detail` 래퍼) | 5/5 |
| `lang-cp`의 `&lt;&lt;` 이스케이프 | 화면에 `<<`로 정상 렌더링(태그로 먹히지 않음) |
| 잔존 "OT —" 문자열 | 0건 |
| 스크린샷(1280×900, `lang-cp.html`) | 1번 카드 제목·요약 정상 표시, "전체 12건" 유지 |

## 남은 이슈

- **제거된 OT 내용은 되살리지 않았다.** 지시가 "첫번째 항목을 Output으로 채운다"였고 12개 구성을 유지하는 쪽을 택했기 때문에, 언어별 실행 모델(메모리 모델·JVM·인터프리터·이벤트 루프·렌더링 파이프라인) 설명은 커리큘럼에서 빠졌다. 이 내용을 살리려면 항목이 13개가 되거나 다른 카드에 흡수시켜야 해서 사용자 판단이 필요하다.
- Language 외 코스(Web & WebApp 5개 페이지)도 같은 12항목 아코디언 형식이지만 이번 지시 범위가 아니라 손대지 않았다.
