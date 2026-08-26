package com.automation.encryptiontool.domain.repository

import com.automation.encryptiontool.domain.model.SettingsModel
import kotlinx.coroutines.flow.Flow

interface SettingsRepository {
    fun observeSettings(): Flow<SettingsModel>
    suspend fun updateSettings(settings: SettingsModel)
}
