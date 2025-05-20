<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 일정 관리 페이지</title>
	<link rel="stylesheet" href="<c:url value='/css/bookManage.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<link href="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.10.2/fullcalendar.min.css" rel="stylesheet">
	<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/moment.js/2.29.1/moment.min.js"></script>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/fullcalendar/3.10.2/fullcalendar.min.js"></script>
	
	<!-- 프로그램 리스트 가져오는 api 호출 url -->
	<c:url value="/api/program/list.do" var="programListUrl"/>
	<!-- 로그인 페이지 url -->
	<c:url value="/login.do" var="loginUrl"/>
	<!-- 로그아웃 api 호출 url -->
	<c:url value="/api/user/logout.do" var="logoutUrl" />
	<!-- 프로그램 등록/수정 페이지 url -->
	<c:url value="/programForm.do" var="programFormUrl"/>
	<!-- 목록 페이지 URL -->
	<c:url value="/booking.do" var="bookingUrl"/>
	
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
   	
   	<!-- 캘린더 -->
   	<div id='calendar'></div>
    
    <button type="button" id="btnCreateProgram">프로그램 신규 등록</button>
    <button type="button" id="btnEditProgram" style="display: none;">선택한 프로그램 수정</button>
    <button type="button" id="btnGoBooking">예약 페이지로 돌아가기</button>
    
    <script>
    	var currentProgramIdx = null;
    	
    	function renderProgramButtons(programList) {
    	    var $wrapper = $('#programListWrapper');
    	    $wrapper.empty();

    	    programList.forEach(program => {
    	        var $btn = $('<button>').addClass('program-btn').text(program.programName).data('idx', program.idx)
    	            .click(function () {
    	                $('.program-btn').removeClass('active');
    	                $(this).addClass('active');
    	                currentProgramIdx = $(this).data('idx');
    	                $('#btnEditProgram').show();
    	            });
    	        $wrapper.append($btn);
    	    });
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
				$('#welcomeMsg').text('');
				$('#btnGoLogin').show();
				$('#btnLogout').hide();
	        }
	        
	        var calendar = $('#calendar').fullCalendar({
	            header: {
	                left: 'prev,next today',
	                center: 'title',
	                right: 'month,agendaWeek,agendaDay'
	            },
	            selectable: true,
	            selectHelper: true,
	            editable: true,
	            eventLimit: true,
	            events: function(start, end, timezone, callback) {
	                // AJAX를 통해 서버에서 일정 데이터를 가져옵니다.
	                
	            },
	        });
	    	
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
	        
	        // 프로그램 등록 버튼 핸들러
	        $('#btnCreateProgram').click(function() {
	        	// 설문 등록 페이지로 이동
				postTo('${programFormUrl}', {});
			});
			
	        // 프로그램 수정 버튼 핸들러
	        $('#btnEditProgram').click(function() {
	        	// 설문 수정 페이지로 이동
				postTo('${programFormUrl}', { idx: currentProgramIdx });
			});
			
			// 설문 목록 버튼 핸들러
	        $('#btnGoBooking').click(function() {
	        	// 설문 목록 페이지로 이동
				postTo('${bookingUrl}', {});
			});
			
	    });
    </script>
</body>
</html>