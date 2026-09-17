package com.nova.ai.core.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nova.ai.core.domain.entity.AiModel;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface AiModelMapper extends BaseMapper<AiModel> {
}
