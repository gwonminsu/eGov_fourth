<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 하기</title>

	<link rel="stylesheet" href="<c:url value='/css/programBooking.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 예약자(메인) 페이지 URL -->
	<c:url value="/booking.do" var="bookingUrl"/>
   	<!-- 현재 날짜의 프로그램 일정 조회 API -->
    <c:url value="/api/schedule/getProgramSchedule.do" var="getProgramScheduleApi"/>
    <!-- 프로그램 일정에 예약 등록 요청 API -->
    <c:url value="/api/booking/createBooking.do" var="crateBookingApi"/>
	
	<script>
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var sessionUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		var sessionUserPhone = '<c:out value="${sessionScope.loginUser.userPhone}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.isAdmin}" default="" />';
		
		var fileUrl = '<c:out value="/files/예약 프로젝트 예약 신청서_기본.xlsx" />';
		var jsonUrl = '<c:out value="/files/bookingDropdownData.json" />'
		
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
	
	<h2>예약 하기<span id="capacityView"></span></h2>
	
	<p class="info-desc">
		※ 어쩌구 하시길 바랍니다
	</p>
	<p class="info-desc">
		※ 저쩌구 하시길 바랍니다
	</p>
	
	<table class="form-table booking-table">
		<tr>
			<th>체험명</th>
			<td>
				<div id="programName"></div>
			</td>
			<th>시간</th>
			<td>
				<div id="programTime"></div>
			</td>
		</tr>
		<tr>
			<th>대표 예약자</th>
			<td>
				<div id="bookerName"></div>
			</td>
			<th>전화번호</th>
			<td>
				<input type="text" id="bookerPhone" required maxlength="11" />
			</td>
		</tr>
		<tr>
			<th>예약구분</th>
			<td id="bookingTypeTd">
				<select id="bookingType">
					<option value="개인">개인</option>
					<option value="단체">단체</option>
				</select>
			</td>
			<th id="groupRow">단체명</th>
			<td>
				<input type="text" id="groupName" disabled="disabled" required maxlength="20" />
			</td>
		</tr>
	</table>
	
	<h3>체험 인원 정보</h3>
	
	<p class="info-desc">
		※ (개인) 중증 장애인을 포함한 예약자는 안내데스크 문의 후 예약 바랍니다.
	</p>
	
	<!-- 체험 인원 테이블 -->
	<table class="form-table booker-table">
		<thead>
			<tr>
				<th>번호</th>
				<th>성명</th>
				<th>성별</th>
				<th>구분</th>
				<th>거주지</th>
				<th>상세주소</th>
				<th>장애여부</th>
				<th>외국인</th>
				<th>삭제</th>
			</tr>
		</thead>
		<tbody id="userList">
		</tbody>
	</table>
	
	<div class="btn-area">
		<button id="btnAddUser">인원 추가하기 ➕</button>
	</div>
	<br/><br/><br/>
	
	<div class="btn-area">
		<button id="btnExcelDownload">엑셀양식 다운로드 📥</button>
		<button id="btnExcelUpload">엑셀업로드 📤</button>
	</div>
	
	<div class="btn-area">
		<button id="btnCancel">이전</button>
		<button id="btnSave">저장</button>
	</div>
	
	<script>
		var idx = '${param.idx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		var optionsData = {}; // 예약인 드롭다운 데이터
		
		$(function(){
			$('#programName').text(programName);
			$('#programTime').text(date);
			$('#bookerName').text(sessionUserName);
			$('#bookerPhone').val(sessionUserPhone);
			
    		// 이 프로그램 일정 조회 요청
    		$.ajax({
    			url: '${getProgramScheduleApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ idx: idx }),
    			success: function(schedule){
					console.log(JSON.stringify(schedule));
					var bookingCnt = 0; // 임시값
					var start = schedule.startDatetime.substr(11,5);
					var end = schedule.endDatetime.substr(11,5);
					$('#programTime').text('[' + date + '] ' + start + ' - ' + end);
					$('#capacityView').text('(' + bookingCnt + '/' + schedule.capacity + ')');
    			},
				error: function(){
					alert('현재 프로그램 일정 조회 중 에러 발생');
				}
    		});
    		
			// 예약구분 변경 시 단체명 표시 여부 토글
			$('#bookingType').on('change', function () {
				var type = $(this).val();
				if (type === '단체') {
					$('#groupName').prop('disabled', false);
				} else {
					$('#groupName').prop('disabled', true);
					$('#groupName').val(''); // 선택 바뀌면 입력값도 초기화
				}
			});
			
			// 인원 추가 버튼
			$('#btnAddUser').on('click', function () {
				// 드롭다운 옵션 json 파일 가져와서 예약인 로우 추가
				$.getJSON(jsonUrl, function(data) {
					optionsData = data;
					// console.log(JSON.stringify(data));
					// 번호
					var index = $('#userList tr').length;
					var $tr = $('<tr>');
					$tr.append($('<td>').text(index + 1));
					
					// 성명
					$tr.append($('<td>').append($('<input type="text">').addClass('booker-name').attr('placeholder', '성함')));

					// 성별
					var $genderTd = $('<td>');
					$genderTd.append($('<label>').append($('<input type="radio">')
								.attr({type: 'radio', name: 'sex' + index, value: 'man', checked: true}), ' 남자'));
					$genderTd.append($('<label>').css('margin-left', '8px').append($('<input type="radio">')
								.attr({type: 'radio', name: 'sex' + index, value: 'woman'}), ' 여자'));
					$tr.append($genderTd);
					
					// 대상 구분
					var $userType = $('<select>').addClass('user-type').append($('<option>').val('').text('대상구분'));
					optionsData.userTypeList.forEach(function(obj) {
						var key = Object.keys(obj)[0];
						var value = obj[key];
						$userType.append($('<option>').val(key).text(value));
					});
					$tr.append($('<td>').append($userType));
					
					// 행정구역(거주지)
					var $region = $('<select>').addClass('administration-area').append($('<option>').val('').text('거주지'));
					Object.keys(optionsData.cityMap).forEach(function(area) {
						$region.append($('<option>').val(area).text(area));
					})
					$tr.append($('<td>').append($region));
					
					// 상세주소
					var $city = $('<select>').addClass('city').append($('<option>').val('').text('시·군'));
					// 행정구역 변경 시 해당 상세주소 필터링
					$region.on('change', function () {
						var selected = $(this).val();
						var cities = optionsData.cityMap[selected] || [];
						$city.empty().append('<option value="">시·군</option>');
						cities.forEach(function(city) {
							if (city) $city.append($('<option>').val(city).text(city));
						});
					});
					$tr.append($('<td>').append($city));
					
					$tr.append($('<td>').append($('<input type="checkbox">').addClass('disabled'))); // 장애여부
					$tr.append($('<td>').append($('<input type="checkbox">').addClass('foreigner'))); // 외국인 여부
					$tr.append($('<td>').append($('<button>').addClass('btn-delete').text('삭제'))); // 삭제 버튼

					$('#userList').append($tr);
				});
			});
			$('#btnAddUser').trigger('click'); // 페이지 진입 시 초기 상태 반영
	
			// 삭제 버튼
			$('#userList').on('click', '.btn-delete', function () {
				$(this).closest('tr').remove();
			});
	
			// 엑셀 다운로드 버튼
			$('#btnExcelDownload').on('click', function () {
				$('<a>').attr('href', fileUrl).attr('download', '예약 프로젝트 예약 신청서_기본.xlsx')[0].click();
			});
			
			// 엑셀 업로드 버튼
			$('#btnExcelUpload').on('click', function () {
				alert('아직 구현하지 않은 기능');
			});
	
			// 저장 버튼 (API 미연결, 데이터 콘솔 확인용)
			$('#btnSave').on('click', function () {
				var bookerList = []; // 예약인 리스트 배열 준비
				$('#userList tr').each(function () {
					var $tr = $(this);
					bookerList.push({
						bookerName: $tr.find('.booker-name').val(),
						sex: $tr.find('input[type=radio]:checked').val(),
						userType: $tr.find('.user-type').val(),
						administrationArea: $tr.find('.administration-area').val(),
						city: $tr.find('.city').val(),
						isDisabled: $tr.find('.disabled').is(':checked'),
						isForeigner: $tr.find('.foreigner').is(':checked'),
					});
				});

				// 예약 데이터 준비
				var payload = {
						userIdx: sessionUserIdx,
						programScheduleIdx: idx,
						phone: $('#bookerPhone').val(),
						isGroup: $('#bookingType').val() === '단체',
						groupName: $('#groupName').val(),
						bookerList: bookerList
				}
				
				console.log("최종 전송 데이터:", payload);

	    		// 예약 등록 요청
	    		$.ajax({
	    			url: '${crateBookingApi}',
	    			type:'POST',
	    			contentType: 'application/json',
	    			dataType: 'json',
	    			data: JSON.stringify(payload),
	    			success: function(res){
						if (res.error) {
							alert(res.error);
						} else {
							alert('예약 등록 완료');
							postTo('${bookingUrl}', { programIdx: programIdx });
			            }
	    			},
					error: function(xhr){
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '예약 등록 중 에러 발생';
							}
						}
						alert(errMsg);
					}
	    		});
			});
	
			// 돌아가기 버튼
			$('#btnCancel').on('click', function () {
				postTo('${bookingUrl}', { programIdx: programIdx });
			});
		});
	</script>
</body>
</html>
