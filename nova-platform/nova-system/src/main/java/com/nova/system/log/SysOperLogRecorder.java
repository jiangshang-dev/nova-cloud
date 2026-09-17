package com.nova.system.log;

import com.nova.core.utils.IdGeneratorUtil;
import com.nova.log.model.OperLogInfo;
import com.nova.log.recorder.OperLogRecorder;
import com.nova.system.domain.entity.SysOperLog;
import com.nova.system.mapper.SysOperLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class SysOperLogRecorder implements OperLogRecorder {

    private final SysOperLogMapper sysOperLogMapper;

    @Override
    public void record(OperLogInfo info) {
        if (info == null) {
            return;
        }
        SysOperLog log = new SysOperLog();
        log.setId(IdGeneratorUtil.nextId());
        log.setTenantId(info.getTenantId() == null ? 0L : info.getTenantId());
        log.setTitle(info.getTitle());
        log.setBusinessType(info.getBusinessType() == null ? 0 : info.getBusinessType());
        log.setMethod(info.getMethod());
        log.setRequestMethod(info.getRequestMethod());
        log.setOperName(info.getOperName());
        log.setOperUrl(info.getOperUrl());
        log.setOperIp(info.getOperIp());
        log.setOperParam(info.getOperParam());
        log.setJsonResult(info.getJsonResult());
        log.setStatus(info.getStatus() == null ? 1 : info.getStatus());
        log.setErrorMsg(info.getErrorMsg());
        log.setOperTime(info.getOperTime());
        log.setCostTime(info.getCostTime() == null ? 0L : info.getCostTime());
        sysOperLogMapper.insert(log);
    }
}
