package com.nova.file.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nova.file.domain.entity.FileChunk;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface FileChunkMapper extends BaseMapper<FileChunk> {
}
