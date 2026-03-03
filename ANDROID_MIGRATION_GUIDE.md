# Flutter Web -> Android 앱 전환 가이드

이 문서는 현재 개발된 **Flutter Web (Admin App)** 프로젝트를 **안드로이드 앱(.apk)**으로 빌드하고 운영하기 위해 필요한 설정과 고려 사항을 정리한 가이드입니다.

---

## 1. ⚙️ 개발 환경 설정 (Prerequisites)

안드로이드 앱을 빌드하려면 다음 도구들이 설치되어 있어야 합니다.

1.  **Android Studio 설치**:
    - [Download Android Studio](https://developer.android.com/studio)
    - 설치 시 **Android SDK**, **Android SDK Command-line Tools**, **Android SDK Build-Tools**를 반드시 체크하여 설치하세요.
2.  **Flutter 플러그인 설정**:
    - Android Studio > Settings > Plugins > "Flutter" 검색 후 설치.
3.  **라이선스 동의**:
    - 터미널에서 다음 명령어 실행 후 모든 항목에 `y` 입력:
        ```bash
        flutter doctor --android-licenses
        ```
    - `flutter doctor` 명령어로 모든 항목이 체크(v) 되었는지 확인.

---

## 2. 🚨 코드 및 설정 수정 사항

웹 환경과 앱 환경은 보안 정책과 네트워크 접근 방식이 다르므로 다음 사항을 수정해야 합니다.

### A. 네트워크 설정 (API 주소 변경)

- **문제**: 웹에서는 `localhost`가 내 PC를 의미하지만, 안드로이드 에뮬레이터에서 `localhost`는 **폰 자기 자신**을 의미합니다.
- **해결**: `.env` 파일의 API 주소를 변경해야 합니다.
    - **에뮬레이터 사용 시**: `http://10.0.2.2:3000` (안드로이드가 PC를 가리키는 특수 IP)
    - **실물 기기 테스트 시**: PC의 내부 IP 사용 (예: `192.168.0.x:3000`) + 방화벽 인바운드 허용.
    - **배포(Production) 시**: 실제 도메인 사용 (예: `https://api.your-service.com`).

### B. 권한 설정 (AndroidManifest.xml)

- **파일 위치**: `flutter_admin_app/android/app/src/main/AndroidManifest.xml`
- **내용 추가**: `<manifest>` 태그 안에 다음 권한을 추가해야 합니다.
    ```xml
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    ```

### C. 구글 로그인 설정 (SHA-1 디지털 서명)

- **문제**: 웹 로그인은 도메인 등록으로 충분하지만, 앱 로그인은 **SHA-1 지문** 등록이 필수입니다.
- **해결 방법**:
    1.  **SHA-1 추출**:
        - 터미널(프로젝트 루트)에서 실행:
            ```bash
            cd android
            ./gradlew signingReport
            ```
        - 출력된 `SHA1: AA:BB:CC...` 형태의 값을 복사.
    2.  **Supabase/Google Cloud Console 등록**:
        - Supabase Dashboard > Authentication > Google Provider 설정에는 **Web Client ID**만 필요.
        - **Google Cloud Console** > API & Services > Credentials > **Create OAuth Client ID (Android)** 선택.
        - 패키지 이름(`com.example.flutter_admin_app`)과 위에서 복사한 **SHA-1**을 입력하여 등록.

---

## 3. 🚀 빌드 및 실행 명령어

### 에뮬레이터에서 실행 (테스트)

1.  Android Studio에서 AVD Manager로 가상 기기(Pixel 등)를 실행합니다.
2.  터미널에서 실행:
    ```bash
    flutter run -d <device-id>
    # 예: flutter run -d emulator-5554
    ```

### 배포용 APK 파일 생성

구글 플레이 스토어에 올리거나, 직접 설치할 수 있는 설치 파일(.apk)을 만듭니다.

```bash
flutter build apk --release
```

- 생성 위치: `build/app/outputs/flutter-apk/app-release.apk`

---

## 4. 💡 추가 팁 (웹 vs 앱 차이)

- **새로고침(F5)**: 앱에는 '새로고침' 버튼이 없습니다. 데이터가 갱신되어야 하는 화면(리스트 등)에는 **`RefreshIndicator`** (당겨서 새로고침) 위젯을 구현해야 합니다.
- **파일 선택**: 웹(`Image.network`)과 달리 앱은 파일 시스템(`File`)을 사용하므로, 이미지 업로드 로직에서 `kIsWeb` 조건문을 사용하여 분기 처리가 필요할 수 있습니다. (현재 코드는 `file_picker` 등을 사용하여 잘 추상화되어 있는지 확인 필요)
