package com.nova.ai.core.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nova.ai.core.domain.entity.AiAgentMessage;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AiAgentMessageMapper extends BaseMapper<AiAgentMessage> {
}
