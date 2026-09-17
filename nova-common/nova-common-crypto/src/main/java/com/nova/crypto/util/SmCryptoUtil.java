package com.nova.crypto.util;

import cn.hutool.core.util.HexUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.SmUtil;
import cn.hutool.crypto.symmetric.SM4;

import java.nio.charset.StandardCharsets;

/**
 * 国密 SM3 / SM4 工具。
 */
public final class SmCryptoUtil {

    private SmCryptoUtil() {
    }

    /**
     * SM3 摘要（hex）。
     */
    public static String sm3Hex(String content) {
        return SmUtil.sm3(content);
    }

    /**
     * SM3 签名：content + salt。
     */
    public static String sm3Sign(String content, String salt) {
        return SmUtil.sm3(StrUtil.nullToEmpty(content) + StrUtil.nullToEmpty(salt));
    }

    /**
     * 校验 SM3 签名。
     */
    public static boolean verifySm3Sign(String content, String salt, String sign) {
        if (StrUtil.isBlank(sign)) {
            return false;
        }
        return sm3Sign(content, salt).equalsIgnoreCase(sign);
    }

    /**
     * SM4 加密，返回 hex。
     */
    public static String sm4EncryptHex(String plainText, String key) {
        return buildSm4(key).encryptHex(plainText);
    }

    /**
     * SM4 解密（hex 密文）。
     */
    public static String sm4DecryptHex(String cipherHex, String key) {
        return buildSm4(key).decryptStr(cipherHex);
    }

    private static SM4 buildSm4(String key) {
        byte[] keyBytes = normalizeKey(key);
        return SmUtil.sm4(keyBytes);
    }

    /**
     * SM4 要求 16 字节密钥。
     */
    private static byte[] normalizeKey(String key) {
        if (StrUtil.isBlank(key)) {
            throw new IllegalArgumentException("SM4 key 不能为空");
        }
        byte[] raw = key.getBytes(StandardCharsets.UTF_8);
        if (raw.length == 16) {
            return raw;
        }
        // 尝试按 hex 解析（32 位 hex = 16 字节）
        if (key.length() == 32 && key.matches("(?i)[0-9a-f]{32}")) {
            return HexUtil.decodeHex(key);
        }
        byte[] fixed = new byte[16];
        System.arraycopy(raw, 0, fixed, 0, Math.min(raw.length, 16));
        return fixed;
    }
}
