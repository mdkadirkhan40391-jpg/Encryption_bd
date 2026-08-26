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
