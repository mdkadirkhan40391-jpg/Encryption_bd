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
