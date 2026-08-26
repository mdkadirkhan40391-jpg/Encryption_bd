#!/bin/sh
set -e

ROOT="EncryptionAutomationTool"
rm -rf "$ROOT"
mkdir -p "$ROOT"

# create directories
mkdir -p "$ROOT/gradle/wrapper"
mkdir -p "$ROOT/.github/workflows"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/db"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/preferences"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/data/model"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/data/remote"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/data/repository"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/data/security"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/model"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/repository"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/security"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/usecase"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/di"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/theme"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/navigation"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components"
mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/settings"
mkdir -p "$ROOT/app/src/test/java/com/automation/encryptiontool/domain"
mkdir -p "$ROOT/app/src/test/java/com/automation/encryptiontool/data"
mkdir -p "$ROOT/app/src/test/java/com/automation/encryptiontool/worker"
mkdir -p "$ROOT/app/src/androidTest/java/com/automation/encryptiontool/data"
mkdir -p "$ROOT/app/src/androidTest/java/com/automation/encryptiontool/ui"

# README
cat > "$ROOT/README.md" <<'EOF'
# EncryptionAutomationTool

This repository was scaffolded with placeholder files and folders by a script.
এই রিপোজিটরি প্লেসহোল্ডার ফাইল দিয়ে তৈরি করা হয়েছে — কোড পরে পরিবর্তন করবেন।
EOF

# .gitignore
cat > "$ROOT/.gitignore" <<'EOF'
# Android/Gradle ignores
.gradle/
/local.properties
/.idea/
.DS_Store
/build/
*/build/
.cxx/
/.gradle/
.settings/

# Kotlin
*.iml

# Keystore
*.jks
EOF

# gradle.properties
cat > "$ROOT/gradle.properties" <<'EOF'
# Placeholder gradle properties
org.gradle.jvmargs=-Xmx1536m
EOF

# settings.gradle.kts
cat > "$ROOT/settings.gradle.kts" <<'EOF'
rootProject.name = "EncryptionAutomationTool"
include(":app")
EOF

# root build.gradle.kts
cat > "$ROOT/build.gradle.kts" <<'EOF'
// Placeholder build script
plugins {
    // apply plugins here
}

// TODO: Add build configuration
EOF

# gradlew
cat > "$ROOT/gradlew" <<'EOF'
#!/bin/sh
# Placeholder gradlew script
echo "This is a placeholder for gradlew"
EOF
chmod +x "$ROOT/gradlew"

# gradle wrapper props and placeholder jar
cat > "$ROOT/gradle/wrapper/gradle-wrapper.properties" <<'EOF'
# Gradle Wrapper properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6-bin.zip
EOF

cat > "$ROOT/gradle/wrapper/gradle-wrapper.jar" <<'EOF'
# Placeholder for gradle-wrapper.jar binary. Replace with actual jar if needed.
EOF

# GitHub workflow
cat > "$ROOT/.github/workflows/build.yml" <<'EOF'
name: CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up JDK
        uses: actions/setup-java@v4
        with:
          distribution: 'temurin'
          java-version: '17'
      - name: Build
        run: ./gradlew build || true
EOF

# app module placeholders
cat > "$ROOT/app/build.gradle.kts" <<'EOF'
// app module placeholder build file
plugins {
    // id("com.android.application") version "7.4.0"
}

// TODO: configure android app build
EOF

cat > "$ROOT/app/proguard-rules.pro" <<'EOF'
# ProGuard rules placeholder
# Add rules here as needed
EOF

cat > "$ROOT/app/src/main/AndroidManifest.xml" <<'EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.automation.encryptiontool">

    <application
        android:label="EncryptionAutomationTool">
    </application>

</manifest>
EOF

# Kotlin placeholder files
cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/MainApplication.kt" <<'EOF'
package com.automation.encryptiontool

// TODO: Implement MainApplication
class MainApplication : android.app.Application() {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/MainActivity.kt" <<'EOF'
package com.automation.encryptiontool

// TODO: Implement MainActivity
class MainActivity : androidx.activity.ComponentActivity() {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/db/AppDatabase.kt" <<'EOF'
package com.automation.encryptiontool.data.local.db

// TODO: Implement AppDatabase (Room)
interface AppDatabase {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/db/ChatPairDao.kt" <<'EOF'
package com.automation.encryptiontool.data.local.db

// TODO: Implement ChatPairDao (Room DAO)
interface ChatPairDao {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/db/ChatPairEntity.kt" <<'EOF'
package com.automation.encryptiontool.data.local.db

// TODO: Implement ChatPairEntity (Room Entity)
data class ChatPairEntity(val id: Long = 0L)
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/db/DatabaseConverters.kt" <<'EOF'
package com.automation.encryptiontool.data.local.db

// TODO: Implement Database converters
object DatabaseConverters {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/preferences/SettingsDataStore.kt" <<'EOF'
package com.automation.encryptiontool.data.local.preferences

// TODO: Implement SettingsDataStore
class SettingsDataStore {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/local/preferences/TokenStorage.kt" <<'EOF'
package com.automation.encryptiontool.data.local.preferences

// TODO: Implement TokenStorage
class TokenStorage {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/model/ChatPairDto.kt" <<'EOF'
package com.automation.encryptiontool.data.model

// TODO: ChatPairDto
data class ChatPairDto(val id: Long = 0L)
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/model/EncryptedJsonDto.kt" <<'EOF'
package com.automation.encryptiontool.data.model

// TODO: EncryptedJsonDto
data class EncryptedJsonDto(val payload: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/model/GithubFileDto.kt" <<'EOF'
package com.automation.encryptiontool.data.model

// TODO: GithubFileDto
data class GithubFileDto(val name: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/model/GithubRepositoryDto.kt" <<'EOF'
package com.automation.encryptiontool.data.model

// TODO: GithubRepositoryDto
data class GithubRepositoryDto(val fullName: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/model/SettingsDto.kt" <<'EOF'
package com.automation.encryptiontool.data.model

// TODO: SettingsDto
data class SettingsDto(val key: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/remote/GithubApiService.kt" <<'EOF'
package com.automation.encryptiontool.data.remote

// TODO: GithubApiService
interface GithubApiService {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/remote/GithubApiModels.kt" <<'EOF'
package com.automation.encryptiontool.data.remote

// TODO: Github API models
object GithubApiModels {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/remote/GithubRemoteDataSource.kt" <<'EOF'
package com.automation.encryptiontool.data.remote

// TODO: GithubRemoteDataSource
class GithubRemoteDataSource {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/repository/EncryptionRepositoryImpl.kt" <<'EOF'
package com.automation.encryptiontool.data.repository

// TODO: EncryptionRepositoryImpl
class EncryptionRepositoryImpl {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/repository/GithubRepositoryImpl.kt" <<'EOF'
package com.automation.encryptiontool.data.repository

// TODO: GithubRepositoryImpl
class GithubRepositoryImpl {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/repository/SettingsRepositoryImpl.kt" <<'EOF'
package com.automation.encryptiontool.data.repository

// TODO: SettingsRepositoryImpl
class SettingsRepositoryImpl {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/data/security/Aes256EncryptorImpl.kt" <<'EOF'
package com.automation.encryptiontool.data.security

// TODO: Aes256EncryptorImpl
class Aes256EncryptorImpl {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/model/ChatPairModel.kt" <<'EOF'
package com.automation.encryptiontool.domain.model

// TODO: ChatPairModel
data class ChatPairModel(val id: Long = 0L)
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/model/EncryptedJsonOutput.kt" <<'EOF'
package com.automation.encryptiontool.domain.model

// TODO: EncryptedJsonOutput
data class EncryptedJsonOutput(val payload: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/model/RawJsonInput.kt" <<'EOF'
package com.automation.encryptiontool.domain.model

// TODO: RawJsonInput
data class RawJsonInput(val raw: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/model/SettingsModel.kt" <<'EOF'
package com.automation.encryptiontool.domain.model

// TODO: SettingsModel
data class SettingsModel(val key: String = "")
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/repository/EncryptionRepository.kt" <<'EOF'
package com.automation.encryptiontool.domain.repository

# TODO: EncryptionRepository interface
interface EncryptionRepository {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/repository/GithubRepository.kt" <<'EOF'
package com.automation.encryptiontool.domain.repository

// TODO: GithubRepository interface
interface GithubRepository {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/repository/SettingsRepository.kt" <<'EOF'
package com.automation.encryptiontool.domain.repository

// TODO: SettingsRepository interface
interface SettingsRepository {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/security/Encryptor.kt" <<'EOF'
package com.automation.encryptiontool.domain.security

// TODO: Encryptor interface
interface Encryptor {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/usecase/EncryptJsonUseCase.kt" <<'EOF'
package com.automation.encryptiontool.domain.usecase

// TODO: EncryptJsonUseCase
class EncryptJsonUseCase {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/usecase/PushToGithubUseCase.kt" <<'EOF'
package com.automation.encryptiontool.domain.usecase

// TODO: PushToGithubUseCase
class PushToGithubUseCase {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/usecase/ManageTtlExpiryUseCase.kt" <<'EOF'
package com.automation.encryptiontool.domain.usecase

// TODO: ManageTtlExpiryUseCase
class ManageTtlExpiryUseCase {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/domain/usecase/SaveSettingsUseCase.kt" <<'EOF'
package com.automation.encryptiontool.domain.usecase

// TODO: SaveSettingsUseCase
class SaveSettingsUseCase {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/di/SecurityModule.kt" <<'EOF'
package com.automation.encryptiontool.di

// TODO: SecurityModule
object SecurityModule {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/di/NetworkModule.kt" <<'EOF'
package com.automation.encryptiontool.di

// TODO: NetworkModule
object NetworkModule {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/di/DatabaseModule.kt" <<'EOF'
package com.automation.encryptiontool.di

// TODO: DatabaseModule
object DatabaseModule {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/di/RepositoryModule.kt" <<'EOF'
package com.automation.encryptiontool.di

// TODO: RepositoryModule
object RepositoryModule {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/di/WorkerModule.kt" <<'EOF'
package com.automation.encryptiontool.di

// TODO: WorkerModule
object WorkerModule {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/theme/GithubDarkColorPalette.kt" <<'EOF'
package com.automation.encryptiontool.ui.theme

// TODO: GithubDarkColorPalette
object GithubDarkColorPalette {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/theme/Typography.kt" <<'EOF'
package com.automation.encryptiontool.ui.theme

// TODO: Typography
object Typography {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/theme/AppTheme.kt" <<'EOF'
package com.automation.encryptiontool.ui.theme

// TODO: AppTheme
object AppTheme {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/navigation/AppNavigation.kt" <<'EOF'
package com.automation.encryptiontool.ui.navigation

// TODO: AppNavigation
object AppNavigation {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/navigation/Screen.kt" <<'EOF'
package com.automation.encryptiontool.ui.navigation

// TODO: Screen
object Screen {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/MainChatScreen.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat

// TODO: MainChatScreen
object MainChatScreen {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/MainChatViewModel.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat

// TODO: MainChatViewModel
class MainChatViewModel {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/MainChatUiState.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat

// TODO: MainChatUiState
data class MainChatUiState(val placeholder: Boolean = true)
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/ChatLazyColumnFeed.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: ChatLazyColumnFeed
object ChatLazyColumnFeed {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/ChatPairCard.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: ChatPairCard
object ChatPairCard {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/CodeEditorView.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: CodeEditorView
object CodeEditorView {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/ActionIconToolbar.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: ActionIconToolbar
object ActionIconToolbar {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/SecurityInputBar.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: SecurityInputBar
object SecurityInputBar {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/BottomJsonInputArea.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: BottomJsonInputArea
object BottomJsonInputArea {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/LineNumberColumn.kt" <<'EOF'
package com.automation.encryptiontool.ui.main_chat.components

// TODO: LineNumberColumn
object LineNumberColumn {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/SyntaxHighlightText.kt" <<'EOF'
package com.automation.encryptiontool.ui/main_chat.components

// TODO: SyntaxHighlightText
object SyntaxHighlightText {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/settings/SettingsScreen.kt" <<'EOF'
package com.automation.encryptiontool.ui.settings

// TODO: SettingsScreen
object SettingsScreen {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/settings/SettingsViewModel.kt" <<'EOF'
package com.automation.encryptiontool.ui.settings

// TODO: SettingsViewModel
class SettingsViewModel {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/ui/settings/SettingsUiState.kt" <<'EOF'
package com.automation.encryptiontool.ui.settings

// TODO: SettingsUiState
data class SettingsUiState(val placeholder: Boolean = true)
EOF

mkdir -p "$ROOT/app/src/main/java/com/automation/encryptiontool/worker"
cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/worker/TtlAutoDeleteWorker.kt" <<'EOF'
package com.automation.encryptiontool.worker

// TODO: TtlAutoDeleteWorker
class TtlAutoDeleteWorker {
}
EOF

cat > "$ROOT/app/src/main/java/com/automation/encryptiontool/worker/WorkerScheduler.kt" <<'EOF'
package com.automation.encryptiontool.worker

// TODO: WorkerScheduler
object WorkerScheduler {
}
EOF

# Test and androidTest placeholders
cat > "$ROOT/app/src/test/java/com/automation/encryptiontool/domain/.placeholder" <<'EOF'
# placeholder for test directory
EOF

cat > "$ROOT/app/src/test/java/com/automation/encryptiontool/data/.placeholder" <<'EOF'
# placeholder for test directory
EOF

cat > "$ROOT/app/src/test/java/com/automation/encryptiontool/worker/.placeholder" <<'EOF'
# placeholder for test directory
EOF

cat > "$ROOT/app/src/androidTest/java/com/automation/encryptiontool/data/.placeholder" <<'EOF'
# placeholder for androidTest data
EOF

cat > "$ROOT/app/src/androidTest/java/com/automation/encryptiontool/ui/.placeholder" <<'EOF'
# placeholder for androidTest ui
EOF

# create zip
ZIPNAME="EncryptionAutomationTool.zip"
rm -f "$ZIPNAME"
if command -v zip >/dev/null 2>&1; then
  zip -r "$ZIPNAME" "$ROOT" >/dev/null
  echo "Created $ZIPNAME"
else
  echo "zip command not found. The directory '$ROOT' has been created. Install zip and run: zip -r $ZIPNAME $ROOT"
fi

echo "Scaffold finished. Directory created: $ROOT"
