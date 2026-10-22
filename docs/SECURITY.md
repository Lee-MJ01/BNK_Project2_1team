# 비밀정보 정리와 개발 환경

## 이번 정리 범위

- 기존 로컬 변경인 `MyBatisConfig.java`의 Master/Slave 접속정보 주입과 `application.yml`의 환경변수 전환을 유지하고 보완했다.
- DB 감시용 연결도 같은 환경변수를 사용한다. Elasticsearch, Redis, 수출입은행 API, AI 서버 주소와 Pinecone 호스트를 코드에서 분리했다.
- Flutter의 도로명주소 API 키를 삭제했다. 앱은 `/backend/api/mobile/member/addresses?keyword=...`를 호출하며 서버가 `JUSO_API_KEY`로 조회한다. 회원가입 전에 쓰므로 이 조회 경로는 로그인 없이 허용한다. 검색어 길이와 외부 호출 시간은 제한한다.
- Firebase Android 설정은 로컬 파일을 보존하고 Git 추적에서 제외했다. 새 개발자는 Firebase 콘솔에서 자신의 앱 설정을 내려받는다. `google-services.json.example`에는 구조만 있다. 이 파일의 API 키는 Android 앱에 포함되는 값이므로 Git 제외와 함께 Firebase/Google Cloud의 앱·API 제한도 확인한다.
- `.env`, 서비스계정 JSON, 개인키와 서명키를 제외하고 Docker 빌드 컨텍스트에서도 비밀파일을 제외했다.
- 기존 Slave DB 환경변수 배포 누락과 `TERMS_BASE_DIR` 미반영을 수정했다.
- 배포 시 GitHub Secrets를 셸 명령에 직접 삽입하지 않는다. runner에서 검증한 환경파일만 전송하고 서버에는 권한 `600`으로 설치한다. 필수값 누락 시 서버 변경 전에 실패한다.

## 남은 키 교체 작업

현재 파일에서 값을 삭제해도 **과거 커밋·복제본에 공개된 값은 남는다**. 기존 값을 다시 사용하지 말고 발급 서비스에서 폐기·재발급해야 한다. 실제 키 폐기, GitHub Secrets 등록, 운영 서버 변경은 이번 로컬 작업으로 수행하지 않았다.

| 확인 대상 | 필요한 작업 |
| --- | --- |
| Oracle Master/Slave, Elasticsearch | 공개된 계정 비밀번호 변경, 네트워크 접근 범위 확인 |
| 수출입은행 API, 도로명주소 API | 기존 키 폐기 후 새 키를 `EXIM_AUTH_KEY`, `JUSO_API_KEY`에 저장 |
| Firebase Android 설정 | 프로젝트 사용 현황과 API/앱 제한 확인, 필요 시 키 교체 후 앱 설정 갱신 |
| 과거 `application.yml`의 API 키 | Git 이력 검사를 통해 제공자를 확인하고 폐기·재발급 |
| OpenAI, Solapi, Pinecone, DeepL, 메일, 서비스계정 | 발급 서비스의 사용 기록 및 기존 유출 여부 확인 후 필요한 자격증명 교체 |
| JWT 서명키 | 유출된 경우 교체하고 기존 로그인 토큰 만료 처리 |
| AES 암호화키 | 기존 데이터 복호화에 필요하므로 재암호화·이관 계획을 세운 뒤 교체 |

모든 로컬 Git 이력은 다음 명령으로 재검사할 수 있다. 알려진 과거 노출 때문에 실패하는 것은 예상된 결과이며, 출력의 비밀값은 마스킹된다. 약한 DB 비밀번호도 잡도록 기본 Gitleaks 규칙을 확장했다. 탐지 결과가 없다는 것만으로 모든 자격증명이 안전하다고 보장하지 않는다.

```powershell
python scripts/security.py history
```

공유 이력을 다시 쓰면 팀원의 브랜치와 PR에도 영향을 준다. 이번 변경은 이력을 재작성하거나 강제 push하지 않는다. 키 폐기 후 팀원과 범위를 합의하여 별도 수행한다.

## 새 PC에서 설정

저장소 루트에서 Python 3.10 이상으로 실행한다. Gitleaks 8.30.1을 공식 GitHub 릴리스에서 내려받고 SHA-256을 검증한다. 전역 Git 설정은 바꾸지 않는다.

```powershell
python scripts/security.py setup
Copy-Item backend/.env.example backend/.env
```

`backend/.env`에 새 자격증명을 입력한다. 예시 파일은 비밀값이 비어 있으므로 복사만으로 운영 서비스가 실행되지 않는다. 서버 외부 서비스 접속을 포함한 전체 실행에는 Oracle Master/Slave, Elasticsearch, Redis, 메일/API 설정과 Firebase ADC 또는 서비스계정 파일이 필요하다.

로컬 Java 실행은 `backend/`에서 `.env`를 Spring 설정으로 읽는다. 이때 값은 따옴표 없이 Java properties 형식으로 입력하고, 백슬래시는 이스케이프한다. 서비스계정 경로에는 `/`를 사용하면 편하다. 컨테이너 안에서 `localhost`는 컨테이너 자신이므로 Compose 실행 시 외부 서비스 주소를 해당 환경에 맞게 지정한다.

```powershell
cd backend
.\gradlew.bat clean assemble test --tests '*AddressSearchServiceTest'
.\gradlew.bat bootRun
```

Java 21이 필요하다. 기존 `BackendApplicationTests.contextLoads`는 실제 DB·Firebase 등의 설정을 요구하는 통합 테스트다. CI는 전체 컴파일과 새 주소검색의 외부 통신 없는 테스트를 실행한다. 전체 통합 테스트는 별도 테스트 서비스와 자격증명을 준비한 뒤 실행한다.

Flutter는 `bnk_proj/android/app/google-services.json`을 로컬에 준비하고 Flutter SDK로 `flutter pub get`, `flutter analyze`, 기기 실행을 진행한다. API 서버 선택은 기존 `ApiService.currentUrl`을 사용한다. 앱에는 `JUSO_API_KEY`를 전달하지 않는다.

## commit과 push

설치 후 `git commit`은 스테이징한 전체 내용을 검사한다. `git push`는 push할 최종 파일과 새 커밋을 검사하므로, 키를 커밋했다가 다음 커밋에서 지워도 차단한다. 새 브랜치는 `origin/main`에 이미 있는 이력을 제외한 커밋을 검사한다. 이전에 노출된 전체 이력을 매번 push 차단 대상으로 삼는 대신 별도의 `history` 명령으로 감사한다.

```powershell
git switch -c codex/my-improvement
# 작업 후
git add <변경한 파일>
git commit -m "Describe the improvement"
git push
```

`push.autoSetupRemote=true`, `push.default=simple`로 새 브랜치의 첫 push가 upstream을 연결한다. `pull.ff=only`, `fetch.prune=true`도 이 저장소에만 설정한다. 훅은 새 복제본에 자동 설치되지 않으므로 각 PC에서 setup을 한 번 실행한다. 로컬 훅은 우회될 수 있어 GitHub Actions에서도 같은 검사를 실행한다. 서버의 필수 상태검사/브랜치 보호는 별도 저장소 관리 설정이며 이 작업에서 변경하지 않았다.

## GitHub Actions 배포 설정

저장소 Settings → Secrets and variables → Actions에 `backend/.env.example`과 같은 이름으로 새 값을 등록한다. 예시의 `localhost` 주소를 운영에 그대로 쓰지 않는다. 특히 새로 참조하는 값은 다음과 같다.

- `SLAVE_DB_URL`, `SLAVE_DB_USERNAME`, `SLAVE_DB_PASSWORD`
- `PINECONE_INDEX_HOST`, `JUSO_API_KEY`
- `AI_SERVER_RECO_URL`, `REDIS_PASSWORD`는 선택값이다. 추천 서버 미지정 시 `AI_SERVER_URL`을 사용한다.
- `TERMS_BASE_DIR`은 배포 시 `/app/uploads/terms`로 고정한다.
- `FIREBASE_SERVICE_ACCOUNT_PATH`는 Compose가 컨테이너 내부 경로를 지정한다. 서버의 `/opt/keys/firebase-sa.json` 파일을 별도로 준비한다. GitHub Secrets에 서비스계정 JSON 본문을 넣을 필요는 없다.

GCP 연결에는 기존 `GCP_WIF_PROVIDER`, `GCP_SA_EMAIL`, `GCP_PROJECT_ID`가 필요하다. VM `bnk-api-server`와 `asia-northeast3-a`, Docker Compose, 인증서 경로는 기존 배포 구성을 따른다. 배포용 dotenv 값은 줄바꿈·NUL·작은따옴표를 포함하면 실패하도록 하여 셸/파서 해석 차이를 차단한다. 키를 만들 때 이를 고려한다.

`codex/**` 브랜치 push와 PR에서는 검사가 실행되고, 운영 배포는 `main`에서만 실행된다. 현재 변경 브랜치를 main에 합치기 전에 위 Secrets와 운영 파일을 준비한다. 이 작업 자체는 운영 배포를 실행하지 않는다.
