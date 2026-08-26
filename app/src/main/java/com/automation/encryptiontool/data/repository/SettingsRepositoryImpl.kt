package com.automation.encryptiontool.data.repository

import com.automation.encryptiontool.data.local.preferences.SettingsDataStore
import com.automation.encryptiontool.domain.model.SettingsModel
import com.automation.encryptiontool.domain.repository.SettingsRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class SettingsRepositoryImpl @Inject constructor(
    private val settingsDataStore: SettingsDataStore
) : SettingsRepository {
    override fun observeSettings(): Flow<SettingsModel> = settingsDataStore.settingsFlow
    override suspend fun updateSettings(settings: SettingsModel) = settingsDataStore.updateSettings(settings)
}
