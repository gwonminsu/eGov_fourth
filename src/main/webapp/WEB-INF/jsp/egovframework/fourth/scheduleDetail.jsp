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
   	<!-- 예약 인원 직접 추가 페이지 URL -->
	<c:url value="/addBooker.do" var="addBookerUrl"/>
   	<!-- 예약 마감 기안문 작성 페이지 URL -->
	<c:url value="/approvalReq.do" var="approvalReqUrl"/>
   	<!-- 예약 마감 기안문 확인 페이지 URL -->
	<c:url value="/approvalDetail.do" var="approvalDetailUrl"/>
	<!-- 결재 페이지 URL -->
	<c:url value="/approvalRes.do" var="approvalResUrl"/>
	<!-- 프로그램 일정 수정 API URL -->
    <c:url value="/api/schedule/updateSchedule.do" var="updateApi"/>
   	<!-- 현재 프로그램 일정 조회 API URL -->
    <c:url value="/api/schedule/getProgramSchedule.do" var="getProgramScheduleApi"/>
	<!-- 현재 프로그램 일정의 예약 조회 API URL -->
    <c:url value="/api/booking/getBookingList.do" var="getBookingListApi"/>
   	<!-- 현재 프로그램 일정의 특정 예약 삭제 API URL -->
    <c:url value="/api/booking/delete.do" var="deleteBookingApi"/>
    <!-- 현재 프로그램 일정의 기안문 정보 조회 -->
    <c:url value="/api/approval/getScheduleReq.do" var="getScheduleReqApi" />
    <!-- 등록된 기안문의 결재자들 조회 -->
	<c:url value="/api/approval/getSnapUserList.do" var="getSnapUserListApi" />
	
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

	<h2 id="pageTitle">예약정보 변경</h2>
	
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
				<span id="info-text"></span>
			</td>
		</tr>
	</table>
	
	<div class="btn-area1">
		<div id="approvalReqStatusText" style="display: none;"></div>
		<button id="btnGoApprovalReq" style="display: none;">기안확인</button>
		<button id="btnReuseApprovalReq" style="display: none;">기안문 재작성</button>
		<button id="btnClose">예약마감</button>
		<button id="btnSubmit">저장</button>
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
				<th>예약자명(단체)</th>
				<th>예약자수</th>
				<th>예약자확인</th>
				<th>삭제</th>
				<th>수료증</th>
			</tr>
		</thead>
		<tbody id="bookerList">
		</tbody>
	</table>
	
	<div class="btn-area2">
		<button id="btnCancel">돌아가기</button>
		<button id="btnAddBooker">예약자 추가</button>
	</div>
	
	<div class="black-bg">
		<!-- 모달 창 영역 -->
		<div class="white-bg">
			<div id="modal-header">
				<h3><span id="m-idx"></span>예약자 확인</h3>
				<button id="btnModalClose">X</button>
			</div>
			<div id="modal-body">
			</div>
		</div>
	</div>
	
	<script>
		var idx = '${param.idx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		// 기안문 응답 페이지에서 진입한 경우 사용
		var reqIdx = '${param.approvalReqIdx}';
		var pageIndex = '${param.pageIndex}';
		
		var bookingList = [];
		var approvalReqIdx = '';
		var approvalReqUserIdx = '';
		
		var isClosed = false;
		
		// 체험 인원 로우 추가 함수
		function addBookingRow(booking) {
			var index = $('#bookerList tr').length + 1;
			var programNameText = $('#programName').text();
			var bookingType = booking.isGroup ? '단체' : '개인';
			var bookerName = booking.groupName !== '' ? booking.userName + '(' + booking.groupName + ')' : booking.userName;
			var bookerCnt = booking.bookerList.length;

			var $tr = $('<tr>').attr('data-booking-idx', booking.idx);
			$tr.append($('<td>').text(index)); // 번호
			$tr.append($('<td>').text(programNameText)); // 체험명
			$tr.append($('<td>').text(bookingType)); // 예약구분
			var $dateTag = $('<div>').addClass('date-tag').text(booking.createdAt.substr(0,10));
			var $bookingTime = $('<div>').addClass('booking-time-box').append($dateTag).append($('<span>').text(booking.createdAt.substr(11,5)));
			$tr.append($('<td>').append($bookingTime)); // 예약시간
			$tr.append($('<td>').text(bookerName)); // 예약자명
			$tr.append($('<td>').text(bookerCnt)); // 예약자수

			// 버튼들
			var $btnShow = $('<button>').addClass('btn-show').text('확인');
			var $btnDelete = $('<button>').addClass('btn-delete').text('삭제');
			if (isClosed) {
				$btnDelete.addClass('disabled-btn');
			}
			var $btnPrint = $('<button>').addClass('btn-print').text('출력');

			$tr.append($('<td>').append($btnShow)); // 예약자확인
			$tr.append($('<td>').append($btnDelete)); // 삭제
			$tr.append($('<td>').append($btnPrint)); // 수료증

			$('#bookerList').append($tr);
		};
		
		// 테이블 재 렌더링을 위한 프로그램 일정의 예약 목록 조회 요청 함수
		function loadBookingList() {
			$('#bookerList').empty();
    		$.ajax({
    			url: '${getBookingListApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ programScheduleIdx: idx }),
    			success: function(list){
					// console.log(JSON.stringify(list));
					bookingList = list;
					if (list.length === 0) {
						$('#bookerList').append($('<tr>').append($('<td>').attr('colspan', '9').append($('<div>').addClass('no-data-text').text('아직 등록된 예약이 없습니다.'))));
					}
					list.forEach(function(booking) {
						addBookingRow(booking);
					});
    			},
				error: function(){
					alert('현재 프로그램 일정의 예약 목록 조회 중 에러 발생');
				}
    		});
			
		}
		
		$(function () {
			// 이 프로그램 일정 조회 요청
    		$.ajax({
    			url: '${getProgramScheduleApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ idx: idx }),
    			success: function(schedule){
					console.log(JSON.stringify(schedule));
					$('#programName').text(schedule.programName);
					var scheduleDate = schedule.startDatetime.substr(0,10);
					$('#scheduleDate').text(scheduleDate);
					var start = schedule.startDatetime.substr(11,5);
					var end = schedule.endDatetime.substr(11,5);
					$('#scheduleTime').text(start + ' - ' + end);
					$('#capacity').val(parseInt(schedule.capacity));
					$('#info-text').text('(예약건수 : ' + schedule.bookingCount + ', 예약 인원: ' + schedule.bookerCount + ')');
    			},
				error: function(){
					alert('현재 프로그램 일정 조회 중 에러 발생');
				}
    		});
			
			// 이 프로그램 일정의 예약 마감 기안문 조회 요청
    		$.ajax({
    			url: '${getScheduleReqApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ programScheduleIdx: idx }),
    			success: function(res){
					console.log(JSON.stringify(res.approvalReq));
					var data = res.approvalReq;
					if (data) {
						approvalReqIdx = data.idx;
						approvalReqUserIdx = data.reqUserIdx;
						$('#btnGoApprovalReq').show();
						$('#btnClose').hide();
						var statusText = '';
						if (data.status === 'PENDING') {
							statusText = '결재 상태: 결재 진행 중';
						} else if (data.status === 'APPROVED') {
							isClosed = true;
							$('#btnAddBooker').addClass('disabled-btn');
							$('#btnSubmit').addClass('disabled-btn');
							$('.btn-delete').addClass('disabled-btn');
							statusText = '결재 상태: 결재 완료';
							var $tag = $('<div>').addClass('title-tag').text('예약 마감');
							$('#pageTitle').append($tag);
						} else {
							statusText = '결재 상태: 반려';
							$('#btnGoApprovalReq').hide();
							$('#btnReuseApprovalReq').show();
						}
						$('#approvalReqStatusText').addClass('status-' + data.status.toLowerCase()).text(statusText).show();
					}
					loadBookingList(); // 프로그램 일정의 예약 목록 조회 요청
    			},
				error: function(){
					alert('현재 일정의 기안문 조회 중 에러 발생');
				}
    		});
    		
			// 돌아가기
			$('#btnCancel').on('click', function () {
				if (pageIndex) {
					postTo('${approvalResUrl}', { idx: reqIdx, programIdx: programIdx, pageIndex: pageIndex });
				} else {
					postTo('${bookManageUrl}', { programIdx: programIdx });
				}
			});
		
			// 저장 버튼
			$('#btnSubmit').on('click', function (e) {
				if (isClosed) {
					e.preventDefault();
					return;
				}
				
				if (!confirm('일정 정보를 수정하시겠습니까?')) return;
				
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
		
			// 예약마감, 기안문 재작성 버튼
			$('#btnClose, #btnReuseApprovalReq').on('click', function () {
				postTo('${approvalReqUrl}', { programScheduleIdx: idx, programIdx: programIdx, programName: programName, date: date, approvalReqIdx: reqIdx, pageIndex: pageIndex });
			});
			
			// 기안 확인 버튼
			$('#btnGoApprovalReq').on('click', function () {
				console.log(approvalReqIdx);
	 			// 기안문의 결재라인의 결재자들 조회
	 			$.ajax({
					url: '${getSnapUserListApi}',
					type:'POST',
					contentType: 'application/json',
					dataType: 'json',
					data: JSON.stringify({ approvalReqIdx: approvalReqIdx }),
					success: function(userList){
						// console.log(JSON.stringify(userList));
						// 기안문 열람 가능한 유저인지 확인
						var allowd = false
						for (var i=0; i < userList.length; i++) {
							var user = userList[i];
							// 기안문 열람 잠금이 false인 사용자이거나 기안문 작성자면 허용
							if (approvalReqUserIdx === sessionUserIdx || (sessionUserIdx === user.userIdx && !user.isLocked)) {
								postTo('${approvalDetailUrl}', { idx: approvalReqIdx, programScheduleIdx: idx, programIdx: programIdx, programName: programName, date: date, approvalReqIdx: reqIdx, pageIndex: pageIndex });
								allowd = true;
								break;
							}
						}
						if (!allowd) {
							alert('기안문 작성자와 허용된 결재자만 확인 할 수 있습니다');
						}
					},
					error: function(){
						alert('결재 기안문 라인 유저 목록 조회 중 에러 발생');
					}
				});
			});
		
			// 예약자 추가
			$('#btnAddBooker').on('click', function (e) {
				if (isClosed) {
					e.preventDefault();
					return;
				}
				postTo('${addBookerUrl}', { idx: idx, programIdx: programIdx, programName: programName, date: date, approvalReqIdx: reqIdx, pageIndex: pageIndex });
			});
		
			// 예약자 테이블 내부 버튼
			$('#bookerList').on('click', '.btn-show', function () {
				var index = $(this).closest('tr').index(); // 몇 번째 tr인지 찾기
				var booking = bookingList[index]; // 해당 booking 객체 가져오기

				var bookerList = booking.bookerList;

				// 모달 바디 초기화
				$('#modal-body').empty();
				
				$('#m-idx').text('[' + (index + 1) + '] ');
				$('#modal-body').prepend($('<h4>').text('총 ' + bookerList.length + '명')).append($('<div>').attr('id', 'modal-content'));

				// 예약자 정보 렌더링
				bookerList.forEach(function(booker, i) {
					var sexText = booker.sex === 'man' ? '♂️' : '♀️';
					var typeMap = {
						baby: '미취학 아동',
						child: '어린이',
						youth: '청소년',
						adult: '성인'
					};
					var userTypeText = typeMap[booker.userType] || booker.userType;
					
					var $title = $('<div>').append($('<strong>').text((i + 1) + '.' + booker.bookerName + sexText + ' (' + userTypeText + ')'));
					var $live = $('<div>').text('거주지: ' + booker.administrationArea + ' ' + (booker.city ? booker.city : ''));
					var $ps = $('<div>').text('장애인: ' + (booker.isDisabled ? 'O' : 'X') + ', 외국인: ' + (booker.isForeigner ? 'O' : 'X'));
					var $item = $('<div>').addClass('modal-item').append($title).append($live).append($ps);

					$('#modal-content').append($item);
				});

				// 모달창 열기
				$('.black-bg').addClass('show-modal');
			});
			$('#bookerList').on('click', '.btn-delete', function (e) {
				if (isClosed) {
					e.preventDefault();
					return;
				}
				if (!confirm('정말 삭제하시겠습니까?')) return;
				var $tr = $(this).closest('tr');
				var bookingIdx = $tr.data('booking-idx');
				console.log(bookingIdx);
				$.ajax({
					url : '${deleteBookingApi}',
					type : 'POST',
					contentType : 'application/json',
					data : JSON.stringify({ idx : bookingIdx }),
					success : function(res) {
						if (res.error) {
							alert(res.error);
						} else {
							alert('예약 삭제가 완료되었습니다');
							loadBookingList();
						}
					},
					error: function(xhr){
						var errMsg = xhr.responseJSON && xhr.responseJSON.error;
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '예약 삭제 중 에러 발생';
							}
						}
						alert(errMsg);
					}
				});
			});
			$('#bookerList').on('click', '.btn-print', function () {
				alert('수료증 출력 기능 구현 예정');
			});
			
			// 모달 창 닫기 버튼
			$('#btnModalClose').on('click', function () {
				$('.black-bg').removeClass('show-modal');
			});
			
			// 배경 눌러도 닫힘
			$('.black-bg').click(function(e) {
				if (e.target === this) {
					$(this).removeClass('show-modal');
				}
			});
		});
	</script>

</body>
</html>
