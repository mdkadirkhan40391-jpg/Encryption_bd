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
