package com.automation.encryptiontool.ui.main_chat

import com.automation.encryptiontool.domain.model.ChatPairModel

data class MainChatUiState(
    val chatPairs: List<ChatPairModel> = emptyList(),
    val isLoading: Boolean = false,
    val securityCode: String = "",
    val jsonInput: String = "",
    val pushStates: Map<String, PushState> = emptyMap()
)

sealed interface PushState {
    data object Idle : PushState
    data object Pushing : PushState
    data object Success : PushState
    data class Failed(val message: String) : PushState
}
