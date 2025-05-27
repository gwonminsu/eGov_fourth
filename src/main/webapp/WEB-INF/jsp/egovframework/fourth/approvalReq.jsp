<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프로그램 작성/수정 폼</title>

<link rel="stylesheet" href="<c:url value='/css/approvalReq.css'/>" />
<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

<!-- 일정 관리(상세) 페이지 URL -->
<c:url value="/scheduleDetail.do" var="scheduleDetailUrl"/>
<!-- API URL -->
<c:url value="/api/approval/create.do" var="createApi" />

<script>
	var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
	var isAdmin = '<c:out value="${sessionScope.loginUser.isAdmin}" default="" />';
	var userName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
	var userDepartment = '<c:out value="${sessionScope.loginUser.department}" default="" />';
	var userPosition = '<c:out value="${sessionScope.loginUser.position}" default="" />';
	
    // 동적 POST 폼 생성 함수
    function postTo(url, params) {
        var form = $('<form>').attr({ method: 'POST', action: url });
        $.each(params, function(name, value){
            $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
        });
        form.appendTo('body').submit();
    }

	// 바이트 수를 읽기 편한 문자열로 변환
	function formatBytes(bytes) {
		if (bytes === 0) return '0 Bytes';
		var k = 1024;
		var sizes = [ 'Bytes', 'KB', 'MB', 'GB', 'TB' ];
		// 지수 계산
		var i = Math.floor(Math.log(bytes) / Math.log(k));
		// 해당 단위로 나눈 값
		var value = bytes / Math.pow(k, i);
		return value.toFixed(2) + ' ' + sizes[i];
	}
</script>
</head>
<body>
	<h2 id="formTitle">예약 마감 기안문</h2>

	<table class="form-table">
		<tr>
			<th>문서번호</th>
			<td><input type="text" id="docId" class="input-center" disabled /></td>
			<th>기안일자</th>
			<td><input type="date" id="draftDate" class="input-center" disabled required /></td>
		</tr>
		<tr>
			<th>성명</th>
			<td><input type="text" id="userName" class="input-center" disabled /></td>
			<th>부서/직위</th>
			<td><input type="text" id="departmentAndPosition" class="input-center" disabled /></td>
		</tr>
		<tr>
			<th>제목</th>
			<td colspan="3"><input type="text" id="reqTitle" class="input-center" maxlength="100" required placeholder="제목을 입력하세요" /></td>
		</tr>
		<tr>
			<th>내용</th>
			<td colspan="3">
				<textarea id="reqContent" rows="10" required
					oninput="this.style.height='auto'; this.style.height=this.scrollHeight+'px';"
					placeholder="기안 내용을 입력하세요."></textarea>
			</td>
		</tr>
		<tr>
			<th>첨부파일</th>
			<td colspan="3">
				<div id="attachFileWrapper">
					<input type="file" id="fileInput" multiple />
					<div id="dropZone">
						이곳에 파일을 드래그 앤 드롭 하거나, 클릭하여 업로드하세요.<br/>
						<small>(50MB 이하만 첨부하세요)</small>
					</div>
					<div id="fileList"></div>
				</div>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnSelectApprovalLine">결재 라인 지정</button>
		<div>
			<button id="btnSubmit">결재 요청</button>
			<button id="btnCancel">취소</button>
		</div>
	</div>

	<script>
		var programScheduleIdx = '${param.programScheduleIdx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름

		var fileList = [];
		
		// 첨부된 파일 리스트 렌더링
		function renderFileList() {
			$('#fileList').empty();
			fileList.forEach(function(file, i) {
				var name = file.name;
				var size = formatBytes(file.size);
				var $item = $('<div>').addClass('file-item').text(name + ' [' + size + '] ');
				var $btn = $('<button>').text('제거').attr('data-index', i).addClass('btn-remove');
				$item.append($btn);
				$('#fileList').append($item);
			});
		}

		// 파일 리스트 처리 핸들러
		function handleFiles(files) {
			for (var i = 0; i < files.length; i++) {
				fileList.push(files[i]);
			}
			renderFileList();
		}
		
		// 현재 날짜 반환
		function getToday() {
			var today = new Date();
			var year = today.getFullYear();
			var month = String(today.getMonth() + 1).padStart(2, '0');
			var day = String(today.getDate()).padStart(2, '0');
			return year + '-' + month + '-' + day;
		}

		$(function() {
			$('#docId').val('자동 부여');
			$('#draftDate').val(getToday());
			$('#userName').val(userName);
			$('#departmentAndPosition').val(userDepartment + ' / ' + userPosition);
			$('#reqTitle').val(date.substr(0, 4) + '년 ' + date.substr(5,2) + '월 ' + date.substr(8,2) + '일 예약 마감 결재건');

			// 첨부파일 선택기로 선택 시
			$('#fileInput').on('change', function(e) {
				handleFiles(e.target.files);
			});
			// 드래그 앤 드랍으로 선택 시
			var $dz = $('#dropZone');
			$dz.on('dragover', function(e) {
				e.preventDefault();
				e.originalEvent.dataTransfer.dropEffect = 'copy';
				$dz.addClass('dragover');
			});
			$dz.on('dragleave dragend', function(e) {
				e.preventDefault();
				$dz.removeClass('dragover');
			});
			$dz.on('drop', function(e) {
				e.preventDefault();
				$dz.removeClass('dragover');
				handleFiles(e.originalEvent.dataTransfer.files);
			});
			
			// 파일 제거 버튼 클릭 핸들러
			$('#fileList').on('click', '.btn-remove', function () {
				var index = $(this).data('index');
				fileList.splice(index, 1);
				renderFileList(); // 리스트 다시 렌더링
			});


			$('#btnSubmit').click(function(e) {
				// 폼 검증(하나라도 인풋이 비어있으면 알림)
				if (!$('#reqTitle')[0].reportValidity()) return;
				if (!$('#reqContent')[0].reportValidity()) return;

				var payload = {
					approvalLineIdx : 'APPLN-1',
					programScheduleIdx : programScheduleIdx,
					reqUserIdx : sessionUserIdx,
					title : $('#reqTitle').val(),
					content : $('#reqContent').val(),
				}

				console.log("전송 준비된 데이터:", JSON.stringify(payload));
				console.log("첨부파일 수:", fileList.length);

				// FormData에 payload와 파일 추가
				var formData = new FormData();
				formData.append("program", new Blob([ JSON.stringify(payload) ], { type : "application/json" }));
				for (var i = 0; i < fileList.length; i++) {
					formData.append("files", fileList[i]);
				}
				
				// 예약 마감 기안문 결재 요청
/* 				$.ajax({
					url : '${createApi}',
					type : 'POST',
					processData : false,
					contentType : false,
					data : formData,
					success : function(res) {
						if (res.error) {
							alert(res.error);
						} else {
							alert('예약 마감 기안문 결재 요청 완료');
							postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: programIdx, programName: programName, date: date });
						}
					},
					error : function(xhr) {
						// 네트워크 연결 리셋 시 (멀티파트 파일들 크기가 제한 크기보다 크면 발생)
						if (xhr.status === 0) {
							alert("첨부 파일 크기가 너무 커서 서버 연결이 리셋됐습니다. 파일 크기를 확인해주세요.");
							return;
						}
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '예약 마감 기안문 결재 요청 중 에러 발생';
							}
						}
						alert(errMsg);
					}
				}); */
			});
			
			// 결재 라인 지정 모달 창 표시 예정
			$('#btnSelectApprovalLine').click(function() {
				// 결재 라인 지정 모달 창 표시 예정
				alert('해당 기능 공사 준비 중');
			});

			// 취소 버튼 핸들러
			$('#btnCancel').click(function() {
				// 예약 관리(상세) 페이지 이동
				postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: programIdx, programName: programName, date: date });
			});

		});
	</script>
</body>
</html>