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
	<!-- 프로그램 일정 생성 API URL -->
    <c:url value="/api/schedule/createSchedule.do" var="createApi"/>
   	<!-- 현재 날짜의 프로그램 일정 조회 API URL -->
    <c:url value="/api/schedule/getDateScheduleList.do" var="getDateScheduleListApi"/>
    <!-- 현재 날짜의 프로그램 일정 조회 API URL -->
    <c:url value="/api/schedule/getMonthScheduleList.do" var="getMonthScheduleListApi"/>
    
	
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
		<tr>
			<th>등록된 일정</th>
			<td colspan="3">
				<div id="scheduleListArea">
					<!-- 여기에 태그 형식으로 "[2025-xx-xx] hh:mm - hh:mm" 내용으로 세로 배치로 나열될 예정  -->
				</div>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnCancel">돌아가기</button>
		<button id="btnSubmit">저장</button>
	</div>

	<script>
		var idx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜(2025-05-15)
		var monthDate = '${param.monthDate}'; // 일괄 등록용 달 날짜(2025-05)
		var programName = '${param.programName}'; // 프로그램 이름
		
		var mode = monthDate ? 'bulk' : 'single';
		
		var existingSchedules = []; // 일정 충돌 체크용
		
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
			if (mode === 'bulk') {
				$('#scheduleDate').text(monthDate);
				$('#btnSubmit').text('일괄 저장');
			} else {
				$('#scheduleDate').text(date);
			}
			generateTimeOptions('#scheduleStartTime', 9, 18);
			generateTimeOptions('#scheduleEndTime', 9, 18);
			
			var req = mode === 'bulk' ? { programIdx: idx, month: monthDate } : { programIdx: idx, date: date };
			
    		// 현재 날짜의 프로그램 일정 조회 요청
    		$.ajax({
    			url: mode === 'bulk' ? '${getMonthScheduleListApi}' : '${getDateScheduleListApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify(req),
    			success: function(list){
					console.log(JSON.stringify(list));
					existingSchedules = list;
					
					var $listView = $('#scheduleListArea');
					$listView.empty();
					
					if(list.length === 0) {
						$listView.append($('<div>').addClass('no-data-text').text('아직 등록된 일정이 없습니다.'))
					} else {
						list.forEach(function(item) {
							var itemDate = item.startDatetime.substr(0,10) // 날짜 구간만 자르기
							var start = item.startDatetime.substr(11,5); // 시간 구간만 자르기
							var end = item.endDatetime.substr(11,5);
							$listView.append($('<div>').addClass('schedule-item').text('[' + itemDate + '] ' + start + ' - ' + end));
						})
					}
    			},
				error: function(){
					alert(date + '의 프로그램 일정 조회 중 에러 발생');
				}
    		});
			
			// 시작 시간 선택 시 종료 시간 필터링
			$('#scheduleStartTime').on('change', function() {
				const selectedStart = $(this).val();
				generateEndTimeOptions(selectedStart, '#scheduleEndTime', 9, 18);
			});
	    	
	        $('#btnSubmit').click(function(e){
	        	if (mode === 'bulk') {
	        		if(!confirm('일괄 저장 시 겹치는 일정은 제외하고 저장됩니다. 등록하시겠습니까?')) return;
	        	}
	        	if(!confirm('일정을 등록하시겠습니까?')) return;
	        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
	            var startTime = $('#scheduleStartTime').val();
	            var endTime = $('#scheduleEndTime').val();
	            var capacity = parseInt($('#capacity').val());

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
	            
				var payload = [];
				
		        if (mode === 'bulk') {
		        	var year = monthDate.split('-')[0];
		        	var month = monthDate.split('-')[1];
		        	var lastDay = new Date(year, month, 0).getDate();
		        
		        	// 달의 첫번째 날 마지막 날까지 반복
		        	for (var d = 1; d <= lastDay; d++) {
		        		var dayStr = String(d).padStart(2, '0');
		        		var fullDate = year + '-' + month + '-' + dayStr;
		        		var dayOfWeek = new Date(fullDate).getDay();
		        		if (dayOfWeek === 0) continue; // 일요일(휴일이면 payload 배열 추가 패스)
		        
		        		var newStart = new Date(fullDate + 'T' + startTime + ':00');
		        		var newEnd = new Date(fullDate + 'T' + endTime + ':00');
		        
		        		var conflict = false;
		        		for (var i = 0; i < existingSchedules.length; i++) {
		        			var item = existingSchedules[i];
		        			var itemStart = new Date(item.startDatetime.replace(' ', 'T'));
		        			var itemEnd = new Date(item.endDatetime.replace(' ', 'T'));
		        			if (newStart < itemEnd && itemStart < newEnd) {
		        				conflict = true;
		        				break;
		        			}
		        		}
		        		if (conflict) continue; // 충돌되는 날도 패스
		        
		        		payload.push({
		        			createUserIdx: sessionUserIdx,
		        			programIdx: idx,
		        			startDatetime: fullDate + ' ' + startTime + ':00',
		        			endDatetime: fullDate + ' ' + endTime + ':00',
		        			capacity: capacity
		        		});
		        	}
		        
		        	if (payload.length === 0) {
		        		alert('등록 가능한 일정이 없습니다.');
		        		return;
		        	}
		        } else {
		            // 일정 충돌 체크
		            var newStart = new Date(date + ' ' + startTime + ':00');
		            var newEnd = new Date(date + ' ' + endTime + ':00');
		         	// 입력한 시간대와 기존에 스케쥴의 시간대가 겹치는지 하나씩 확인
					for (var i = 0; i < existingSchedules.length; i++) {
						var item = existingSchedules[i];
						var itemStart = new Date(item.startDatetime.replace(' ', 'T'));
						var itemEnd = new Date(item.endDatetime.replace(' ', 'T'));
						if (newStart < itemEnd && itemStart < newEnd) {
							alert('선택한 시간대에 이미 등록된 일정이 있습니다.');
							return;
						}
					}
		         	
		            payload.push({
		            	createUserIdx: sessionUserIdx,
		            	programIdx: idx,
		            	startDatetime: date + ' ' + startTime + ':00',
		            	endDatetime: date + ' ' + endTime + ':00',
		            	capacity: capacity
		            });
		        }

	            console.log("제출할 데이터:", payload);
	            
	    		// 프로그램 일정 등록 요청
 	    		$.ajax({
	    			url: '${createApi}',
	    			type:'POST',
	    			contentType: 'application/json',
	    			dataType: 'json',
	    			data: JSON.stringify(payload),
	    			success: function(res){
						if (res.error) {
							alert(res.error);
						} else if(res.skipped && res.skipped.length > 0) {
							console.log('일부 일정은 충돌되어 등록되지 않았습니다.\n' + res.skipped.join('\n'));
						} else {
							alert('프로그램 일정 등록 완료');
			            }
						postTo('${bookManageUrl}', { programIdx: idx });
	    			},
					error: function(xhr){
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '프로그램 일정 등록 중 에러 발생';
							}
						}
						alert(errMsg);
					}
	    		});
	    		
	        });
	    	
	    	$('#btnCancel').click(function() {
	    		// 예약 관리자 페이지 이동
	    		postTo('${bookManageUrl}', { programIdx: idx });
	    	});
	    	
	    });
	</script>
</body>
</html>