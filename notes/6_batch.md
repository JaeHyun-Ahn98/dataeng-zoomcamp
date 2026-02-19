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
