#!/bin/bash

# create_projectc.sh - DI, Worker, App Entry

echo "Creating DI, Worker, and App Entry files..."

# Create di directory
mkdir -p app/src/main/java/com/automation/encryptiontool/di

# Create DI files
cat > app/src/main/java/com/automation/encryptiontool/di/DatabaseModule.kt << 'EOF'
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
EOF

cat > app/src/main/java/com/automation/encryptiontool/di/NetworkModule.kt << 'EOF'
package com.automation.encryptiontool.di

import com.automation.encryptiontool.data.remote.GitHubApiService
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideJson(): Json = Json { ignoreUnknownKeys = true }

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        val logging = HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BASIC }
        return OkHttpClient.Builder().addInterceptor(logging).build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(client: OkHttpClient, json: Json): Retrofit =
        Retrofit.Builder()
            .baseUrl(GitHubApiService.BASE_URL)
            .client(client)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()

    @Provides
    @Singleton
    fun provideGitHubApiService(retrofit: Retrofit): GitHubApiService =
        retrofit.create(GitHubApiService::class.java)
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/di/RepositoryModule.kt << 'EOF'
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
EOF

# Create worker directory
mkdir -p app/src/main/java/com/automation/encryptiontool/worker

cat > app/src/main/java/com/automation/encryptiontool/worker/TtlAutoDeleteWorker.kt << 'EOF'
package com.automation.encryptiontool.worker

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.automation.encryptiontool.domain.usecase.ManageTtlExpiryUseCase
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject

@HiltWorker
class TtlAutoDeleteWorker @AssistedInject constructor(
    @Assisted context: Context,
    @Assisted params: WorkerParameters,
    private val manageTtlExpiryUseCase: ManageTtlExpiryUseCase
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result = try {
        manageTtlExpiryUseCase()
        Result.success()
    } catch (e: Exception) {
        Result.retry()
    }

    companion object {
        const val WORK_NAME = "ttl_auto_delete_work"
    }
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/worker/TtlWorkScheduler.kt << 'EOF'
package com.automation.encryptiontool.worker

import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

object TtlWorkScheduler {
    fun schedule(workManager: WorkManager) {
        val request = PeriodicWorkRequestBuilder<TtlAutoDeleteWorker>(1, TimeUnit.HOURS).build()
        workManager.enqueueUniquePeriodicWork(
            TtlAutoDeleteWorker.WORK_NAME,
            ExistingPeriodicWorkPolicy.KEEP,
            request
        )
    }
}
EOF

# Create App Entry files
cat > app/src/main/java/com/automation/encryptiontool/MainApplication.kt << 'EOF'
package com.automation.encryptiontool

import android.app.Application
import androidx.hilt.work.HiltWorkerFactory
import androidx.work.Configuration
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject

@HiltAndroidApp
class MainApplication : Application(), Configuration.Provider {

    @Inject lateinit var workerFactory: HiltWorkerFactory

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder().setWorkerFactory(workerFactory).build()
}
EOF

cat > app/src/main/java/com/automation/encryptiontool/MainActivity.kt << 'EOF'
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
EOF

echo "✅ DI, Worker, and App Entry created successfully!"
echo "📁 Created: 3 DI modules, 2 workers, 2 app entry files"
