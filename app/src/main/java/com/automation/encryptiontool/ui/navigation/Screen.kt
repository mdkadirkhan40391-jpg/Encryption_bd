package com.automation.encryptiontool.ui.navigation

sealed class Screen(val route: String) {
    data object MainChat : Screen("main_chat")
    data object Settings : Screen("settings")
}

object Routes {
    const val MAIN_CHAT = "main_chat"
    const val SETTINGS = "settings"
}
