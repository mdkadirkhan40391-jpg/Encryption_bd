package com.automation.encryptiontool.domain.repository

interface GithubRepository {
    suspend fun pushFile(
        path: String,
        commitMessage: String,
        base64Content: String,
        branch: String
    ): Result<Unit>
}
