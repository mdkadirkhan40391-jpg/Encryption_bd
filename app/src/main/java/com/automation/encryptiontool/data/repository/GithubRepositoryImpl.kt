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
