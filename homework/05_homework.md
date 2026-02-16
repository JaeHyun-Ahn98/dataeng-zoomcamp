# 모듈 5 숙제: Bruin을 이용한 데이터 플랫폼

이 숙제에서는 Bruin을 사용하여 데이터 수집부터 리포팅까지 전체 데이터 파이프라인을 구축해 봅니다.

## 설정

1. Bruin CLI 설치: `curl -LsSf https://getbruin.com/install/cli | sh`
2. zoomcamp 템플릿 초기화: `bruin init zoomcamp my-pipeline`
3. DuckDB 연결 정보로 `.bruin.yml` 설정
4. [기본 모듈 README](https://www.google.com/search?q=../../../05-data-platforms/)의 튜토리얼을 따라 하세요.

설정을 마치면 작동하는 NYC 택시 데이터 파이프라인을 갖게 됩니다.

---

### 질문 1. Bruin 파이프라인 구조

Bruin 프로젝트에서 필수적인 파일/디렉토리는 무엇인가요?

* `bruin.yml` 및 `assets/`
* `.bruin.yml` 및 `pipeline.yml` (자산은 어디에나 있을 수 있음)
* `.bruin.yml` 및 `pipeline.yml`과 `assets/`가 포함된 `pipeline/` 디렉토리 ✅
* `pipeline.yml` 및 `assets/`만 필요

---

### 질문 2. 구체화(Materialization) 전략

`pickup_datetime`을 기준으로 월별로 구성된 NYC 택시 데이터를 처리하는 파이프라인을 만들고 있습니다. 중복을 제거하고 데이터를 정제하는 스테이징(staging) 레이어에 어떤 구체화 전략을 사용해야 할까요?

* `append` - 항상 새로운 행 추가
* `replace` - 테이블을 비우고(truncate) 완전히 다시 빌드
* `time_interval` - 시간 컬럼을 기반으로 한 증분(incremental) 방식 ✅
* `view` - 가상 테이블만 생성

---

### 질문 3. 파이프라인 변수

`pipeline.yml`에 다음과 같은 변수가 정의되어 있습니다.

```yaml
variables:
  taxi_types:
    type: array
    items:
      type: string
    default: ["yellow", "green"]

```

파이프라인을 실행할 때 노란색 택시(`yellow`)만 처리하도록 이 변수를 어떻게 덮어쓰나요?

* `bruin run --taxi-types yellow`
* `bruin run --var taxi_types=yellow`
* `bruin run --var 'taxi_types=["yellow"]'` ✅
* `bruin run --set taxi_types=["yellow"]`

---

### 질문 4. 의존성을 포함한 실행

`ingestion/trips.py` 자산을 수정했고, 이 자산과 그 뒤에 이어지는 모든 다운스트림(downstream) 자산들을 실행하려고 합니다. 어떤 명령어를 사용해야 하나요?

* `bruin run ingestion.trips --all`
* `bruin run ingestion/trips.py --downstream`
* `bruin run pipeline/trips.py --recursive`
* `bruin run --select ingestion.trips+` ✅

---

### 질문 5. 품질 검사 (Quality Checks)

trips 테이블의 `pickup_datetime` 컬럼에 NULL 값이 절대 들어오지 않도록 보장하고 싶습니다. 자산 정의에 어떤 품질 검사를 추가해야 할까요?

* `unique: true`
* `not_null: true` ✅
* `positive: true`
* `accepted_values: [not_null]`

---

### 질문 6. 계보(Lineage) 및 의존성

파이프라인을 구축한 후, 자산 간의 의존성 그래프를 시각화하고 싶습니다. 어떤 Bruin 명령어를 사용해야 하나요?

* `bruin graph`
* `bruin dependencies`
* `bruin lineage` ✅
* `bruin show`

---

### 질문 7. 첫 실행

새 DuckDB 데이터베이스에서 Bruin 파이프라인을 처음 실행합니다. 테이블을 처음부터 새로 생성하도록 보장하려면 어떤 플래그를 사용해야 하나요?

* `--create`
* `--init`
* `--full-refresh` ✅
* `--truncate`

---

## 솔루션 제출

* 제출 폼: [https://courses.datatalks.club/de-zoomcamp-2026/homework/hw5](https://courses.datatalks.club/de-zoomcamp-2026/homework/hw5)

---
