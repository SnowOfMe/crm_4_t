package com.bjpowernode.crm.workbench.service;

import java.util.List;

import com.bjpowernode.crm.workbench.domain.Activity;

public interface ClueActivityRelationService {

	/**
	 * 根据线索id获取线索关联的所有市场活动
	 * @param clueId 线索id
	 * @return 市场活动列表
	 */
	List<Activity> getActivityByClueId(String clueId);

}
