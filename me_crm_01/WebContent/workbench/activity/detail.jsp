<%@page contentType="text/html;charset=UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<base href="${pageContext.request.scheme}://${pageContext.request.serverName}:${pageContext.request.serverPort}${pageContext.request.contextPath }/">
<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	
	$(function(){
		//日历插件
		$(".time").datetimepicker({
			language : 'zh-CN',//显示中文
			format : 'yyyy-mm-dd',//显示格式
			initialDate : new Date(),//初始化当前日期
			minView:"month",
			autoclose : true,//选中自动关闭
			todayBtn : true,//显示今日按钮
			clearBtn : true
		})
		
		//调用备注方法显示页面
		displayRemark();
		
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$("body").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		});
		
		$("body").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		});
		
		$("body").on("mouseover",".myHref",function(){
			$(this).children("span").css("color","red");
		});
		
		$("body").on("mouseout",".myHref",function(){
			$(this).children("span").css("color","red");
		});
		
		//备注新增
		 $("#saveRemarkBtn").click(function(){
			var noteContent = $("#remark");
			$.ajax({
				type : "get",
				url : "workbench/activity/remarkSave.do",
				data : {
					"noteContent" : $.trim(noteContent.val()),
					"activityId" : "${activity.id}"
				},
				beforeSend : function(){
					if($("#remark").val() == ""){
						alert("备注信息不能为空");
						return false;
					}
					return true;
				},
				success : function(json){
					if(json.success){
						$("#remark").val("");
						var html = "";
						
						html += '<div id=d-'+json.activityRemark.id+' class="remarkDiv" style="height: 60px;">';
						html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
						html += '<div style="position: relative; top: -40px; left: 40px;" >';
						html += '<h5 id=e-'+json.activityRemark.id+'>'+json.activityRemark.noteContent+'</h5>';
						html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+"${activity.name}"+'</b> <small style="color: gray;" id="small'+json.activityRemark.id+'"> '+(json.activityRemark.editFlag == 0 ? json.activityRemark.creatTime : json.activityRemark.editTime) +'由'+(json.activityRemark.editFlag == 0 ?json.activityRemark.creatBy : json.activityRemark.editBy)+'</small>';
						html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
						html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+json.activityRemark.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>';
						html += '&nbsp;&nbsp;&nbsp;&nbsp;';
						html += '<a class="myHref" href="javascript:void(0)" onclick= "deleteRemarkById(\''+json.activityRemark.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
						html += '</div>';
						html += '</div>';
						html += '</div>';
						
						$("#remarkId").val(json.activityRemark.id);
						$("#remarkDiv").before(html);
					}else{
						alert("保存失败");
					}
				}
			})
			
		})
		
		//点击编辑按钮时获取页面信息
		$("#editBtn").click(function(){
			$.ajax({
				type : "get",
				url : "settings/qx/user/list.do",
				success : function(data){
					var html = "";
					$.each(data,function(i,n){
						html += '<option value = "'+n.id+'" '+(n.name=="${activity.owner}"? "selected" : "" )+'>'+n.name+'</option>'
					})
					$("#edit-marketActivityOwner").html(html);
					
					$("#editActivityModal").modal("show");
				}
			});
			$("#edit-marketActivityOwner").val("${activity.owner}");
			$("#edit-marketActivityName").val("${activity.name}");
			$("#edit-startTime").val("${activity.startTime}");
			$("#edit-startTime").val("${activity.endTime}");
			$("#edit-cost").val("${activity.cost}");
			$("#edit-describe").val("${activity.description}");
		})
		
		//保存编辑的数据
		$("#saveEditBtn").click(function(){
			$.ajax({
				type : "post",
				url : "workbench/activity/updateActivity.do",
				data : {
					"id" : "${activity.id}",
					"owner" : $("#edit-marketActivityOwner").val(),
					"name" :  $.trim($("#edit-marketActivityName").val()),
					"startTime" : $("#edit-startTime").val(),
					"endTime" : $("#edit-endTime").val(),
					"cost" : $.trim($("#edit-cost").val()),
					"description" : $.trim($("#edit-describe").val()),
					"editBy" : "${user.name}"
				},
				beforeSend : function(){
					if($("#edit-marketActivityName").val() == ""){
						alert("名称不能为空");
						return false;
					}
					return true;
				},
				success : function(json){
					if(json.success){
						$("#line_1").html('市场活动-'+json.activity.name+'<small>'+json.activity.startTime +' ~'+ json.activity.endTime+'</small>');
						$("#line_2").html(json.activity.owner);
						$("#line_3").html(json.activity.name);
						$("#line_4").html('&8888;' + json.activity.startTime);
						$("#line_5").html('&nbsp;' + json.activity.endTime);
						$("#line_6").html('&nbsp;' + json.activity.cost);
						$("#line_8").html('<b>'+json.activity.editBy+'&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">'+json.activity.editTime+'</small>'); 
						$("#editActivityModal").modal("hide");
					}else{
						alert("更新失败");
					} 
				}
			});
		})
		
		//删除
		$("#deleteBtn").click(function(){
			if(window.confirm("确认删除吗?")){
				$.post(
					"workbench/activity/deleteActivity.do",
					{"id" : "${activity.id}"},
					function(data){
						if(data.success){
							document.location.href="workbench/activity/index.jsp";
						}else{
							alert("删除失败");
						}
					}
				)
			}
			
		})
		
		//更新
		$("#saveRemarkEditBtn").click(function(){
			$.ajax({
				type : "post",
				url : "workbench/activity/updateRemark.do",
				data : {
					"id" : 	$("#remarkId").val(),
					"noteContent" : $("#edit-remark-describe").val()
				},
				beforeSend : function(){
					if($("#edit-remark-describe").val() == ""){
						alert("内容不能为空");
						return false;
					}
					return true;
				},
				success : function(data){
					if(data.success){
						$("#editActivityRemarkModal").modal("hide");
						$("#e-" + $("#remarkId").val()).html(data.noteContent);
						$("#small" + $("#remarkId").val()).html(data.editTime + "由" + data.editBy);
					}else{
						alert("更新失败");
					}
				}
				
			})
		})
		
	});
	
	//获取备注信息
	function editRemark(id){
		$("#edit-remark-describe").val($("#e-" + id).text());
		$("#editActivityRemarkModal").modal("show");
		$("#remarkId").val(id);
	}
	
	
	
	//删除备注方法
	function deleteRemarkById(id){
		$.post(
			"workbench/activity/deleteRemark.do",
			{"id" : id},
			function(data){
				if(data.success){
					$("#d-" +id).remove();
				}else{
					alert("删除失败");
				}
			}
		)
	}
	
	function displayRemark(){
		
		 $.ajax({
			type : "get",
			url : "workbench/activity/remarkList.do",
			data : {
				"id" : "${activity.id}"
			},
			success : function(data){
				var html = '';
				$.each(data.success,function(i,n){
					html += '<div id=d-'+n.id+' class="remarkDiv" style="height: 60px;">';
					html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html += '<div style="position: relative; top: -40px; left: 40px;" >';
					html += '<h5 id=e-'+n.id+'>'+n.noteContent+'</h5>';
					html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>'+"${activity.name}"+'</b> <small style="color: gray;" id="small'+n.id+'"> '+(n.editFlag == 0 ? n.creatTime : n.editTime) +'由'+(n.editFlag == 0 ? n.creatBy : n.editBy)+'</small>';
					html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '<a class="myHref" href="javascript:void(0);" onclick= "editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>';
					html += '&nbsp;&nbsp;&nbsp;&nbsp;';                 
					html += '<a class="myHref" href="javascript:void(0);" onclick= "deleteRemarkById(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>';
					html += '</div>';
					html += '</div>';
					html += '</div>';
				});
				$("#remarkDiv").before(html);
			}
			
		})
	}
	
</script>

</head>
<body>
	<!--修改备注的模态窗口  -->
	<div class="modal fade" id="editActivityRemarkModal" role="dialog">
		<input type="hidden" id="remarkId">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel1">修改市场活动备注</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-remark-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary"  id="saveRemarkEditBtn">更新</button>
                </div>
            </div>
        </div>
    </div>
	




    <!-- 修改市场活动的模态窗口 -->
    <div class="modal fade" id="editActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-marketActivityOwner">
                                    <option>zhangsan</option>
                                    <option>lisi</option>
                                    <option>wangwu</option>
                                </select>
                            </div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-startTime" value="2020-10-10">
                            </div>
                            <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-endTime" value="2020-10-20">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-cost" value="5,000">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
                            </div>
                        </div>

                    </form>

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button type="button" class="btn btn-primary"  id="saveEditBtn">更新</button>
                </div>
            </div>
        </div>
    </div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3 id="line_1">市场活动-${activity.name}<small>${activity.startTime} ~ ${activity.endTime}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b id="line_2">${activity.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="line_3">${activity.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b id="line_4">&nbsp;${activity.startTime}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="line_5">&nbsp;${activity.endTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b id="line_6">&nbsp;${activity.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div id="line_7" style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.creatBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.creatTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div id="line_8" style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${activity.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${activity.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b id="line_8">
					&nbsp;${activity.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		<!-- 
		备注1
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>哎呦！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>
				</div>
			</div>
		</div>
		
		备注2
		<div class="remarkDiv" style="height: 60px;">
			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">
			<div style="position: relative; top: -40px; left: 40px;" >
				<h5>呵呵！</h5>
				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>
				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: red;"></span></a>
					&nbsp;&nbsp;&nbsp;&nbsp;
					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: red;"></span></a>
				</div>
			</div>
		</div> -->
		
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>