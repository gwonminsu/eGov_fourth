<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약정보 변경</title>
	
	<link rel="stylesheet" href="<c:url value='/css/scheduleDetail.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 목록 페이지 URL -->
	<c:url value="/bookManage.do" var="bookManageUrl"/>
	<!-- 프로그램 일정 수정 API URL -->
    <c:url value="/api/schedule/updateSchedule.do" var="updateApi"/>
   	<!-- 현재 날짜의 프로그램 일정 조회 API URL -->
    <c:url value="/api/schedule/getProgramSchedule.do" var="getProgramScheduleApi"/>
	
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
	</script>
</head>
<body>

	<h2>예약정보 변경</h2>
	
	<h4>예약정보 확인</h4>
	
	<table class="form-table book-table">
		<tr>
			<th>체험명</th>
			<td>
				<div id="programName"></div>
			</td>
			<th>날짜</th>
			<td>
				<div id="scheduleDate"></div>
			</td>
		</tr>
		<tr>
			<th>시간</th>
			<td>
				<div id="scheduleTime"></div>
			</td>
			<th>제한인원수</th>
			<td>
				<input type="number" id="capacity" name="capacity" min="1" required /> 명
				<span class="info-text">(예약건수 : n, 예약 인원: n)</span>
			</td>
		</tr>
	</table>
	
	<div class="btn-area1">
			<button id="btnClose">예약마감</button>
			<button id="btnSubmit" style="background-color: #b48cf3; color: white;">저장</button>
	</div>
	
	<br/>
	
	<!-- 예약자 정보 테이블 -->
	<table class="form-table booker-table">
		<thead>
			<tr>
				<th>번호</th>
				<th>체험명</th>
				<th>예약구분</th>
				<th>예약시간</th>
				<th>예약자명</th>
				<th>예약자수</th>
				<th>예약자확인</th>
				<th>삭제</th>
				<th>수료증</th>
			</tr>
		</thead>
		<tbody id="bookerList">
			<tr>
				<td>1</td>
				<td>???????????????????????????</td>
				<td>일반</td>
				<td>YYYY-MM-DD(hh:mm)</td>
				<td>?</td>
				<td>n</td>
				<td><button class="btn-confirm">확인</button></td>
				<td><button class="btn-delete">삭제</button></td>
				<td><button class="btn-print">출력</button></td>
			</tr>
		</tbody>
	</table>
	
	<div class="btn-area2">
		<button id="btnCancel">돌아가기</button>
		<button id="btnAddBooker" style="background-color: #ff6e00; color: white;">예약자 추가</button>
	</div>
	
	<script>
		var idx = '${param.idx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		
		$(document).ready(function () {
			$('#programName').text(programName);
			$('#scheduleDate').text(date);
			console.log(programIdx);
			
    		// 이 프로그램 일정 조회 요청
    		$.ajax({
    			url: '${getProgramScheduleApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ idx: idx }),
    			success: function(schedule){
					console.log(JSON.stringify(schedule));
					var start = schedule.startDatetime.substr(11,5);
					var end = schedule.endDatetime.substr(11,5);
					$('#scheduleTime').text(start + ' - ' + end);
					$('#capacity').val(parseInt(schedule.capacity));
    			},
				error: function(){
					alert('현재 프로그램 일정 조회 중 에러 발생');
				}
    		});
		
			// 돌아가기
			$('#btnCancel').on('click', function () {
				postTo('${bookManageUrl}', { programIdx: programIdx });
			});
		
			// 저장 버튼
			$('#btnSubmit').on('click', function () {
	        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
	            var capacity = parseInt($('#capacity').val());

	            // 빈 값 확인
	            if (!capacity) {
	                alert('제한 인원 수 값을 입력해주세요.');
	                return;
	            }

	            // 인원 수 유효성 검증 (정수, 1 이상)
	            if (!/^\d+$/.test(capacity) || parseInt(capacity) < 1) {
	                alert('제한 인원은 1명 이상이어야 합니다.');
	                return;
	            }
	            
	    		// 프로그램 일정 수정 요청
	    		$.ajax({
	    			url: '${updateApi}',
	    			type:'POST',
	    			contentType: 'application/json',
	    			dataType: 'json',
	    			data: JSON.stringify({ idx: idx, capacity: capacity }),
	    			success: function(res){
						if (res.error) {
							alert(res.error);
						} else {
							alert('프로그램 일정 수정 완료');
							postTo('${bookManageUrl}', { programIdx: programIdx });
			            }
	    			},
					error: function(xhr){
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '프로그램 일정 수정 중 에러 발생';
							}
						}
						alert(errMsg);
					}
	    		});

			});
		
			// 예약마감 버튼(기안문 작성 예정)
			$('#btnClose').on('click', function () {
				alert('예약마감 처리 예정');
			});
		
			// 예약자 추가
			$('#btnAddBooker').on('click', function () {
				alert('예약자 추가 기능 구현 예정 ');
			});
		
			// 예약자 테이블 내부 버튼
			$('#bookerList').on('click', '.btn-confirm', function () {
				alert('예약자 확인 처리 예정');
			});
			$('#bookerList').on('click', '.btn-delete', function () {
				if (confirm('정말 삭제하시겠습니까?')) {
					alert('삭제 처리 예정');
				}
			});
			$('#bookerList').on('click', '.btn-print', function () {
				alert('수료증 출력 기능 구현 예정');
			});
		});
	</script>

</body>
</html>
