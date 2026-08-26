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
