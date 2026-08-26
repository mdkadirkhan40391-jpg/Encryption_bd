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
