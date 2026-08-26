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
