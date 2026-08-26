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
