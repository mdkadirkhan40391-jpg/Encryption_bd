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
