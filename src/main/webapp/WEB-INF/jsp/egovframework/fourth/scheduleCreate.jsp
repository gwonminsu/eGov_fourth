<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 일정 등록 페이지</title>
	
	<link rel="stylesheet" href="<c:url value='/css/scheduleCreate.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

	<!-- 목록 페이지 URL -->
	<c:url value="/bookManage.do" var="bookManageUrl"/>
	<!-- 임시 API URL -->
    <c:url value="/api/manage/createSchedule.do" var="createApi"/>
	
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
	<h2 id="formTitle">예약 일정 생성</h2>
	<h4>예약 정보 확인</h4>
	
	<table class="form-table">
		<tr>
			<th>체험명</th>
			<td colspan="3">
				<div id="programName"></div>
			</td>
		</tr>
		<tr>
			<th>날짜</th>
			<td colspan="3">
				<div id="scheduleDate"></div>
			</td>
		</tr>
		<tr>
			<th>시작 시간</th>
			<td>
				<select id="scheduleStartTime"></select>
			</td>
			<th>종료 시간</th>
			<td>
				<select id="scheduleEndTime"></select>
			</td>

		</tr>
		<tr>
			<th>제한인수</th>
			<td colspan="3">
				<input type="number" id="capacity" name="capacity" min="1" required />명
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnCancel">돌아가기</button>
		<button id="btnSubmit">저장</button>
	</div>

	<script>
		var idx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		// 시간 선택 옵션 생성기
		function generateTimeOptions(selector, open, close) {
			var $select = $(selector);
			$select.empty();

			for (var hour = open; hour <= close; hour++) {
				for (var min of [0, 30]) {
					var hourStr = String(hour).padStart(2, '0');
					var minStr = (min === 0) ? '00' : '30';
					var time = hourStr + ':' + minStr;
					if (time !== close + ':30') {
						$select.append($('<option>').val(time).text(time));
					}
				}
			}
		}
		
		// 시간 선택 옵션 생성기에서 종료 시간 옵션을 시작 시간 이후만 보이게 필터링
		function generateEndTimeOptions(startTime, selector, open, close) {
			var $select = $(selector);
			$select.empty();
			var hasOption = false; // 옵션 있는지 확인하는 변수

			for (var hour = open; hour <= close; hour++) {
				for (var min of [0, 30]) {
					var hourStr = String(hour).padStart(2, '0');
					if (min === 0) {
						minStr = '00';
					} else {
						minStr = '30';
					}
					var time = hourStr + ':' + minStr;
					
					// 시작 시간보다 큰 시간만 추가
					if (time > startTime && time !== close + ':30') {
						$select.append($('<option>').val(time).text(time));
						hasOption = true;
					}
					
				}
			}
			if (!hasOption) {
				$select.append($('<option>').val('').text('종료 가능한 시간 없음').prop('disabled', true));
			}
		}
		
		$(function(){
			$('#programName').text(programName);
			$('#scheduleDate').text(date);
			generateTimeOptions('#scheduleStartTime', 9, 18);
			generateTimeOptions('#scheduleEndTime', 9, 18);
			
			// 시작 시간 선택 시 종료 시간 필터링
			$('#scheduleStartTime').on('change', function() {
				const selectedStart = $(this).val();
				generateEndTimeOptions(selectedStart, '#scheduleEndTime', 9, 18);
			});
	    	
	        $('#btnSubmit').click(function(e){
	        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
	            var startTime = $('#scheduleStartTime').val();
	            var endTime = $('#scheduleEndTime').val();
	            var capacity = $('#capacity').val();

	            // 빈 값 확인
	            if (!startTime || !endTime || !capacity) {
	                alert('모든 값을 입력해주세요.');
	                return;
	            }

	            // 시간 순서 검증
	            if (startTime >= endTime) {
	                alert('종료 시간은 시작 시간보다 늦어야 합니다.');
	                return;
	            }

	            // 인원 수 유효성 검증 (정수, 1 이상)
	            if (!/^\d+$/.test(capacity) || parseInt(capacity) < 1) {
	                alert('제한 인원은 1명 이상이어야 합니다.');
	                return;
	            }

	            const payload = {
	                programIdx: idx,
	                date: date,
	                startTime: startTime,
	                endTime: endTime,
	                capacity: capacity
	            };

	            console.log("제출할 데이터:", payload);
	    		
	        });
	    	
	    	$('#btnCancel').click(function() {
	    		// 예약 관리자 페이지 이동
	    		postTo('${bookManageUrl}', { programIdx: idx });
	    	});
	    	
	    });
	</script>
</body>
</html>