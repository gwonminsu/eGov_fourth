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
<c:url value="/api/user/searchUser.do" var="searchUserApi" />

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
	
<!-- 모달 창 영역 -->
<div class="black-bg">
	<div class="white-bg">
		<div id="modal-header">
			<h3>결재 라인 선택</h3>
			<button id="btnModalClose">닫기</button>
		</div>
		<div id="modal-body">
			<div class="modal-section">
				<!-- 결재 라인 목록 -->
				<div class="line-list-wrap">
					<table class="approval-line-table">
						<thead>
							<tr><th>결재라인명</th><th>수정일자</th></tr>
						</thead>
						<tbody id="approvalLineList">
							<!-- 동적 삽입 -->
						</tbody>
					</table>
				</div>

				<!-- 사용자 검색 + 선택 + 라인 편집 -->
				<div class="user-select-wrap">
					<!-- 검색 + 사용자 리스트 -->
					<div class="user-search-list">
						<div class="filter-wrap">
							<div>
								<label>부서: </label><input type="text" id="searchDept" placeholder="부서" />
								<label style="margin-left: 10px;">직급: </label><input type="text" id="searchPosition" placeholder="직급" />
							</div>
							<div>
								<label>이름: </label><input type="text" id="searchName" placeholder="이름" />
								<button id="btnSearchUser">검색</button>
							</div>
						</div>
						<div class="user-list-wrap">
							<table class="user-table">
								<thead><tr><th>부서</th><th>이름</th></tr></thead>
								<tbody id="userList"></tbody>
							</table>
						</div>
					</div>

					<!-- 결재 라인 편집기 -->
					<div class="line-editor-wrap">
						<div><label>결재라인명: </label><input type="text" id="approvalLineName" placeholder="결재라인명을 입력하세요" /></div>
						
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
				</div> <!-- user-select-wrap -->
			</div>
		</div>
	</div>
</div>


	<script>
		var programScheduleIdx = '${param.programScheduleIdx}'; // 프로그램 일정 idx
		var programIdx = '${param.programIdx}'; // 프로그램 idx
		var date = '${param.date}'; // 선택된 날짜
		var programName = '${param.programName}'; // 프로그램 이름
		
		var currentLine = null; // 선택된 결재 라인
		var selectedUser = null; // 선택된 사용자
		var editingLineIdx = null; // 수정 중인 결재라인 idx 저장
		var lineMode = 'create'; // 결재 라인 모드

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
		
		// 결재 라인 내용 초기화
		function lineClear() {
			$('#approverList, #cooperatorList, #referenceList').empty();
	    	selectedUser = null;
	    	currentLine = null;
	    	editingLineIdx = null;
	    	$('#approvalLineName').val('');
		}
		
		// 결재 라인 선택 모달 초기화
		function initApprovalModal() {
			// 선택된 정보들 초기화
			lineClear(); // 결재자/협조자/참조자 등 리스트 초기화
			lineMode = 'create';
			$('#btnSaveLine').text('등록');

			// 결재라인 목록 초기화
			$('#approvalLineList').empty();

			// 사용자 검색 필터 초기화
			$('#searchDept').val('');
			$('#searchPosition').val('');
			$('#searchName').val('');

			// 사용자 리스트 초기화
			$('#userList').empty().append($('<tr>').append($('<td>').attr('colspan', '2').append($('<div>').addClass('no-data-text').text('결재 라인에 등록할 사용자를 검색해 주세요'))));

		}
		
		$(function() {
			$('#docId').val('자동 부여');
			$('#draftDate').val(getToday());
			$('#userName').val(userName);
			$('#departmentAndPosition').val(userDepartment + ' / ' + userPosition);
			$('#reqTitle').val(date.substr(0, 4) + '년 ' + date.substr(5,2) + '월 ' + date.substr(8,2) + '일 예약 마감 결재건');
			
			/* ------------------ 결재 라인 선택 모달 관련 스크립트 시작 ------------------  */
			
			// 결재 라인 지정 모달 창 열기 버튼
			$('#btnSelectApprovalLine').click(function() {
				initApprovalModal(); // 모달창 초기화
				// 사용자의 결재 라인 목록 조회 요청
/* 	    		$.ajax({
	    			url: '${getApprovalLinesApi}',
	    			type:'POST',
	    			contentType: 'application/json',
	    			dataType: 'json',
	    			data: JSON.stringify({ createUserIdx: sessionUserIdx }),
	    			success: function(lineList){
	    				// 여기에 approvalLineList에 로우 추가 예정
	    			},
					error: function(){
						alert('사용자 결재 라인 조회 중 에러 발생');
					}
	    		}); */
				// 더미 데이터 삽입
				$('#approvalLineList').html(`
					<tr class="approval-line-row" data-line='{
						"idx": "LINE001",
						"lineName": "기본 결재라인",
						"lineUsers": [
							{ "idx": "U001", "name": "홍길동", "type": "approv" },
							{ "idx": "U002", "name": "트럼프", "type": "approv" },
							{ "idx": "U003", "name": "김영희", "type": "coop" },
							{ "idx": "U004", "name": "이철수", "type": "ref" }
						]
					}'><td>기본 결재라인</td><td>2025-05-20</td></tr>
					<tr class="approval-line-row" data-line='{
						"idx": "LINE002",
						"lineName": "두번째 결재라인",
						"lineUsers": [
							{ "idx": "U004", "name": "이철수", "type": "approv" },
							{ "idx": "U002", "name": "트럼프", "type": "approv" },
							{ "idx": "U003", "name": "김영희", "type": "coop" },
							{ "idx": "U001", "name": "홍길동", "type": "coop" },
							{ "idx": "U005", "name": "머스크", "type": "ref" }
						]
					}'><td>두번째 결재라인</td><td>2025-05-28</td></tr>
				`);


				// 모달 바디 초기화
				// $('#modal-body').empty();
				// 결재 라인 지정 모달 창 열기
				$('.black-bg').addClass('show-modal');
			});
			
			// 모달 창 닫기 버튼
			$('#btnModalClose, .black-bg').on('click', function (e) {
				if (e.target === this || $(e.target).is('#btnModalClose')) {
					$('.black-bg').removeClass('show-modal');
				}
			});
			
			// 검색 버튼 핸들러
			$('#btnSearchUser').click(function () {
				var dept = $('#searchDept').val();
				var name = $('#searchName').val();
				var position = $('#searchPosition').val();

 				$.ajax({
					url: '${searchUserApi}',
					type: 'POST',
					contentType: 'application/json',
					dataType: 'json',
					data: JSON.stringify({
						department: dept,
						name: name,
						position: position
					}),
					success: function (userList) {
						console.log(JSON.stringify(userList));
						$('#userList').empty();

						if (!userList || userList.length === 0) {
							$('#userList').append($('<tr>').append($('<td>').attr('colspan', '2').append($('<div>').addClass('no-data-text').text('검색된 사용자 없음'))));
							return;
						}

						userList.forEach(function (user) {
							var userData = JSON.stringify({ idx: user.idx, name: user.userName });
							var $row = $('<tr>').attr('data-user', userData)
											.append($('<td>').text(user.department || '(부서 없음)'))
											.append($('<td>').text(user.userName + '(' + (user.position || '직급 없음') + ')'));
							$('#userList').append($row);
						});
					},
					error: function () {
						alert('사용자 검색 중 오류 발생');
					}
				});
				
			});
			
			// 유저 리스트 클릭 시 활성화 표시
			$('#userList').on('click', 'tr', function() {
				$('#userList tr').removeClass('active');
				$(this).addClass('active');
				selectedUser = $(this).data('user');
				console.log(selectedUser);
			});
			
			// 결재자/협조자/참조자 추가 버튼 클릭
			$('#btnAddApprover').click(function() {
				if (!selectedUser) return;
				if (selectedUser.idx === sessionUserIdx) {
					alert('본인은 추가 불가능합니다.');
					return;
				}
				$('#approverList').append($('<li>').attr('data-user', selectedUser.idx).text(selectedUser.name));
			});
			
			$('#btnAddCooperator').click(function() {
				if (!selectedUser) return;
				$('#cooperatorList').append($('<li>').attr('data-user', selectedUser.idx).text(selectedUser.name));
			});
			
			$('#btnAddReference').click(function() {
				if (!selectedUser) return;
				$('#referenceList').append($('<li>').attr('data-user', selectedUser.idx).text(selectedUser.name));
			});
			
			// 항목 클릭 시 active 표시
			$('.line-list').on('click', 'li', function() {
				$('.line-list li').removeClass('active');
				$(this).addClass('active');
			});
			
			// 결재라인 목록 클릭 시 내용 세팅
			$('#approvalLineList').on('click', 'tr', function () {
				if(!confirm('결재 라인 선택 시 수정 중인 작업 내용을 잃어버리게 됩니다.')) return;
				lineClear();
				$('#approvalLineList tr').removeClass('active');
				$(this).addClass('active');
				
				var line = $(this).data('line');
				editingLineIdx = line.idx;
				$('#approvalLineName').val(line.lineName);
				lineMode = 'edit';
				$('#btnSaveLine').text('수정');
				
				line.lineUsers.forEach(function(user) {
					var li = $('<li>').attr('data-user', user.idx).text(user.name);
					if (user.type === 'approv') $('#approverList').append(li);
					else if (user.type === 'coop') $('#cooperatorList').append(li);
					else if (user.type === 'ref') $('#referenceList').append(li);
				});
				
				currentLine = line.idx;
			});
			
			// 삭제/위아래 이동 버튼은 이후 구현 예정
			$('.line-controls').on('click', 'button', function () {
				var $ul = $(this).closest('.line-section').find('ul');
				var $selected = $ul.find('li.active');
				if ($selected.length === 0) return;
				
				if ($(this).hasClass('btn-up')) {
					var $prev = $selected.prev();
					if ($prev.length) $selected.insertBefore($prev);
				} else if ($(this).hasClass('btn-down')) {
					var $next = $selected.next();
					if ($next.length) $selected.insertAfter($next);
				} else if ($(this).hasClass('btn-remove')) {
					$selected.remove();
				}
			});
			
			// 등록/수정 버튼 클릭 시 ajax 전송
			$('#btnSaveLine').click(function() {
				var lineName = $('#approvalLineName').val();
				if (!lineName) return alert('결재라인명을 입력하세요');
				
				var gatherUsers = function(selector, type) {
					var list = [];
					$(selector).each(function(i, el) {
						list.push({
							idx: $(el).data('user'),
							type: type,
							seq: i + 1
						});
					});
					return list;
				};
				
			    var approvers = gatherUsers('#approverList li', 'approv');
			    var cooperators = gatherUsers('#cooperatorList li', 'coop');
			    if (approvers.length < 1 || cooperators.length < 1) {
			    	alert('협조자와 결재자는 필수로 등록 하셔야 합니다.');
			    }
			    var references = gatherUsers('#referenceList li', 'ref');
			    var lineUsers = [...approvers, ...cooperators, ...references];
				
				var payload = {
					      createUserIdx: sessionUserIdx,
					      lineName: lineName,
					      lineUsers: lineUsers
				};
				if (lineMode === 'edit') payload.idx = editingLineIdx;
				
				console.log('등록할 결재라인:', payload);
			    
				/*
				$.ajax({
					url: lineMode === 'create' ? '/api/approval/create.do' : '/api/approval/update.do',
					type: 'POST',
					contentType: 'application/json',
					data: JSON.stringify(payload),
					success: function(res) {
						alert('결재라인 등록 완료');
						// 목록 다시 불러오기 등 처리
						lineClear();
						if(lineMode === 'edit') {
							lineMode = 'create';
							$(this).text('등록');
						}
					},
					error : function(xhr) {
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
							} catch (e) {
								errMsg = '결재 라인 ' + (lineMode === 'create' ? '등록' : '수정') + ' 요청 중 에러 발생';
							}
						}
						alert(errMsg);
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

			// 취소 버튼 핸들러
			$('#btnCancel').click(function() {
				// 예약 관리(상세) 페이지 이동
				postTo('${scheduleDetailUrl}', { idx: programScheduleIdx, programIdx: programIdx, programName: programName, date: date });
			});

		});
	</script>
</body>
</html>