package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.width
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.automation.encryptiontool.ui.theme.GithubTextSecondary

@Composable
fun LineNumberColumn(
    lineCount: Int,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier.width(28.dp)) {
        repeat(lineCount) { index ->
            Text(
                text = "${index + 1}",
                color = GithubTextSecondary,
                fontFamily = FontFamily.Monospace,
                fontSize = 13.sp
            )
        }
    }
}
