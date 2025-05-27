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
	
	<div class="black-bg">
		<!-- 모달 창 영역 -->
		<div class="white-bg">
			<div id="modal-header">
				<h3>결재 라인 선택</h3>
				<button id="btnModalClose">닫기</button>
			</div>
			<div id="modal-body">
				<!-- 모달 내부 영역 세팅: 결재라인 선택 -->
				<div class="modal-section">
					
					<!-- 상단: 결재라인 목록 -->
					<div class="line-list-wrap">
						<table class="approval-line-table">
							<thead>
								<tr>
									<th>결재라인명</th>
									<th>수정일자</th>
								</tr>
							</thead>
							<tbody id="approvalLineList">
								<!-- 결재라인 목록 삽입 -->
							</tbody>
						</table>
					</div>
				
					<!-- 사용자 검색 + 리스트 + 라인 편집 (가로 배치) -->
					<div class="user-select-wrap">
						
						<!-- 검색 영역 + 사용자 테이블 -->
						<div class="user-search-list">
							<div class="filter-wrap">
								<label>부서</label><input type="text" id="searchDept" placeholder="전체" />
								<label>이름</label><input type="text" id="searchName" placeholder="이름" />
								<label>직급</label><input type="text" id="searchPosition" placeholder="전체" />
								<button id="btnSearchUser">검색</button>
							</div>
							<div class="user-list-wrap">
								<table class="user-table">
									<thead><tr><th>부서</th><th>이름</th></tr></thead>
									<tbody id="userList"></tbody>
								</table>
							</div>
						</div>
				
						<!-- 결재라인 편집 -->
						<div class="line-editor-wrap">
							<div>
								<label>결재라인명: </label><input type="text" id="approvalLineName" placeholder="결재라인명을 입력하세요" />
							</div>
				
							<div class="line-section">
								<label>결재자</label>
								<ul id="approverList" class="line-list"></ul>
								<div class="line-controls">
									<button id="btnAddApprover">추가</button>
									<button class="btn-up">▲</button>
									<button class="btn-down">▼</button>
									<button class="btn-remove">삭제</button>
								</div>
							</div>
							<div class="line-section">
								<label>협조자</label>
								<ul id="cooperatorList" class="line-list"></ul>
								<div class="line-controls">
									<button id="btnAddCooperator">추가</button>
									<button class="btn-up">▲</button>
									<button class="btn-down">▼</button>
									<button class="btn-remove">삭제</button>
								</div>
							</div>
							<div class="line-section">
								<label>참조자</label>
								<ul id="referenceList" class="line-list"></ul>
								<div class="line-controls">
									<button id="btnAddReference">추가</button>
									<button class="btn-up">▲</button>
									<button class="btn-down">▼</button>
									<button class="btn-remove">삭제</button>
								</div>
							</div>
							<div class="line-save-wrap">
								<button id="btnSaveLine">등록</button>
								<button id="btnSelectLine">선택</button>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script>
		var programScheduleIdx = '${param.programScheduleIdx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		var currentLine = null;
		var selectedUser = null;

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
			
			/* ------------------ 결재 라인 선택 모달 관련 스크립트 시작 ------------------  */
			
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
			
			// 유저 리스트 클릭 시 활성화 표시
			$('#userList').on('click', 'tr', function() {
				$('#userList tr').removeClass('active');
				$(this).addClass('active');
				selectedUser = $(this).data('user');
			});
			
			// 결재자/협조자/참조자 추가 버튼 클릭
			$('#btnAddApprover').click(function() {
				if (!selectedUser) return;
				$('#approverList').append('<li data-user="' + selectedUser.id + '">' + selectedUser.name + '</li>');
			});
			
			$('#btnAddCooperator').click(function() {
				if (!selectedUser) return;
				$('#cooperatorList').append('<li data-user="' + selectedUser.id + '">' + selectedUser.name + '</li>');
			});
			
			$('#btnAddReference').click(function() {
				if (!selectedUser) return;
				$('#referenceList').append('<li data-user="' + selectedUser.id + '">' + selectedUser.name + '</li>');
			});
			
			// 항목 클릭 시 active 표시
			$('.line-list').on('click', 'li', function() {
				$('.line-list li').removeClass('active');
				$(this).addClass('active');
			});
			
			// 삭제/위아래 이동 버튼은 이후 구현 예정
			
			// 등록 버튼 클릭 시 ajax 전송 (틀만)
			$('#btnSaveLine').click(function() {
				var lineName = $('#approvalLineName').val();
				if (!lineName) return alert('결재라인명을 입력하세요');
				var approvers = [], cooperators = [], references = [];
				$('#approverList li').each(function() { approvers.push($(this).data('user')); });
				$('#cooperatorList li').each(function() { cooperators.push($(this).data('user')); });
				$('#referenceList li').each(function() { references.push($(this).data('user')); });
				
				var payload = {
						name: lineName,
						approvers: approvers,
						cooperators: cooperators,
						references: references
				};
				
				console.log('등록할 결재라인:', payload);
				
				// ajax 전송 틀
				/*
				$.ajax({
					url: '/api/approval-line/create.do',
					type: 'POST',
					contentType: 'application/json',
					data: JSON.stringify(payload),
					success: function(res) {
						alert('결재라인 등록 완료');
						// 목록 다시 불러오기 등 처리
					}
				});
				*/
			});
			
			// 선택 버튼 클릭 시 선택된 라인 currentLine에 저장
			$('#btnSelectLine').click(function() {
				if (!currentLine) return alert('선택된 결재라인이 없습니다');
				console.log('선택된 결재라인 IDX:', currentLine);
				$('.black-bg').removeClass('show-modal');
			});
			
			/* ------------------- 결재 라인 선택 모달 관련 스크립트 끝 -------------------  */

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
				// 모달 바디 초기화
				// $('#modal-body').empty();
				// 결재 라인 지정 모달 창 열기
				$('.black-bg').addClass('show-modal');
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