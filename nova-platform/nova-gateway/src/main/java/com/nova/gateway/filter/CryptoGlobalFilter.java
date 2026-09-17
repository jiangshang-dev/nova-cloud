package com.nova.gateway.filter;

import cn.hutool.core.util.StrUtil;
import com.nova.crypto.properties.CryptoProperties;
import com.nova.crypto.util.SmCryptoUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.reactivestreams.Publisher;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.core.io.buffer.DataBufferFactory;
import org.springframework.core.io.buffer.DataBufferUtils;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpRequestDecorator;
import org.springframework.http.server.reactive.ServerHttpResponseDecorator;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;

/**
 * 网关 SM3/SM4 报文加解密过滤器。
 * <p>
 * nova.crypto.enabled=false 时明文透传；为 true 时：
 * 请求体 SM4 解密、响应体 SM4 加密，并可校验/回写 SM3 签名。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class CryptoGlobalFilter implements GlobalFilter, Ordered {

    private final CryptoProperties cryptoProperties;

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        if (!cryptoProperties.isEnabled()) {
            return chain.filter(exchange);
        }

        String encryptFlag = exchange.getRequest().getHeaders().getFirst(cryptoProperties.getEncryptHeader());
        if ("0".equals(encryptFlag) || "false".equalsIgnoreCase(encryptFlag)) {
            return chain.filter(exchange);
        }

        ServerHttpRequest request = exchange.getRequest();
        HttpMethod method = request.getMethod();
        boolean hasBody = method == HttpMethod.POST || method == HttpMethod.PUT || method == HttpMethod.PATCH;

        Mono<ServerWebExchange> exchangeMono = Mono.just(exchange);
        if (hasBody) {
            exchangeMono = DataBufferUtils.join(request.getBody())
                    .flatMap(dataBuffer -> {
                        byte[] bytes = new byte[dataBuffer.readableByteCount()];
                        dataBuffer.read(bytes);
                        DataBufferUtils.release(dataBuffer);
                        String cipherText = new String(bytes, StandardCharsets.UTF_8).trim();
                        if (StrUtil.isBlank(cipherText)) {
                            return Mono.just(exchange);
                        }
                        try {
                            String sign = request.getHeaders().getFirst(cryptoProperties.getSignHeader());
                            if (StrUtil.isNotBlank(sign)
                                    && !SmCryptoUtil.verifySm3Sign(cipherText, cryptoProperties.getSm3Salt(), sign)) {
                                return writeJson(exchange, HttpStatus.BAD_REQUEST, "SM3 签名校验失败").then(Mono.empty());
                            }
                            String plain = SmCryptoUtil.sm4DecryptHex(cipherText, cryptoProperties.getSm4Key());
                            byte[] newBytes = plain.getBytes(StandardCharsets.UTF_8);
                            ServerHttpRequestDecorator decorator = new ServerHttpRequestDecorator(request) {
                                @Override
                                public Flux<DataBuffer> getBody() {
                                    return Flux.defer(() -> Flux.just(exchange.getResponse().bufferFactory().wrap(newBytes)));
                                }

                                @Override
                                public HttpHeaders getHeaders() {
                                    HttpHeaders headers = new HttpHeaders();
                                    headers.putAll(super.getHeaders());
                                    headers.setContentLength(newBytes.length);
                                    headers.setContentType(MediaType.APPLICATION_JSON);
                                    return headers;
                                }
                            };
                            return Mono.just(exchange.mutate().request(decorator).build());
                        } catch (Exception ex) {
                            log.error("请求体 SM4 解密失败", ex);
                            return writeJson(exchange, HttpStatus.BAD_REQUEST, "请求体解密失败").then(Mono.empty());
                        }
                    })
                    .switchIfEmpty(Mono.just(exchange));
        }

        return exchangeMono.flatMap(ex -> {
            DataBufferFactory bufferFactory = ex.getResponse().bufferFactory();
            ServerHttpResponseDecorator decoratedResponse = new ServerHttpResponseDecorator(ex.getResponse()) {
                @Override
                public Mono<Void> writeWith(Publisher<? extends DataBuffer> body) {
                    if (body instanceof Flux<? extends DataBuffer> fluxBody) {
                        return super.writeWith(fluxBody.buffer().map(dataBuffers -> {
                            DataBuffer joined = bufferFactory.join(dataBuffers);
                            byte[] content = new byte[joined.readableByteCount()];
                            joined.read(content);
                            DataBufferUtils.release(joined);
                            String plain = new String(content, StandardCharsets.UTF_8);
                            String cipher = SmCryptoUtil.sm4EncryptHex(plain, cryptoProperties.getSm4Key());
                            String sign = SmCryptoUtil.sm3Sign(cipher, cryptoProperties.getSm3Salt());
                            getDelegate().getHeaders().set(cryptoProperties.getSignHeader(), sign);
                            getDelegate().getHeaders().set(cryptoProperties.getEncryptHeader(), "1");
                            getDelegate().getHeaders().setContentType(MediaType.TEXT_PLAIN);
                            byte[] cipherBytes = cipher.getBytes(StandardCharsets.UTF_8);
                            getDelegate().getHeaders().setContentLength(cipherBytes.length);
                            return bufferFactory.wrap(cipherBytes);
                        }));
                    }
                    return super.writeWith(body);
                }
            };
            return chain.filter(ex.mutate().response(decoratedResponse).build());
        });
    }

    private Mono<Void> writeJson(ServerWebExchange exchange, HttpStatus status, String message) {
        exchange.getResponse().setStatusCode(status);
        exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);
        byte[] bytes = ("{\"code\":" + status.value() + ",\"message\":\"" + message + "\",\"data\":null}")
                .getBytes(StandardCharsets.UTF_8);
        DataBuffer buffer = exchange.getResponse().bufferFactory().wrap(bytes);
        return exchange.getResponse().writeWith(Mono.just(buffer));
    }

    @Override
    public int getOrder() {
        return -90;
    }
}
