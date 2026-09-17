package com.nova.log.aspect;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.nova.log.annotation.AutoLog;
import com.nova.log.model.OperLogInfo;
import com.nova.log.recorder.OperLogRecorder;
import com.nova.security.constants.SecurityConstants;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.core.annotation.Order;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.multipart.MultipartFile;

import java.lang.reflect.Method;
import java.time.LocalDateTime;
import java.util.StringJoiner;

/**
 * {@link AutoLog} 切面：采集操作日志并交给 {@link OperLogRecorder} 持久化。
 */
@Slf4j
@Aspect
@Order(50)
@RequiredArgsConstructor
public class AutoLogAspect {

    private static final int MAX_PARAM_LENGTH = 2000;

    private final ObjectProvider<OperLogRecorder> operLogRecorderProvider;
    private final ObjectMapper objectMapper;

    @Around("@annotation(com.nova.log.annotation.AutoLog)")
    public Object around(ProceedingJoinPoint point) throws Throwable {
        long begin = System.currentTimeMillis();
        Object result = null;
        Throwable error = null;
        try {
            result = point.proceed();
            return result;
        } catch (Throwable ex) {
            error = ex;
            throw ex;
        } finally {
            try {
                saveLog(point, System.currentTimeMillis() - begin, result, error);
            } catch (Exception ex) {
                log.warn("记录操作日志失败: {}", ex.getMessage());
            }
        }
    }

    private void saveLog(ProceedingJoinPoint point, long cost, Object result, Throwable error) {
        OperLogRecorder recorder = operLogRecorderProvider.getIfAvailable();
        if (recorder == null) {
            return;
        }
        MethodSignature signature = (MethodSignature) point.getSignature();
        Method method = signature.getMethod();
        AutoLog autoLog = method.getAnnotation(AutoLog.class);
        if (autoLog == null) {
            return;
        }

        HttpServletRequest request = currentRequest();
        String className = point.getTarget().getClass().getName();
        String methodName = signature.getName();

        OperLogInfo.OperLogInfoBuilder builder = OperLogInfo.builder()
                .title(autoLog.value())
                .businessType(resolveBusinessType(autoLog.businessType(), methodName))
                .method(className + "." + methodName + "()")
                .costTime(cost)
                .operTime(LocalDateTime.now())
                .status(error == null ? 1 : 0)
                .errorMsg(error == null ? null : truncate(error.getMessage(), 500));

        if (request != null) {
            builder.requestMethod(request.getMethod())
                    .operUrl(request.getRequestURI())
                    .operIp(clientIp(request))
                    .operName(request.getHeader(SecurityConstants.USERNAME_HEADER))
                    .userId(parseLong(request.getHeader(SecurityConstants.USER_ID_HEADER)))
                    .tenantId(null);
            if (autoLog.saveRequestData()) {
                builder.operParam(truncate(buildParams(point.getArgs()), MAX_PARAM_LENGTH));
            }
        }
        if (autoLog.saveResponseData() && result != null && error == null) {
            builder.jsonResult(truncate(toJson(result), MAX_PARAM_LENGTH));
        }

        recorder.record(builder.build());
    }

    private int resolveBusinessType(int annotated, String methodName) {
        if (annotated != 0) {
            return annotated;
        }
        String name = methodName.toLowerCase();
        if (name.startsWith("add") || name.startsWith("create") || name.startsWith("insert") || name.startsWith("save")) {
            return 1;
        }
        if (name.startsWith("edit") || name.startsWith("update") || name.startsWith("modify")) {
            return 2;
        }
        if (name.startsWith("del") || name.startsWith("remove") || name.contains("delete")) {
            return 3;
        }
        if (name.contains("assign") || name.contains("auth") || name.contains("grant")) {
            return 4;
        }
        return 0;
    }

    private String buildParams(Object[] args) {
        if (args == null || args.length == 0) {
            return "";
        }
        StringJoiner joiner = new StringJoiner(", ");
        for (Object arg : args) {
            if (arg == null || arg instanceof MultipartFile
                    || arg instanceof HttpServletRequest
                    || arg instanceof jakarta.servlet.ServletResponse
                    || arg instanceof org.springframework.validation.BindingResult) {
                continue;
            }
            joiner.add(toJson(arg));
        }
        return joiner.toString();
    }

    private String toJson(Object obj) {
        try {
            return objectMapper.writeValueAsString(obj);
        } catch (Exception ex) {
            return String.valueOf(obj);
        }
    }

    private static String truncate(String text, int max) {
        if (text == null) {
            return null;
        }
        return text.length() <= max ? text : text.substring(0, max);
    }

    private static Long parseLong(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Long.valueOf(value);
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static String clientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
            int idx = ip.indexOf(',');
            return idx > 0 ? ip.substring(0, idx).trim() : ip.trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (ip != null && !ip.isBlank() && !"unknown".equalsIgnoreCase(ip)) {
            return ip;
        }
        return request.getRemoteAddr();
    }

    private static HttpServletRequest currentRequest() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attrs == null ? null : attrs.getRequest();
    }
}
