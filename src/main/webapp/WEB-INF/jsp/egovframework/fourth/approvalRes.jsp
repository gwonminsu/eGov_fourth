<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>기안문 결재하기</title>
	
	<link rel="stylesheet" href="<c:url value='/css/approvalRes.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

	<!-- 결재 목록 페이지 URL -->
	<c:url value="/approvalList.do" var="approvalListUrl"/>
	<!-- 일정 상세 페이지 URL -->
	<c:url value="/scheduleDetail.do" var="scheduleDetailUrl"/>
	<!-- API URL -->
    <c:url value="/api/approval/getApprovalReq.do" var="getApprovalReq" />
    <c:url value="/api/approval/getReqAttachList.do" var="getReqAttachListApi" />
    <c:url value="/api/approval/getSnapUserList.do" var="getSnapUserListApi" />
	<c:url value="/api/approval/getUserAndReqRes.do" var="getUserReqResApi" />
	<c:url value="/api/approval/getReqRes.do" var="getReqResApi" />
	<c:url value="/api/approval/deleteReq.do" var="deleteReqApi" />
    <c:url value="/api/approval/createApprovalRes.do" var="createApprovalResApi" />
    <c:url value="/api/approval/isCurrentTurn.do" var="checkCurrentTurnApi" />
	
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
	<div id="titleHeader">
		<h2 id="formTitle">기안문 결재</h2>
		<button id="btnGoSchedule">이 기안문에 대한 일정 페이지</button>
	</div>
	<hr/>
	
	<div id="headTableWrapper">
		<!-- 결재 수행 테이블 -->
		<table class="approval-res-table">
			<thead>
				<tr><th colspan="3">응답</th></tr>
			</thead>
			<tbody>
				<tr>
					<td colspan="2">
						<input type="text" id="approvalComment" placeholder="결재 의견을 입력하세요">
					</td>
				</tr>
				<tr>
					<td>
						<button id="btnApprove">결재</button>
					</td>
					<td>
						<button id="btnReject">반려</button>
					</td>
				</tr>
			</tbody>
		</table>
		<!-- 기안문 결재할 유저 목록 테이블 -->
		<div id="listTableWrapper">
			<table class="user-list-table" id="refTable" style="display: none;">
				<thead>
					<tr><th colspan="3">참조</th></tr>
				</thead>
				<tbody id="cooperatorLineList"></tbody>
			</table>
			
			<table class="user-list-table">
				<thead>
					<tr><th colspan="3">결재</th></tr>
				</thead>
				<tbody id="approvalLineList"></tbody>
			</table>
		</div>

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
			<th>결재 의견</th>
			<td colspan="3">
				<div id="commentWrapper">
					<div id="commentList"></div>
				</div>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<div>
			<button id="btnCancel">이전</button>
		</div>
	</div>

	<script>
		var idx = '${param.idx}'; // 기안문 idx

		// 상태 유지용 파라미터 변수
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var pageIndex = '${param.pageIndex}' // 페이지 인덱스
		
		var programScheduleIdx = '';
		
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
						// 응답 없으면 지금 턴인지 추가 확인
						$.ajax({
							url: '${checkCurrentTurnApi}',
							type: 'POST',
							contentType: 'application/json',
							dataType: 'json',
							data: JSON.stringify({ approvalReqIdx: idx, userIdx: userIdx }),
							success: function(isTurn){
								callback(isTurn ? 'WAITING' : null); // WAITING이면 대기중, 아니면 null
							},
							error: function(){
								callback(null);
							}
						});
					}
				},
				error: function(){
					alert('응답 조회 중 에러 발생');
					callback(null);
				}
			});
		}
		
		// 응답 처리 핸들러
		function handleApproval(status, comment) {
			if (!confirm(status === 'APPROVED' ? '결재하시겠습니까?' : '반려하시겠습니까?')) return;

			var req = {
				approvalReqIdx: idx,
				userIdx: sessionUserIdx,
				approvalStatus: status,
				comment: comment
			};
			
			console.log(JSON.stringify(req));

 			$.ajax({
				url: '${createApprovalResApi}',
				type: 'POST',
				contentType: 'application/json',
				data: JSON.stringify(req),
				success: function (res) {
					if (res.error) {
						alert(res.error);
					} else {
						alert('처리 완료');
						postTo('${approvalListUrl}', { programIdx: programIdx, pageIndex: pageIndex });
					}
				},
				error: function () {
					alert('결재 처리 중 에러 발생');
				}
			});
		}
		
		$(function() {
			// 기안문 상세 내용 조회 요청
 			$.ajax({
				url: '${getApprovalReq}',
				type:'POST',
				contentType: 'application/json',
				dataType: 'json',
				data: JSON.stringify({ idx: idx }),
				success: function(data){
					console.log(JSON.stringify(data));
					programScheduleIdx = data.programScheduleIdx;
					$('#docId').text(data.docId);
					$('#draftDate').text(data.createdAt.substr(0, 10));
					$('#userName').text(data.userName);
					$('#departmentAndPosition').text(data.userDepartment + ' / ' + data.userPosition);
					$('#reqTitle').text(data.title);
					$('#reqContent').text(data.content);
					
					// 기안문의 모든 결재 응답 데이터 조회(삭제 버튼 권한 확인용)
		 			$.ajax({
						url: '${getReqResApi}',
						type:'POST',
						contentType: 'application/json',
						dataType: 'json',
						data: JSON.stringify({ approvalReqIdx: idx }),
						success: function(resList){
							// console.log(JSON.stringify(resList));
							if (resList.length < 1 && data.reqUserIdx === sessionUserIdx) {
								$('#btnDelete').show();
							}
						},
						error: function(){
							alert('결재 기안문의 결재 응답 데이터 조회 중 에러 발생');
						}
					});
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
					
					if (refList.length > 0) {
						$('#refTable').show();
					}
					
					// seq 순서대로 정렬 후 append
					function renderLineUserList(list, targetId, callback) {
						list.sort(function(a, b) {
							return a.seq - b.seq;
						});
						
						var i = 0;
						
						function processNext() {
							// 리스트의 모든 결재자 처리하면 다음 콜백 실행
							if (i >= list.length) {
								if (typeof callback === 'function') callback();
								return;
							}
							
							var user = list[i];
							// user의 응답 이력 조회
							checkApprovalResponse(user.userIdx, function(resData) {
								// 결재자 테이블 렌더링
								console.log(JSON.stringify(resData));
								var typeLabel = '';
								var typeClass = '';
								if (user.type === 'coop') {
									typeLabel = '협조';
									typeClass = 'type-coop';
								} else if (user.type === 'approv') {
									typeLabel = '결재';
									typeClass = 'type-approv';
								} else if (user.type === 'ref') {
									typeLabel = '참조';
									typeClass = 'type-ref';
								}
								var $tag = $('<span>').addClass('type-tag').addClass(typeClass).text(typeLabel + ' ');
								
								var $name = $('<td>').append($tag).append($('<span>').text(user.userName + '(' + user.userPosition + ')'));
								var $status = $('<td>')
								var $resDate = $('<td>')
								if (resData && resData !== 'WAITING') {
									$status.text(resData.approvalStatus === 'APPROVED' ? '결재' : '반려');
									$resDate.text(resData.createdAt.substr(0,10));
								} else if(resData === 'WAITING') {
									$status.text('대기중');
									$resDate.text('');
								} else {
									$status.text('');
									$resDate.text('');
								}
								var $row = $('<tr>').append($name).append($status).append($resDate);
								$('#' + targetId).append($row);
								// 의견 리스트 렌더링
								if (resData && resData.comment) {
									var $item = $('<div>').addClass('comment-item')
													.text('🔸 ' + user.userName + '(' + user.userPosition + ')' + ': ' + resData.comment);
									$('#commentList').append($item)
								}
								i++;
								processNext(); // 재귀 호출
							});
						}
						processNext();
					}
					
					// 로그인한 사용자가 참조자인 경우 반려 비활성화
					var isRef = false;
					for (var i = 0; i < userList.length; i++) {
						var user = userList[i];
						if (user.type === 'ref' && user.userIdx === sessionUserIdx) {
							isRef = true;
							break;
						}
					}
					if (isRef) {
						$('#btnReject').prop('disabled', true).addClass('disabled');
					}
					
					// 콜백을 이용해서 협조자, 결재자, 참조자 순서로 순차 실행
					renderLineUserList(coopList, 'approvalLineList', function() {
						renderLineUserList(approvList, 'approvalLineList', function() {
							renderLineUserList(refList, 'cooperatorLineList');
						});
					});
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
			
	        // 예약 일정 관리 페이지(상세) 이동
	        $('#btnGoSchedule').click(function () {
	        	postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: programIdx, pageIndex: pageIndex, approvalReqIdx: idx });
	        });
			
 			// 결재 처리
 			$('#btnApprove').click(function () {
 				var comment = $('#approvalComment').val().trim();
 				handleApproval('APPROVED', comment);
 			});

 			// 반려 처리
 			$('#btnReject').click(function () {
 				var comment = $('#approvalComment').val().trim();
 				handleApproval('REJECTED', comment);
 			});

			// 취소 버튼 핸들러
			$('#btnCancel').click(function() {
				// 기안문 목록 페이지 이동
				postTo('${approvalListUrl}', { programIdx: programIdx, pageIndex: pageIndex });
			});

		});
	</script>
</body>
</html>