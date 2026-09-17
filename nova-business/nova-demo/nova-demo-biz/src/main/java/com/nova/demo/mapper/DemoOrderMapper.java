package com.nova.demo.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nova.demo.domain.entity.DemoOrder;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface DemoOrderMapper extends BaseMapper<DemoOrder> {
}
