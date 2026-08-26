package com.automation.encryptiontool.domain.model

data class SettingsModel(
    val githubPat: String? = null,
    val githubEmail: String? = null,
    val githubUsername: String? = null,
    val defaultRepo: String? = null,
    val defaultBranch: String = "main",
    val ttlHours: Int = 24,
    val defaultSecurityCode: String? = null
)
