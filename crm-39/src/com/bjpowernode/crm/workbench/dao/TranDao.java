package com.bjpowernode.crm.workbench.dao;

import com.bjpowernode.crm.workbench.domain.Tran;

public interface TranDao {

	/**
	 * 保存交易
	 * @param tran
	 */
	int save(Tran tran);

	/**
	 * 
	 * @param id
	 * @return
	 */
	Tran getById(String id);

}
