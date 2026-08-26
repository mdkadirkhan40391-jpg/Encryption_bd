package com.automation.encryptiontool.data.remote

import com.automation.encryptiontool.data.remote.dto.CreateOrUpdateFileRequest
import com.automation.encryptiontool.data.remote.dto.CreateOrUpdateFileResponse
import com.automation.encryptiontool.data.remote.dto.GitHubContentResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.PUT
import retrofit2.http.Path
import retrofit2.http.Query

interface GitHubApiService {
    @GET("repos/{owner}/{repo}/contents/{path}")
    suspend fun getFileContent(
        @Header("Authorization") authorization: String,
        @Path("owner") owner: String,
        @Path("repo") repo: String,
        @Path(value = "path", encoded = true) path: String,
        @Query("ref") branch: String
    ): Response<GitHubContentResponse>

    @PUT("repos/{owner}/{repo}/contents/{path}")
    suspend fun createOrUpdateFile(
        @Header("Authorization") authorization: String,
        @Path("owner") owner: String,
        @Path("repo") repo: String,
        @Path(value = "path", encoded = true) path: String,
        @Body request: CreateOrUpdateFileRequest
    ): Response<CreateOrUpdateFileResponse>

    companion object {
        const val BASE_URL = "https://api.github.com/"
    }
}
