package com.automation.encryptiontool.domain.security

import com.automation.encryptiontool.domain.model.EncryptedPayload

interface Encryptor {
    fun encrypt(plainText: String, securityCode: String, keyVersion: Int = 1): EncryptedPayload
    fun decrypt(payload: EncryptedPayload, securityCode: String): String
}
