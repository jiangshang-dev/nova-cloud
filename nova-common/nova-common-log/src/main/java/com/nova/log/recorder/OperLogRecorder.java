package com.nova.log.recorder;

import com.nova.log.model.OperLogInfo;

/**
 * 操作日志落库 SPI。业务服务实现并注册为 Spring Bean 后由切面调用。
 */
@FunctionalInterface
public interface OperLogRecorder {

    void record(OperLogInfo info);
}
