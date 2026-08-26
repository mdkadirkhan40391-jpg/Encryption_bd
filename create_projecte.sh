#!/bin/bash

# create_projecte.sh - Main Chat UI Components

echo "Creating Main Chat UI Components..."

# Create main_chat directory
mkdir -p app/src/main/java/com/automation/encryptiontool/ui/main_chat
mkdir -p app/src/main/java/com/automation/encryptiontool/ui/main_chat/components

# Create main chat viewmodel and state
cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/MainChatUiState.kt << 'EOF'
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
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/MainChatViewModel.kt << 'EOF'
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
EOF

# Create components
cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/CodeEditorView.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.automation.encryptiontool.ui.theme.GithubSurface
import com.automation.encryptiontool.ui.theme.GithubTextPrimary
import com.automation.encryptiontool.ui.theme.GithubTextSecondary

@Composable
fun CodeEditorView(
    text: String,
    modifier: Modifier = Modifier,
    isEditable: Boolean = false,
    onValueChange: (String) -> Unit = {}
) {
    val lines = text.ifEmpty { " " }.split("\n")

    Row(modifier = modifier.background(GithubSurface).padding(8.dp)) {
        Column {
            lines.forEachIndexed { index, _ ->
                Text(
                    text = "${index + 1}",
                    color = GithubTextSecondary,
                    fontFamily = FontFamily.Monospace,
                    fontSize = 13.sp,
                    modifier = Modifier.width(28.dp)
                )
            }
        }
        if (isEditable) {
            BasicTextField(
                value = text,
                onValueChange = onValueChange,
                textStyle = TextStyle(color = GithubTextPrimary, fontFamily = FontFamily.Monospace, fontSize = 13.sp),
                modifier = Modifier.padding(start = 8.dp)
            )
        } else {
            Text(
                text = text,
                color = GithubTextPrimary,
                fontFamily = FontFamily.Monospace,
                fontSize = 13.sp,
                modifier = Modifier.padding(start = 8.dp)
            )
        }
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/ActionIconToolbar.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Message
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Upload
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.automation.encryptiontool.ui.theme.GithubAccentBlue

@Composable
fun ActionIconToolbar(
    onPath: () -> Unit, onCommit: () -> Unit, onPush: () -> Unit,
    onCopy: () -> Unit, onReset: () -> Unit, onDelete: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(modifier = modifier.fillMaxWidth().padding(vertical = 4.dp), horizontalArrangement = Arrangement.SpaceEvenly) {
        IconButton(onClick = onPath) { Icon(Icons.Filled.Folder, "Path", tint = GithubAccentBlue) }
        IconButton(onClick = onCommit) { Icon(Icons.Filled.Message, "Commit", tint = GithubAccentBlue) }
        IconButton(onClick = onPush) { Icon(Icons.Filled.Upload, "Push", tint = GithubAccentBlue) }
        IconButton(onClick = onCopy) { Icon(Icons.Filled.ContentCopy, "Copy", tint = GithubAccentBlue) }
        IconButton(onClick = onReset) { Icon(Icons.Filled.Refresh, "Reset", tint = GithubAccentBlue) }
        IconButton(onClick = onDelete) { Icon(Icons.Filled.Delete, "Delete", tint = GithubAccentBlue) }
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/ChatPairCard.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.unit.dp
import com.automation.encryptiontool.domain.model.ChatPairModel
import com.automation.encryptiontool.ui.main_chat.PushState
import com.automation.encryptiontool.ui.theme.GithubAccentGreen
import com.automation.encryptiontool.ui.theme.GithubAccentRed
import com.automation.encryptiontool.ui.theme.GithubSurface
import com.automation.encryptiontool.ui.theme.GithubTextSecondary

@Composable
fun ChatPairCard(
    chatPair: ChatPairModel,
    pushState: PushState,
    onPath: () -> Unit, onCommit: () -> Unit, onPush: () -> Unit,
    onCopy: () -> Unit, onReset: () -> Unit, onDelete: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth().clip(RoundedCornerShape(8.dp)).background(GithubSurface).padding(8.dp)
    ) {
        Text("Input", color = GithubTextSecondary)
        CodeEditorView(text = chatPair.rawInput)

        Text("Encrypted Output", color = GithubTextSecondary, modifier = Modifier.padding(top = 8.dp))
        CodeEditorView(text = buildOutputPreview(chatPair))

        when (pushState) {
            is PushState.Pushing -> Text("পুশ হচ্ছে...", color = GithubTextSecondary)
            is PushState.Success -> Text("পুশ সফল", color = GithubAccentGreen)
            is PushState.Failed -> Text(pushState.message, color = GithubAccentRed)
            PushState.Idle -> Unit
        }

        ActionIconToolbar(onPath, onCommit, onPush, onCopy, onReset, onDelete)
    }
}

private fun buildOutputPreview(chatPair: ChatPairModel): String {
    val p = chatPair.encryptedOutput
    return "{\n  \"algorithm\": \"${p.algorithm}\",\n  \"salt\": \"${p.salt}\",\n  \"iv\": \"${p.iv}\",\n  \"cipherText\": \"${p.cipherText.take(32)}...\"\n}"
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/ChatLazyColumnFeed.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.ui.Modifier
import com.automation.encryptiontool.domain.model.ChatPairModel
import com.automation.encryptiontool.ui.main_chat.PushState

@Composable
fun ChatLazyColumnFeed(
    chatPairs: List<ChatPairModel>,
    pushStates: Map<String, PushState>,
    onPath: (ChatPairModel) -> Unit, onCommit: (ChatPairModel) -> Unit, onPush: (ChatPairModel) -> Unit,
    onCopy: (ChatPairModel) -> Unit, onReset: (ChatPairModel) -> Unit, onDelete: (ChatPairModel) -> Unit,
    modifier: Modifier = Modifier
) {
    val listState = rememberLazyListState()

    LaunchedEffect(chatPairs.size) {
        if (chatPairs.isNotEmpty()) listState.animateScrollToItem(chatPairs.size - 1)
    }

    LazyColumn(state = listState, modifier = modifier) {
        items(chatPairs, key = { it.id }) { chatPair ->
            ChatPairCard(
                chatPair = chatPair,
                pushState = pushStates[chatPair.id] ?: PushState.Idle,
                onPath = { onPath(chatPair) }, onCommit = { onCommit(chatPair) }, onPush = { onPush(chatPair) },
                onCopy = { onCopy(chatPair) }, onReset = { onReset(chatPair) }, onDelete = { onDelete(chatPair) }
            )
        }
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/SecurityInputBar.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.weight
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.automation.encryptiontool.ui.theme.GithubAccentBlue

@Composable
fun SecurityInputBar(
    securityCode: String, onSecurityCodeChange: (String) -> Unit, onSubmit: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(modifier = modifier.fillMaxWidth().padding(8.dp)) {
        OutlinedTextField(
            value = securityCode, onValueChange = onSecurityCodeChange,
            label = { Text("সিকিউরিটি কোড") },
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.weight(1f)
        )
        IconButton(onClick = onSubmit) { Icon(Icons.Filled.Send, "Submit", tint = GithubAccentBlue) }
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/BottomJsonInputArea.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.automation.encryptiontool.ui.theme.GithubSurface

@Composable
fun BottomJsonInputArea(jsonText: String, onJsonTextChange: (String) -> Unit, modifier: Modifier = Modifier) {
    CodeEditorView(
        text = jsonText, isEditable = true, onValueChange = onJsonTextChange,
        modifier = modifier.fillMaxWidth().heightIn(min = 120.dp).background(GithubSurface)
    )
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/MainChatScreen.kt << 'EOF'
package com.automation.encryptiontool.ui.main_chat

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.weight
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.automation.encryptiontool.ui.main_chat.components.BottomJsonInputArea
import com.automation.encryptiontool.ui.main_chat.components.ChatLazyColumnFeed
import com.automation.encryptiontool.ui.main_chat.components.SecurityInputBar

@Composable
fun MainChatScreen(onOpenSettings: () -> Unit, viewModel: MainChatViewModel = hiltViewModel()) {
    val chatPairs by viewModel.chatPairs.collectAsState()
    val pushStates by viewModel.pushStates.collectAsState()
    var securityCode by remember { mutableStateOf("") }
    var jsonInput by remember { mutableStateOf("") }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Encryption Automation Tool") },
                actions = {
                    IconButton(onClick = onOpenSettings) { Icon(Icons.Filled.Settings, "Settings") }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding)) {
            ChatLazyColumnFeed(
                chatPairs = chatPairs,
                pushStates = pushStates,
                onPath = { /* Path ইনপুট ডায়ালগ — পরের ধাপে যোগ হবে */ },
                onCommit = { /* Commit-মেসেজ ইনপুট ডায়ালগ — পরের ধাপে যোগ হবে */ },
                onPush = { viewModel.onPush(it) },
                onCopy = { /* ClipboardManager দিয়ে কপি — পরের ধাপে যোগ হবে */ },
                onReset = { securityCode = ""; jsonInput = "" },
                onDelete = { viewModel.onDelete(it.id) },
                modifier = Modifier.weight(1f)
            )
            SecurityInputBar(
                securityCode = securityCode,
                onSecurityCodeChange = { securityCode = it },
                onSubmit = { viewModel.onSubmit(jsonInput, securityCode); jsonInput = "" }
            )
            BottomJsonInputArea(jsonText = jsonInput, onJsonTextChange = { jsonInput = it })
        }
    }
}
