package com.automation.encryptiontool.domain.usecase

import com.automation.encryptiontool.domain.model.SettingsModel
import com.automation.encryptiontool.domain.repository.SettingsRepository
import javax.inject.Inject

class SaveSettingsUseCase @Inject constructor(
    private val settingsRepository: SettingsRepository
) {
    suspend operator fun invoke(settings: SettingsModel) {
        settingsRepository.updateSettings(settings)
    }
}
