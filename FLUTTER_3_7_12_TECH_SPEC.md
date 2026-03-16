# 🛠️ Flutter 3.7.12 개발 환경 명세서 (FLUTTER_3_7_12_TECH_SPEC.md)

이 문서는 MasterTreeApp 프로젝트의 Flutter 3.7.12 기반 개발 환경 스펙과 빌드 이슈 해결 방법을 정리한 가이드입니다.

---

## 1. 코어 툴 버전 (Core Tool Versions)

| Tool | Version | Remark |
| :--- | :--- | :--- |
| **Flutter SDK** | `3.7.12` | Stable Channel 고정 |
| **Dart SDK** | `2.19.6` | Null Safety 지원 최종 안정 버전 |
| **JDK (Java)** | `OpenJDK 17 (LTS)` | **필수**: Java 21 사용 시 빌드 오류 발생 |
| **Gradle** | `7.5` | `gradle-wrapper.properties` 설정 |
| **Kotlin** | `1.7.10` | `build.gradle` 설정 |
| **AGP (Android Gradle Plugin)** | `7.2.0` | `build.gradle` 설정 |

## 2. 안드로이드 빌드 상세 설정 (Android Build Config)

*   **Compile SDK Version**: `33` (Android 13)
*   **Min SDK Version**: `21` (LTS 호환성 보장)
*   **Target SDK Version**: `33`
*   **Java Home 설정**: 터미널에서 아래 명령어로 Java 17을 강제 지정해야 함
    ```powershell
    $env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.17.10-hotspot'
    ```

## 3. 주요 플러그인 호환성 (Verified Version List)

Dart 2.19.6 환경에서 컴파일 오류가 없는 검증된 버전입니다.

*   `supabase_flutter`: `^1.10.3`
*   `provider`: `^6.0.5`
*   `http`: `^0.13.6` (1.0 이상 금지)
*   `fl_chart`: `^0.60.0`
*   `google_fonts`: `^4.0.4`
*   `cached_network_image`: `^3.2.3`
*   `flutter_dotenv`: `^5.1.0`

## 4. 빈번한 빌드 에러 및 해결 방법 (Troubleshooting)

### 4.1 "Unsupported class file major version 65"
*   **원인**: Java 21 환경에서 Gradle 7.5를 실행할 때 발생하는 버전 불일치 에러.
*   **해결**: 시스템에 설치된 **Java 17** 경로를 확인하고 `JAVA_HOME`을 해당 경로로 변경 후 재빌드.

### 4.2 "Duplicate Class" (라이브러리 충돌)
*   **원인**: 일부 플러그인이 상위 버전의 AndroidX 라이브러리를 강제 참조할 때 발생.
*   **해결**: `flutter_user_app/android/app/build.gradle` 하단에 아래 전략 추가:
    ```gradle
    configurations.all {
        resolutionStrategy {
            force 'androidx.core:core:1.10.1'
            force 'androidx.activity:activity:1.7.2'
        }
    }
    ```

### 4.3 한글 깨짐 이슈 (Encoding)
*   **원인**: Windows 터미널 기본 인코딩(MS949)과 소스코드(UTF-8) 불일치.
*   **해결**: 터미널 실행 시 항상 `chcp 65001`을 입력하여 UTF-8 환경으로 전환.

---
**주의**: 본 명세서 외의 버전 상향은 의존성 연쇄 오류를 유발할 수 있으므로 변경 시 반드시 사전 테스트가 필요합니다.
