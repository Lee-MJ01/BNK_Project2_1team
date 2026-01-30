# FLOBANK (플로뱅크)

> **최우수상 수상 프로젝트**
> 부산은행 × 그린컴퓨터아카데미 산학 협력 은행 앱 개발 프로젝트

AI와 음성 비서를 결합한 **사용자 중심 외환 특화 뱅킹 서비스**

---

## 프로젝트 한 줄 요약

복잡하게 흩어진 외환 서비스를 하나의 **자연스러운 흐름(Flow)** 으로 통합하고,
AI 음성 비서를 통해 **초보 사용자도 쉽게 이용 가능한 외환 금융 경험**을 제공하는 은행 앱

---

## 1. 프로젝트 개요

기존 외환 서비스는 환율 조회, 환전, 외화예금 가입이 각각 분리되어 있어 사용자 진입 장벽이 높았습니다.
**FLOBANK**는 이 과정을 하나의 흐름으로 연결하고, AI 음성 가이드를 통해 금융 용어와 절차를 쉽게 풀어주는 것을 목표로 합니다.

* **진행 기관**: 부산은행, 그린컴퓨터아카데미
* **프로젝트 성격**: 산학 협력 실무 프로젝트 (2차 프로젝트)
* **성과**: **최우수상 수상**

---

## 2. 나의 역할 (My Role)

> **이민준 | Backend / Team Leader**

* **조장 / 프로젝트 리딩**
* **전체 시스템 아키텍처 설계**
* **로그인 및 인증 로직 구현 (Spring Security 기반)**
* **외환 환전 핵심 비즈니스 로직 구현**
* **Oracle DB Master/Slave 이중화 설계 및 구현**
* **자동 장애 감지 및 Failover 복구 로직 구현**
* **배포용 GCP 서버 구축**
* **고가용성(HA) 구성용 GCP 서버 인프라 설계**
* **GitHub Actions 기반 GitHub–GCP CI/CD 파이프라인 구축**

> 단순 기능 구현을 넘어, **"실제 금융 서비스라면 어떻게 설계해야 하는가"**를 기준으로
> 안정성·확장성·운영 관점의 구조를 설계하고 구현했습니다.

---

## 4. 시스템 아키텍처
* GCP 기반 서버 인프라
* Oracle DB Master / Slave 이중화
* Redis 비동기 처리 구조
* CI/CD 자동 배포 파이프라인

---

## 5. 핵심 기술 구현 (Why & How)

### ① 음성 기반 외화예금 가입 가이드

**Why**
복잡한 금융 용어와 절차는 초보 사용자에게 큰 장벽입니다.

**How**

* Server-side **State Machine(S0~S5)** 기반 가입 흐름 관리
* 사용자 Intent를 서버에서 판단하여 다음 단계 결정
* Flutter **Global Overlay UI** 로 앱 어디서든 음성 대화 유지

---

### ② 고가용성 아키텍처 & 자동 장애 조치

**Why**
금융 서비스는 중단 없이 동작해야 하며, DB 장애는 곧 서비스 장애로 이어집니다.

**How**

* Oracle **Master/Slave Replication** 구성
* `DbHealthChecker`를 통한 1초 단위 헬스 체크
* 장애 감지 시 `ReplicationRoutingDataSource`로 즉시 Failover
* Redis Queue 기반 비동기 로그 처리로 성능 및 안정성 확보

---

### ③ 실시간 환율 스캐너 (OCR)

* Google ML Kit `TextRecognizer` 활용
* 카메라 화면의 환율 텍스트 실시간 인식
* 정규표현식 기반 가격 데이터 필터링 및 원화 환산

---

### ④ GARCH 모델 기반 환율 변동성 예측

* `GARCH(1,1)` 모델 적용
* 익일 환율 변동 폭 예측
* 분산 → 표준편차 변환으로 사용자 친화적 UX 제공

---

## 6. 트러블슈팅

### 음성 비서 무한 루프 문제

* Retry Counter 및 Guard 로직 도입
* 3회 실패 시 ERROR 상태로 전이

### DB 동기화 실패로 인한 트랜잭션 충돌

* Slave 저장 로직 트랜잭션 분리
* 핵심 비즈니스 로직과 로그 처리 분리

---

## 7. 기술 스택

* **Backend**: Java 17, Spring Boot 3.x, MyBatis, Spring Security
* **Frontend**: Flutter (Dart)
* **Database**: Oracle DB (Master/Slave), Redis, Elasticsearch
* **AI**: OpenAI API, Google Gemini, Google ML Kit
* **DevOps**: Docker, GCP, Nginx, GitHub Actions

---

## 8. 프로젝트 결과

* Redis 비동기 처리로 DB 병목 제거
* 자동 Failover 기반 무중단 서비스 구조 설계
* AI 음성 + OCR 기반 차별화된 금융 UX 구현
* **최우수상 수상으로 기술력 및 완성도 검증**

---

## 9. 결과 보고서

 **최종 결과 보고서**
[최종 결과 보고서 (Google Drive)](https://drive.google.com/file/d/1LWS5zEJrTKAV466jentCkP0gNsPNK7_0/view)


---

## 10. 회고

> 기능 구현보다 **설계의 중요성**을 체감한 프로젝트였습니다.
> 실제 금융 서비스 수준을 기준으로 안정성과 운영을 고민하며 성장할 수 있었습니다.
