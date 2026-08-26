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
