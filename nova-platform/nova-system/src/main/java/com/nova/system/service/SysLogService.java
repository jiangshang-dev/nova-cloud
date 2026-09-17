package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.exception.ServiceException;
import com.nova.system.domain.entity.SysLoginLog;
import com.nova.system.domain.entity.SysOperLog;
import com.nova.system.mapper.SysLoginLogMapper;
import com.nova.system.mapper.SysOperLogMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
@RequiredArgsConstructor
public class SysLogService {

    private final SysOperLogMapper sysOperLogMapper;
    private final SysLoginLogMapper sysLoginLogMapper;

    public Page<SysOperLog> operPage(long current, long size, String operName, String title, Integer status) {
        LambdaQueryWrapper<SysOperLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(operName), SysOperLog::getOperName, operName)
                .like(StringUtils.hasText(title), SysOperLog::getTitle, title)
                .eq(status != null, SysOperLog::getStatus, status)
                .orderByDesc(SysOperLog::getOperTime)
                .orderByDesc(SysOperLog::getId);
        return sysOperLogMapper.selectPage(new Page<>(current, size), wrapper);
    }

    public void deleteOper(Long id) {
        if (sysOperLogMapper.deleteById(id) == 0) {
            throw new ServiceException("操作日志不存在");
        }
    }

    public void clearOper() {
        sysOperLogMapper.delete(new LambdaQueryWrapper<>());
    }

    public Page<SysLoginLog> loginPage(long current, long size, String username, Integer status) {
        LambdaQueryWrapper<SysLoginLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(username), SysLoginLog::getUsername, username)
                .eq(status != null, SysLoginLog::getStatus, status)
                .orderByDesc(SysLoginLog::getLoginTime)
                .orderByDesc(SysLoginLog::getId);
        return sysLoginLogMapper.selectPage(new Page<>(current, size), wrapper);
    }

    public void deleteLogin(Long id) {
        if (sysLoginLogMapper.deleteById(id) == 0) {
            throw new ServiceException("登录日志不存在");
        }
    }

    public void clearLogin() {
        sysLoginLogMapper.delete(new LambdaQueryWrapper<>());
    }

    public void saveLoginLog(SysLoginLog log) {
        if (log.getId() == null) {
            log.setId(com.nova.core.utils.IdGeneratorUtil.nextId());
        }
        if (log.getTenantId() == null) {
            log.setTenantId(0L);
        }
        if (log.getLoginTime() == null) {
            log.setLoginTime(java.time.LocalDateTime.now());
        }
        if (log.getStatus() == null) {
            log.setStatus(1);
        }
        sysLoginLogMapper.insert(log);
    }

    public void saveOperLog(SysOperLog log) {
        if (log.getId() == null) {
            log.setId(com.nova.core.utils.IdGeneratorUtil.nextId());
        }
        if (log.getTenantId() == null) {
            log.setTenantId(0L);
        }
        if (log.getOperTime() == null) {
            log.setOperTime(java.time.LocalDateTime.now());
        }
        if (log.getStatus() == null) {
            log.setStatus(1);
        }
        if (log.getCostTime() == null) {
            log.setCostTime(0L);
        }
        sysOperLogMapper.insert(log);
    }
}
