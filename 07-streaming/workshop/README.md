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

워크숍 폴더(`07-streaming/workshop/`)에 아래 내용을 저장합니다.

```yaml
services:
  redpanda:
    image: redpandadata/redpanda:v25.3.9
    command:
      - redpanda
      - start
      - --smp '1'                # CPU 코어 1개 사용 (Seastar 프레임워크 기반)
      - --reserve-memory 0M      # 개발 환경을 위해 추가 메모리 예약 안 함
      - --overprovisioned        # 특정 CPU 코어에 스레드 고정 안 함 (충돌 방지)
      - --node-id '1'            # 클러스터 내 브로커 고유 식별자
      - --kafka-addr PLAINTEXT://0.0.0.0:29092,OUTSIDE://0.0.0.0:9092
      - --advertise-kafka-addr PLAINTEXT://redpanda:29092,OUTSIDE://localhost:9092
      - --pandaproxy-addr 0.0.0.0:8082,OUTSIDE://0.0.0.0:28082
      - --advertise-pandaproxy-addr localhost:8082,OUTSIDE://localhost:28082
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

이제 이 명령어를 순서대로 복사해서 사용하시면 됩니다. **1번의 `docker compose up redpanda -d**` 부터 시작해 볼까요? 🚀🐻