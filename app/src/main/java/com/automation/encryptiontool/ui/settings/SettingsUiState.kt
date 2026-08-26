package com.automation.encryptiontool.ui.settings

import com.automation.encryptiontool.domain.model.SettingsModel

data class SettingsUiState(
    val settings: SettingsModel = SettingsModel(),
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
)
