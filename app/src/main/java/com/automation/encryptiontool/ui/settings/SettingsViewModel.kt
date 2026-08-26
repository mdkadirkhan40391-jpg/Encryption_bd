package com.automation.encryptiontool.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.automation.encryptiontool.domain.model.SettingsModel
import com.automation.encryptiontool.domain.repository.SettingsRepository
import com.automation.encryptiontool.domain.usecase.SaveSettingsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    settingsRepository: SettingsRepository,
    private val saveSettingsUseCase: SaveSettingsUseCase
) : ViewModel() {
    val settings: StateFlow<SettingsModel> = settingsRepository.observeSettings()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), SettingsModel())

    fun onSave(settings: SettingsModel) {
        viewModelScope.launch { saveSettingsUseCase(settings) }
    }
}
