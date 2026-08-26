package com.automation.encryptiontool.di

import com.automation.encryptiontool.data.security.Aes256EncryptorImpl
import com.automation.encryptiontool.data.security.KeystoreCipherHelper
import com.automation.encryptiontool.domain.security.Encryptor
import dagger.Binds
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class SecurityModule {

    @Binds
    @Singleton
    abstract fun bindEncryptor(impl: Aes256EncryptorImpl): Encryptor

    companion object {
        @Provides
        @Singleton
        fun provideKeystoreCipherHelper(): KeystoreCipherHelper = KeystoreCipherHelper()
    }
}
