<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 일정 관리 페이지</title>

	<link rel="stylesheet" href="<c:url value='/css/tui-calendar.min.css'/>" />
	<link rel="stylesheet" href="<c:url value='/css/bookManage.css'/>" />
	
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<script src="<c:url value='/js/tui/tui-code-snippet.min.js'/>"></script>
    <script src="<c:url value='/js/tui/tui-dom.min.js'/>"></script>
    <script src="<c:url value='/js/tui/tui-calendar.min.js'/>"></script>
	
	<!-- 프로그램 리스트 가져오는 api 호출 url -->
	<c:url value="/api/program/list.do" var="programListUrl"/>
   	<!-- 현재 날짜의 프로그램 일정 조회 API URL -->
    <c:url value="/api/schedule/getProgramScheduleList.do" var="getProgramScheduleListApi"/>
	<!-- 로그인 페이지 url -->
	<c:url value="/login.do" var="loginUrl"/>
	<!-- 로그아웃 api 호출 url -->
	<c:url value="/api/user/logout.do" var="logoutUrl" />
	<!-- 프로그램 등록/수정 페이지 url -->
	<c:url value="/programForm.do" var="programFormUrl"/>
	<!-- 예약자(메인) 페이지 URL -->
	<c:url value="/booking.do" var="bookingUrl"/>
	<!-- 예약 일정 생성 페이지 URL -->
	<c:url value="/scheduleCreate.do" var="scheduleCreateUrl"/>
	<!-- 일정 상세 페이지 URL -->
	<c:url value="/scheduleDetail.do" var="scheduleDetailUrl"/>

	<!-- 세션에 담긴 사용자 이름을 JS 변수로 -->
	<script>
		// 서버에서 렌더링 시점에 loginUser.userName 이 없으면 빈 문자열로
		var loginUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.isAdmin}" default="" />';
		
		// GET아닌 POST로 진입하기
		function postTo(url, params) {
		    // 폼 요소 생성
		    var form = $('<form>').attr({ method: 'POST', action: url });
		    // hidden input으로 파라미터 삽입
		    $.each(params, function(name, value) {
		        $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
		    });
		    // body에 붙이고 제출
		    form.appendTo('body').submit();
		}
		
	</script>
</head>
<body>
    <h2>🛠️ 관리자 페이지(예약 일정 관리)</h2>
    
	<!-- 사용자 로그인 상태 영역 -->
	<div id="userInfo">
		<span id="loginMsg"></span>
		<button type="button" id="btnGoLogin">로그인하러가기</button>
		<button type="button" id="btnLogout">로그아웃</button>
	</div>
	
	<!-- 프로그램 선택 리스트 -->
    <div id="programListArea">
    	<div id="programListWrapper" class="program-scroll">
		</div>
   	</div>
   	
   	<div id="calendarUI">
		<input type="number" id="yearInput" min="2000" max="2100" />
		<span>년</span>
		<input type="number" id="monthInput" min="1" max="12" />
		<span>월</span>
		<button id="btnPrevMonth">◀</button>
		<button id="btnNextMonth">▶</button>
	</div>
	
	<div id="calendarHeader">
		<div id="calendarInfo">
			<div style="font-weight: bold">예약 일정 관리</div>
			<div id="cDate"></div>
		</div>
		<button id="btnGoNewMonthSchedule">프로그램일정 일괄 생성</button>
	</div>

   	<!-- 캘린더 -->
   	<div id='calendar'></div>
    
    <button type="button" id="btnCreateProgram">프로그램 신규 등록</button>
    <button type="button" id="btnEditProgram" style="display: none;">선택한 프로그램 수정</button>
    <button type="button" id="btnGoBooking">예약 페이지로 돌아가기</button>
    
    <script>
    	var idx = '${param.programIdx}';
    	var currentProgramIdx = null;
    	var currentProgramName = '';
    	var programSchedules = [];
    	var calendar;
    	
    	// 프로그램 버튼 렌더
    	function renderProgramButtons(programList) {
    	    var $wrapper = $('#programListWrapper');
    	    $wrapper.empty();
    	    console.log(idx);

    	    programList.forEach(function(program) {
    	        var $btn = $('<button>').addClass('program-btn').text(program.programName)
    	        				.data('idx', program.idx).data('name', program.programName).click(onProgramBtnClick);
    	        // 파라미터로 받아온 프로그램 idx에 해당하는 버튼 클릭
    	        if (program.idx == idx) {
    	            $btn.trigger('click');
    	        }
    	        $wrapper.append($btn);
    	    });
    	}
    	
    	// 프로그램 버튼 핸들러
    	function onProgramBtnClick() {
            $('.program-btn').removeClass('active');
            $(this).addClass('active');
            currentProgramIdx = $(this).data('idx');
            currentProgramName = $(this).data('name');
            $('#btnEditProgram').show();
            calendar.clear();
            
            // 프로그램의 전체 일정 조회
    		$.ajax({
    			url: '${getProgramScheduleListApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ programIdx: currentProgramIdx }),
    			success: function(list){
					programSchedules = list;
					// console.log(JSON.stringify(programSchedules));
					
					// Toast UI 에 맞는 스케줄 객체로 변환
					var schedules = programSchedules.map(function(item){
						return {
							id: item.idx,
							calendarId: item.programIdx,
							title: item.startDatetime.substr(11,5) + ' - ' + item.endDatetime.substr(11,5),
							category: 'time',
							start: item.startDatetime.replace(' ', 'T'),
							end: item.endDatetime.replace(' ', 'T'),
							raw: item
						};
					});
					calendar.createSchedules(schedules); // 캘린더에 일정 등록
    			},
				error: function(){
					alert('프로그램 일정 조회 중 에러 발생');
				}
    		});
            
            calendar.render();
    	}
    	
	    $(function(){
		    // 프로그램 리스트 불러오기
		    $.ajax({
		        url: '${programListUrl}',
		        type: 'POST',
		        contentType: 'application/json',
		        dataType: 'json',
		        data: JSON.stringify({}),
		        success: function(data) {
		            if (data.length === 0) {
		                // 프로그램이 아예 없는 경우
		                $('#programListWrapper').append($('<span>').addClass('no-data-text').text('등록된 프로그램 없음'));
		                return;
		            }
		            renderProgramButtons(data);
		        },
		        error: function() {
		            alert('프로그램 목록을 불러오는데 실패했습니다.');
		        }
		    });
	    	
	        // 로그인 여부에 따라 버튼 토글
	        if (loginUserName) {
				$('#loginMsg').text('현재 로그인 중인 사용자: ' + loginUserName);
				$('#btnGoLogin').hide();
				$('#btnLogout').show();
	        } else {
				$('#btnGoLogin').show();
				$('#btnLogout').hide();
	        }
	        
	        /* ----------------------------------- 여기부터 캘린더 ----------------------------------- */
	        
	        // 토스트 캘린더
	        var Calendar = tui.Calendar;
	        var options = {
				defaultView: 'month',  // 월 별로 보기
				taskView: false,  // 할 일 뷰 끄기
				scheduleView: ['time'], // 시간 일정만
				useFormPopup: false, // 기본 팝업 끄기
				useDetailPopup: false, // 기본 디테일 팝업 끄기
				month: {
					startDayOfWeek: 1, // 월요일부터 시작
					daynames: ['일', '월', '화', '수', '목', '금', '토'],  // 요일 한글 설정
				},
				template: {
					monthGridHeader: function(date) {
						if (date.day === 0) {
							return parseInt(date.date.substr(8,2)) + '<br/><span style="font-size: 12px;">휴일</span></span>';
						}
						return parseInt(date.date.substr(8,2));
					},
					time: function(schedule) {
						// console.log(JSON.stringify(schedule));
						var bookerCnt = schedule.raw.bookerCount; // 예약인 수
						var date = schedule.raw.startDatetime.substr(0,10);
						var start = schedule.raw.startDatetime.substr(11,5);
						var end = schedule.raw.startDatetime.substr(11,5);
						$tag = $('<span>').addClass('timeTag').text(start);
						$status = $('<span>').addClass('scheduleStatus').text('예약 상황(' + bookerCnt + '/' + schedule.raw.capacity + ')');
						$btn = $('<span>').addClass('btnGoSchedule').attr('data-id', schedule.id).attr('data-date', date)
											.append($tag).append($status);
						return $btn.prop('outerHTML');
					},
					monthGridFooter: function(date) {
						$btn = $('<button>').addClass('btnGoNewSchedule').attr('data-date', date.date).text('신규 등록');
						/* {"date":"2025-04-28","month":4,"day":1,"isToday":false,
							"ymd":"20250428","hiddenSchedules":0,"width":14.285714285714286,
							"left":0,"color":"rgba(51, 51, 51, 0.4)",
							"backgroundColor":"inherit","isOtherMonth":true} */
						if (!currentProgramIdx) {
							return '';
						}
						if (date.isOtherMonth || date.day === 0) {
							return '';
						}
						return $btn.prop('outerHTML'); // monthGridFooter는 html 문자열을 반환하므로
					}
				}
	        }
	        calendar = new Calendar('#calendar', options);
	        
	     	// 초기 년/월 input 채우기
	        var today = calendar.getDate();
	        $('#yearInput').val(today.getFullYear());
	        $('#monthInput').val(today.getMonth() + 1);
	        $('#cDate').text(today.getFullYear() + '년 ' + (today.getMonth() + 1) + '일');

	        // 현재 캘린더 기준으로 input 갱신
	        function updateDateInputs() {
	            var currentDate = calendar.getDate();
	            $('#yearInput').val(currentDate.getFullYear());
	            $('#monthInput').val(currentDate.getMonth() + 1);
	            $('#cDate').text(currentDate.getFullYear() + '년 ' + (currentDate.getMonth() + 1) + '일');
	        }
	        
	        // 이전 달 이동 버튼 핸들러
	        $('#btnPrevMonth').click(function () {
	            calendar.prev();
	            updateDateInputs();
	        });

	        // 다음 달 이동 버튼 핸들러
	        $('#btnNextMonth').click(function () {
	            calendar.next();
	            updateDateInputs();
	        });

	        // 년/월 인풋으로 이동
	        $('#yearInput, #monthInput').on('change', function () {
	            var year = parseInt($('#yearInput').val());
	            var month = parseInt($('#monthInput').val());
	            if (!isNaN(year) && !isNaN(month) && month >= 1 && month <= 12) {
	                calendar.setDate(new Date(year, month - 1, 1));
	            }
	        });
	        
	        // 일정 생성 버튼 핸들러
	        $('#calendar').on('click', '.btnGoNewSchedule', function(e){
				e.stopPropagation();
				var date = $(this).data('date');
				postTo('${scheduleCreateUrl}', { programIdx: currentProgramIdx, programName: currentProgramName, date: date });
			});
	        
	        // 예약 일정 관리 페이지(상세) 이동 버튼 핸들러
	        $('#calendar').on('click', '.btnGoSchedule', function(e){
	        	e.stopPropagation();
	        	var programScheduleIdx = $(this).data('id');
	        	var date = $(this).data('date');
	        	console.log(programScheduleIdx);
	        	postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: currentProgramIdx, programName: currentProgramName, date: date });
	        });
	        
	        /* ----------------------------------- 여기까지 캘린더 ----------------------------------- */
	    	
	    	// 로그인 버튼 핸들러
	    	$('#btnGoLogin').click(function() {
	    		// 로그인 페이지 이동
	    		postTo('${loginUrl}', {});
	    	});
	    	
	        // 로그아웃
	        $('#btnLogout').click(function(){
				$.ajax({
					url: '${logoutUrl}',
					type: 'POST',
					success: function(){
						location.reload();
					},
					error: function(){
						alert('로그아웃 중 오류 발생');
					}
				});
	        });
	        
	        // 프로그램 일정 일괄 등록 버튼 핸들러
	        $('#btnGoNewMonthSchedule').click(function() {
	        	if (!currentProgramIdx) {
	        		alert('먼저 프로그램을 선택하세요');
	        		return;
	        	}
	        	var year = calendar.getDate().getFullYear();
	        	var month = calendar.getDate().getMonth() + 1;
	        	var monthDate = year + '-' + String(month).padStart(2, "0")
	        	console.log(monthDate);
	        	// 프로그램 등록 페이지로 이동
	        	postTo('${scheduleCreateUrl}', { programIdx: currentProgramIdx, programName: currentProgramName, monthDate: monthDate });
			});
	        
	        // 프로그램 등록 버튼 핸들러
	        $('#btnCreateProgram').click(function() {
	        	// 프로그램 등록 페이지로 이동
				postTo('${programFormUrl}', { programIdx: currentProgramIdx });
			});
			
	        // 프로그램 수정 버튼 핸들러
	        $('#btnEditProgram').click(function() {
	        	// 프로그램 수정 페이지로 이동
				postTo('${programFormUrl}', { idx: currentProgramIdx });
			});
			
			// 예약 페이지 버튼 핸들러
	        $('#btnGoBooking').click(function() {
	        	// 예약 페이지로 이동
				postTo('${bookingUrl}', {});
			});
			
	    });
    </script>
</body>
</html>