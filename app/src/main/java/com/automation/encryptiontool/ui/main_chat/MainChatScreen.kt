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
