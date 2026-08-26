#!/bin/bash

# create_projectd.sh - Theme, Navigation, Settings

echo "Creating Theme, Navigation, and Settings files..."

# Create theme directory
mkdir -p app/src/main/java/com/automation/encryptiontool/ui/theme

cat > app/src/main/java/com/automation/encryptiontool/ui/theme/GithubDarkColorPalette.kt << 'EOF'
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
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/theme/AppTheme.kt << 'EOF'
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
EOF

# Create navigation directory
mkdir -p app/src/main/java/com/automation/encryptiontool/ui/navigation

cat > app/src/main/java/com/automation/encryptiontool/ui/navigation/AppNavHost.kt << 'EOF'
package com.automation.encryptiontool.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.automation.encryptiontool.ui.main_chat.MainChatScreen
import com.automation.encryptiontool.ui.settings.SettingsScreen

object Routes {
    const val MAIN_CHAT = "main_chat"
    const val SETTINGS = "settings"
}

@Composable
fun AppNavHost(navController: NavHostController = rememberNavController()) {
    NavHost(navController = navController, startDestination = Routes.MAIN_CHAT) {
        composable(Routes.MAIN_CHAT) {
            MainChatScreen(onOpenSettings = { navController.navigate(Routes.SETTINGS) })
        }
        composable(Routes.SETTINGS) {
            SettingsScreen(onBack = { navController.popBackStack() })
        }
    }
}
EOF

# Create settings files
mkdir -p app/src/main/java/com/automation/encryptiontool/ui/settings

cat > app/src/main/java/com/automation/encryptiontool/ui/settings/SettingsUiState.kt << 'EOF'
package com.automation.encryptiontool.ui.settings

import com.automation.encryptiontool.domain.model.SettingsModel

data class SettingsUiState(
    val settings: SettingsModel = SettingsModel(),
    val isLoading: Boolean = false,
    val isSaved: Boolean = false,
    val errorMessage: String? = null
)
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/settings/SettingsViewModel.kt << 'EOF'
package com.automation.encryptiontool.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.automation.encryptiontool.domain.model.SettingsModel
import com.automation.encryptiontool.domain.repository.SettingsRepository
import com.automation.encryptiontool.domain.usecase.SaveSettingsUseCase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class SettingsViewModel @Inject constructor(
    settingsRepository: SettingsRepository,
    private val saveSettingsUseCase: SaveSettingsUseCase
) : ViewModel() {
    val settings: StateFlow<SettingsModel> = settingsRepository.observeSettings()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), SettingsModel())

    fun onSave(settings: SettingsModel) {
        viewModelScope.launch { saveSettingsUseCase(settings) }
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/ui/settings/SettingsScreen.kt << 'EOF'
package com.automation.encryptiontool.ui.settings

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.automation.encryptiontool.domain.model.SettingsModel

@Composable
fun SettingsScreen(onBack: () -> Unit, viewModel: SettingsViewModel = hiltViewModel()) {
    val settings by viewModel.settings.collectAsState()
    var pat by remember(settings) { mutableStateOf(settings.githubPat ?: "") }
    var email by remember(settings) { mutableStateOf(settings.githubEmail ?: "") }
    var username by remember(settings) { mutableStateOf(settings.githubUsername ?: "") }
    var repo by remember(settings) { mutableStateOf(settings.defaultRepo ?: "") }
    var branch by remember(settings) { mutableStateOf(settings.defaultBranch) }
    var ttlHours by remember(settings) { mutableStateOf(settings.ttlHours) }
    var defaultCode by remember(settings) { mutableStateOf(settings.defaultSecurityCode ?: "") }
    var ttlMenuExpanded by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("সেটিংস") },
                navigationIcon = { IconButton(onClick = onBack) { Icon(Icons.Filled.ArrowBack, "Back") } }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.fillMaxSize().padding(padding).padding(16.dp)) {
            OutlinedTextField(pat, { pat = it }, label = { Text("GitHub PAT") }, modifier = Modifier.padding(bottom = 8.dp))
            OutlinedTextField(email, { email = it }, label = { Text("Email") }, modifier = Modifier.padding(bottom = 8.dp))
            OutlinedTextField(username, { username = it }, label = { Text("Username") }, modifier = Modifier.padding(bottom = 8.dp))
            OutlinedTextField(repo, { repo = it }, label = { Text("Default Repository") }, modifier = Modifier.padding(bottom = 8.dp))
            OutlinedTextField(branch, { branch = it }, label = { Text("Branch") }, modifier = Modifier.padding(bottom = 8.dp))

            TextButton(onClick = { ttlMenuExpanded = true }) { Text("TTL: $ttlHours ঘণ্টা") }
            DropdownMenu(expanded = ttlMenuExpanded, onDismissRequest = { ttlMenuExpanded = false }) {
                DropdownMenuItem(text = { Text("24 ঘণ্টা") }, onClick = { ttlHours = 24; ttlMenuExpanded = false })
                DropdownMenuItem(text = { Text("48 ঘণ্টা") }, onClick = { ttlHours = 48; ttlMenuExpanded = false })
            }

            OutlinedTextField(defaultCode, { defaultCode = it }, label = { Text("ডিফল্ট সিকিউরিটি কোড") }, modifier = Modifier.padding(vertical = 8.dp))

            Button(onClick = {
                viewModel.onSave(SettingsModel(
                    githubPat = pat.ifBlank { null }, githubEmail = email.ifBlank { null },
                    githubUsername = username.ifBlank { null }, defaultRepo = repo.ifBlank { null },
                    defaultBranch = branch, ttlHours = ttlHours, defaultSecurityCode = defaultCode.ifBlank { null }
                ))
                onBack()
            }) { Text("সেভ করুন") }
        }
    }
}
EOF

echo "✅ Theme, Navigation, and Settings created successfully!"
echo "📁 Created: 2 theme files, 1 navigation file, 3 settings files"
