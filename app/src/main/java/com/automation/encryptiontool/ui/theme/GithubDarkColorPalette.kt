package com.automation.encryptiontool.ui.theme

import androidx.compose.material3.darkColorScheme
import androidx.compose.ui.graphics.Color

val GithubBackground = Color(0xFF0D1117)
val GithubSurface = Color(0xFF161B22)
val GithubBorder = Color(0xFF30363D)
val GithubTextPrimary = Color(0xFFC9D1D9)
val GithubTextSecondary = Color(0xFF8B949E)
val GithubAccentBlue = Color(0xFF58A6FF)
val GithubAccentGreen = Color(0xFF3FB950)
val GithubAccentRed = Color(0xFFF85149)

val GithubDarkColorScheme = darkColorScheme(
    background = GithubBackground,
    surface = GithubSurface,
    primary = GithubAccentBlue,
    secondary = GithubAccentGreen,
    error = GithubAccentRed,
    onBackground = GithubTextPrimary,
    onSurface = GithubTextPrimary,
    outline = GithubBorder
)
