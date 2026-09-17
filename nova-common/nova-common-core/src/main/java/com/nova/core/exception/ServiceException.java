package com.nova.core.exception;

import com.nova.core.enums.IBaseEnum;
import lombok.Getter;

/**
 * 业务异常。
 */
@Getter
public class ServiceException extends RuntimeException {

    private final Integer code;

    public ServiceException(String message) {
        super(message);
        this.code = 500;
    }

    public ServiceException(String message, Object... params) {
        super(format(message, params));
        this.code = 500;
    }

    public ServiceException(IBaseEnum<Integer> base, Object... params) {
        super(format(base.getMessage(), params));
        this.code = base.getCode();
    }

    public ServiceException(Integer code, String message) {
        super(message);
        this.code = code;
    }

    private static String format(String message, Object... params) {
        if (message == null) {
            return null;
        }
        if (params == null || params.length == 0) {
            return message;
        }
        return String.format(message.replace("{}", "%s"), params);
    }
}
