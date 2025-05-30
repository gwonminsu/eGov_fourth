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
	<h2 id="formTitle">예약 마감 기안문</h2>

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
		var idx = '${param.approvalReqIdx}'; // 기안문 idx
		// 상태 유지용 파라미터 변수
		var programScheduleIdx = '${param.programScheduleIdx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		var approvalLineIdx = null; // 기안문 라인 idx

		var fileList = [];
		
		// 첨부된 파일 리스트 렌더링
		function renderFileList() {
			$('#fileList').empty();
			fileList.forEach(function(file, i) {
				var name = file.name;
				var size = formatBytes(file.size);
				var $item = $('<div>').addClass('file-item').text(name + ' [' + size + '] ');
				$('#fileList').append($item);
			});
		}
		
		// 현재 날짜 반환
		function getToday() {
			var today = new Date();
			var year = today.getFullYear();
			var month = String(today.getMonth() + 1).padStart(2, '0');
			var day = String(today.getDate()).padStart(2, '0');
			return year + '-' + month + '-' + day;
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
					console.log(JSON.stringify(data));
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

			// 취소 버튼 핸들러
			$('#btnCancel').click(function() {
				// 예약 관리(상세) 페이지 이동
				postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: programIdx, programName: programName, date: date });
			});

		});
	</script>
</body>
</html>