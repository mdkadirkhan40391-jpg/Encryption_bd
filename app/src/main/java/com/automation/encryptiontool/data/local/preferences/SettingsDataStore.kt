package com.automation.encryptiontool.data.local.preferences

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.automation.encryptiontool.data.security.KeystoreCipherHelper
import com.automation.encryptiontool.domain.model.SettingsModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore by preferencesDataStore(name = "settings")

@Singleton
class SettingsDataStore @Inject constructor(
    @ApplicationContext private val context: Context,
    private val keystoreCipherHelper: KeystoreCipherHelper
) {
    private object Keys {
        val GITHUB_PAT_ENCRYPTED = stringPreferencesKey("github_pat_encrypted")
        val GITHUB_EMAIL = stringPreferencesKey("github_email")
        val GITHUB_USERNAME = stringPreferencesKey("github_username")
        val DEFAULT_REPO = stringPreferencesKey("default_repo")
        val DEFAULT_BRANCH = stringPreferencesKey("default_branch")
        val TTL_HOURS = intPreferencesKey("ttl_hours")
        val DEFAULT_SECURITY_CODE = stringPreferencesKey("default_security_code")
    }

    val settingsFlow: Flow<SettingsModel> = context.dataStore.data.map { prefs ->
        SettingsModel(
            githubPat = prefs[Keys.GITHUB_PAT_ENCRYPTED]?.let { keystoreCipherHelper.decrypt(it) },
            githubEmail = prefs[Keys.GITHUB_EMAIL],
            githubUsername = prefs[Keys.GITHUB_USERNAME],
            defaultRepo = prefs[Keys.DEFAULT_REPO],
            defaultBranch = prefs[Keys.DEFAULT_BRANCH] ?: "main",
            ttlHours = prefs[Keys.TTL_HOURS] ?: 24,
            defaultSecurityCode = prefs[Keys.DEFAULT_SECURITY_CODE]
        )
    }

    suspend fun updateSettings(settings: SettingsModel) {
        context.dataStore.edit { prefs ->
            settings.githubPat?.let { prefs[Keys.GITHUB_PAT_ENCRYPTED] = keystoreCipherHelper.encrypt(it) }
            settings.githubEmail?.let { prefs[Keys.GITHUB_EMAIL] = it }
            settings.githubUsername?.let { prefs[Keys.GITHUB_USERNAME] = it }
            settings.defaultRepo?.let { prefs[Keys.DEFAULT_REPO] = it }
            prefs[Keys.DEFAULT_BRANCH] = settings.defaultBranch
            prefs[Keys.TTL_HOURS] = settings.ttlHours
            settings.defaultSecurityCode?.let { prefs[Keys.DEFAULT_SECURITY_CODE] = it }
        }
    }
}
