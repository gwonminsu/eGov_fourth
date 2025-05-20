<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>프로그램 작성/수정 폼</title>
	
	<link rel="stylesheet" href="<c:url value='/css/programForm.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>

	<!-- 목록 페이지 URL -->
	<c:url value="/bookManage.do" var="bookManageUrl"/>
	<!-- 임시 API URL -->
    <c:url value="/api/program/create.do" var="createApi"/>
    <c:url value="/api/program/edit.do" var="editApi"/>
    <c:url value="/api/program/delete.do" var="deleteApi"/>
    <c:url value="/api/program/detail.do" var="detailApi"/>
	
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
	<h2 id="formTitle">프로그램 등록 폼</h2>
	<div id="programFormGuide"><h3>현재 수정중인 프로그램 idx: <span id="idxShow"></span></h3></div>
	
	<table class="form-table">
		<tr>
			<th>프로그램 이름</th>
			<td colspan="3">
				<input type="text" id="programName" required maxlength="20"/>
			</td>
		</tr>
		<tr>
			<th>주요 대상 연령</th>
			<td colspan="3">
				<select id="userType" required>
				    <option value="">선택해주세요</option>
				    <option value="baby">미취학 아동</option>
				    <option value="child">어린이</option>
				    <option value="youth">청소년</option>
				    <option value="adult">성인</option>
				    <option value="all">전연령</option>
				</select>
			</td>
		</tr>
		<tr>
			<th>프로그램 개요</th>
			<td colspan="3">
				<textarea id="description" rows="1" required oninput="this.style.height='auto'; this.style.height=this.scrollHeight+'px';"></textarea>
			</td>
		</tr>
	</table>

	<div class="btn-area">
		<button id="btnSubmit">저장</button>
		<button id="btnDelete" style="display: none;">삭제</button>
		<button id="btnCancel">취소</button>
	</div>

	<script>
		// 프로그램 idx
		var idx = '${param.idx}';  
		// 폼 모드
		var mode;
		if (idx) {
			mode = 'edit';
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
		
		$(function(){
	    	if (mode === 'edit') {
	    		$('#formTitle').text('프로그램 수정 폼');
	    		$('#surveyFormGuide').show();
	    		$('#idxShow').text(idx);
	    		$('#btnDelete').show();
	    		
	    		// 프로그램 메타 정보 가져와서 input에 채워넣기
	    		$.ajax({
	    			url: '${detailApi}',
	    			type: 'POST',
	    			contentType: 'application/json',
	    			data: JSON.stringify({ idx: idx }),
	    			dataType: 'json'
	    		}).done(function(item) {
		   	        $('#programName').val(item.title);
		   	        $('#description').val(item.description);
		   	     	$('#userType').val(item.userType);
				});
	    	} else {
	    		$('#programFormGuide').hide();
	    	}
			
	    	
	        $('#btnSubmit').click(function(e){
	        	// 폼 검증(하나라도 인풋이 비어있으면 알림)
	    		if (!$('#programName')[0].reportValidity()) return;
	    		if (!$('#description')[0].reportValidity()) return;
	    		
	    		if ($('#userType').val() === "") {
	    			alert('대상 연령을 선택하세요');
	    			return;
	    		}
	    		
				var payload = {
						createUserIdx: sessionUserIdx,
						programName: $('#programName').val(),
						userType: $('#userType').val(),
						description: $('#description').val(),
				}
				if (mode === 'edit') {
					payload.idx = idx;
				}
				
				console.log(JSON.stringify(payload));
	    		
	    		// 프로그램 등록 요청
	    		$.ajax({
	    			url: apiUrl,
	    			type:'POST',
	    			contentType: 'application/json',
	    			dataType: 'json',
	    			data: JSON.stringify(payload),
	    			success: function(res){
						if (res.error) {
							alert(res.error);
						} else {
							if (mode === 'edit') {
								alert('프로그램 수정 완료');
							} else {
								alert('프로그램 등록 완료');
							}
							postTo('${bookManageUrl}', {});
			            }
	    			},
					error: function(xhr){
						// 네트워크 연결 리셋 시 (멀티파트 파일들 크기가 제한 크기보다 크면 발생)
						if (xhr.status === 0) {
							alert("이미지 파일 크기가 너무 커서 서버 연결이 리셋됐습니다. 파일 크기를 확인해주세요.");
							return;
						}
						var errMsg = xhr.responseJSON && xhr.responseJSON.error; // 인터셉터에서 에러메시지 받아옴
						if (!errMsg) {
							try {
								errMsg = JSON.parse(xhr.responseText).error;
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
	        	if (!confirm('정말 삭제하시겠습니까?')) return;
				$.ajax({
					url: '${deleteApi}',
					type: 'POST',
					contentType: 'application/json',
					data: JSON.stringify({ idx: idx }),
					success: function(res) {
						if (res.error) {
							alert(res.error);
						} else {
							alert('프로그램 삭제가 완료되었습니다');
							postTo('${bookManageUrl}', {});
						}
					}
				})
	        	
			})
	    	
	    	$('#btnCancel').click(function() {
	    		// 예약 관리자 페이지 이동
	    		postTo('${bookManageUrl}', {});
	    	});
	    	
	    });
	</script>
</body>
</html>