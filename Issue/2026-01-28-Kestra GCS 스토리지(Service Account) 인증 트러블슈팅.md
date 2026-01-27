# 📝 Kestra GCS 스토리지(Service Account) 인증 트러블슈팅

## 1. 문제 상황 및 에러 로그 분석

Kestra를 Docker Compose로 실행하고,
스토리지를 **Google Cloud Storage(GCS)** 로 설정하는 과정에서 여러 문제가 발생함.

### ① Docker 데몬 권한 에러 (Permission denied)

**증상:**

```text
permission denied while trying to connect to the Docker daemon socket
```

**원인:**
Docker 명령어 실행 시 현재 사용자 계정이 `docker` 그룹에 포함되어 있지 않아
`/var/run/docker.sock` 접근 권한이 없었음.

---

### ② Service Account JSON 파싱 에러

**증상:**

* Kestra 기동 실패 또는 GCS 접근 실패
* Google 인증 단계에서 JSON 파싱 오류 발생
* private_key 관련 오류 메시지 출력

**원인:**
`KESTRA_CONFIGURATION` 내부에 Service Account JSON을 **문자열 형태로 직접 삽입**하는 과정에서
`private_key` 필드의 줄바꿈(`\n`)과 escape 처리가 깨짐.

---

### ③ private_key 인증 실패

**증상:**

* JSON 파일 자체는 정상처럼 보임
* 하지만 GCS 인증 시 계속 실패

**원인:**
`private_key`는 단순 문자열이 아니라 **PEM 포맷 인증서**이며,
YAML → 문자열 → JSON → PEM 변환 과정 중 한 단계라도 깨지면
Google Auth SDK가 유효하지 않은 키로 판단함.

---

## 2. 문제의 핵심 원인 정리

* Service Account 키를 **문자열로 직접 넣는 방식은 매우 취약**
* `\n` 하나만 잘못 처리되어도 키가 손상됨
* Kestra 최신 버전은 Google Auth SDK의 **strict 파싱 정책**을 그대로 따름
* 강의에서 사용된 방식은 **과거 버전 / 데모 환경에서만 우연히 동작한 케이스**

---

## 3. 해결 과정 (Step-by-Step)

### ① Service Account JSON을 파일로 유지

GCP에서 다운로드한 Service Account JSON을 **절대 수정하지 않고 그대로 유지**함.

```bash
/home/jaehyen07/kestra/secrets/gcp-sa.json
```

---

### ② Docker 볼륨으로 JSON 파일 마운트

컨테이너 내부에서 파일 형태로 접근할 수 있도록 설정.

```yaml
volumes:
  - /home/jaehyen07/kestra/secrets/gcp-sa.json:/secrets/gcp-sa.json:ro
```

---

### ③ Kestra 설정에서는 파일 경로만 지정

Service Account 내용을 직접 넣지 않고, **파일 경로만 참조**하도록 변경.

```yaml
storage:
  type: gcs
  gcs:
    bucket: kestra-gcs-example0127
    projectId: kestra-sandbox-485208
    serviceAccount: /secrets/gcp-sa.json
```

---

### ④ 컨테이너 내부에서 파일 정상 여부 확인

```bash
docker exec -it kestra-server sh
cat /secrets/gcp-sa.json
```

* JSON 구조 정상
* private_key 줄바꿈 정상 유지
* GCS 인증 성공

---

## 4. 최종 docker-compose.yml (Success Code)

이 설정이 성공한 이유는
**“Service Account 키를 문자열이 아닌 파일로 다뤘기 때문”**이다.

```yaml
services:
  kestra:
    image: kestra/kestra:latest
    container_name: kestra-server
    command: server standalone
    restart: unless-stopped

    volumes:
      - kestra-data:/app/storage
      - /var/run/docker.sock:/var/run/docker.sock
      - /tmp/kestra-wd:/tmp/kestra-wd
      - /home/jaehyen07/kestra/secrets/gcp-sa.json:/secrets/gcp-sa.json:ro

    environment:
      KESTRA_CONFIGURATION: |
        datasources:
          postgres:
            url: jdbc:postgresql://10.106.112.3:5432/postgres
            driverClassName: org.postgresql.Driver
            username: kestra
            password: Kestra1234!

        kestra:
          repository:
            type: postgres

          storage:
            type: gcs
            gcs:
              bucket: kestra-gcs-example0127
              projectId: kestra-sandbox-485208
              serviceAccount: /secrets/gcp-sa.json

          queue:
            type: postgres

          tasks:
            tmp-dir:
              path: /tmp/kestra-wd/tmp
```

---

## 5. 강의 방식이 되었던 이유 (왜 나는 안 됐나?)

* 강의는 **과거 Kestra 버전**
* Google Auth SDK가 상대적으로 느슨한 시기
* 데모/실습 환경
* 운영 환경 고려 없음

👉 최신 Kestra + 최신 SDK 환경에서는 **더 이상 안전하지도, 보장되지도 않는 방식**임.

---

## 6. 학습 포인트

* Service Account 키는 **항상 파일로 관리**
* YAML 안에 JSON 문자열 직접 삽입 ❌
* `latest` vs `latest-full` 이미지는 본질적 해결책이 아님
* 지금 사용한 방식이 **공식 문서 + 실무 표준**

---

### ✅ 한 줄 요약 (~한다)

* Service Account를 문자열로 넣는 방식은 깨지기 쉽다
* 최신 Kestra에서는 strict 파싱으로 인해 실패한다
* 파일 마운트 방식이 유일하게 안전한 정답이다

---

