package com.automation.encryptiontool.ui.main_chat

import android.util.Base64
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.automation.encryptiontool.domain.model.ChatPairModel
import com.automation.encryptiontool.domain.repository.ChatPairRepository
import com.automation.encryptiontool.domain.repository.SettingsRepository
import com.automation.encryptiontool.domain.usecase.EncryptJsonUseCase
import com.automation.encryptiontool.domain.usecase.PushToGithubUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainChatViewModel @Inject constructor(
    private val chatPairRepository: ChatPairRepository,
    private val encryptJsonUseCase: EncryptJsonUseCase,
    private val pushToGithubUseCase: PushToGithubUseCase,
    settingsRepository: SettingsRepository
) : ViewModel() {

    val chatPairs: StateFlow<List<ChatPairModel>> = chatPairRepository.observeChatPairs()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val defaultBranch: StateFlow<String> = settingsRepository.observeSettings()
        .map { it.defaultBranch }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), "main")

    private val _pushStates = MutableStateFlow<Map<String, PushState>>(emptyMap())
    val pushStates: StateFlow<Map<String, PushState>> = _pushStates

    fun onSubmit(rawJson: String, securityCode: String) {
        if (rawJson.isBlank() || securityCode.isBlank()) return
        viewModelScope.launch { encryptJsonUseCase(rawJson, securityCode) }
    }

    fun onStageCommit(chatPairId: String, path: String, commitMessage: String) {
        viewModelScope.launch { pushToGithubUseCase.stageCommit(chatPairId, path, commitMessage) }
    }

    fun onPush(chatPair: ChatPairModel) {
        val path = chatPair.stagedPath
        val message = chatPair.stagedCommitMessage
        if (path.isNullOrBlank() || message.isNullOrBlank()) {
            _pushStates.value += (chatPair.id to PushState.Failed("আগে Path আর Commit মেসেজ দিন"))
            return
        }
        viewModelScope.launch {
            _pushStates.value += (chatPair.id to PushState.Pushing)
            val base64Content = Base64.encodeToString(buildOutputJson(chatPair).toByteArray(), Base64.NO_WRAP)
            val result = pushToGithubUseCase.push(path, message, base64Content, defaultBranch.value)
            _pushStates.value += (chatPair.id to result.fold(
                onSuccess = { PushState.Success },
                onFailure = { PushState.Failed(it.message ?: "Push ব্যর্থ হয়েছে") }
            ))
        }
    }

    fun onDelete(chatPairId: String) {
        viewModelScope.launch { chatPairRepository.deleteChatPair(chatPairId) }
    }

    private fun buildOutputJson(chatPair: ChatPairModel): String {
        val p = chatPair.encryptedOutput
        return """{"version":${p.version},"algorithm":"${p.algorithm}","keyVersion":${p.keyVersion},"salt":"${p.salt}","iv":"${p.iv}","cipherText":"${p.cipherText}"}"""
    }
}
