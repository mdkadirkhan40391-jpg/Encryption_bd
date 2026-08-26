#!/bin/bash

# create_projectb.sh - Data Layer

echo "Creating Data Layer (Part 2/3 - Data)..."

# Create data directories
mkdir -p app/src/main/java/com/automation/encryptiontool/data/local/db
mkdir -p app/src/main/java/com/automation/encryptiontool/data/local/preferences
mkdir -p app/src/main/java/com/automation/encryptiontool/data/security
mkdir -p app/src/main/java/com/automation/encryptiontool/data/remote
mkdir -p app/src/main/java/com/automation/encryptiontool/data/remote/dto
mkdir -p app/src/main/java/com/automation/encryptiontool/data/repository

# Create database files
cat > app/src/main/java/com/automation/encryptiontool/data/local/db/ChatPairEntity.kt << 'EOF'
package com.automation.encryptiontool.data.local.db

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "chat_pairs")
data class ChatPairEntity(
    @PrimaryKey val id: String,
    val rawInput: String,
    val algorithm: String,
    val keyVersion: Int,
    val salt: String,
    val iv: String,
    val cipherText: String,
    val stagedPath: String?,
    val stagedCommitMessage: String?,
    val createdAt: Long,
    val expiresAt: Long
)
EOF

cat > app/src/main/java/com/automation/encryptiontool/data/local/db/ChatPairDao.kt << 'EOF'
package com.automation.encryptiontool.data.local.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface ChatPairDao {
    @Query("SELECT * FROM chat_pairs WHERE expiresAt > :now ORDER BY createdAt ASC")
    fun observeActiveChatPairs(now: Long): Flow<List<ChatPairEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insert(entity: ChatPairEntity)

    @Query("UPDATE chat_pairs SET stagedPath = :path, stagedCommitMessage = :commitMessage WHERE id = :id")
    suspend fun updateStagedCommit(id: String, path: String, commitMessage: String)

    @Query("DELETE FROM chat_pairs WHERE id = :id")
    suspend fun deleteById(id: String)

    @Query("DELETE FROM chat_pairs WHERE expiresAt <= :now")
    suspend fun deleteExpired(now: Long)
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/data/local/db/AppDatabase.kt << 'EOF'
package com.automation.encryptiontool.data.local.db

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [ChatPairEntity::class], version = 1, exportSchema = true)
abstract class AppDatabase : RoomDatabase() {
    abstract fun chatPairDao(): ChatPairDao
}
EOF

# Create security implementations
cat > app/src/main/java/com/automation/encryptiontool/data/security/KeystoreCipherHelper.kt << 'EOF'
package com.automation.encryptiontool.data.security

import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Base64
import java.security.KeyStore
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.GCMParameterSpec
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class KeystoreCipherHelper @Inject constructor() {
    private val keyStore = KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }

    private fun getOrCreateSecretKey(): SecretKey {
        (keyStore.getKey(KEY_ALIAS, null) as? SecretKey)?.let { return it }
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        val spec = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .build()
        keyGenerator.init(spec)
        return keyGenerator.generateKey()
    }

    fun encrypt(plainText: String): String {
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, getOrCreateSecretKey())
        val cipherBytes = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        val combined = cipher.iv + cipherBytes
        return Base64.encodeToString(combined, Base64.NO_WRAP)
    }

    fun decrypt(encoded: String): String {
        val combined = Base64.decode(encoded, Base64.NO_WRAP)
        val iv = combined.copyOfRange(0, IV_SIZE_BYTES)
        val cipherBytes = combined.copyOfRange(IV_SIZE_BYTES, combined.size)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, getOrCreateSecretKey(), GCMParameterSpec(TAG_LENGTH_BITS, iv))
        return String(cipher.doFinal(cipherBytes), Charsets.UTF_8)
    }

    companion object {
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val KEY_ALIAS = "encryption_tool_pat_key"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val IV_SIZE_BYTES = 12
        private const val TAG_LENGTH_BITS = 128
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/data/security/Aes256EncryptorImpl.kt << 'EOF'
package com.automation.encryptiontool.data.security

import android.util.Base64
import com.automation.encryptiontool.domain.model.EncryptedPayload
import com.automation.encryptiontool.domain.security.Encryptor
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec
import javax.inject.Inject

class Aes256EncryptorImpl @Inject constructor() : Encryptor {
    override fun encrypt(plainText: String, securityCode: String, keyVersion: Int): EncryptedPayload {
        val salt = ByteArray(SALT_SIZE_BYTES).also { SecureRandom().nextBytes(it) }
        val secretKey = deriveKey(securityCode, salt)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        val iv = cipher.iv
        val cipherBytes = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        return EncryptedPayload(
            version = 1,
            algorithm = "AES-256-GCM",
            keyVersion = keyVersion,
            salt = Base64.encodeToString(salt, Base64.NO_WRAP),
            iv = Base64.encodeToString(iv, Base64.NO_WRAP),
            cipherText = Base64.encodeToString(cipherBytes, Base64.NO_WRAP)
        )
    }

    override fun decrypt(payload: EncryptedPayload, securityCode: String): String {
        val salt = Base64.decode(payload.salt, Base64.NO_WRAP)
        val iv = Base64.decode(payload.iv, Base64.NO_WRAP)
        val cipherBytes = Base64.decode(payload.cipherText, Base64.NO_WRAP)
        val secretKey = deriveKey(securityCode, salt)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(TAG_LENGTH_BITS, iv))
        return String(cipher.doFinal(cipherBytes), Charsets.UTF_8)
    }

    private fun deriveKey(securityCode: String, salt: ByteArray): SecretKey {
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        val spec = PBEKeySpec(securityCode.toCharArray(), salt, PBKDF2_ITERATIONS, KEY_SIZE_BITS)
        val keyBytes = factory.generateSecret(spec).encoded
        return SecretKeySpec(keyBytes, "AES")
    }

    companion object {
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val SALT_SIZE_BYTES = 16
        private const val KEY_SIZE_BITS = 256
        private const val TAG_LENGTH_BITS = 128
        private const val PBKDF2_ITERATIONS = 210_000
    }
}
EOF

# Create preferences
cat > app/src/main/java/com/automation/encryptiontool/data/local/preferences/SettingsDataStore.kt << 'EOF'
package com.automation.encryptiontool.data.local.preferences

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.automation.encryptiontool.data.security.KeystoreCipherHelper
import com.automation.encryptiontool.domain.model.SettingsModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore by preferencesDataStore(name = "settings")

@Singleton
class SettingsDataStore @Inject constructor(
    @ApplicationContext private val context: Context,
    private val keystoreCipherHelper: KeystoreCipherHelper
) {
    private object Keys {
        val GITHUB_PAT_ENCRYPTED = stringPreferencesKey("github_pat_encrypted")
        val GITHUB_EMAIL = stringPreferencesKey("github_email")
        val GITHUB_USERNAME = stringPreferencesKey("github_username")
        val DEFAULT_REPO = stringPreferencesKey("default_repo")
        val DEFAULT_BRANCH = stringPreferencesKey("default_branch")
        val TTL_HOURS = intPreferencesKey("ttl_hours")
        val DEFAULT_SECURITY_CODE = stringPreferencesKey("default_security_code")
    }

    val settingsFlow: Flow<SettingsModel> = context.dataStore.data.map { prefs ->
        SettingsModel(
            githubPat = prefs[Keys.GITHUB_PAT_ENCRYPTED]?.let { keystoreCipherHelper.decrypt(it) },
            githubEmail = prefs[Keys.GITHUB_EMAIL],
            githubUsername = prefs[Keys.GITHUB_USERNAME],
            defaultRepo = prefs[Keys.DEFAULT_REPO],
            defaultBranch = prefs[Keys.DEFAULT_BRANCH] ?: "main",
            ttlHours = prefs[Keys.TTL_HOURS] ?: 24,
            defaultSecurityCode = prefs[Keys.DEFAULT_SECURITY_CODE]
        )
    }

    suspend fun updateSettings(settings: SettingsModel) {
        context.dataStore.edit { prefs ->
            settings.githubPat?.let { prefs[Keys.GITHUB_PAT_ENCRYPTED] = keystoreCipherHelper.encrypt(it) }
            settings.githubEmail?.let { prefs[Keys.GITHUB_EMAIL] = it }
            settings.githubUsername?.let { prefs[Keys.GITHUB_USERNAME] = it }
            settings.defaultRepo?.let { prefs[Keys.DEFAULT_REPO] = it }
            prefs[Keys.DEFAULT_BRANCH] = settings.defaultBranch
            prefs[Keys.TTL_HOURS] = settings.ttlHours
            settings.defaultSecurityCode?.let { prefs[Keys.DEFAULT_SECURITY_CODE] = it }
        }
    }
}
EOF

# Create API service and DTOs
cat > app/src/main/java/com/automation/encryptiontool/data/remote/GitHubApiService.kt << 'EOF'
package com.automation.encryptiontool.data.remote

import com.automation.encryptiontool.data.remote.dto.CreateOrUpdateFileRequest
import com.automation.encryptiontool.data.remote.dto.CreateOrUpdateFileResponse
import com.automation.encryptiontool.data.remote.dto.GitHubContentResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query

interface GitHubApiService {
    @GET("repos/{owner}/{repo}/contents/{path}")
    suspend fun getFileContent(
        @Header("Authorization") authorization: String,
        @Path("owner") owner: String,
        @Path("repo") repo: String,
        @Path(value = "path", encoded = true) path: String,
        @Query("ref") branch: String
    ): Response<GitHubContentResponse>

    @PUT("repos/{owner}/{repo}/contents/{path}")
    suspend fun createOrUpdateFile(
        @Header("Authorization") authorization: String,
        @Path("owner") owner: String,
        @Path("repo") repo: String,
        @Path(value = "path", encoded = true) path: String,
        @Body request: CreateOrUpdateFileRequest
    ): Response<CreateOrUpdateFileResponse>

    companion object {
        const val BASE_URL = "https://api.github.com/"
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/data/remote/dto/GitHubDtos.kt << 'EOF'
package com.automation.encryptiontool.data.remote.dto

import kotlinx.serialization.Serializable

@Serializable
data class GitHubContentResponse(
    val sha: String,
    val content: String? = null,
    val encoding: String? = null
)

@Serializable
data class CreateOrUpdateFileRequest(
    val message: String,
    val content: String,
    val sha: String? = null,
    val branch: String? = null
)

@Serializable
data class CreateOrUpdateFileResponse(
    val content: GitHubContentInfo? = null
)

@Serializable
data class GitHubContentInfo(
    val sha: String,
    val path: String
)
EOF

# Create repository implementations
cat > app/src/main/java/com/automation/encryptiontool/data/repository/ChatPairRepositoryImpl.kt << 'EOF'
package com.automation.encryptiontool.data.repository

import com.automation.encryptiontool.data.local.db.ChatPairDao
import com.automation.encryptiontool.data.local.db.ChatPairEntity
import com.automation.encryptiontool.domain.model.ChatPairModel
import com.automation.encryptiontool.domain.model.EncryptedPayload
import com.automation.encryptiontool.domain.repository.ChatPairRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

class ChatPairRepositoryImpl @Inject constructor(
    private val dao: ChatPairDao
) : ChatPairRepository {
    override fun observeChatPairs(): Flow<List<ChatPairModel>> =
        dao.observeActiveChatPairs(System.currentTimeMillis()).map { list -> list.map { it.toDomainModel() } }

    override suspend fun saveChatPair(chatPair: ChatPairModel) = dao.insert(chatPair.toEntity())
    override suspend fun updateStagedCommit(id: String, path: String, commitMessage: String) =
        dao.updateStagedCommit(id, path, commitMessage)
    override suspend fun deleteChatPair(id: String) = dao.deleteById(id)
    override suspend fun deleteExpiredChatPairs(now: Long) = dao.deleteExpired(now)
}

private fun ChatPairEntity.toDomainModel() = ChatPairModel(
    id = id,
    rawInput = rawInput,
    encryptedOutput = EncryptedPayload(1, algorithm, keyVersion, salt, iv, cipherText),
    createdAt = createdAt,
    expiresAt = expiresAt,
    stagedPath = stagedPath,
    stagedCommitMessage = stagedCommitMessage
)

private fun ChatPairModel.toEntity() = ChatPairEntity(
    id = id,
    rawInput = rawInput,
    algorithm = encryptedOutput.algorithm,
    keyVersion = encryptedOutput.keyVersion,
    salt = encryptedOutput.salt,
    iv = encryptedOutput.iv,
    cipherText = encryptedOutput.cipherText,
    stagedPath = stagedPath,
    stagedCommitMessage = stagedCommitMessage,
    createdAt = createdAt,
    expiresAt = expiresAt
)
EOF

cat > app/src/main/java/com/automation/encryptiontool/data/repository/GithubRepositoryImpl.kt << 'EOF'
package com.automation.encryptiontool.data.repository

import com.automation.encryptiontool.data.local.preferences.SettingsDataStore
import com.automation.encryptiontool.data.remote.GitHubApiService
import com.automation.encryptiontool.data.remote.dto.CreateOrUpdateFileRequest
import com.automation.encryptiontool.domain.repository.GithubRepository
import kotlinx.coroutines.flow.first
import javax.inject.Inject

class GithubRepositoryImpl @Inject constructor(
    private val apiService: GitHubApiService,
    private val settingsDataStore: SettingsDataStore
) : GithubRepository {
    override suspend fun pushFile(
        path: String,
        commitMessage: String,
        base64Content: String,
        branch: String
    ): Result<Unit> = runCatching {
        val settings = settingsDataStore.settingsFlow.first()
        val pat = requireNotNull(settings.githubPat) { "GitHub PAT configured নেই" }
        val owner = requireNotNull(settings.githubUsername) { "GitHub username configured নেই" }
        val repo = requireNotNull(settings.defaultRepo) { "Default repo configured নেই" }
        val authHeader = "Bearer $pat"

        val existingSha = runCatching {
            apiService.getFileContent(authHeader, owner, repo, path, branch).body()?.sha
        }.getOrNull()

        val response = apiService.createOrUpdateFile(
            authorization = authHeader,
            owner = owner,
            repo = repo,
            path = path,
            request = CreateOrUpdateFileRequest(
                message = commitMessage,
                content = base64Content,
                sha = existingSha,
                branch = branch
            )
        )
        check(response.isSuccessful) { "GitHub push failed: ${response.code()} ${response.message()}" }
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/data/repository/SettingsRepositoryImpl.kt << 'EOF'
package com.automation.encryptiontool.data.repository

import com.automation.encryptiontool.data.local.preferences.SettingsDataStore
import com.automation.encryptiontool.domain.model.SettingsModel
import com.automation.encryptiontool.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class SettingsRepositoryImpl @Inject constructor(
    private val settingsDataStore: SettingsDataStore
) : SettingsRepository {
    override fun observeSettings(): Flow<SettingsModel> = settingsDataStore.settingsFlow
    override suspend fun updateSettings(settings: SettingsModel) = settingsDataStore.updateSettings(settings)
}
EOF

echo "✅ Data Layer created successfully!"
echo "📁 Created: 3 database files, 2 security, 1 preferences, 1 API service, 1 DTO, 3 repositories"
