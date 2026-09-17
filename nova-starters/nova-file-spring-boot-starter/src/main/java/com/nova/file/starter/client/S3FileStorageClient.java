package com.nova.file.starter.client;

import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.nova.file.starter.enums.StorageType;
import com.nova.file.starter.model.PartETagInfo;
import com.nova.file.starter.model.StorageConfig;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;
import software.amazon.awssdk.services.s3.model.AbortMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.CompleteMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.CompletedMultipartUpload;
import software.amazon.awssdk.services.s3.model.CompletedPart;
import software.amazon.awssdk.services.s3.model.CreateMultipartUploadRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.HeadBucketRequest;
import software.amazon.awssdk.services.s3.model.HeadObjectRequest;
import software.amazon.awssdk.services.s3.model.ListPartsRequest;
import software.amazon.awssdk.services.s3.model.NoSuchKeyException;
import software.amazon.awssdk.services.s3.model.Part;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.model.UploadPartRequest;

import java.io.InputStream;
import java.net.URI;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

/**
 * MinIO / RustFS / 阿里云 OSS / 标准 S3，统一走 AWS SDK v2。
 */
public class S3FileStorageClient implements FileStorageClient {

    private final StorageConfig config;
    private final StorageType storageType;
    private final S3Client s3Client;
    private final String bucket;
    private final String keyPrefix;

    public S3FileStorageClient(StorageConfig config) {
        this.config = config;
        this.storageType = StorageType.fromCode(config.getStorageType());
        if (!storageType.isS3Compatible()) {
            throw new IllegalArgumentException("非 S3 兼容类型: " + storageType);
        }
        if (StrUtil.isBlank(config.getEndpoint())) {
            throw new IllegalArgumentException("endpoint 不能为空");
        }
        if (StrUtil.isBlank(config.getAccessKey()) || StrUtil.isBlank(config.getSecretKey())) {
            throw new IllegalArgumentException("accessKey/secretKey 不能为空");
        }
        if (StrUtil.isBlank(config.getBucketName())) {
            throw new IllegalArgumentException("bucketName 不能为空");
        }
        this.bucket = config.getBucketName();
        this.keyPrefix = normalizePrefix(config.getBasePath());
        this.s3Client = buildClient(config, storageType);
    }

    @Override
    public StorageType type() {
        return storageType;
    }

    @Override
    public StorageConfig config() {
        return config;
    }

    @Override
    public void upload(String objectKey, InputStream in, long size, String contentType) {
        PutObjectRequest.Builder builder = PutObjectRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey));
        if (StrUtil.isNotBlank(contentType)) {
            builder.contentType(contentType);
        }
        s3Client.putObject(builder.build(), RequestBody.fromInputStream(in, size));
    }

    @Override
    public InputStream download(String objectKey) {
        return s3Client.getObject(GetObjectRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey))
                .build());
    }

    @Override
    public void delete(String objectKey) {
        s3Client.deleteObject(DeleteObjectRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey))
                .build());
    }

    @Override
    public boolean exists(String objectKey) {
        try {
            s3Client.headObject(HeadObjectRequest.builder()
                    .bucket(bucket)
                    .key(fullKey(objectKey))
                    .build());
            return true;
        } catch (NoSuchKeyException e) {
            return false;
        } catch (Exception e) {
            String msg = e.getMessage();
            if (msg != null && msg.contains("404")) {
                return false;
            }
            throw e;
        }
    }

    @Override
    public void ping() {
        s3Client.headBucket(HeadBucketRequest.builder().bucket(bucket).build());
    }

    @Override
    public String getAccessUrl(String objectKey) {
        String key = fullKey(objectKey);
        if (StrUtil.isNotBlank(config.getDomain())) {
            return joinUrl(config.getDomain(), key);
        }
        String endpoint = ensureScheme(config.getEndpoint());
        return joinUrl(endpoint, bucket + "/" + key);
    }

    @Override
    public String initiateMultipart(String objectKey, String contentType) {
        CreateMultipartUploadRequest.Builder builder = CreateMultipartUploadRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey));
        if (StrUtil.isNotBlank(contentType)) {
            builder.contentType(contentType);
        }
        return s3Client.createMultipartUpload(builder.build()).uploadId();
    }

    @Override
    public String uploadPart(String objectKey, String uploadId, int partNumber, InputStream in, long size) {
        UploadPartRequest request = UploadPartRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey))
                .uploadId(uploadId)
                .partNumber(partNumber)
                .build();
        return s3Client.uploadPart(request, RequestBody.fromInputStream(in, size)).eTag();
    }

    @Override
    public void completeMultipart(String objectKey, String uploadId, List<PartETagInfo> parts) {
        List<CompletedPart> completedParts = parts.stream()
                .sorted(Comparator.comparingInt(PartETagInfo::getPartNumber))
                .map(p -> CompletedPart.builder()
                        .partNumber(p.getPartNumber())
                        .eTag(p.getEtag())
                        .build())
                .collect(Collectors.toList());
        s3Client.completeMultipartUpload(CompleteMultipartUploadRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey))
                .uploadId(uploadId)
                .multipartUpload(CompletedMultipartUpload.builder().parts(completedParts).build())
                .build());
    }

    @Override
    public void abortMultipart(String objectKey, String uploadId) {
        s3Client.abortMultipartUpload(AbortMultipartUploadRequest.builder()
                .bucket(bucket)
                .key(fullKey(objectKey))
                .uploadId(uploadId)
                .build());
    }

    @Override
    public List<Integer> listUploadedParts(String objectKey, String uploadId) {
        List<Integer> indexes = new ArrayList<>();
        String marker = null;
        do {
            var resp = s3Client.listParts(ListPartsRequest.builder()
                    .bucket(bucket)
                    .key(fullKey(objectKey))
                    .uploadId(uploadId)
                    .partNumberMarker(marker == null ? null : Integer.parseInt(marker))
                    .build());
            for (Part part : resp.parts()) {
                indexes.add(part.partNumber());
            }
            marker = Boolean.TRUE.equals(resp.isTruncated()) && resp.nextPartNumberMarker() != null
                    ? String.valueOf(resp.nextPartNumberMarker())
                    : null;
        } while (marker != null);
        return indexes;
    }

    @Override
    public void close() {
        s3Client.close();
    }

    private String fullKey(String objectKey) {
        String key = StrUtil.removePrefix(objectKey.replace('\\', '/'), "/");
        if (StrUtil.isBlank(keyPrefix)) {
            return key;
        }
        return keyPrefix + "/" + key;
    }

    private static S3Client buildClient(StorageConfig config, StorageType type) {
        JSONObject ext = StrUtil.isBlank(config.getExtConfig())
                ? new JSONObject()
                : JSONUtil.parseObj(config.getExtConfig());
        boolean pathStyle = ext.containsKey("pathStyle")
                ? ext.getBool("pathStyle")
                : (type == StorageType.MINIO || type == StorageType.RUSTFS || type == StorageType.S3);

        String region = StrUtil.blankToDefault(config.getRegion(), defaultRegion(type, config.getEndpoint()));
        URI endpoint = URI.create(ensureScheme(config.getEndpoint()));

        return S3Client.builder()
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(config.getAccessKey(), config.getSecretKey())))
                .endpointOverride(endpoint)
                .region(Region.of(region))
                .serviceConfiguration(S3Configuration.builder()
                        .pathStyleAccessEnabled(pathStyle)
                        .chunkedEncodingEnabled(false)
                        .build())
                .build();
    }

    private static String defaultRegion(StorageType type, String endpoint) {
        if (type == StorageType.OSS) {
            // oss-cn-beijing.aliyuncs.com -> oss-cn-beijing
            String host = endpoint.replace("https://", "").replace("http://", "");
            int idx = host.indexOf('.');
            if (idx > 0) {
                return host.substring(0, idx);
            }
            return "oss-cn-beijing";
        }
        return "us-east-1";
    }

    private static String normalizePrefix(String basePath) {
        if (StrUtil.isBlank(basePath)) {
            return "";
        }
        return StrUtil.removeSuffix(StrUtil.removePrefix(basePath.replace('\\', '/'), "/"), "/");
    }

    private static String ensureScheme(String endpoint) {
        if (endpoint.startsWith("http://") || endpoint.startsWith("https://")) {
            return endpoint;
        }
        return "https://" + endpoint;
    }

    private static String joinUrl(String domain, String path) {
        return StrUtil.removeSuffix(domain, "/") + "/" + StrUtil.removePrefix(path, "/");
    }
}
