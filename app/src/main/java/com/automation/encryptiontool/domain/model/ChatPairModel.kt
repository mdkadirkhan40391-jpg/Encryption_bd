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
