<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약정보 확인</title>

	<link rel="stylesheet" href="<c:url value='/css/bookingInfo.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

	<!-- 예약자(메인) 페이지 URL -->
	<c:url value="/booking.do" var="bookingUrl"/>
	<!-- 예약 목록 API URL -->
	<c:url value="/api/booking/getUserBookingList.do" var="getBookingListApi"/>
	<!-- 예약 삭제 API URL -->
	<c:url value="/api/booking/delete.do" var="deleteBookingApi"/>

	<script>
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var sessionUserName = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
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
	<h2 id="pageTitle">예약정보 확인</h2><br/>
	
	<p class="info-desc">
		※ 취소 및 변경은 2일 전까지 홈페이지 이용, 이후에는 전화로 연락 바랍니다.
	</p>

	<table class="form-table booking-table">
		<thead>
			<tr>
				<th>체험명</th>
				<th>예약시간</th>
				<th>예약자수</th>
				<th>예약정보</th>
				<th>취소</th>
			</tr>
		</thead>
		<tbody id="bookingList">
		</tbody>
	</table>
	
	<div class="btn-area">
		<button id="btnPrev">돌아가기</button>
	</div>

	<!-- 모달 창 영역 -->
	<div class="black-bg">
		<div class="white-bg">
			<div id="modal-header">
				<h3><span id="modal-title-prefix"></span>예약 정보</h3>
				<button id="btnModalClose">X</button>
			</div>
			<div id="modal-body"></div>
		</div>
	</div>
	
	<script>
		var programIdx = '${param.programIdx}'; // 프로그램 idx
	
		var bookingList = [];
	
		// 모달 열기 이벤트 위임
		$('#bookingList').on('click', '.btn-show', function () {
		    var index = $(this).closest('tr').index(); // 몇 번째 tr인지 확인
		    var booking = bookingList[index]; // 해당 booking 객체 가져오기

			$('#modal-body').empty();
			$('#modal-title-prefix').text('[' + booking.programName + '] ');

			// 예약 메타 테이블 생성
			var $metaTable = $('<table>').addClass('form-table meta-table');
			$metaTable.append(
				$('<tr>').append($('<th>').text('체험명'))
							.append($('<td>').text(booking.programName))
							.append($('<th>').text('시간'))
							.append($('<td>').text(booking.scheduleStart.substr(0, 16)))
			);
			$metaTable.append(
				$('<tr>').append($('<th>').text('대표 예약자'))
							.append($('<td>').text(booking.userName || '-'))
							.append($('<th>').text('전화번호'))
							.append($('<td>').text(booking.phone || '-'))
			);
			$metaTable.append(
				$('<tr>').append($('<th>').text('구분'))
							.append($('<td>').attr('colspan', 3).text(booking.isGroup ? '단체 (' + booking.groupName + ')' : '개인'))
			);

			$('#modal-body').append($metaTable);

		    // 예약자 수 + 개별 정보
		    $('#modal-body').append($('<h4>').text('총 ' + booking.bookerList.length + '명')).append($('<div id="modal-content">'));
		    booking.bookerList.forEach(function (booker, i) {
		        var sexText = booker.sex === 'man' ? '♂️' : '♀️';
		        var typeMap = {
		            baby: '미취학 아동',
		            child: '어린이',
		            youth: '청소년',
		            adult: '성인'
		        };
		        var userTypeText = typeMap[booker.userType] || booker.userType;

		        var $title = $('<div>').append($('<strong>').text((i + 1) + '. ' + booker.bookerName + sexText + ' (' + userTypeText + ')'));
		        var $live = $('<div>').text('거주지: ' + booker.administrationArea + ' ' + (booker.city ? booker.city : ''));
		        var $ps = $('<div>').text('장애인: ' + (booker.isDisabled ? 'O' : 'X') + ', 외국인: ' + (booker.isForeigner ? 'O' : 'X'));
		        var $item = $('<div>').addClass('modal-item').append($title).append($live).append($ps);

		        $('#modal-content').append($item);
		    });


		    $('.black-bg').addClass('show-modal'); // 모달 띄우기
		});
	
		$(function () {
			$('#bookingList').empty();
			// 예약 목록 가져오기
			$.ajax({
				url: '${getBookingListApi}',
				type: 'POST',
				contentType: 'application/json',
				dataType: 'json',
				data: JSON.stringify({ userIdx: sessionUserIdx }),
				success: function (list) {
					console.log(JSON.stringify(list));
					bookingList = list;
	
					if (list.length === 0) {
						$('#bookingList').append($('<tr>').append($('<td colspan="5">').append($('<div class="no-data-text">').text('예약 내역이 없습니다.'))));
					}
	
					list.forEach(function (booking, index) {
						var $tr = $('<tr>').attr('data-booking-idx', booking.idx);
						$tr.append($('<td>').text(booking.programName));
						$tr.append($('<td>').text(booking.createdAt.substr(0, 10) + '(' + booking.createdAt.substr(11, 5) + ')'));
						$tr.append($('<td>').text(booking.bookerList.length));
						$tr.append($('<td>').append($('<button>').addClass('btn-show').text('확인')));
						
						var startDateStr = booking.scheduleStart.substr(0, 10);
						var startDate = new Date(startDateStr);
						var today = new Date();
						var limitDate = new Date(today);
						limitDate.setDate(today.getDate() + 2); // 오늘 + 2일

						var $cancelBtn = $('<button>').addClass('btn-delete').text('예약 취소');

						if (startDate <= limitDate) {
							$cancelBtn.addClass('disabled-btn').prop('disabled', true); // 취소 제한
						}

						$tr.append($('<td>').append($cancelBtn));
						$('#bookingList').append($tr);
					});
				},
				error: function () {
					alert('예약 목록 조회 실패');
				}
			});
			
			// 예약 취소 버튼
			$('#bookingList').on('click', '.btn-delete', function () {
				var index = $(this).closest('tr').index();
				var booking = bookingList[index];

				// 다시 한 번 시간 체크
				var startDateStr = booking.scheduleStart.substr(0, 10);
				var startDate = new Date(startDateStr);
				var today = new Date();
				var limitDate = new Date(today);
				limitDate.setDate(today.getDate() + 2);

				if (startDate <= limitDate) {
					alert('일정 시작일 기준 2일 전까지만 취소가 가능합니다.');
					return;
				}

				if (!confirm('정말 예약을 취소하시겠습니까?')) return;

				// 예약 + 예약 인원 삭제 요청
 				$.ajax({
					url: '${deleteBookingApi}',
					type: 'POST',
					contentType: 'application/json',
					dataType: 'json',
					data: JSON.stringify({ idx: booking.idx }),
					success: function (res) {
						alert('예약이 취소되었습니다.');
						location.reload(); // 페이지 새로고침
					},
					error: function () {
						alert('예약 취소 중 에러 발생');
					}
				});
			});

			
			// 돌아가기 버튼
			$('#btnPrev').on('click', function () {
				postTo('${bookingUrl}', { programIdx: programIdx });
			});
	
			// 모달 닫기 버튼
			$('#btnModalClose').on('click', function () {
				$('.black-bg').removeClass('show-modal');
			});
	
			// 배경 클릭 시 모달 닫기
			$('.black-bg').on('click', function (e) {
				if (e.target === this) {
					$(this).removeClass('show-modal');
				}
			});
		});

	</script>
	
</body>
</html>
