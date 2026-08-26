package com.automation.encryptiontool.di

import com.automation.encryptiontool.data.repository.ChatPairRepositoryImpl
import com.automation.encryptiontool.data.repository.GithubRepositoryImpl
import com.automation.encryptiontool.data.repository.SettingsRepositoryImpl
import com.automation.encryptiontool.data.security.Aes256EncryptorImpl
import com.automation.encryptiontool.domain.repository.ChatPairRepository
import com.automation.encryptiontool.domain.repository.GithubRepository
import com.automation.encryptiontool.domain.repository.SettingsRepository
import com.automation.encryptiontool.domain.security.Encryptor
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds @Singleton
    abstract fun bindChatPairRepository(impl: ChatPairRepositoryImpl): ChatPairRepository

    @Binds @Singleton
    abstract fun bindGithubRepository(impl: GithubRepositoryImpl): GithubRepository

    @Binds @Singleton
    abstract fun bindSettingsRepository(impl: SettingsRepositoryImpl): SettingsRepository

    @Binds @Singleton
    abstract fun bindEncryptor(impl: Aes256EncryptorImpl): Encryptor
}
