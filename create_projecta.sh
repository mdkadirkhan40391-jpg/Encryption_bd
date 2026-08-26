#!/bin/bash

# create_projecta.sh - Domain Layer (Pure Kotlin, কোনো Android/JCE ইমপোর্ট নেই)

echo "Creating Domain Layer (Part 2/3 - Domain)..."

# Create domain directories
mkdir -p app/src/main/java/com/automation/encryptiontool/domain/model
mkdir -p app/src/main/java/com/automation/encryptiontool/domain/security
mkdir -p app/src/main/java/com/automation/encryptiontool/domain/repository
mkdir -p app/src/main/java/com/automation/encryptiontool/domain/usecase

# Create domain model files
cat > app/src/main/java/com/automation/encryptiontool/domain/model/ChatPairModel.kt << 'EOF'
package com.automation.encryptiontool.domain.model

data class ChatPairModel(
    val id: String,
    val rawInput: String,
    val encryptedOutput: EncryptedPayload,
    val createdAt: Long,
    val expiresAt: Long,
    val stagedPath: String? = null,
    val stagedCommitMessage: String? = null
)

data class EncryptedPayload(
    val version: Int,
    val algorithm: String,
    val keyVersion: Int,
    val salt: String,
    val iv: String,
    val cipherText: String
)
EOF

cat > app/src/main/java/com/automation/encryptiontool/domain/model/SettingsModel.kt << 'EOF'
package com.automation.encryptiontool.domain.model

data class SettingsModel(
    val githubPat: String? = null,
    val githubEmail: String? = null,
    val githubUsername: String? = null,
    val defaultRepo: String? = null,
    val defaultBranch: String = "main",
    val ttlHours: Int = 24,
    val defaultSecurityCode: String? = null
)
EOF

# Create domain security interface
cat > app/src/main/java/com/automation/encryptiontool/domain/security/Encryptor.kt << 'EOF'
package com.automation.encryptiontool.domain.security

import com.automation.encryptiontool.domain.model.EncryptedPayload

interface Encryptor {
    fun encrypt(plainText: String, securityCode: String, keyVersion: Int = 1): EncryptedPayload
    fun decrypt(payload: EncryptedPayload, securityCode: String): String
}
EOF

# Create domain repository interfaces
cat > app/src/main/java/com/automation/encryptiontool/domain/repository/ChatPairRepository.kt << 'EOF'
package com.automation.encryptiontool.domain.repository

import com.automation.encryptiontool.domain.model.ChatPairModel
import kotlinx.coroutines.flow.Flow

interface ChatPairRepository {
    fun observeChatPairs(): Flow<List<ChatPairModel>>
    suspend fun saveChatPair(chatPair: ChatPairModel)
    suspend fun updateStagedCommit(id: String, path: String, commitMessage: String)
    suspend fun deleteChatPair(id: String)
    suspend fun deleteExpiredChatPairs(now: Long)
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/domain/repository/GithubRepository.kt << 'EOF'
package com.automation.encryptiontool.domain.repository

interface GithubRepository {
    suspend fun pushFile(
        path: String,
        commitMessage: String,
        base64Content: String,
        branch: String
    ): Result<Unit>
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/domain/repository/SettingsRepository.kt << 'EOF'
package com.automation.encryptiontool.domain.repository

import com.automation.encryptiontool.domain.model.SettingsModel
import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    fun observeSettings(): Flow<SettingsModel>
    suspend fun updateSettings(settings: SettingsModel)
}
EOF

# Create domain use cases
cat > app/src/main/java/com/automation/encryptiontool/domain/usecase/EncryptJsonUseCase.kt << 'EOF'
package com.automation.encryptiontool.domain.usecase

import com.automation.encryptiontool.domain.model.ChatPairModel
import com.automation.encryptiontool.domain.repository.ChatPairRepository
import com.automation.encryptiontool.domain.repository.SettingsRepository
import com.automation.encryptiontool.domain.security.Encryptor
import kotlinx.coroutines.flow.first
import java.util.UUID
import javax.inject.Inject

class EncryptJsonUseCase @Inject constructor(
    private val encryptor: Encryptor,
    private val chatPairRepository: ChatPairRepository,
    private val settingsRepository: SettingsRepository
) {
    suspend operator fun invoke(rawJson: String, securityCode: String, keyVersion: Int = 1): ChatPairModel {
        val payload = encryptor.encrypt(rawJson, securityCode, keyVersion)
        val ttlHours = settingsRepository.observeSettings().first().ttlHours
        val now = System.currentTimeMillis()

        val chatPair = ChatPairModel(
            id = UUID.randomUUID().toString(),
            rawInput = rawJson,
            encryptedOutput = payload,
            createdAt = now,
            expiresAt = now + ttlHours * 60L * 60L * 1000L
        )
        chatPairRepository.saveChatPair(chatPair)
        return chatPair
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/domain/usecase/PushToGithubUseCase.kt << 'EOF'
package com.automation.encryptiontool.domain.usecase

import com.automation.encryptiontool.domain.repository.ChatPairRepository
import com.automation.encryptiontool.domain.repository.GithubRepository
import javax.inject.Inject

class PushToGithubUseCase @Inject constructor(
    private val githubRepository: GithubRepository,
    private val chatPairRepository: ChatPairRepository
) {
    suspend fun stageCommit(chatPairId: String, path: String, commitMessage: String) {
        chatPairRepository.updateStagedCommit(chatPairId, path, commitMessage)
    }

    suspend fun push(path: String, commitMessage: String, base64Content: String, branch: String): Result<Unit> {
        return githubRepository.pushFile(path, commitMessage, base64Content, branch)
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/domain/usecase/ManageTtlExpiryUseCase.kt << 'EOF'
package com.automation.encryptiontool.domain.usecase

import com.automation.encryptiontool.domain.repository.ChatPairRepository
import javax.inject.Inject

class ManageTtlExpiryUseCase @Inject constructor(
    private val chatPairRepository: ChatPairRepository
) {
    suspend operator fun invoke() {
        chatPairRepository.deleteExpiredChatPairs(System.currentTimeMillis())
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/domain/usecase/SaveSettingsUseCase.kt << 'EOF'
package com.automation.encryptiontool.domain.usecase

import com.automation.encryptiontool.domain.model.SettingsModel
import com.automation.encryptiontool.domain.repository.SettingsRepository
import javax.inject.Inject

class SaveSettingsUseCase @Inject constructor(
    private val settingsRepository: SettingsRepository
) {
    suspend operator fun invoke(settings: SettingsModel) {
        settingsRepository.updateSettings(settings)
    }
}
EOF

echo "✅ Domain Layer created successfully!"
echo "📁 Created: 2 models, 1 security interface, 3 repositories, 4 use cases"
