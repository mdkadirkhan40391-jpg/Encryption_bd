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
