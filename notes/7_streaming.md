# 🌊 [Data Engineering Zoomcamp 2025] 스트리밍 데이터 처리의 본질

> **Instructor:** Zach Wilson (데이터 엔지니어링 전문가)

---

### 🚀 1. 스트리밍의 정의: "패러다임의 전환"

* **단순한 '빠른 배치'가 아님:** 데이터가 발생하는 즉시 처리하는 사고방식의 변화를 의미합니다.
* **비즈니스 가치 우선:** 모든 데이터를 실시간으로 만들 필요는 없습니다. 사기 탐지(Fraud)나 실시간 추천처럼 **'저지연성(Low Latency)'**이 돈이 되는 곳에 적용해야 합니다.

### ⏱️ 2. 시간과의 싸움: "시간의 두 얼굴"

* **Event Time vs Processing Time:** * **사건 발생 시간(Event Time)**을 기준으로 처리하는 것이 가장 중요하며 어렵습니다.
* **워터마크(Watermarks):** 네트워크 지연 등으로 늦게 도착하는 데이터를 어디까지 기다려줄 것인지 결정하는 기준점입니다.
* **윈도잉(Windowing):** 끊임없이 흐르는 데이터를 5분, 10분 단위로 잘라 분석하는 핵심 기술입니다.

### 🛡️ 3. 데이터 무결성: "정확히 한 번만 처리하기"

* **상태 관리(Stateful):** 합계나 중복 제거를 위해 시스템이 이전 기록을 기억해야 하는 고난도 작업입니다.
* **장애 복구:** 시스템이 멈춰도 데이터가 누락되거나 중복되지 않도록 보장하는 **Exactly-once** 구현이 핵심입니다.

### 🛠️ 4. 추천 기술 스택: "최강의 조합"

* **메시지 브로커:** 데이터의 고속도로 역할을 하는 **Apache Kafka**.
* **처리 엔진:** 상태 관리와 시간 처리에 가장 강력한 **Apache Flink**를 추천합니다. (Spark Streaming보다 더 세밀한 제어가 가능합니다.)

### 💡 5. 실무자를 위한 뼈 때리는 조언

* **Keep it Simple:** 스트리밍은 아키텍처가 매우 복잡해집니다. 꼭 필요한 경우가 아니면 배치를 먼저 고려하세요.
* **Backfilling 대비:** 과거 데이터를 다시 밀어 넣어야 할 때를 대비해, 스트리밍 코드가 배치 환경에서도 돌아가도록 설계하는 것이 프로의 기술입니다.

---


---

# 1. 🌊 [Data Engineering] 실시간 스트리밍과 Apache Kafka 핵심 요약

## 1. 데이터 스트림(Data Stream)의 이해

데이터 스트림은 고정된 데이터 셋(Batch)과 달리, **끊임없이 생성되고 흐르는 데이터**의 형태를 말합니다.

* **무한성 (Unbounded):** 끝이 정해져 있지 않고 24시간 내내 발생합니다.
* **즉시성 (Low Latency):** 데이터가 발생하는 즉시 처리하여 가치를 만들어냅니다. (예: 카드 부정 사용 탐지)
* **불변성 (Immutable):** 한 번 발생한 이벤트(결제, 클릭 등)는 수정되지 않으며 기록으로 남습니다.

---

## 2. Apache Kafka: 스트림 데이터의 "중앙 고속도로"

카프카는 이러한 스트림 데이터를 여러 곳으로 안전하게 전달하고 임시 저장하는 **분산 메시징 플랫폼**입니다.

### 🏗️ 핵심 구성 요소 (Core Components)

* **Producer (생산자):** 데이터를 생성하여 카프카로 보내는 주체 (앱 로그, IoT 센서 등).
* **Consumer (소비자):** 카프카에서 데이터를 가져와 분석하거나 저장하는 주체.
* **Broker (브로커):** 카프카 서버 그 자체. 데이터를 저장하고 관리하는 물리적 노드(Node)입니다.
* **Topic (토픽):** 데이터가 저장되는 **분류 이름(폴더)**입니다. 생산자와 소비자는 특정 토픽을 기준으로 소통합니다.

### ⚙️ 고성능과 안정성의 비결 (핵심!)

* **Partition (파티션):** 하나의 토픽을 여러 개로 쪼개어 여러 브로커에 분산 저장합니다.
> **💡 [면접 대비 메모] 파티션 = 성능(병렬 처리)**
> 파티션이 많을수록 여러 명의 컨슈머가 동시에 데이터를 읽을 수 있어 처리 속도가 비약적으로 향상됩니다.


* **Replication (복제):** 데이터를 다른 브로커에 복사해둡니다.
> **💡 [면접 대비 메모] 복제 = 안정성(데이터 백업/고가용성)**
> 특정 브로커 서버가 고장 나더라도 복제본(Follower)이 대장(Leader) 역할을 이어받아 데이터 유실을 막습니다.


* **Offset (오프셋):** 파티션 내에서 메시지의 위치를 나타내는 **고유 번호**입니다. 소비자가 어디까지 읽었는지 기억하는 체크포인트 역할을 합니다.

---

## 3. 결론: 왜 데이터 엔지니어는 카프카를 쓰는가?

1. **완충 작용 (Buffering):** 데이터가 폭주해도 카프카가 중간에서 다 받아주기 때문에, 뒤쪽의 분석 시스템이 과부하로 다운되는 것을 방지합니다.
2. **확장성 (Scalability):** 파티션을 늘리거나 브로커를 추가함으로써 무한히 밀려드는 데이터를 감당할 수 있습니다.
3. **유연성:** 하나의 데이터를 여러 팀(분석팀, 운영팀 등)에서 각자의 목적으로 동시에 가져가 사용할 수 있습니다.

---


# 2. 📝 [Study Note] Kafka 실습 핵심 요약 (Confluent & Local)

## 1. 카프카 운영 방식 비교

* **Confluent Cloud:** 카프카를 서비스(SaaS)로 빌려 쓰는 방식. 설정이 편하지만 유료고 설정이 자동화되어 있어 내부 로직 공부에는 한계가 있음.
* **Local (Docker):** 내 컴퓨터에 직접 띄우는 방식. 서버 설정, 포트 포워딩, 브로커 관리를 직접 해야 해서 실력 쌓기에 더 좋음. (**선택: 로컬 실습**)

## 2. 외부 접속을 위한 3대 필수 설정

카프카 외부(Python 스크립트 등)에서 접속할 때 반드시 알아야 할 정보들:

* **Bootstrap Server:** 카프카 클러스터의 '입구' 주소. (로컬은 보통 `localhost:9092`)
* **Security & Auth:** 클라우드에서는 API Key/Secret이 필요하지만, 로컬 실습에서는 보통 보안 설정을 풀고(PLAINTEXT) 진행함.
* **Schema Registry:** 데이터의 '규격(데이터 타입 등)'을 약속하는 저장소. 보내는 놈과 받는 놈의 형식을 일치시켜서 에러를 방지함.

## 3. 핵심 부가 기능

* **Kafka Connect:** 코딩 없이 설정만으로 DB(Postgres 등)나 클라우드 저장소(S3, GCS)와 데이터를 주고받게 해주는 커넥터.
* **KSQL / ksqlDB:** 카프카에 흐르는 데이터를 SQL 문법으로 실시간 쿼리할 수 있게 해주는 도구. (Java/Python 코딩 양을 줄여줌)

## 4. 로컬 실습 시 주의사항 (Troubleshooting)

* **Port 9092:** 카프카 기본 포트. 다른 프로세스가 쓰고 있는지 확인 필수.
* **Retention Policy:** 데이터 보관 주기. 로컬은 용량이 작으므로 너무 길게 잡지 않도록 주의.
* **Advertised Listeners:** Docker 내부망과 내 컴퓨터(Host) 사이의 통신 설정. 이게 꼬이면 접속 에러 발생함.

---

### 💡 [나를 위한 한 줄 요약]

> **"클라우드(Confluent)는 편의성 중심, 로컬(Docker)은 제어권 중심이다. 실습할 땐 Docker로 직접 인프라를 건드려보는 게 취업 시 기술 면접 대응에 훨씬 유리함!"**

---

축하드립니다! 산전수전 다 겪으며 드디어 **로컬 데이터 스트리밍 파이프라인(Kafka + Spark)**을 완벽하게 구축하셨네요.

나중에 비슷한 문제가 생겼을 때나, 기술 면접에서 "환경 구축 경험"을 설명하실 수 있도록 오늘 해결한 과정을 핵심 위주로 정리해 드릴게요.

---

## 3. 🛠️ Data Engineering Zoomcamp: 스트리밍 환경 구축기

### 1. 문제 상황 (Trouble)

* 강사의 GitHub 폴더 구조를 로컬에 수동으로 복사하여 환경을 구축하려 함.
* `docker-compose up` 실행 시 `jupyterlab`, `spark-master` 등의 이미지를 찾을 수 없어 **Pull Access Denied** 에러 발생.
* 이미지 빌드 스크립트(`build.sh`)가 리눅스용 변수 설정으로 되어 있어 윈도우(Git Bash)에서 정상 작동하지 않음.

### 2. 해결 과정 (Actions)

#### **① 이미지 계층 구조 이해 및 수동 빌드**

Docker 이미지들이 서로를 참조(`FROM`)하고 있어 순서대로 빌드해야 함을 파악했습니다.

* `cluster-base` → `spark-base` → `spark-master`/`worker`/`jupyterlab` 순으로 빌드 진행.

#### **② 환경 변수 주입 및 윈도우 호환성 해결**

Git Bash에서 빌드 시, `--build-arg` 옵션을 통해 버전 정보를 직접 주입하여 빌드 에러를 방지했습니다.

```bash
docker build -t jupyterlab --build-arg spark_version=3.3.1 ...

```

#### **③ Python 보안 정책(PEP 668) 대응**

최신 OS 베이스 이미지에서 `pip install`이 차단되는 문제를 Dockerfile 수정(`--break-system-packages`)을 통해 해결했습니다.

#### **④ 멀티 컨테이너 네트워크 연결**

Kafka 폴더와 Spark 폴더가 분리되어 있었지만, `docker-compose`의 `external: true` 설정을 통해 `kafka-spark-network`라는 공유 네트워크로 모든 서비스를 묶었습니다.

### 3. 최종 인프라 구성 (Results)

| 서비스 | 주소 | 역할 |
| --- | --- | --- |
| **Kafka Control Center** | `localhost:9021` | 데이터 스트림(Topic) 모니터링 |
| **Spark Master UI** | `localhost:8080` | 데이터 처리 엔진 상태 및 워커 확인 |
| **JupyterLab** | `localhost:8888` | PySpark 실습 코드 작성 및 실행 환경 |

---

### 📝 [Study Note] 핵심 교훈

> "현업에서도 Docker 이미지는 단순히 `up` 하는 것이 아니라, 보안 정책이나 라이브러리 버전에 따라 직접 `Dockerfile`을 수정하고 빌드 인자를 관리하며 최적화하는 과정이 반드시 수반된다."

---

## 4. 🛠️ 실시간 데이터 송수신 및 Avro 스키마 적용기

### 1. 데이터 설계도 작성 (Avro Schema 정의)

데이터를 무작정 보내는 것이 아니라, **'약속된 형식'**에 맞추어 압축 전송하기 위해 Avro 설계도를 만들었습니다.

* **Key 설계도 (`taxi_ride_key.avsc`)**: 어떤 필드를 기준으로 데이터를 식별할지 정의 (예: `vendor_id`)
* **Value 설계도 (`taxi_ride_value.avsc`)**: 실제 택시 운행 정보의 타입 정의 (int, float 등)

```json
/* taxi_ride_value.avsc 예시 */
{
  "namespace": "com.datatalksclub.taxi",
  "type": "record",
  "name": "RideRecord",
  "fields": [
    { "name": "vendor_id", "type": "int" },
    { "name": "passenger_count", "type": "int" },
    { "name": "trip_distance", "type": "float" },
    { "name": "payment_type", "type": "int" },
    { "name": "total_amount", "type": "float" }
  ]
}

```

### 2. 데이터 발송기 구현 및 실행 (Producer)

로컬의 CSV 데이터를 읽어서 카프카로 쏘아 올리는 역할을 합니다. 이때 **Schema Registry**와 통신하여 데이터를 이진법(Binary)으로 압축합니다.

* **핵심 로직**: CSV 한 줄을 읽어 Avro 객체로 변환 후 `producer.produce()` 호출.
* **결과**: 터미널에 `Record ... successfully produced` 메시지 출력 확인.

```python
# producer.py 핵심 코드 (요약)
from confluent_kafka.avro import AvroProducer

producer = AvroProducer(config, default_key_schema=key_schema, default_value_schema=value_schema)
producer.produce(topic='rides_avro', key=key_dict, value=value_dict)

```

### 3. 데이터 수신기 구현 및 실행 (Consumer)

카프카에 쌓인 이진 데이터를 다시 우리가 읽을 수 있는 파이썬 딕셔너리로 번역하여 출력합니다.

* **핵심 로직**: `while True` 루프를 돌며 카프카를 폴링(`poll`)하고, 받은 데이터를 Deserializer로 복원.
* **결과**: 콘솔에 `RideRecord: {'vendor_id': 1, 'total_amount': 12.35, ...}` 실시간 출력 성공!

```python
# consumer.py 핵심 코드 (요약)
while True:
    msg = consumer.poll(1.0)
    if msg:
        # 이진 데이터를 다시 텍스트(dict)로 번역
        record = avro_value_deserializer(msg.value(), ...)
        print(f"Received: {record}")

```

### 4. 네트워크 트러블슈팅: Docker 컨테이너 간 통신 해결

Control Center 웹 화면에서 **"Schema Registry is not set up"** 에러가 발생하는 문제를 해결했습니다.

* **원인**: 도커 컨테이너 내부에서는 서로를 `localhost`가 아닌 **서비스 이름**으로 불러야 함을 파악.
* **해결**: `docker-compose.yml` 설정 수정.

```yaml
# docker-compose.yml 수정 내용
control-center:
  environment:
    # 수정 전: http://localhost:8081
    CONTROL_CENTER_SCHEMA_REGISTRY_URL: "http://schema-registry:8081" 

```

### 5. 최종 결과 (Summary)

* **터미널**: Producer와 Consumer가 실시간으로 데이터를 주고받음.
* **웹 UI (`localhost:9021`)**: `rides_avro` 토픽 내에 실제 데이터(Messages)와 설계도(Schema)가 정상적으로 표시됨.

---

### 📝 [Study Note] 핵심 교훈

> "도커 환경에서 서비스 간 통신 시 `localhost`는 자기 자신만을 의미한다. **컨테이너 네트워크 내에서는 서비스 이름이 곧 주소**가 된다는 점을 명심하자. 또한, Avro를 사용하면 데이터 용량을 획기적으로 줄이면서도 데이터의 무결성(Type Check)을 보장할 수 있다."

---

요청하신 PyFlink 스트리밍 워크숍 전체 가이드를 그대로 출력해 드립니다. 실습 도중 발생했던 **따옴표 에러 방지**를 위해 1번 섹션의 YAML 코드 내용만 사용자님 환경에 맞게 아주 살짝 보정해 두었으니, 이대로 복사해서 사용하시면 완벽할 것입니다.

---

# 🏗️ PyFlink: 스트리밍 처리 워크숍 (전 과정 통합 가이드)

본 워크숍은 실시간 스트리밍 파이프라인을 단계별로 구축합니다. 메시지 브로커, 프로듀서, 컨슈머부터 시작하여 데이터베이스와 스트림 처리 프레임워크(Flink)를 추가합니다. NYC Yellow Taxi 데이터를 소스로 사용합니다.

**최종 구조:** `Producer (Python) -> Kafka (Redpanda) -> Flink -> PostgreSQL`

---

## 1. Redpanda - Kafka 호환 브로커 설정

메시지를 생성하거나 소비하기 전에 메시지 브로커가 필요합니다. 저희는 Apache Kafka를 완벽하게 대체할 수 있는 **Redpanda**를 사용합니다.

### **왜 Kafka 대신 Redpanda인가?**

* **JVM 미필요:** C++로 작성되어 메모리 오버헤드가 적고 몇 초 만에 시작됩니다.
* **ZooKeeper 미필요:** Raft 합의 프로토콜을 사용하여 내부적으로 처리하므로 실행 서비스가 하나 줄어듭니다.
* **단일 바이너리:** 컨테이너 하나면 충분합니다.

### **Step 1: `docker-compose.yml` 작성**

워크숍 폴더(`07-streaming/workshop/`)에 아래 내용을 저장합니다. (**Windows 환경 에러 방지를 위해 숫자의 따옴표를 제거했습니다.**)

```yaml
services:
  redpanda:
    image: redpandadata/redpanda:v25.3.9
    container_name: redpanda
    command:
      - redpanda
      - start
      - --smp=1                 # CPU 코어 1개 사용
      - --reserve-memory=0M     # 개발 환경용 메모리 예약 해제
      - --overprovisioned
      - --node-id=1             # 브로커 고유 식별자
      - --kafka-addr=PLAINTEXT://0.0.0.0:29092,OUTSIDE://0.0.0.0:9092
      - --advertise-kafka-addr=PLAINTEXT://redpanda:29092,OUTSIDE://localhost:9092
      - --pandaproxy-addr=0.0.0.0:8082,OUTSIDE://0.0.0.0:28082
      - --advertise-pandaproxy-addr=localhost:8082,OUTSIDE://localhost:28082
    ports:
      - 9092:9092    # 외부용 (Python 접속)
      - 29092:29092  # 내부용 (Flink 접속)
      - 8082:8082    # HTTP 프록시 (외부)

```

### **Step 2: 실행 및 확인 명령어**

```bash
# Redpanda 실행
docker compose up redpanda -d

# 실행 상태 확인
docker compose ps

# 로그 확인 (성공 메시지 확인용)
docker logs -f redpanda

```

---

## 2. 데이터 전송 (Produce Messages)

### **Step 1: 환경 설정 (uv 사용)**

```bash
# 프로젝트 초기화 (Python 3.12)
uv init -p 3.12

# 필요한 라이브러리 설치
uv add kafka-python pandas pyarrow

```

### **Step 2: 프로듀서 실행**

데이터를 전송할 때는 **Serialization(직렬화)** 과정을 거쳐 Python 객체를 JSON 바이트로 변환합니다.

```bash
# Parquet 데이터를 읽어 Redpanda로 전송
uv run python src/producers/producer.py

```

---

## 3. 데이터 수신 (Consume Messages)

### **Step 1: 컨슈머 실행**

`auto_offset_reset='earliest'` 설정을 통해 처음부터 모든 메시지를 읽어오는지 확인합니다.

```bash
# 전송된 메시지를 실시간으로 수신하여 출력
uv run python src/consumers/consumer.py

```

---

## 4. 데이터 저장: PostgreSQL 연동

### **Step 1: Postgres 추가 (`docker-compose.yml`에 추가)**

```yaml
  postgres:
    image: postgres:18
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"

```

### **Step 2: 실행 및 DB 저장 명령어**

```bash
# Postgres 실행
docker compose up postgres -d

# 라이브러리 설치 및 저장 스크립트 실행
uv add psycopg2-binary
uv run python src/consumers/consumer_postgres.py

```

* **확인:** SQL 클라이언트에서 `SELECT * FROM processed_events;` 실행.

---

## 5. Flink 활용 이론 (Spark Streaming과 비교)

| 비교 항목 | Spark Streaming (Micro-batch) | Flink (Native Streaming) |
| --- | --- | --- |
| **처리 방식** | 짧은 간격(Pull)으로 데이터를 모아서 처리 | 데이터가 들어오는 즉시 한 건씩 처리(Push) |
| **지연 시간** | 최소 수백 ms 이상 | 매우 낮은 지연 시간 (초저지연) |

**Flink를 쓰는 이유:** 윈도우(Windowing), 체크포인팅(자동 복구), 병렬 처리 및 다양한 커넥터 지원 때문입니다.

---

## 6. Flink 클러스터 구축 및 실행

### **Step 1: Flink 이미지 빌드 및 실행**

```bash
# Dockerfile.flink 등을 기반으로 클러스터 실행
docker compose up --build -d

```

### **Step 2: Flink 잡(Job) 제출 명령어**

**예제 1: 단순 통과 잡 (Pass-through)**

```bash
docker compose exec jobmanager ./bin/flink run \
  -py /opt/src/job/pass_through_job.py \
  --pyFiles /opt/src \
  -d

```

**예제 2: 윈도우 집계 잡 (Aggregation)**
5초의 **Watermark(워터마크)**를 설정하여 지연 데이터가 들어와도 **Upsert**로 결과를 업데이트합니다.

```bash
docker compose exec jobmanager ./bin/flink run \
  -py /opt/src/job/job_aggregation.py \
  --pyFiles /opt/src \
  -d

```

---

## 7. 윈도우 유형 및 실습 마무리

### **윈도우 3가지 유형**

1. **Tumbling (회전):** 겹치지 않는 고정 크기 (예: 매 1시간).
2. **Sliding (슬라이딩):** 겹치는 윈도우 (예: 15분마다 갱신되는 1시간 단위).
3. **Session (세션):** 활동 중단 시까지 유지되는 가변 크기.

### **Step 1: 최종 데이터 확인 및 정리**

```bash
# 집계 결과 확인
SELECT * FROM processed_events_aggregated;

# 모든 리소스 삭제 (볼륨 포함)
docker compose down -v

```

---
