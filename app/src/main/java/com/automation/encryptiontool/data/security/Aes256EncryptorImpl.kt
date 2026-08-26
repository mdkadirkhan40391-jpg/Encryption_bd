package com.automation.encryptiontool.data.security

import android.util.Base64
import com.automation.encryptiontool.domain.model.EncryptedPayload
import com.automation.encryptiontool.domain.security.Encryptor
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.SecretKey
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.PBEKeySpec
import javax.crypto.spec.SecretKeySpec
import javax.inject.Inject

class Aes256EncryptorImpl @Inject constructor() : Encryptor {
    override fun encrypt(plainText: String, securityCode: String, keyVersion: Int): EncryptedPayload {
        val salt = ByteArray(SALT_SIZE_BYTES).also { SecureRandom().nextBytes(it) }
        val secretKey = deriveKey(securityCode, salt)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.ENCRYPT_MODE, secretKey)
        val iv = cipher.iv
        val cipherBytes = cipher.doFinal(plainText.toByteArray(Charsets.UTF_8))
        return EncryptedPayload(
            version = 1,
            algorithm = "AES-256-GCM",
            keyVersion = keyVersion,
            salt = Base64.encodeToString(salt, Base64.NO_WRAP),
            iv = Base64.encodeToString(iv, Base64.NO_WRAP),
            cipherText = Base64.encodeToString(cipherBytes, Base64.NO_WRAP)
        )
    }

    override fun decrypt(payload: EncryptedPayload, securityCode: String): String {
        val salt = Base64.decode(payload.salt, Base64.NO_WRAP)
        val iv = Base64.decode(payload.iv, Base64.NO_WRAP)
        val cipherBytes = Base64.decode(payload.cipherText, Base64.NO_WRAP)
        val secretKey = deriveKey(securityCode, salt)
        val cipher = Cipher.getInstance(TRANSFORMATION)
        cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(TAG_LENGTH_BITS, iv))
        return String(cipher.doFinal(cipherBytes), Charsets.UTF_8)
    }

    private fun deriveKey(securityCode: String, salt: ByteArray): SecretKey {
        val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
        val spec = PBEKeySpec(securityCode.toCharArray(), salt, PBKDF2_ITERATIONS, KEY_SIZE_BITS)
        val keyBytes = factory.generateSecret(spec).encoded
        return SecretKeySpec(keyBytes, "AES")
    }

    companion object {
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val SALT_SIZE_BYTES = 16
        private const val KEY_SIZE_BITS = 256
        private const val TAG_LENGTH_BITS = 128
        private const val PBKDF2_ITERATIONS = 210_000
    }
}
