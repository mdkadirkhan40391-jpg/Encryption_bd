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
