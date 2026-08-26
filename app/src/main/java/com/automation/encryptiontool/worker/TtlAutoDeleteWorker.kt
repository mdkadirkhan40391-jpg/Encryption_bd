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
