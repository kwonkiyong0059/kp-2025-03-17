package com.kkd.back

interface S3Service {
    fun getBucketNames(): List<String>
}