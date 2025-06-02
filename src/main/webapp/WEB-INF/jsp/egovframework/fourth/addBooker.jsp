<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 인원 직접 추가</title>

	<link rel="stylesheet" href="<c:url value='/css/addBooker.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 일정 관리(상세) 페이지 URL -->
	<c:url value="/scheduleDetail.do" var="scheduleDetailUrl"/>
   	<!-- 현재 날짜의 프로그램 일정 조회 API -->
    <c:url value="/api/schedule/getProgramSchedule.do" var="getProgramScheduleApi"/>
    <!-- 프로그램 일정에 예약 등록 요청 API -->
    <c:url value="/api/booking/createBooking.do" var="crateBookingApi"/>
	
	<script>
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		var sessionUserPhone = '<c:out value="${sessionScope.loginUser.userPhone}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.isAdmin}" default="" />';
		
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
	
	<h2>예약 인원 추가<span id="capacityView"></span></h2>
	
	<p class="info-desc">
		예약 인원은 관리자 이름으로 새로 추가됩니다.
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
	
	<div class="btn-area">
		<button id="btnCancel">이전</button>
		<button id="btnSave">저장</button>
	</div>
	
	<script>
		var idx = '${param.idx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		// 기안문 응답 페이지에서 진입한 경우 사용
		var reqIdx = '${param.approvalReqIdx}';
		var pageIndex = '${param.pageIndex}';
		
		var optionsData = {}; // 예약인 드롭다운 데이터
		
		// 체험 인원 로우 추가 함수
		function addUserRow(callback) {
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
				var $genderTd = $('<td>').css('white-space', 'nowrap');
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
				if (callback) callback($tr);
			});
		};
		
		$(function(){
    		// 이 프로그램 일정 조회 요청
    		$.ajax({
    			url: '${getProgramScheduleApi}',
    			type:'POST',
    			contentType: 'application/json',
    			dataType: 'json',
    			data: JSON.stringify({ idx: idx }),
    			success: function(schedule){
					console.log(JSON.stringify(schedule));
					var bookerCnt = schedule.bookerCount;
					$('#capacityView').text('(' + bookerCnt + '/' + schedule.capacity + ')');
    			},
				error: function(){
					alert('현재 프로그램 일정 조회 중 에러 발생');
				}
    		});
    		
			// 인원 추가 버튼
			$('#btnAddUser').on('click', function () {
				addUserRow();
			});
			$('#btnAddUser').trigger('click'); // 페이지 진입 시 초기 상태 반영
	
			// 삭제 버튼
			$('#userList').on('click', '.btn-delete', function () {
				$(this).closest('tr').remove();
			});
	
			// 저장 버튼
			$('#btnSave').on('click', function () {
				if (!confirm('예약 인원을 추가하시겠습니끼?')) return;
				var isValid = true;
				
				var bookerList = [];
				$('#userList tr').each(function (i) {
					var $tr = $(this);
					var name = $tr.find('.booker-name').val().trim();
					var sex = $tr.find('input[type=radio]:checked').val();
					var userType = $tr.find('.user-type').val();
					var area = $tr.find('.administration-area').val();
					var city = $tr.find('.city').val();

					// 필수값 검증
					if (!name || !sex || !userType || !area) {
						alert((i + 1) + '번 인원의 성명, 성별, 구분, 거주지는 필수입니다.');
						isValid = false;
						return false;
					}

					// 경상북도일 때만 시군 입력 필요
					if (area === '경상북도' && !city) {
						alert((i + 1) + '번 인원의 상세주소(시·군)를 선택해주세요.');
						isValid = false;
						return false;
					}
					
					// 예약인 리스트 배열 준비 완료
					bookerList.push({
						bookerName: name,
						sex: sex,
						userType: userType,
						administrationArea: area,
						city: city,
						isDisabled: $tr.find('.disabled').is(':checked'),
						isForeigner: $tr.find('.foreigner').is(':checked'),
					});
				});
				
				if (!isValid) return;

				// 예약 데이터 준비
				var payload = {
						userIdx: sessionUserIdx,
						programScheduleIdx: idx,
						phone: sessionUserPhone,
						isGroup: false,
						groupName: '관리자 수동 추가',
						bookerList: bookerList,
						willCheck: false
				}
				
				console.log("최종 전송 데이터:", JSON.stringify(payload));

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
							alert('예약자 직접 등록 완료');
							postTo('${scheduleDetailUrl}', { idx: idx, programIdx: programIdx, programName: programName, date: date });
			            }
	    			},
					error: function(xhr){
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '예약자 직접 등록 중 에러 발생';
							}
						}
						alert(errMsg);
					}
	    		});
			});
	
			// 돌아가기 버튼
			$('#btnCancel').on('click', function () {
				postTo('${scheduleDetailUrl}', { idx: idx, programIdx: programIdx, programName: programName, date: date, approvalReqIdx: reqIdx, pageIndex: pageIndex });
			});
		});
	</script>
</body>
</html>
