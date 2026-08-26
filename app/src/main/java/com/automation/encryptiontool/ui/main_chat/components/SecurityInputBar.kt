package com.automation.encryptiontool.ui.main_chat.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.weight
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import com.automation.encryptiontool.ui.theme.GithubAccentBlue

@Composable
fun SecurityInputBar(
    securityCode: String, onSecurityCodeChange: (String) -> Unit, onSubmit: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(modifier = modifier.fillMaxWidth().padding(8.dp)) {
        OutlinedTextField(
            value = securityCode, onValueChange = onSecurityCodeChange,
            label = { Text("সিকিউরিটি কোড") },
            visualTransformation = PasswordVisualTransformation(),
            modifier = Modifier.weight(1f)
        )
        IconButton(onClick = onSubmit) { Icon(Icons.Filled.Send, "Submit", tint = GithubAccentBlue) }
    }
}
