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
