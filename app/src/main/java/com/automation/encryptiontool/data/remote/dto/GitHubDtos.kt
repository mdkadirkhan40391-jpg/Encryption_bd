package com.automation.encryptiontool.data.remote.dto

import kotlinx.serialization.Serializable

@Serializable
data class GitHubContentResponse(
    val sha: String,
    val content: String? = null,
    val encoding: String? = null
)

@Serializable
data class CreateOrUpdateFileRequest(
    val message: String,
    val content: String,
    val sha: String? = null,
    val branch: String? = null
)

@Serializable
data class CreateOrUpdateFileResponse(
    val content: GitHubContentInfo? = null
)

@Serializable
data class GitHubContentInfo(
    val sha: String,
    val path: String
)
