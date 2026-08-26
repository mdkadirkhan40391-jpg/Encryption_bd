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
