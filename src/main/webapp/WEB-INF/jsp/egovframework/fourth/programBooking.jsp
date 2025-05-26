<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>예약 하기</title>

	<link rel="stylesheet" href="<c:url value='/css/programBooking.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<script src="<c:url value='/js/xlsx.full.min.js'/>"></script>
	
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
		<input type="file" id="excelFileInput" accept=".xlsx" style="display: none;" />
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
		
		// 엑셀의 구분 텍스트를 키로 변환하는 함수
		function getUserTypeKey(text) {
		    var map = {
		        '미취학 아동(0~5세)': 'baby',
		        '어린이(6~12세)': 'child',
		        '청소년(13~18세)': 'youth',
		        '성인(19~)': 'adult',
		        '전체 연령': 'all'
		    };
		    return map[text] || '';
		};
		
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
					
					// 엑셀 업로드 시 city 값을 지정해주는 로직
					var selectedCity = $(this).data('selected-city');
					if (selectedCity) {
						$city.val(selectedCity);
						$(this).removeData('selected-city'); // 다 썼으면 초기화
					}
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
					var bookerCnt = schedule.bookerCount; // 임시값
					var start = schedule.startDatetime.substr(11,5);
					var end = schedule.endDatetime.substr(11,5);
					$('#programTime').text('[' + date + '] ' + start + ' - ' + end);
					$('#capacityView').text('(' + bookerCnt + '/' + schedule.capacity + ')');
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
				addUserRow();
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
				$('#excelFileInput').trigger('click'); // 숨겨진 파일 인풋의 파일 선택 클릭
			});
			
			// 파일 선택되면 파싱
			$('#excelFileInput').on('change', function (e) {
			    var file = e.target.files[0];
			    if (!file) return;
			    if (!file.name.endsWith('.xlsx')) {
			        alert('엑셀 파일만 업로드 가능합니다.');
			        return;
			    }

			    var reader = new FileReader();
			    reader.onload = function (e) {
			    	$('#userList').empty(); // 기존 예약인 row 삭제
			        var data = e.target.result;
			        var workbook = XLSX.read(data, { type: 'binary' });
			        var sheetName = workbook.SheetNames[0]; // 시트 이름
			        console.log(sheetName);
			        var rawData = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName]); // 시트에서 데이터 가져옴
			     	// 데이터 가공해서 jsonData에 넣어줌
			        jsonData = [];
			        rawData.forEach(function(row) {
						var data = {
							'성명': row['성명'],
							'성별': row['성별'],
							'구분': row['구분'],
							'거주지': row['거주지'],
							'시/군(경상북도)': row['시/군(경상북도)'],
							'장애인': row['장애인'],
							'외국인': row['외국인']
						};
						
						// 값이 하나라도 있는 로우는 추가
						var hasVal = false;
						for (var key in data) {
							if (data[key] != null && data[key].toString().trim() !== "") { // 공백까지 거르기
								hasVal = true;
								break;
							}
						}
						if (hasVal) {
							jsonData.push(data);
						}
					});
			        
			        console.log(JSON.stringify(jsonData));

			        jsonData.forEach(function(row) {
			        	addUserRow(function($newRow) {
				            $newRow.find('.booker-name').val(row['성명']);
				            $newRow.find('input[type=radio][value="' + (row['성별'] === '여' ? 'woman' : 'man') + '"]').prop('checked', true);
				            $newRow.find('.user-type').val(getUserTypeKey(row['구분']));
				            $newRow.find('.administration-area').data('selected-city', row['시/군(경상북도)']).val(row['거주지']).trigger('change');
				            $newRow.find('.disabled').prop('checked', row['장애인'] === 'Y');
				            $newRow.find('.foreigner').prop('checked', row['외국인'] === 'Y');
			        	});
			        });
			    };
			    reader.readAsBinaryString(file);
			    $(this).val(''); // 같은 이름 파일 재업로드 가능하게 하기 위해 파일 데이터 삭제
			});
	
			// 저장 버튼 (API 미연결, 데이터 콘솔 확인용)
			$('#btnSave').on('click', function () {
				var isValid = true;
				
				// 전화번호 검증
				var phoneNumber = $('#bookerPhone').val();
				var phoneRegex = /^010\d{8}$/; // 정규식
				if (!phoneRegex.test(phoneNumber)) {
					alert('전화번호는 010으로 시작하는 11자리 숫자여야 합니다.');
					$('#bookerPhone').focus();
					return;
				}
				
				// 단체명 검증
				if ($('#bookingType').val() === '단체' && !$('#groupName').val().trim()) {
					alert('단체일 경우 단체명을 입력해 주세요.');
					$('#groupName').focus();
					return;
				}
				
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
						phone: $('#bookerPhone').val(),
						isGroup: $('#bookingType').val() === '단체',
						groupName: $('#groupName').val(),
						bookerList: bookerList
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
