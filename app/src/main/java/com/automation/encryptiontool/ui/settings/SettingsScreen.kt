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
