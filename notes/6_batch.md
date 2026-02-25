## 1. 🎥 배치 처리 입문 (Introduction to Batch Processing)

### 1. 데이터 처리의 유형

* **배치 처리(Batch Processing):** 데이터를 일정 기간(1시간, 1일, 1주일 등) 동안 모았다가 한꺼번에 처리하는 방식입니다.
* **스트리밍 처리(Streaming Processing):** 데이터가 발생하는 즉시 실시간으로 처리하는 방식입니다.

### 2. 배치 처리의 주기와 오케스트레이션

* 배치는 보통 **스케줄(Schedule)**에 의해 실행됩니다.
* 예: 매일 오전 2시, 매주 월요일 등


* 이런 실행 주기를 관리하는 도구가 바로 **오케스트레이터(Orchestrator)**이며, 우리가 배운 Bruin, Airflow, Prefect 등이 이에 해당합니다.

### 3. 배치 처리의 장점 (왜 실시간이 아닌 배치를 쓰는가?)

* **관리의 용이성:** 실시간 시스템은 24시간 내내 켜져 있어야 하고 장애 대응이 어렵지만, 배치는 정해진 시간에만 자원을 집중하면 됩니다.
* **재시도 가능성(Retryability):** 배치가 실패하더라도 원인 수정 후 해당 구간만 다시 실행(Backfill)하기가 매우 수월합니다.
* **비용 효율성:** 자원을 미리 예약하거나 필요할 때만 대량으로 빌려 쓸 수 있어 경제적입니다.

### 4. 배치 처리의 기술 스택

* 파이썬 스크립트, SQL 쿼리 등이 주를 이루며, 데이터 양이 많아지면 Spark 같은 분산 처리 엔진을 사용하게 됩니다.

---

## 2. 🎥 Spark 입문 (Introduction to Spark)

배치 처리의 강력한 도구인 Spark가 무엇인지, 그리고 다른 도구들과 어떤 차이가 있는지 상세히 다룹니다.

### 1. Spark란 무엇인가?

* **정의:** 대규모 데이터 처리를 위한 **분산 연산 엔진(Distributed Computing Engine)**입니다.
* 단일 컴퓨터가 처리할 수 없는 방대한 데이터를 여러 대의 컴퓨터(클러스터)에 나눠서 병렬로 처리합니다.

### 2. 데이터 처리 도구들의 비교 (언제 Spark를 쓰는가?)

* **Pandas:** 데이터가 한 대의 컴퓨터 메모리(RAM)에 들어올 때 사용합니다. 수백 MB ~ 수 GB 정도에 적합합니다.
* **SQL (Data Warehouse):** 정형 데이터를 다룰 때 매우 빠르고 편리하지만, 매우 복잡한 비정형 데이터 처리나 복잡한 알고리즘 적용에는 한계가 있습니다.
* **Spark:** 테라바이트(TB) 이상의 데이터를 다루거나, SQL만으로는 구현하기 힘든 복잡한 데이터 변환 로직이 필요할 때 선택합니다.

### 3. Spark의 주요 기능

* **Spark SQL:** SQL 문법을 그대로 사용하여 데이터를 처리할 수 있습니다.
* **DataFrames:** Pandas와 유사한 인터페이스를 제공하여 데이터 과학자들이 쉽게 적응할 수 있습니다.
* **MLlib:** 대규모 데이터에 대한 머신러닝 알고리즘을 지원합니다.
* **GraphX:** 그래프 데이터 분석 기능을 제공합니다.

### 4. Spark 작업의 흐름: 클러스터 구조

강사는 Spark가 어떻게 협업하는지 비유를 들어 설명합니다.

* **Driver:** 전체 작업의 계획을 세우고 지휘하는 '팀장'입니다. 코드를 분석하고 작업을 쪼갭니다.
* **Executor:** 실제로 데이터를 연산하는 '일꾼'들입니다. 여러 대의 컴퓨터에 흩어져 있습니다.
* **Cluster Manager:** 일꾼들에게 리소스(CPU, 메모리)를 배분하는 '관리자'입니다. (예: Kubernetes, YARN 등)

### 5. 왜 Spark가 여전히 대세인가?

* 하둡(Hadoop)의 맵리듀스(MapReduce) 방식은 디스크를 거쳐야 해서 느렸지만, Spark는 **인메모리(In-memory)** 방식을 사용하여 최대 100배까지 빠릅니다.
* 또한 다양한 데이터 소스(S3, HDFS, BigQuery 등)와 쉽게 연결되는 확장성을 가집니다.

---

### 📝 전체 요약 및 연결

1. **배치 처리**는 현대 데이터 엔지니어링의 근간이며, 안정성과 효율성을 위해 필수적입니다.
2. 이 배치 처리를 수행할 때, 데이터가 너무 많아지면 **Spark**라는 강력한 분산 엔진이 구원투수로 등판합니다.
3. 사용자님은 이제 **Bruin**이라는 관리자를 통해 이 **배치 주기**를 설정하고, 필요에 따라 **Spark** 같은 엔진을 호출하여 대규모 데이터를 요리하는 구조를 이해하신 것입니다.
보내주신 배치 처리와 Spark 입문 이론 내용에 이어서, 앞서 정리한 실전 설치 가이드를 **3번 항목부터 시작되도록** 번호를 맞춰 정리해 드립니다. 이 문서 하나만 저장해두시면 이론부터 윈도우 실전 설치까지 완벽한 한 권의 가이드북이 됩니다.

---

## 3. 🚀 Windows 환경 Spark 3.3.2 실전 설치 가이드

이 섹션은 Windows 10/11 환경에서 **Git Bash(MINGW64)**를 사용하여 Spark 3.3.2를 실제로 설치하고 Jupyter Notebook에서 실행하는 과정을 다룹니다.

### 1) Java 설치 (JDK 11)

Spark는 Java 11 환경이 필요합니다.

1. [Oracle JDK 11 다운로드](https://www.oracle.com/de/java/technologies/javase/jdk11-archive-downloads.html)에서 **Windows x64 Compressed Archive**를 받습니다.
2. 경로에 공백이 없는 곳에 압축을 풉니다. (예: `C:/tools/jdk-11.0.13`)
3. Git Bash에서 환경 변수를 설정합니다.

```bash
export JAVA_HOME="/c/tools/jdk-11.0.13"
export PATH="${JAVA_HOME}/bin:${PATH}"

# 설치 확인
java --version

```

### 2) Hadoop Binaries (winutils) 설정

윈도우는 하둡 파일 시스템이 없으므로 `winutils.exe`가 포함된 바이너리가 필수입니다.

1. `C:/tools/hadoop-3.2.0/bin` 폴더를 생성합니다.
2. Git Bash에서 아래 스크립트를 실행하여 필요한 파일들을 다운로드합니다. (curl 사용 버전)

```bash
HADOOP_VERSION="3.2.0"
PREFIX="https://raw.githubusercontent.com/cdarlint/winutils/master/hadoop-${HADOOP_VERSION}/bin/"
FILES="hadoop.dll hadoop.exp hadoop.lib hadoop.pdb libwinutils.lib winutils.exe winutils.pdb"

for FILE in ${FILES}; do
  curl -o "${FILE}" "${PREFIX}/${FILE}";
done

# 환경 변수 설정
export HADOOP_HOME="/c/tools/hadoop-3.2.0"
export PATH="${HADOOP_HOME}/bin:${PATH}"

```

### 3) Spark 3.3.2 설치

1. Spark 3.3.2 압축 파일을 다운로드하고 `C:/tools/`에 압축을 풉니다.

```bash
wget https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz
tar xzfv spark-3.3.2-bin-hadoop3.tgz

# 환경 변수 설정
export SPARK_HOME="/c/tools/spark-3.3.2-bin-hadoop3"
export PATH="${SPARK_HOME}/bin:${PATH}"

```

2. **⚠️ (필수) Python 3.11+ 호환성 패치**:
최신 파이썬(3.11 이상) 사용 시 `typing.io` 모듈 에러가 발생합니다. 아래 파일을 수정해야 합니다.
* **파일 경로**: `C:\tools\spark-3.3.2-bin-hadoop3\python\pyspark\broadcast.py`
* **수정 내용**: `from typing.io import BinaryIO` → `from typing import BinaryIO` (중간의 `.io` 삭제)



---

## 4. PySpark 및 PYTHONPATH 설정

파이썬이 Spark 라이브러리와 `py4j`를 인식할 수 있도록 경로를 연결합니다.

```bash
# 유닉스 스타일 경로를 윈도우 스타일로 변환
SPARK_WIN=`cygpath -w ${SPARK_HOME}`

# PYTHONPATH 설정 (py4j 버전은 반드시 폴더 내 실제 파일명과 일치해야 함)
export PYTHONPATH="${SPARK_WIN}\\python\\"
export PYTHONPATH="${SPARK_WIN}\\python\\lib\\py4j-0.10.9.5-src.zip;$PYTHONPATH"

```

> **💡 팁**: 매번 입력하기 번거롭다면 윈도우 **시스템 환경 변수 편집**에서 `PYTHONPATH`라는 이름으로 위 경로들을 직접 등록하는 것이 좋습니다.

---

## 5. Jupyter Notebook 최종 테스트

### 1) 테스트 데이터 준비

```bash
mkdir -p ~/tmp && cd ~/tmp
wget https://d37ci6vzurychx.cloudfront.net/misc/taxi_zone_lookup.csv

```

### 2) Jupyter 실행 및 코드 검증

`jupyter notebook`을 실행한 뒤 아래 코드를 작성하여 Spark가 정상 작동하는지 확인합니다.

```python
import pyspark
from pyspark.sql import SparkSession

# 1. Spark 세션 생성 (Driver 프로세스 시작)
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .getOrCreate()

# 2. CSV 데이터 읽기
df = spark.read \
    .option("header", "true") \
    .csv('taxi_zone_lookup.csv')

df.show()

# 3. Parquet 쓰기 테스트
# 이미 'zones' 폴더가 있다면 에러가 발생하므로 overwrite 옵션을 사용합니다.
df.write.parquet('zones', mode='overwrite')

```

---

## ⚠️ 트러블슈팅 가이드 (Troubleshooting)

| 발생 에러 | 원인 | 해결책 |
| --- | --- | --- |
| **ModuleNotFoundError: No module named 'py4j'** | 파이썬이 py4j 위치를 모름 | `PYTHONPATH`에 py4j .zip 파일 경로가 포함되었는지 확인 |
| **ModuleNotFoundError: No module named 'typing.io'** | 파이썬 3.11 버전 이상 충돌 | `broadcast.py` 파일 내 `typing.io`를 `typing`으로 수정 |
| **FileNotFoundException: Hadoop bin...** | `winutils.exe` 미설치 | `HADOOP_HOME/bin` 안에 `winutils.exe` 파일 배치 확인 |
| **AnalysisException: path ... already exists** | 저장하려는 폴더가 이미 존재 | `df.write.parquet(..., mode='overwrite')` 옵션 사용 |


---

## 6. 🛠️ Spark 실전 데이터 엔지니어링 (Hands-on Practice)

### 1) 로컬 환경의 두 창문: 8888 vs 4040

컴퓨터 내부에서 실행 중인 서로 다른 서비스에 접속하기 위한 "문의 번호"

* **`localhost:8888` (Jupyter Notebook / 작업장)**
* **역할:** 내가 코드를 타이핑하고 실행하는 장소
* **내용:** `.ipynb` 파일을 열고, 파이썬 코드를 쓰고, 실행 결과를 확인하는 인터페이스


* **`localhost:4040` (Spark UI / 상황실)**
* **역할:** Spark 엔진이 내부에서 어떻게 일하고 있는지 보여주는 모니터 상황실
* **내용:** 내가 던진 작업(Job)이 몇 조각으로 나뉘었는지, 데이터 이동(**Exchange**)이 발생하는지 시각화(**DAG**)
* **주의:** `spark = ...` 세션이 실행 중일 때만 열립니다.



### 2) 노트북 실습 코드 5단계 (04_pyspark.ipynb)

#### **Step 1: 환경 초기화 및 세션 생성**

가장 먼저 Spark가 내 컴퓨터의 자원을 쓸 수 있도록 통로를 뚫어줍니다.

```python
import os
import sys
from pyspark.sql import SparkSession

# 파이썬 경로 고정 (버전 호환성 에러 방지)
os.environ['PYSPARK_PYTHON'] = sys.executable
os.environ['PYSPARK_DRIVER_PYTHON'] = sys.executable

# Spark 세션 시작 (상황실 4040 활성화)
spark = SparkSession.builder \
    .master("local[*]") \
    .appName('test') \
    .config("spark.driver.host", "127.0.0.1") \
    .getOrCreate()

```

#### **Step 2: 데이터 구조 파악 (Pandas 활용)**

전체 파일을 읽기 전, 작은 샘플(`head.csv`)로 데이터의 형태를 미리 공부합니다.

```python
import pandas as pd
df_pandas = pd.read_csv('head.csv')

# 데이터 타입 확인 (이걸 보고 Spark 스키마를 설계합니다)
df_pandas.dtypes 
df_spark.schema

```

#### **Step 3: 명시적 스키마 정의 (StructType)**

Spark가 수 기가의 데이터를 훑으며 타입을 추측하는 시간을 아끼기 위해, 우리가 타입을 직접 지정합니다.

```python
from pyspark.sql import types

schema = types.StructType([
    types.StructField('hvfhs_license_num', types.StringType(), True),
    types.StructField('dispatching_base_num', types.StringType(), True),
    types.StructField('pickup_datetime', types.TimestampType(), True),
    types.StructField('dropoff_datetime', types.TimestampType(), True),
    types.StructField('PULocationID', types.IntegerType(), True),
    types.StructField('DOLocationID', types.IntegerType(), True),
    types.StructField('SR_Flag', types.StringType(), True)
])

```

#### **Step 4: 데이터 로드 및 파티셔닝 (Partitioning)**

이제 본 데이터(`fhvhv_tripdata_2021-01.csv`)를 읽고, 병렬 처리를 위해 데이터를 쪼갭니다.

```python
# 1. 정의한 스키마로 전체 CSV 읽기
df = spark.read \
    .option("header", "true") \
    .schema(schema) \
    .csv('fhvhv_tripdata_2021-01.csv')

# 2. 파티셔닝 (데이터를 24조각으로 나누기)
# 이 때 localhost:4040 상황실에 'Exchange'라는 기록이 남습니다.
df = df.repartition(24)

```

#### **Step 5: Parquet 변환 및 저장**

조각난 데이터를 Spark 전용 포맷인 Parquet으로 저장하며 실습을 마무리합니다.

```python
# 결과를 하드디스크에 저장
df.write.mode('overwrite').parquet('fhvhv/2021/01/')

# 실제 저장된 파일들 확인 (part-00000... 파일들이 24개 보임)
import os
os.listdir('fhvhv/2021/01/')

```

---

## 7. 🧩 Spark 파티셔닝(Partitioning) 심화 이해

### ① 파티션은 "일꾼들에게 나눠줄 도시락"입니다

거대한 피자 한 판(대용량 파일)을 한 명이 먹으려면 오래 걸리지만, 여러 조각으로 잘라 나누어 먹으면 금방 끝납니다.

* **병렬 처리:** 내 컴퓨터 코어가 4개라면, 최소 4개 이상의 파티션이 있어야 모든 코어가 동시에 일합니다.
* **repartition(24)의 의미:** Spark에게 데이터를 공평하게 24덩어리로 다시 쪼개라고 명령하는 것입니다.

### ② 셔플(Shuffle)과 Exchange

데이터를 24개로 새로 나누려면, 기존에 흩어져 있던 데이터들을 다시 모으고 섞어야 합니다.

* 이 과정을 **셔플(Shuffle)**이라고 부릅니다.
* Spark UI(`4040`) 그래프에서는 이 셔플 단계를 **'Exchange'**라는 하늘색 박스로 표시합니다.

### ③ 왜 CSV를 Parquet으로 바꾸나요?

* **압축률:** CSV보다 훨씬 적은 용량을 차지합니다.
* **컬럼 기반 저장:** 내가 원하는 컬럼(예: 날짜)만 골라 읽을 수 있어 검색 속도가 압도적으로 빠릅니다.
* **파티셔닝 유지:** 저장할 때 24개로 나눴다면, 나중에 읽을 때도 24명의 일꾼이 바로 달려들 수 있습니다.

---

## 8. ✨ 최종 요약 및 실습 팁

1. **Skipped 단계?** 에러가 아닙니다. Spark가 이미 계산된 결과를 재사용했다는 똑똑한 증거.
2. **이름이 달라요?** 파이썬 버전 차이로 Spark UI에 이름이 `$anonfun`처럼 보일 수 있지만, 동작은 정상.
3. **저장 에러?** 폴더가 이미 있으면 에러가 납니다. `mode('overwrite')`를 습관화.
4. **성공 확인:** 저장 폴더에 `_SUCCESS` 파일과 `part-xxxxx` 파일 24개가 있다면 완벽하게 성공.

---

## 8. 🏗️ Spark DataFrame 상세 가이드

### 1. Spark DataFrame의 본질

* **분산 컬렉션:** Pandas DataFrame이 단일 컴퓨터의 메모리(RAM)를 사용하는 것과 달리, Spark DataFrame은 클러스터의 여러 노드에 데이터를 **파티션(Partition)** 단위로 나누어 저장하고 병렬로 처리합니다.
* **지연 실행 (Lazy Evaluation):** `select`, `filter` 같은 변환 연산(Transformation)을 호출할 때 즉시 계산하지 않고, 실행 계획(Lineage)만 세워둡니다. 실제 결과가 필요한 `show()`, `write()`, `collect()` 같은 액션(Action)이 호출될 때 비로소 최적화된 경로로 연산을 시작합니다.

---

### 2. 주요 변환 연산 (Transformations) 상세

#### ① 컬럼 선택 및 필터링 (`select`, `filter`)

* 특정 데이터만 추출하여 메모리 사용량을 줄이는 가장 기본적인 단계입니다.
* **실습 예시:** `df.select('pickup_datetime', 'PULocationID').filter(df.PULocationID == 7)`

#### ② 컬럼 생성 및 수정 (`withColumn`)

* 기존 데이터를 가공하여 새로운 정보를 생성할 때 사용합니다. `pyspark.sql.functions`(주로 `F`로 임포트)와 함께 사용되는 것이 핵심입니다.
* **날짜 처리:** `F.to_date()`를 사용하여 타임스탬프 문자열을 실제 날짜 타입으로 변환합니다.
* **사용자 로직 적용:** `crazy_stuff_udf`와 같은 사용자 정의 함수를 연결하여 복잡한 문자열 가공을 수행합니다.

#### ③ 내장 함수 (Built-in Functions) 활용

* `F.col()`, `F.asc()`, `F.desc()` 등을 통해 컬럼을 객체처럼 다루며 정렬이나 복합 연산을 수행합니다.

---

### 3. 사용자 정의 함수 (UDF)의 내부 동작과 주의점

UDF는 Spark DataFrame의 기능을 확장하는 강력한 도구이지만, 내부적으로 상당한 비용이 발생합니다.

* **직렬화 비용:** JVM(Java)에 있는 데이터를 Python 프로세스로 보내기 위해 데이터를 직렬화하고, 결과를 다시 역직렬화하는 과정에서 성능 저하가 발생합니다.
* **버전 민감도:** 현재 사용자님의 에러(`Python worker exited unexpectedly`)에서 보듯, Python 프로세스를 별도로 띄우기 때문에 외부 Python 환경(버전, 라이브러리)과의 호환성이 매우 중요합니다.
* **권장 사항:** 성능 최적화를 위해 가급적 Spark 내장 함수(`F.when()`, `F.substring()` 등)를 우선 사용하고, 내장 함수로 구현이 불가능할 때만 UDF를 사용해야 합니다.

---

### 4. 데이터 구조 최적화: 파티셔닝(Partitioning)

DataFrame의 성능은 데이터가 어떻게 나뉘어 있느냐에 결정됩니다.

* **Repartition vs Coalesce:**
* **`repartition(n)`**: 데이터를 완전히 새로 섞어서(Shuffle) 지정된 `n`개로 나눕니다. 데이터가 늘어날 때나 균등하게 배분할 때 사용합니다.
* **`coalesce(n)`**: 셔플을 최소화하면서 파티션 수를 줄일 때 사용합니다.


* **실습의 의미:** `df.repartition(24)`는 내 로컬 환경의 일꾼(코어)들이 골고루 작업할 수 있도록 데이터를 24개의 균등한 파티션으로 재배열하는 과정입니다.

---

### 5. 저장 포맷의 진화: Parquet (Columnar Storage)

DataFrame을 최종 저장할 때 왜 Parquet을 쓰는지에 대한 이유입니다.

* **컬럼 기반 저장:** CSV처럼 줄 단위로 읽지 않고, 필요한 컬럼만 선택해서 읽을 수 있습니다(Column Pruning).
* **데이터 타입 보존:** CSV는 모든 데이터가 텍스트이지만, Parquet은 스키마 정보를 포함하고 있어 읽어올 때 타입을 다시 지정할 필요가 없습니다.
* **압축 효율:** 유사한 데이터가 모여있는 컬럼 단위로 압축하므로 CSV 대비 용량이 획기적으로 줄어듭니다.

---

### 📝 요약: DataFrame 작업의 핵심 흐름

1. **Schema 정의:** 읽기 속도 최적화.
2. **Transformations:** `select`, `filter`, `withColumn` 등으로 논리적 계획 수립.
3. **Repartition:** 병렬 처리 효율 극대화.
4. **Action:** `show()` 또는 `write.parquet()`로 연산 실행 및 결과 확인.


---

## 9. 🏗️ Spark 실전: 스키마 설계 및 대규모 데이터 통합 (5.3.3)

이 섹션에서는 `05_taxi_schema.ipynb` 파일의 핵심 로직을 통해 **데이터 정제(Cleaning)** 과정을 살펴봅니다.

### 1) 엄격한 설계도 작성을 통한 데이터 정합성 확보

Spark가 데이터를 읽기 전에 우리가 먼저 컬럼명과 타입을 확정 짓습니다.

```python
# [05 노트북 코드] 명시적 스키마 정의 예시 (Green Taxi)
from pyspark.sql import types

green_schema = types.StructType([
    types.StructField("VendorID", types.LongType(), True),
    types.StructField("lpep_pickup_datetime", types.TimestampType(), True),
    types.StructField("lpep_dropoff_datetime", types.TimestampType(), True),
    types.StructField("PULocationID", types.LongType(), True),
    types.StructField("DOLocationID", types.LongType(), True),
    types.StructField("passenger_count", types.DoubleType(), True),
    types.StructField("trip_distance", types.DoubleType(), True),
    # ... (생략) ...
])

```

* **왜 했는가?**: `VendorID`나 `PULocationID`처럼 나중에 JOIN의 키가 될 데이터들이 월별로 타입이 다르게 읽히는 것을 방지합니다.

### 2) 루프를 이용한 대규모 ETL 자동화

수십 개의 폴더에 흩어진 CSV 파일을 한 번에 Parquet으로 변환하는 자동화 로직입니다.

```python
# [05 노트북 코드] 반복문을 통한 월별 데이터 변환
years = [2020, 2021]

for color, schema in taxi_configs:
    for year in years:
        for month in range(1, 13):
            input_path = f'data/raw/{color}/{year}/{month:02d}/*.parquet'
            output_path = f'data/pq/{color}/{year}/{month:02d}/'

            # 1. 정의한 스키마로 읽기
            df = spark.read.schema(schema).parquet(input_path)

            # 2. 4개의 파티션으로 나누어 병렬 저장 최적화
            df.repartition(4).write.mode('overwrite').parquet(output_path)

```

* **핵심 과정**: 읽기(read) → 재분할(repartition) → 쓰기(write) 순서로 진행됩니다. 이 과정을 거치면 원본 대비 용량이 줄고 읽기 속도가 수십 배 빨라진 `data/pq` 폴더가 생성됩니다.

---

## 10. 📊 Spark SQL: 데이터 결합 및 비즈니스 리포트 생성 (5.3.4)

이 섹션에서는 `06_spark_sql.ipynb` 코드를 통해 **데이터 분석 및 요약** 과정을 살펴봅니다.

### 1) 다른 두 세상의 데이터 합치기 (Union)

Green 택시와 Yellow 택시는 컬럼명이 다릅니다. 이를 공통 분모로 묶어주는 작업입니다.

```python
# [06 노트북 코드] 컬럼명 표준화 및 Union
# Green 데이터 컬럼명 변경 (lpep -> pickup/dropoff)
df_green = df_green \
    .withColumnRenamed('lpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('lpep_dropoff_datetime', 'dropoff_datetime')

# Yellow 데이터 컬럼명 변경 (tpep -> pickup/dropoff)
df_yellow = df_yellow \
    .withColumnRenamed('tpep_pickup_datetime', 'pickup_datetime') \
    .withColumnRenamed('tpep_dropoff_datetime', 'dropoff_datetime')

# 두 데이터셋 합치기
df_trips_data = df_green.select(common_columns).unionAll(df_yellow.select(common_columns))

```

### 2) Spark SQL을 활용한 복합 집계 (Aggregation)

합쳐진 전체 데이터를 바탕으로 월별, 구역별 수익 리포트를 만듭니다.

```python
# [06 노트북 코드] 임시 뷰 생성 및 SQL 쿼리 실행
df_trips_data.createOrReplaceTempView('trips_data')

df_result = spark.sql("""
SELECT 
    -- 1. 시간 및 구역 기준
    date_trunc('month', pickup_datetime) AS revenue_month, 
    PULocationID AS zone,
    
    -- 2. 수익 관련 통계
    SUM(total_amount) AS revenue_monthly_total,
    COUNT(1) AS number_records,
    AVG(passenger_count) AS avg_passenger_count,
    AVG(trip_distance) AS avg_trip_distance
FROM 
    trips_data
GROUP BY 
    1, 2
""")

```

### 3) 최종 리포트 파일 최적화 저장

분석 결과물은 용량이 작으므로 관리하기 편하게 파일을 하나로 뭉쳐서 저장합니다.

```python
# [06 노트북 코드] 결과 저장 (파일 1개로 합치기)
df_result.coalesce(1) \
    .write.parquet('data/report/revenue/', mode='overwrite')

```

* **`coalesce(1)`**: 분석 결과 리포트는 보통 작기 때문에 파일이 여러 개로 쪼개져 있으면 오히려 읽기 불편합니다. 이를 하나의 파일로 모아주는 작업입니다.
* **`mode('overwrite')`**: 매달 배치가 돌 때마다 새로운 결과로 덮어씌워 최신 리포트를 유지합니다.

---

### ✨ 요약된 코드 흐름도

1. **`StructType`**: 원본 데이터의 불확실성을 제거 (설계도)
2. **`repartition(4)`**: 분산 처리를 위한 일감 배분 (도시락 쪼개기)
3. **`unionAll`**: 서로 다른 출처의 데이터를 하나로 결합 (통합)
4. **`spark.sql`**: 비즈니스 로직 적용 및 인사이트 추출 (요리)
5. **`coalesce(1)`**: 최종 결과물을 보기 좋게 정리 (포장)
강의 **5.4.1 - Anatomy of a Spark Cluster**의 내용을 핵심 위주로 빠짐없이 정리했다.

---

## 11. 🧠 Spark Internals: Spark 클러스터의 구조 (Anatomy)

Spark가 단순히 코드를 실행하는 것이 아니라, 내부적으로 어떤 컴포넌트들이 어떻게 상호작용하여 분산 처리를 수행하는지 파악한다.

### 1) 클러스터 구성 요소 (Core Components)

Spark 클러스터는 크게 세 가지 핵심 요소로 구성된다.

* **Driver:**
* 사용자가 작성한 코드가 실행되는 곳이다.
* 전체적인 작업의 흐름을 제어하고, 작업을 **Task** 단위로 쪼개어 Executor에게 전달한다.
* Spark 세션(SparkSession)이 생성되는 지점이다.


* **Executor:**
* 실제로 연산(Task)을 수행하는 '일꾼' 프로세스다.
* 데이터를 메모리나 디스크에 저장하고 처리 결과를 Driver에게 보고한다.


* **Cluster Manager:**
* 클러스터의 리소스(CPU, 메모리)를 관리하고 Executor를 할당한다.
* 종류: Spark Standalone, YARN, Kubernetes(K8s), Mesos 등.



### 2) 통신 및 데이터 흐름 (Communication)

1. **Driver ↔ Cluster Manager:** Driver가 리소스를 요청하면 Cluster Manager가 Executor들을 띄워준다.
2. **Driver ↔ Executor:** Driver는 실행 계획을 세워 Task를 Executor에 배포하고, Executor는 실행 상태와 결과를 Driver에 보낸다.
3. **Executor ↔ Executor:** 셔플(Shuffle)이 발생할 때 일꾼들끼리 직접 데이터를 주고받는다.

---

### 3) 코드 실행의 내부 단계 (Execution Hierarchy)

작성한 코드는 Spark 내부에서 다음과 같은 계층으로 쪼개져 실행된다.

* **Job:** `show()`, `write()`, `collect()` 같은 **Action**을 호출할 때 생성되는 최상위 단위다.
* **Stage:** Job 내에서 **Shuffle**이 발생하는 지점을 기준으로 나뉜다. 셔플이 없으면 하나의 Stage로 처리되지만, 데이터 재배치가 필요하면 여러 Stage로 분리된다.
* **Task:** 가장 작은 실행 단위다. 하나의 Stage 내에서 **데이터 파티션 한 개**를 처리하는 실제 작업이다. 파티션이 100개면 Task도 100개가 생성된다.

---

### 4) 실전 적용: `06_spark_sql.ipynb`에서의 구조 이해

내가 작성한 노트북 코드가 내부적으로 어떻게 돌아가는지 연결한다.

```python
# [06_spark_sql.ipynb] 
# 이 코드를 실행하는 순간 Driver는 전체 계획을 세운다.
df_result = spark.read.parquet('data/pq/*/*') \
    .repartition(24) \
    .groupBy('zone') \
    .count()

# Action 호출: 이 때 실제 Job이 생성되어 Executor로 Task가 전달된다.
df_result.show()

```

* **Driver 역할:** `repartition(24)`와 `groupBy`를 보고 "셔플이 필요하니 Stage를 나눠야겠군"이라고 판단한다.
* **Executor 역할:** 각자 맡은 파티션(24개 중 일부)을 가져와서 로컬 카운트를 하고, 셔플 단계에서 다른 Executor와 데이터를 주고받아 최종 결과를 만든다.
* **4040 포트(Spark UI):** 이 화면에서 보이는 **Job -> Stage -> Task** 리스트가 바로 위에서 설명한 Anatomy의 시각화 결과물이다.

---

### ✨ 핵심 요약 및 복습 포인트

1. **Driver**는 팀장, **Executor**는 일꾼, **Cluster Manager**는 인사팀이다.
2. **Shuffle**은 Stage를 가르는 기준이며, 네트워크 비용이 가장 크다.
3. **Task 수 = 파티션 수** 이므로, 적절한 파티셔닝이 성능의 핵심이다.
4. Local 모드(`local[*]`)에서는 내 컴퓨터 한 대가 Driver와 Executor 역할을 모두 수행하는 특수한 케이스다.


---

## 12. ⚙️ Spark Internals: GroupBy 및 Join 실전 (강의 5.4.1 ~ 5.4.2)

이 과정은 흩어져 있는 원본 데이터를 분석 가능한 형태의 **'수익 통계 리포트'**로 변환하는 파이프라인이다.

### 1) 개별 데이터 집계 (GroupBy & Aggregation)

가장 먼저 Green 택시와 Yellow 택시의 방대한 원본 데이터를 시간(hour)과 구역(zone) 단위로 요약한다. 이 과정에서 각 일꾼(Executor)들 사이에 데이터를 재배치하는 **셔플(Shuffle)**이 발생한다.

```python
# [07_groupby_join.ipynb] Green 택시 데이터 요약
df_green_revenue = spark.sql("""
SELECT 
    date_trunc('hour', lpep_pickup_datetime) AS hour, 
    PULocationID AS zone,
    SUM(total_amount) AS amount,
    COUNT(1) AS number_records
FROM
    green
WHERE
    lpep_pickup_datetime >= '2020-01-01 00:00:00'
GROUP BY
    1, 2
""")

# 최적화를 위해 20개의 파티션으로 나누어 저장 (데이터 재배열)
df_green_revenue \
    .repartition(20) \
    .write.parquet('data/report/revenue/green', mode='overwrite')

```

* **동작 원리**: 모든 행을 다 전송하지 않고, 각 파티션에서 먼저 계산한 뒤 결과값만 모으는 방식으로 네트워크 비용을 절감한다.

---

### 2) 두 거대 데이터의 결합 (Outer Join)

요약된 Green 택시 데이터와 Yellow 택시 데이터를 하나로 합친다. 특정 시간대와 구역에 두 택시 중 하나만 운행했을 수도 있으므로 `outer` join을 사용하여 데이터를 누락 없이 통합한다.

```python
# [07_groupby_join.ipynb] 통합을 위한 컬럼명 변경 및 Join
df_green_revenue_tmp = df_green_revenue \
    .withColumnRenamed('amount', 'green_amount') \
    .withColumnRenamed('number_records', 'green_number_records')

df_yellow_revenue_tmp = df_yellow_revenue \
    .withColumnRenamed('amount', 'yellow_amount') \
    .withColumnRenamed('number_records', 'yellow_number_records')

# 'hour'와 'zone'을 키로 사용하여 결합
df_join = df_green_revenue_tmp.join(df_yellow_revenue_tmp, on=['hour', 'zone'], how='outer')

```

---

### 3) 차원 데이터 결합 및 최종 리포트 생성 (Dimension Join)

숫자로만 구성된 요약 데이터에 실제 구역 이름(Manhattan, Brooklyn 등)을 붙여 사용자가 읽기 쉬운 리포트로 완성하는 단계다.

```python
# [07_groupby_join.ipynb] 지명(Zones) 데이터와 결합
df_zones = spark.read.parquet('zones/') 
df_result = df_join.join(df_zones, df_join.zone == df_zones.LocationID)

# 분석에 불필요한 ID 컬럼들은 삭제 후 최종 저장
df_result.drop('LocationID', 'zone').write.parquet('tmp/revenue-zones')

```

---

### ✨ 요약: 07 노트북의 데이터 파이프라인 흐름

1. **Partial Aggregation**: 수백만 건의 로우 데이터를 시간/구역별 요약본으로 압축한다.
2. **Shuffle & Write**: 압축된 데이터를 20개의 균등한 파티션(`repartition`)으로 나누어 디스크에 기록한다.
3. **Outer Join**: 서로 다른 두 데이터셋(Green, Yellow)을 시간과 구역을 기준으로 통합한다.
4. **Final Join**: 숫자로 된 구역 ID를 실제 지명으로 치환하여 최종 리포트를 추출한다.

이 모든 과정은 **Driver(팀장)**가 세운 계획에 따라 **Executor(일꾼)**들이 데이터를 셔플하며 수행하는 복합적인 분산 처리의 결과물이다. 🚀🐻


---

## 13. 🏗️ Spark 실전 프로젝트: 원본 데이터에서 최종 리포트까지 (Notebook 03~07)

이 과정은 단순한 코드 연습이 아니라, **"날것의 CSV 데이터를 읽어(Extract), Spark에 맞게 가공하고(Transform), 분석용 리포트로 저장(Load)"**하는 전체 데이터 엔지니어링 과정을 담고 있습니다.

### 1단계: [03_test & 04_pyspark] 환경 검증 및 Spark 입문

본격적인 분석에 앞서, 내 컴퓨터의 Spark가 데이터를 다룰 준비가 되었는지 확인하고 기초 사용법을 익히는 단계입니다.

* **핵심 작업**: `taxi_zone_lookup.csv`라는 작은 파일을 읽어 Spark 전용 포맷인 **Parquet**으로 변환 저장합니다.
* **시행착오 포인트**: 강의의 옛날 링크(`s3...`) 대신 최신 링크(`d37ci...`)를 사용하여 데이터를 받아야 `PATH_NOT_FOUND` 에러를 피할 수 있습니다.

```python
# [04번 노트북 핵심]
# CSV 읽기 (Pandas와 비슷하지만 '분산'해서 읽음)
df = spark.read.option("header", "true").csv('taxi_zone_lookup.csv')

# 파티셔닝 후 Parquet 저장 (일꾼들에게 일감 배분)
df.repartition(4).write.parquet('zones', mode='overwrite')

```

---

### 2단계: [05_taxi_schema] 데이터 정제 및 대량 변환 (ETL의 정수)

수백 메가바이트의 월별 택시 데이터(Green, Yellow)를 처리하기 위해 **'설계도(Schema)'**를 입히는 아주 중요한 단계입니다.

* **핵심 작업**: Spark가 데이터 타입을 추측하게 두지 않고, 우리가 직접 `StructType`으로 타입을 고정합니다. 그래야 나중에 데이터가 섞여도 에러가 나지 않습니다.
* **자동화**: 반복문을 통해 2020년~2021년의 모든 월별 데이터를 일관된 형식의 Parquet으로 변환합니다.

```python
# [05번 노트북 핵심] 스키마 정의
schema = types.StructType([
    types.StructField('PULocationID', types.IntegerType(), True),
    types.StructField('pickup_datetime', types.TimestampType(), True),
    # ... 중략 ...
])

# 대량 변환 루프 (repartition으로 저장 성능 최적화)
df.repartition(4).write.parquet(output_path)

```

---

### 3단계: [06_spark_sql] 데이터 통합 및 첫 번째 리포트

서로 다른 두 종류의 택시(Green, Yellow) 데이터를 하나로 합치고, SQL 문법을 사용하여 수익 리포트를 뽑아내는 단계입니다.

* **핵심 작업**: 컬럼명이 다른 두 데이터를 `withColumnRenamed`로 맞춘 뒤 `unionAll`로 합칩니다.
* **분석**: `createOrReplaceTempView`를 통해 데이터를 테이블처럼 만들고, 익숙한 SQL로 월별/구역별 수익을 계산합니다.

```python
# [06번 노트북 핵심] SQL 분석
df_trips_data.createOrReplaceTempView('trips_data')

df_result = spark.sql("""
    SELECT date_trunc('month', pickup_datetime) AS month, PULocationID AS zone, SUM(total_amount) AS revenue
    FROM trips_data GROUP BY 1, 2
""")
# 결과는 파일 1개로 깔끔하게 포장
df_result.coalesce(1).write.parquet('data/report/revenue/', mode='overwrite')

```

---

### 4단계: [07_groupby_join] 대규모 집계와 데이터 결합 (Advanced)

데이터 엔지니어링의 꽃인 **Join**과 **Shuffle**을 깊이 있게 다루는 마지막 단계입니다.

* **핵심 작업**:
1. 각 택시 데이터별로 시간대별 수익을 먼저 구합니다 (**GroupBy**).
2. 두 택시의 결과를 하나로 합칩니다 (**Outer Join**).
3. 마지막으로 'LocationID'만 있던 결과에 실제 지명(`zones`)을 붙입니다 (**Dimension Join**).



```python
# [07번 노트북 핵심] Join 연산
# 1단계에서 만든 zones 데이터와 결합
df_zones = spark.read.parquet('zones/')
df_final_report = df_join.join(df_zones, df_join.zone == df_zones.LocationID)

```

---

### 🧠 전체 과정 흐름도 요약 (사용자님을 위한 정리)

1. **데이터 수집 (!wget)**: 원본 CSV 파일을 내 컴퓨터로 가져옵니다.
2. **검증 및 기초 (03/04)**: 환경을 체크하고 작은 파일을 Parquet으로 바꿔 저장하는 연습을 합니다.
3. **설계도 작성 (05)**: 대용량 데이터를 위해 `StructType`으로 타입을 엄격하게 정의합니다.
4. **최적화 저장 (05)**: 원본 CSV를 일꾼들이 읽기 편한 `repartition(4)` 된 Parquet 파일들로 변환합니다.
5. **데이터 통합 (06)**: 서로 다른 출처의 데이터를 하나로 합칩니다 (Union).
6. **비즈니스 로직 (07)**: SQL과 Join을 사용하여 구역별/시간별 최종 수익 리포트를 생성합니다.

---

### 💡 마지막 팁: 왜 이렇게 복잡하게 하나요?

그냥 SQL 하나로 할 수도 있겠지만, **Spark Internals(5.4.1~5.4.2)**에서 배웠듯이 이 과정은 **"일꾼(Executor)들이 가장 빠르고 안정적으로 일을 할 수 있는 환경"**을 만들어가는 과정입니다.

* **Parquet**을 써서 읽기 속도를 높이고,
* **Schema**를 써서 타입을 고정하며,
* **Repartition**을 써서 일감을 골고루 나눠주고,
* **Join**을 통해 흩어진 정보를 하나로 모으는 것.


---

## 14. ⚡ Spark를 사용하는 결정적인 이유 (vs dbt/SQL)

가장 큰 차이는 **"데이터가 어디에서 계산되는가?"**입니다.

### ① 데이터가 데이터 웨어하우스(DW) 밖에 있을 때

dbt는 BigQuery나 Snowflake 같은 DW **내부**에 있는 데이터를 요리하는 도구입니다. 하지만 현업에서는 DW에 들어가기 전의 '날것(Raw)' 데이터가 S3나 GCS 같은 **데이터 레이크**에 수 테라바이트씩 쌓여 있는 경우가 많습니다.

* **Spark:** DW에 넣기엔 너무 크고 지저분한 데이터를 미리 정제(ETL)하여 DW로 넘겨주는 역할을 합니다.

### ② 복잡한 비정형 데이터 처리

SQL은 표(Table) 형태 데이터에는 강하지만, 복잡한 JSON, 이미지, 로그 파일, 또는 머신러닝 알고리즘을 적용하기엔 한계가 있습니다.

* **Spark:** Python이나 Scala 코드를 자유롭게 쓸 수 있어, SQL만으로는 구현하기 힘든 복잡한 로직을 처리할 수 있습니다.

### ③ 실시간 처리 (Streaming)

배치(Batch) 처리 외에 데이터가 들어오는 즉시 처리해야 하는 실시간 대시보드나 이상 감지 시스템이 필요할 때, Spark Streaming(Structured Streaming)은 업계 표준입니다.

---

## 2. 현업에서 Spark 대신 사용하는 것들

Spark가 '대세'이긴 하지만, 회사의 규모나 데이터의 성격에 따라 다른 도구를 선택하기도 합니다.

### ① Trino (구 Presto)

* **특징:** 데이터 레이크(S3 등)에 있는 데이터를 저장소를 옮기지 않고 바로 SQL로 조회할 때 씁니다.
* **차이점:** Spark는 "데이터를 변환하고 저장(ETL)"하는 데 강점이 있고, Trino는 "여러 곳에 흩어진 데이터를 빠르게 조회(Ad-hoc Query)"하는 데 특화되어 있습니다.

### ② Flink

* **특징:** Spark보다 더 '진짜 실시간'에 가까운 처리를 할 때 사용합니다.
* **차이점:** Spark는 실시간 처리를 아주 작은 배치 단위(Micro-batch)로 쪼개서 하지만, Flink는 데이터 한 건 한 건을 즉시 처리합니다. 지연 시간(Latency)이 극도로 중요한 금융권 등에서 선호합니다.

### ③ 현대적 데이터 웨어하우스 (BigQuery, Snowflake, Databricks)

* **특징:** 요즘은 DW 성능이 워낙 좋아져서, 웬만한 양의 데이터는 Spark 없이 SQL만으로 처리합니다. (ELT 방식)
* **Databricks:** 재미있게도 Databricks는 Spark를 만든 사람들이 세운 회사입니다. 결국 현업에서는 '생 Spark'를 관리하기 힘들어서 이런 유료 클라우드 서비스를 사용합니다.

### ④ Pandas / Polars (작은 규모)

* 데이터가 한 대의 컴퓨터 메모리에 들어갈 정도(수십 GB 이하)라면, 굳이 복잡한 Spark 클러스터를 띄우지 않고 **Polars** 같은 고성능 라이브러리를 사용해 비용을 아낍니다.

---

## 3. 요약: 공부의 방향성

1. **Docker/Terraform:** 데이터 인프라를 구축하는 '바구니'를 만듭니다.
2. **Airflow:** 이 모든 작업이 제시간에 돌아가게 '스케줄링'합니다.
3. **Spark:** 데이터 레이크의 거대한 원본 데이터를 '1차 가공'합니다.
4. **dbt:** 가공된 데이터를 DW에 넣고 '비즈니스 로직(SQL)'을 입힙니다.

[Image comparing Batch Processing versus Stream Processing architectures]

**결론:** Spark는 **"SQL만으로는 감당 안 되는 대규모/비정형 데이터를 다루는 법"**을 배우는 과정이다. 현업에서는 Spark를 직접 설치하기보다 AWS EMR이나 Databricks 같은 서비스로 많이 사용한다.
