package com.automation.encryptiontool.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.runtime.Composable
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.sp

val AppTypography = Typography(
    bodyMedium = TextStyle(fontFamily = FontFamily.Default, fontSize = 14.sp),
    bodySmall = TextStyle(fontFamily = FontFamily.Monospace, fontSize = 13.sp)
)

@Composable
fun EncryptionToolTheme(content: @Composable () -> Unit) {
    MaterialTheme(colorScheme = GithubDarkColorScheme, typography = AppTypography, content = content)
}
