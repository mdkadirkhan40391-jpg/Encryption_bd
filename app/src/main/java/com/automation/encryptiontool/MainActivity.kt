package com.automation.encryptiontool

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.work.WorkManager
import com.automation.encryptiontool.ui.navigation.AppNavHost
import com.automation.encryptiontool.ui.theme.EncryptionToolTheme
import com.automation.encryptiontool.worker.TtlWorkScheduler
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        TtlWorkScheduler.schedule(WorkManager.getInstance(applicationContext))
        setContent {
            EncryptionToolTheme {
                AppNavHost()
            }
        }
    }
}
