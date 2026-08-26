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
