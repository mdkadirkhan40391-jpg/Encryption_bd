package com.automation.encryptiontool.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable

@Composable
fun EncryptionToolTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = GithubDarkColorScheme,
        typography = AppTypography,
        content = content
    )
}
