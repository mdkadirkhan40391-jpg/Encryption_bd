package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.sp
import com.automation.encryptiontool.ui.theme.GithubAccentBlue
import com.automation.encryptiontool.ui.theme.GithubAccentGreen
import com.automation.encryptiontool.ui.theme.GithubAccentRed
import com.automation.encryptiontool.ui.theme.GithubTextPrimary
import com.automation.encryptiontool.ui.theme.GithubTextSecondary

@Composable
fun SyntaxHighlightText(
    text: String,
    modifier: Modifier = Modifier,
    isJson: Boolean = true
) {
    if (!isJson) {
        BasicText(
            text = text,
            modifier = modifier,
            style = androidx.compose.ui.text.TextStyle(
                color = GithubTextPrimary,
                fontFamily = FontFamily.Monospace,
                fontSize = 13.sp
            )
        )
        return
    }

    val annotatedString = buildAnnotatedString {
        var insideString = false
        var insideKey = false
        var i = 0

        while (i < text.length) {
            val char = text[i]

            when {
                char == '"' && (i == 0 || text[i - 1] != '\\') -> {
                    if (!insideString) {
                        // Check if this is a key (followed by ':')
                        val nextNonSpace = text.drop(i + 1).dropWhile { it.isWhitespace() }.firstOrNull()
                        insideKey = nextNonSpace == ':'
                    }
                    insideString = !insideString
                    withStyle(style = SpanStyle(color = GithubAccentGreen)) {
                        append(char)
                    }
                    i++
                }
                insideString -> {
                    withStyle(style = SpanStyle(color = GithubAccentGreen)) {
                        append(char)
                    }
                    i++
                }
                char == '{' || char == '}' || char == '[' || char == ']' -> {
                    withStyle(style = SpanStyle(color = GithubAccentBlue)) {
                        append(char)
                    }
                    i++
                }
                char == ':' -> {
                    withStyle(style = SpanStyle(color = GithubTextSecondary)) {
                        append(char)
                    }
                    i++
                }
                char == ',' -> {
                    withStyle(style = SpanStyle(color = GithubTextSecondary)) {
                        append(char)
                    }
                    i++
                }
                char.isDigit() || char == '-' || char == '.' -> {
                    // Numbers
                    val start = i
                    while (i < text.length && (text[i].isDigit() || text[i] == '.' || text[i] == '-' || text[i] == 'e' || text[i] == 'E')) {
                        i++
                    }
                    withStyle(style = SpanStyle(color = GithubAccentRed)) {
                        append(text.substring(start, i))
                    }
                }
                char == 't' && text.startsWith("true", i) -> {
                    withStyle(style = SpanStyle(color = GithubAccentBlue)) {
                        append("true")
                    }
                    i += 4
                }
                char == 'f' && text.startsWith("false", i) -> {
                    withStyle(style = SpanStyle(color = GithubAccentBlue)) {
                        append("false")
                    }
                    i += 5
                }
                char == 'n' && text.startsWith("null", i) -> {
                    withStyle(style = SpanStyle(color = GithubAccentBlue)) {
                        append("null")
                    }
                    i += 4
                }
                char.isWhitespace() -> {
                    append(char)
                    i++
                }
                else -> {
                    withStyle(style = SpanStyle(color = GithubTextPrimary)) {
                        append(char)
                    }
                    i++
                }
            }
        }
    }

    BasicText(
        text = annotatedString,
        modifier = modifier,
        style = androidx.compose.ui.text.TextStyle(
            fontFamily = FontFamily.Monospace,
            fontSize = 13.sp
        )
    )
}
