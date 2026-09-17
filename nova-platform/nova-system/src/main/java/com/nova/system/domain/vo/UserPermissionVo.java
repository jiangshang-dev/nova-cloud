package com.nova.system.domain.vo;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;

@Data
public class UserPermissionVo {
    private List<AppRouteVo> menu = new ArrayList<>();
    private List<String> codeList = new ArrayList<>();
    private List<Object> auth = new ArrayList<>();
    private List<Object> allAuth = new ArrayList<>();
    private Boolean sysSafeMode = false;
}
