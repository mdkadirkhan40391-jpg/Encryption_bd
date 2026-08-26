#!/bin/bash

# create_projectf.sh - বাকি ফাইলসমূহ (Typography, Screen, LineNumberColumn, SyntaxHighlightText, SecurityModule, WorkerModule + Resources)

echo "Creating remaining files..."

# 1. Typography.kt - আলাদা ফাইল
cat > app/src/main/java/com/automation/encryptiontool/ui/theme/Typography.kt << 'EOF'
package com.automation.encryptiontool.ui.theme

import androidx.compose.material3.Typography
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.unit.sp

val AppTypography = Typography(
    displayLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 57.sp,
        lineHeight = 64.sp,
        letterSpacing = (-0.25).sp
    ),
    displayMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 45.sp,
        lineHeight = 52.sp,
        letterSpacing = 0.sp
    ),
    displaySmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 36.sp,
        lineHeight = 44.sp,
        letterSpacing = 0.sp
    ),
    headlineLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 32.sp,
        lineHeight = 40.sp,
        letterSpacing = 0.sp
    ),
    headlineMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 28.sp,
        lineHeight = 36.sp,
        letterSpacing = 0.sp
    ),
    headlineSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 24.sp,
        lineHeight = 32.sp,
        letterSpacing = 0.sp
    ),
    titleLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 22.sp,
        lineHeight = 28.sp,
        letterSpacing = 0.sp
    ),
    titleMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.15.sp
    ),
    titleSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    ),
    bodyLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 16.sp,
        lineHeight = 24.sp,
        letterSpacing = 0.5.sp
    ),
    bodyMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.25.sp
    ),
    bodySmall = TextStyle(
        fontFamily = FontFamily.Monospace,
        fontSize = 13.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.4.sp
    ),
    labelLarge = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 14.sp,
        lineHeight = 20.sp,
        letterSpacing = 0.1.sp
    ),
    labelMedium = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 12.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    ),
    labelSmall = TextStyle(
        fontFamily = FontFamily.Default,
        fontSize = 11.sp,
        lineHeight = 16.sp,
        letterSpacing = 0.5.sp
    )
)
EOF

# 2. Screen.kt - Navigation Routes
cat > app/src/main/java/com/automation/encryptiontool/ui/navigation/Screen.kt << 'EOF'
package com.automation.encryptiontool.ui.navigation

sealed class Screen(val route: String) {
    data object MainChat : Screen("main_chat")
    data object Settings : Screen("settings")
}

object Routes {
    const val MAIN_CHAT = "main_chat"
    const val SETTINGS = "settings"
}
EOF

# 3. LineNumberColumn.kt - আলাদা কম্পোনেন্ট
cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/LineNumberColumn.kt << 'EOF'
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
EOF

# 4. SyntaxHighlightText.kt - JSON সিনট্যাক্স হাইলাইট (ফেজ-২ পলিশ)
cat > app/src/main/java/com/automation/encryptiontool/ui/main_chat/components/SyntaxHighlightText.kt << 'EOF'
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
EOF

# 5. SecurityModule.kt - আলাদা DI মডিউল
cat > app/src/main/java/com/automation/encryptiontool/di/SecurityModule.kt << 'EOF'
package com.automation.encryptiontool.di

import com.automation.encryptiontool.data.security.Aes256EncryptorImpl
import com.automation.encryptiontool.data.security.KeystoreCipherHelper
import com.automation.encryptiontool.domain.security.Encryptor
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class SecurityModule {

    @Binds
    @Singleton
    abstract fun bindEncryptor(impl: Aes256EncryptorImpl): Encryptor

    companion object {
        @Provides
        @Singleton
        fun provideKeystoreCipherHelper(): KeystoreCipherHelper = KeystoreCipherHelper()
    }
}
EOF

# 6. WorkerModule.kt - Worker DI মডিউল
cat > app/src/main/java/com/automation/encryptiontool/di/WorkerModule.kt << 'EOF'
package com.automation.encryptiontool.di

import android.content.Context
import androidx.work.WorkManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object WorkerModule {

    @Provides
    @Singleton
    fun provideWorkManager(@ApplicationContext context: Context): WorkManager =
        WorkManager.getInstance(context)
}
EOF

# 7. AndroidManifest.xml ফিক্সের জন্য themes.xml
mkdir -p app/src/main/res/values

cat > app/src/main/res/values/themes.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="Theme.EncryptionAutomationTool" parent="android:Theme.Material.Light.NoActionBar" />
</resources>
EOF

# 8. strings.xml - অ্যাপের নাম
cat > app/src/main/res/values/strings.xml << 'EOF'
<resources>
    <string name="app_name">Encryption Automation Tool</string>
</resources>
EOF

# 9. Update AppTheme.kt to use separate Typography
cat > app/src/main/java/com/automation/encryptiontool/ui/theme/AppTheme.kt << 'EOF'
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
EOF

echo "✅ All remaining files created successfully!"
echo ""
echo "📁 Created:"
echo "   1. Typography.kt (আলাদা ফাইল)"
echo "   2. Screen.kt (Navigation Routes)"
echo "   3. LineNumberColumn.kt (আলাদা কম্পোনেন্ট)"
echo "   4. SyntaxHighlightText.kt (JSON সিনট্যাক্স হাইলাইট)"
echo "   5. SecurityModule.kt (আলাদা DI মডিউল)"
echo "   6. WorkerModule.kt (Worker DI মডিউল)"
echo "   7. themes.xml (AndroidManifest-এর থিম)"
echo "   8. strings.xml (অ্যাপের নাম)"
echo "   9. AppTheme.kt (আপডেটেড)"
echo ""
echo "🎉 PART 3 সম্পূর্ণ! সব ফাইল তৈরি হয়ে গেছে।"
