package com.automation.encryptiontool.data.local.db

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(entities = [ChatPairEntity::class], version = 1, exportSchema = true)
abstract class AppDatabase : RoomDatabase() {
    abstract fun chatPairDao(): ChatPairDao
}
