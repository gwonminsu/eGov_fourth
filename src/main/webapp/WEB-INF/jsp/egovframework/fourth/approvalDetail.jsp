<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>기안문 상세</title>
	
	<link rel="stylesheet" href="<c:url value='/css/approvalDetail.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 일정 관리(상세) 페이지 URL -->
	<c:url value="/scheduleDetail.do" var="scheduleDetailUrl"/>
	<!-- API URL -->
    <c:url value="/api/approval/getScheduleReq.do" var="getScheduleReqApi" />
    <c:url value="/api/approval/getReqAttachList.do" var="getReqAttachListApi" />
    <c:url value="/api/approval/getSnapUserList.do" var="getSnapUserListApi" />
	<c:url value="/api/approval/getUserAndReqRes.do" var="getUserReqResApi" />
	
	<script>
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.isAdmin}" default="" />';
		
	    // 동적 POST 폼 생성 함수
	    function postTo(url, params) {
	        var form = $('<form>').attr({ method: 'POST', action: url });
	        $.each(params, function(name, value){
	            $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
	        });
	        form.appendTo('body').submit();
	    }
	
		// 바이트 수를 읽기 편한 문자열로 변환
		function formatBytes(bytes) {
			if (bytes === 0) return '0 Bytes';
			var k = 1024;
			var sizes = [ 'Bytes', 'KB', 'MB', 'GB', 'TB' ];
			// 지수 계산
			var i = Math.floor(Math.log(bytes) / Math.log(k));
			// 해당 단위로 나눈 값
			var value = bytes / Math.pow(k, i);
			return value.toFixed(2) + ' ' + sizes[i];
		}
	</script>
</head>
<body>
	<h2 id="formTitle">예약 마감 기안문</h2><hr/>
	
	<div id="lineUserWrapper">
		<!-- 기안문 결재할 유저 목록 테이블 -->
		<table class="user-list-table">
			<thead>
				<tr><th colspan="3">결재</th></tr>
			</thead>
			<tbody id="approvalLineList"></tbody>
		</table>
	</div><hr/>
	
	<!-- 기안 상세 테이블 -->
	<table class="form-table">
		<tr>
			<th>문서번호</th>
			<td><div id="docId"></div></td>
			<th>기안일자</th>
			<td><div id="draftDate"></div></td>
		</tr>
		<tr>
			<th>성명</th>
			<td><div id="userName"></div></td>
			<th>부서/직위</th>
			<td><div id="departmentAndPosition"></div></td>
		</tr>
		<tr>
			<th>제목</th>
			<td colspan="3"><div id="reqTitle"></div></td>
		</tr>
		<tr>
			<th>내용</th>
			<td colspan="3">
				<div id="reqContent"></div>
			</td>
		</tr>
		<tr>
			<th>첨부파일</th>
			<td colspan="3">
				<div id="attachFileWrapper">
					<div id="fileList"></div>
				</div>
			</td>
		</tr>
		<tr>
			<th>기타 의견</th>
			<td colspan="3">
				<div id="commentWrapper">
					<div id="commentList"></div>
				</div>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<div>
			<button id="btnReuse" style="display: none;">재사용</button> <!-- 최종 반려되었을 경우 기안문 재요청 용도로 show? -->
			<button id="btnDelete" style="display: none;">삭제</button> <!-- 결재의 라인 유저들 중에서 하나도 응답안한경우 show -->
			<button id="btnCancel">이전</button>
		</div>
	</div>

	<script>
		var idx = '${param.idx}'; // 기안문 idx
		// 상태 유지용 파라미터 변수
		var programScheduleIdx = '${param.programScheduleIdx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		// 결재할 유저가 이 기안에 응답한 데이터를 조회
		function checkApprovalResponse(userIdx, callback) {
 			$.ajax({
				url: '${getUserReqResApi}',
				type:'POST',
				contentType: 'application/json',
				dataType: 'json',
				data: JSON.stringify({ approvalReqIdx: idx, userIdx: userIdx }),
				success: function(list){
					if (list && list.length > 0) {
						callback(list[0]);
					} else {
						callback(null);
					}
				},
				error: function(){
					alert('응답 조회 중 에러 발생');
					callback(null);
				}
			});
		}
		
		$(function() {
			// 기안문 상세 내용 조회 요청
 			$.ajax({
				url: '${getScheduleReqApi}',
				type:'POST',
				contentType: 'application/json',
				dataType: 'json',
				data: JSON.stringify({ programScheduleIdx: programScheduleIdx }),
				success: function(res){
					var data = res.approvalReq;
					// console.log(JSON.stringify(data));
					$('#docId').text(data.docId);
					$('#draftDate').text(data.createdAt.substr(0, 10));
					$('#userName').text(data.userName);
					$('#departmentAndPosition').text(data.userDepartment + ' / ' + data.userPosition);
					$('#reqTitle').text(data.title);
					$('#reqContent').text(data.content);
				},
				error: function(){
					alert('결재 기안문 상세 조회 중 에러 발생');
				}
			});
			
 			// 기안문의 결재라인의 결재자들 조회
 			$.ajax({
				url: '${getSnapUserListApi}',
				type:'POST',
				contentType: 'application/json',
				dataType: 'json',
				data: JSON.stringify({ approvalReqIdx: idx }),
				success: function(userList){
					console.log(JSON.stringify(userList));
					
					var approvList = [];
					var coopList = [];
					var refList = [];
					
					userList.forEach(function(user) {
						if (user.type === 'approv') {
							approvList.push(user);
						} else if (user.type === 'coop') {
							coopList.push(user);
						} else if (user.type === 'ref') {
							refList.push(user);
						}
					});
					
					// seq 순서대로 정렬 후 append
					function renderLineUserList(list) {
						list.sort(function(a, b) {
							return a.seq - b.seq;
						}).forEach(function(user) {
							// console.log(JSON.stringify(user));
							// 먼저 결재 사용자가 응답했는지 검사하고 응답 있으면 reData 제공
							checkApprovalResponse(user.userIdx, function(resData) {
								// 결재자 테이블 렌더링
								console.log(JSON.stringify(resData));
								var $name = $('<td>').text(user.userName + '(' + user.userPosition + ')');
								var $status = $('<td>')
								var $resDate = $('<td>')
								if (resData) {
									$status.text(resData.approvalStatus === 'approved' ? '결재' : '반려');
									$resDate.text(resData.createdAt.substr(0,10));
								} else {
									$status.text('대기중');
									$resDate.text('');
								}
								var $row = $('<tr>').append($name).append($status).append($resDate);
								$('#approvalLineList').append($row);
								// 의견 리스트 렌더링
								if (resData && resData.comment) {
									var $item = $('<div>').addClass('comment-item')
													.text('🔸 ' + user.userName + '(' + user.userPosition + ')' + ': ' + resData.comment);
									$('#commentList').append($item)
								}
							});
						});
					}
					
					renderLineUserList(coopList);
					renderLineUserList(approvList);
					renderLineUserList(refList);
				},
				error: function(){
					alert('결재 기안문 라인 유저 목록 조회 중 에러 발생');
				}
			});
			
			// 기안문 첨부 파일 목록 조회 요청
 			$.ajax({
				url: '${getReqAttachListApi}',
				type:'POST',
				contentType: 'application/json',
				dataType: 'json',
				data: JSON.stringify({ approvalReqIdx: idx }),
				success: function(fileList){
					// console.log(JSON.stringify(fileList));
					$('#fileList').empty();
					fileList.forEach(function(file, i) {
						var name = file.fileName;
						var size = formatBytes(file.fileSize);
						var url = '/uploads/' + file.fileUuid + file.ext;
						var $item = $('<div>').addClass('file-item');
						var $link = $('<a>').attr('href', url).attr('download', name).text('🔹 ' + name + ' [' + size + ']');
						$('#fileList').append($item.append($link));
					});
				},
				error: function(){
					alert('결재 기안문의 첨부 파일들 조회 중 에러 발생');
				}
			});

			// 취소 버튼 핸들러
			$('#btnCancel').click(function() {
				// 예약 관리(상세) 페이지 이동
				postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: programIdx, programName: programName, date: date });
			});

		});
	</script>
</body>
</html>