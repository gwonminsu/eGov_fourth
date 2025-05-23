<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 페이지</title>

	<link rel="stylesheet" href="<c:url value='/css/tui-calendar.min.css'/>" />
	<link rel="stylesheet" href="<c:url value='/css/booking.css'/>" />
	
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
	<!-- 일정 상세 페이지 URL -->
	<c:url value="/programBooking.do" var="programBookingUrl"/>
	<!-- 관리자 페이지 URL -->
	<c:url value="/bookManage.do" var="bookManageUrl"/>

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
    <h2>예약 페이지</h2>
    
	<!-- 사용자 로그인 상태 영역 -->
	<div id="userInfo">
		<span id="loginMsg"></span>
		<button type="button" id="btnGoLogin">로그인하러가기</button>
		<button type="button" id="btnLogout">로그아웃</button>
	</div>
	
	<!-- 프로그램 선택 리스트 -->
    <div id="programListArea">
    	<div id="programListWrapper" class="program-scroll"></div>
   	</div>
   	
   	<div id="calendarHeader">
   		<button id="btnPrevMonth">◀</button>
		<input type="number" id="yearInput" min="2000" max="2100" />
		<span>년</span>
		<input type="number" id="monthInput" min="1" max="12" />
		<span>월</span>
		<button id="btnNextMonth">▶</button>
	</div>

   	<!-- 캘린더 -->
   	<div id='calendar'></div>
   	
   	<button type="button" id="btnGoBookManage" style="display: none;">관리자 페이지</button>
    
    <script>
    	var idx = '${param.programIdx}';
    	var currentProgramIdx = null;
    	var currentProgramName = '';
    	var programSchedules = [];
    	var calendar;
    	
    	// xss 공격 방지와 동시에 줄바꿈 적용
    	function escapeHtml(str) {
    	    return str.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;").replace(/'/g, "&#039;");
    	}
    	function safeHtmlWithBr(str) {
    	    return escapeHtml(str).replace(/\n/g, "<br>");
    	}
    	
    	// 프로그램 버튼 렌더
    	function renderProgramButtons(programList) {
    	    var $wrapper = $('#programListWrapper');
    	    $wrapper.empty();
    	    console.log(idx);

    	    programList.forEach(function(program) {
    	    	var $image = $('<img>').attr('src', program.imageUrl).attr('alt', program.idx).addClass('program-img');
    	    	var $text = $('<div>').addClass('program-title').text(program.programName)
    	    							.append($('<div>').addClass('program-desc').html(safeHtmlWithBr(program.description)));
    	        var $btn = $('<div>').addClass('program-card').data('idx', program.idx).data('name', program.programName).click(onProgramBtnClick)
    	        							.append($image).append($text)
    	        // 파라미터로 받아온 프로그램 idx에 해당하는 버튼 클릭
    	        if (program.idx == idx) {
    	            $btn.trigger('click');
    	        }
    	        $wrapper.append($btn);
    	    });
    	}
    	
    	// 프로그램 버튼 핸들러
    	function onProgramBtnClick() {
            $('.program-card').removeClass('active');
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
					console.log(JSON.stringify(programSchedules));
					
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
		            
		        	data.forEach(function(program) {
		        		if(!program.imageUrl) {
		        			program.imageUrl = '/uploads/images/no-img.png';
		        		}
		        	});
		        	
		        	// console.log('data: ' + JSON.stringify(data));
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
				// 사용자가 관리자면 버튼 
				if(isAdmin == 'true') {
					$('#btnGoBookManage').show();
				}
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
						var bookingCtn = 0; // 임시(추후에 일정에 예약한 사람수 칼럼 추가 예정)
						var possible = bookingCtn < schedule.raw.capacity ? ' 예약 가능' : ' 예약 불가';
						var date = schedule.raw.startDatetime.substr(0,10);
						var start = schedule.raw.startDatetime.substr(11,5);
						var end = schedule.raw.startDatetime.substr(11,5);
						$status = $('<span>').addClass('scheduleStatus').text(start + possible + ' (' + bookingCtn + '/' + schedule.raw.capacity + ')');
						$btn = $('<span>').addClass('btnGoProgramBooking').attr('data-id', schedule.id).attr('data-date', date)
											.append($status);
						return $btn.prop('outerHTML');
					}
				}
	        }
	        calendar = new Calendar('#calendar', options);
	        
	     	// 초기 년/월 input 채우기
	        var today = calendar.getDate();
	        $('#yearInput').val(today.getFullYear());
	        $('#monthInput').val(today.getMonth() + 1);

	        // 현재 캘린더 기준으로 input 갱신
	        function updateDateInputs() {
	            var currentDate = calendar.getDate();
	            $('#yearInput').val(currentDate.getFullYear());
	            $('#monthInput').val(currentDate.getMonth() + 1);
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
	        
	        // 예약 일정 관리 페이지(상세) 이동 버튼 핸들러
	        $('#calendar').on('click', '.btnGoProgramBooking', function(e){
	        	e.stopPropagation();
	        	var programScheduleIdx = $(this).data('id');
	        	var date = $(this).data('date');
	        	console.log(programScheduleIdx);
	        	postTo('${programBookingUrl}', { idx: programScheduleIdx, programIdx: currentProgramIdx, programName: currentProgramName, date: date });
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
	        
			// 관리자 페이지 버튼 핸들러
	        $('#btnGoBookManage').click(function() {
	        	// 관리자 페이지로 이동
				postTo('${bookManageUrl}', {});
			});
			
	    });
    </script>
</body>
</html>