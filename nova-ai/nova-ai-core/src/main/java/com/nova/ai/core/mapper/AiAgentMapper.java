package com.nova.ai.core.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nova.ai.core.domain.entity.AiAgent;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AiAgentMapper extends BaseMapper<AiAgent> {
}
