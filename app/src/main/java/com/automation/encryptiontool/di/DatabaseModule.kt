package com.automation.encryptiontool.di

import android.content.Context
import androidx.room.Room
import com.automation.encryptiontool.data.local.db.AppDatabase
import com.automation.encryptiontool.data.local.db.ChatPairDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase =
        Room.databaseBuilder(context, AppDatabase::class.java, "encryption_tool.db").build()

    @Provides
    fun provideChatPairDao(db: AppDatabase): ChatPairDao = db.chatPairDao()
}
