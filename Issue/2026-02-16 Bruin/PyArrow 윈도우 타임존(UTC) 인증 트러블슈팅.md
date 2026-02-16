방금 해결한 **윈도우 타임존(PyArrow) 에러 트러블슈팅** 내용을 이전에 작성하신 스타일과 통일감 있게 정리해 드립니다. 나중에 블로그나 개인 기술 노트에 활용하시기 좋습니다!

---

# 📝 Bruin/PyArrow 윈도우 타임존(UTC) 인증 트러블슈팅

## 1. 문제 상황 및 에러 로그 분석

Bruin을 통해 NYC Taxi 데이터를 수집하여 **BigQuery(BQ)**로 적재하는 과정에서 `ingestion.trips` 자산 실행이 반복적으로 실패함.

### ① 타임존 데이터베이스 유실 (ArrowInvalid)

**증상:**

```text
pyarrow.lib.ArrowInvalid: Cannot locate timezone 'UTC': 
Timezone database not found at "C:\Users\...\tzdata"

```

**원인:**
데이터 적재 도구인 `pyarrow`가 시간 데이터를 처리할 때 표준 타임존(UTC) 정보를 확인하려 하지만, **윈도우 운영체제**는 리눅스와 달리 표준 타임존 데이터베이스(`tzdata`)가 기본 경로에 존재하지 않음.

---

### ② 환경 변수 인식 실패

**증상:**

* 파이썬 코드(`trips.py`) 내부에 `os.environ['PYARROW_IGNORE_TIMEZONE'] = '1'`을 추가했으나 동일 에러 발생.

**원인:**
Bruin이 데이터를 BigQuery로 전송할 때 내부적으로 별도의 도구(`ingestr`/`dlt`)를 독립적인 프로세스로 실행함. 따라서 **특정 파이썬 스립트 내부에서 선언한 환경 변수가 적재 엔진까지 전달되지 않음.**

---

## 2. 문제의 핵심 원인 정리

* **윈도우 OS의 한계:** 리눅스 기반 라이브러리인 PyArrow가 윈도우의 타임존 관리 방식을 이해하지 못함.
* **프로세스 격리:** Bruin의 데이터 수집(Collection) 단계와 적재(Ingestion) 단계가 분리되어 있어, 코드 수정만으로는 내부 엔진의 설정을 바꾸기 어려움.
* **엄격한 타입 체크:** `dlt` 라이브러리가 날짜 데이터를 감지하면 자동으로 타임존 변환을 시도하려다 에러 유발.

---

## 3. 해결 과정 (Step-by-Step)

### ① 데이터 타입 우회 전략 (String Casting)

날짜형 데이터를 날짜형 그대로 넘기지 않고, **문자열(String)**로 변환하여 `pyarrow`의 타임존 체크 로직을 원천 봉쇄함.

```python
# 모든 datetime 컬럼을 찾아 문자열로 강제 변환
for col in final_dataframe.select_dtypes(include=['datetime64', 'datetimetz']).columns:
    final_dataframe[col] = final_dataframe[col].dt.strftime('%Y-%m-%d %H:%M:%S')

```

### ② BigQuery의 자동 형변환 활용

BigQuery는 `YYYY-MM-DD HH:MM:SS` 형식의 문자열이 들어오면, 테이블 스키마에 따라 자동으로 **TIMESTAMP**로 인식하여 저장하는 특성을 이용함.

---

## 4. 최종 수정 코드 (Success Logic)

이 설정이 성공한 이유는 **"까다로운 타임존 체크가 필요한 '날짜' 타입을 일반 '문자열'로 속여서 통과시켰기 때문"**이다.

```python
def materialize():
    # ... 데이터 수집 로직 ...
    
    # 모든 데이터프레임 결합
    final_dataframe = pd.concat(dataframes, ignore_index=True)
    
    # [핵심] 윈도우 타임존 에러 방지를 위해 모든 날짜 컬럼을 문자열로 변환
    date_cols = final_dataframe.select_dtypes(include=['datetime64', 'datetimetz']).columns
    for col in date_cols:
        final_dataframe[col] = final_dataframe[col].dt.strftime('%Y-%m-%d %H:%M:%S')
        
    return final_dataframe

```

---

## 5. 근본적인 해결책 (운영 환경 권장)

현재는 문자열 변환으로 해결했으나, 윈도우에서 정석대로 운영하려면 아래 방식이 권장됨.

* **WSL2(Linux) 환경 사용:** 리눅스 환경에서는 `tzdata`가 기본 포함되어 있어 별도 설정 없이 동작함.
* **시스템 환경 변수 등록:** 윈도우 시스템 설정에서 `PYARROW_IGNORE_TIMEZONE=1`을 등록하여 모든 프로세스가 이를 공유하도록 설정.

---

## 6. 학습 포인트

* 윈도우 환경에서의 데이터 엔지니어링은 **OS 차원의 경로/설정 차이**를 항상 고려해야 함.
* 라이브러리 내부에서 발생하는 에러는 때로 **데이터 타입을 변경(Casting)**하는 것만으로도 쉽게 우회 가능함.
* 로컬 환경(Windows)과 대상 환경(BigQuery/Linux) 간의 **데이터 타입 호환성**을 이해하는 것이 중요함.

---

### ✅ 한 줄 요약

* 윈도우는 타임존 DB가 없어 PyArrow 실행 시 에러가 발생하므로, 날짜 데이터를 문자열로 변환하여 적재하는 것이 가장 확실한 우회책이다.

---
