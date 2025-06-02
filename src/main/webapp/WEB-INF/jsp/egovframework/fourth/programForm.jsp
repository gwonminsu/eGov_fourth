<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>프로그램 작성/수정 폼</title>

<link rel="stylesheet" href="<c:url value='/css/programForm.css'/>" />
<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

<!-- 목록 페이지 URL -->
<c:url value="/bookManage.do" var="bookManageUrl" />
<!-- 임시 API URL -->
<c:url value="/api/program/create.do" var="createApi" />
<c:url value="/api/program/edit.do" var="editApi" />
<c:url value="/api/program/delete.do" var="deleteApi" />
<c:url value="/api/program/detail.do" var="detailApi" />
<c:url value="/api/program/image.do" var="imageApi" />

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

	// 바이트 수를 읽기 편한 문자열로 변환
	function formatBytes(bytes) {
		if (bytes === 0)
			return '0 Bytes';
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
	<h2 id="formTitle">프로그램 등록 폼</h2>
	<div id="programFormGuide">
		<h3>
			현재 수정중인 프로그램 idx: <span id="idxShow"></span>
		</h3>
	</div>

	<table class="form-table">
		<tr>
			<th>프로그램 이름</th>
			<td colspan="3"><input type="text" id="programName" required
				maxlength="20" /></td>
		</tr>
		<tr>
			<th>주요 대상 연령</th>
			<td colspan="3"><select id="userType" required>
					<option value="">선택해주세요(만 나이 기준)</option>
					<option value="baby">미취학 아동(0~5세)</option>
					<option value="child">어린이(6~12세)</option>
					<option value="youth">청소년(13~18세)</option>
					<option value="adult">성인(19~)</option>
					<option value="all">전체 연령</option>
			</select></td>
		</tr>
		<tr>
			<th>프로그램 개요</th>
			<td colspan="3"><textarea id="description" rows="1" required
					oninput="this.style.height='auto'; this.style.height=this.scrollHeight+'px';"></textarea>
			</td>
		</tr>
		<tr>
			<th>첨부 이미지</th>
			<td colspan="3">
				<div id="attachFileWrapper">
					<input type="file" id="imageInput"
						accept="image/jpeg,image/png,image/gif,image/bmp,image/svg+xml" />
					<div id="dropZone">여기에 파일을 드래그 앤 드롭 해 주세요</div>
				</div>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnSubmit">저장</button>
		<button id="btnDelete" style="display: none;">삭제</button>
		<button id="btnCancel">취소</button>
	</div>

	<script>
		var programIdx = '${param.programIdx}'; // 프로그램 버튼 유지용
		// 프로그램 idx
		var idx = '${param.idx}';
		// 폼 모드
		var mode;
		if (idx) {
			mode = 'edit';
			programIdx = idx;
		} else {
			mode = 'create';
		}
		// 모드에 따라 apiUrl 주소 변경
		var apiUrl;
		if (mode === 'edit') {
			apiUrl = '${editApi}';
		} else {
			apiUrl = '${createApi}';
		}

		var fileChanged = false;
		var currentFile = null;

		$(function() {
			if (mode === 'edit') {
				$('#formTitle').text('프로그램 수정 폼');
				$('#idxShow').text(idx);
				$('#btnDelete').show();

				// 프로그램 메타 정보 가져와서 input에 채워넣기
				$.ajax({
					url : '${detailApi}',
					type : 'POST',
					contentType : 'application/json',
					data : JSON.stringify({ idx : idx }),
					dataType : 'json',
					success : function(item) {
						$('#programName').val(item.programName);
						$('#description').val(item.description);
						$('#userType').val(item.userType);
						
						// textArea 높이 조절
						$('#description')[0].style.height = 'auto';
						$('#description')[0].style.height = $('#description')[0].scrollHeight + 'px';
					},
					error : function() {
						console.log('프로그램 메타 정보 조회 실패');
					}
				});

				// 이미지 정보 불러와서 이미지 미리보기
				$.ajax({
					url : '${imageApi}',
					type : 'POST',
					contentType : 'application/json',
					data : JSON.stringify({
						programIdx : idx
					}),
					dataType : 'json',
					success : function(imageInfo) {
						// 이미지 URL 구성
						var imageUrl = '/uploads/' + imageInfo.fileUuid
								+ imageInfo.ext;
						var $img = $('<img>').attr({ id : 'imagePreview', src : imageUrl });

						// 파일 이름 + 사이즈 텍스트
						var size = formatBytes(imageInfo.fileSize);
						var fileInfoText = imageInfo.fileName + ' [' + size + ']';
						var $fileInfo = $('<div>').attr('id', 'fileInfoText').text(fileInfoText);

						// 이미지 제거 버튼
						var $removeBtn = $('<button>').attr('id', 'removeImageBtn').text('이미지 제거');

						$('#attachFileWrapper').append($img, $fileInfo,
								$removeBtn);
					},
					error : function() {
						console.log('이미지 정보 조회 실패');
					}
				});

			} else {
				$('#programFormGuide').hide();
			}

			function handleFiles(fileList) {
				if (fileList.length > 1) {
					alert('파일을 하나만 넣어주세요');
					return;
				}
				var file = fileList[0];
				if (!file)
					return; // 파일이 실제로 선택되지 않았다면 그냥 무시

				// 허용 파일 타입 목록
				var allowedTypes = [ 'image/jpeg', 'image/png', 'image/gif',
						'image/bmp', 'image/svg+xml' ];
				// 허용 파일이 아니면 거절
				if (!allowedTypes.includes(file.type)) {
					alert('지원하지 않는 파일 형식입니다.\n허용된 파일 형식: JPG, PNG, GIF, BMP, SVG');
					return;
				}
				currentFile = file;
				fileChanged = true;
				$('#imagePreview').remove(); // 이미지 미리보기 제거
				$('#fileInfoText').remove(); // 파일 정보 텍스트 제거
				$('#removeImageBtn').remove(); // 선택 이미지 삭제 버튼 제거
				var fileInfo = file.name + ' [' + formatBytes(file.size) + ']';
				var $fileInfo = $('<div>').attr('id', 'fileInfoText').text(
						fileInfo);
				var $img = $('<img>').attr('id', 'imagePreview');
				var $removeBtn = $('<button>').attr('id', 'removeImageBtn')
						.text('이미지 제거');
				$('#attachFileWrapper').append($img).append($fileInfo).append(
						$removeBtn);
				var reader = new FileReader();
				reader.onload = function(e) {
					$('#imagePreview').attr('src', e.target.result);
				};
				reader.readAsDataURL(file);
			}

			// 첨부파일 선택기로 선택 시
			$('#imageInput').on('change', function(e) {
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
			// 첨부 이미지 제거 핸들러
			$('#attachFileWrapper').on('click', '#removeImageBtn', function() {
				$('#imagePreview').remove();
				$('#fileInfoText').remove();
				$('#removeImageBtn').remove();
				$('#imageInput').val("");
				fileChanged = true;
				currentFile = null;
			});

			$('#btnSubmit').click(function(e) {
				if(!confirm('프로그램을 ' + (mode === 'edit' ? '수정' : '등록') + '하시겠습니까?')) return;

				// 폼 검증(하나라도 인풋이 비어있으면 알림)
				if (!$('#programName')[0].reportValidity())
					return;
				if (!$('#description')[0].reportValidity())
					return;

				if ($('#userType').val() === "") {
					alert('대상 연령을 선택하세요');
					return;
				}

				var payload = {
					createUserIdx : sessionUserIdx,
					programName : $('#programName').val(),
					userType : $('#userType').val(),
					description : $('#description').val(),
					fileChanged : fileChanged
				}
				if (mode === 'edit') {
					payload.idx = idx;
				}

				console.log(JSON.stringify(payload));

				// FormData에 payload와 파일 추가
				var formData = new FormData();
				formData.append("program", new Blob([ JSON.stringify(payload) ], { type : "application/json" }));
				// var file = $('#imageInput')[0].files[0];
				if (currentFile) {
					formData.append("file", currentFile);
				}

				// 프로그램 등록 요청
				$.ajax({
					url : apiUrl,
					type : 'POST',
					processData : false,
					contentType : false,
					data : formData,
					success : function(res) {
						if (res.error) {
							alert(res.error);
						} else {
							if (mode === 'edit') {
								alert('프로그램 수정 완료');
							} else {
								alert('프로그램 등록 완료');
							}
							postTo('${bookManageUrl}', { programIdx: programIdx });
						}
					},
					error : function(xhr) {
						// 네트워크 연결 리셋 시 (멀티파트 파일들 크기가 제한 크기보다 크면 발생)
						if (xhr.status === 0) {
							alert("이미지 파일 크기가 너무 커서 서버 연결이 리셋됐습니다. 파일 크기를 확인해주세요.");
							return;
						}
						var errMsg = xhr.responseJSON
								&& xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON
										.parse(xhr.responseText).error;
							} catch (e) {
								if (mode === 'edit') {
									errMsg = '프로그램 수정 중 에러 발생';
								} else {
									errMsg = '프로그램 등록 중 에러 발생';
								}
							}
						}
						alert(errMsg);
					}
				});
			});

			$('#btnDelete').click(function() {
				if (isAdmin != 'true') {
					alert('삭제 권한이 없습니다');
					return;
				}
				if (!confirm('정말 삭제하시겠습니까?'))
					return;
				$.ajax({
					url : '${deleteApi}',
					type : 'POST',
					contentType : 'application/json',
					data : JSON.stringify({ idx : idx }),
					success : function(res) {
						if (res.error) {
							alert(res.error);
						} else {
							alert('프로그램 삭제가 완료되었습니다');
							postTo('${bookManageUrl}', { programIdx: programIdx });
						}
					}
				});
			});

			$('#btnCancel').click(function() {
				// 예약 관리자 페이지 이동
				postTo('${bookManageUrl}', { programIdx: programIdx });
			});

		});
	</script>
</body>
</html>