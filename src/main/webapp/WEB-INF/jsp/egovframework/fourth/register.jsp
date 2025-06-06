<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>회원가입</title>
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	<!-- 로그인 페이지 URL -->
	<c:url value="/login.do" var="loginUrl"/>
	
	<script>
		function postTo(url, params) {
		    var form = $('<form>').attr({ method: 'POST', action: url });
		    $.each(params, function(name, value) {
		        $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
		    });
		    form.appendTo('body').submit();
		}
	</script>
</head>
<body>
	<h2>회원가입</h2>
	<label>아이디: 
		<input type="text" id="userId" required maxlength="15"/>
	</label><br/>
	<label>비밀번호: 
		<input type="password" id="userPw" required maxlength="15"/>
	</label><br/>
	<label>이름: 
		<input type="text" id="userName" required maxlength="20"/>
	</label><br/>
	<label>전화번호: 
		<input type="text" id="userPhone" required maxlength="11"/>
	</label><br/>
	<button id="btnRegister">가입하기</button>
	
	<script>
    $('#btnRegister').click(function(){
    	// 폼 검증(하나라도 인풋이 비어있으면 알림)
		var idVal = $('#userId')[0];
		var passwordVal = $('#userPw')[0];
		var nameVal = $('#userName')[0];
		var phoneVal = $('#userPhone')[0];
		
		if (!idVal.reportValidity()) return;
		if (!passwordVal.reportValidity()) return;
		if (!nameVal.reportValidity()) return;
		if (!phoneVal.reportValidity()) return;
		
		// 전화번호 검증
		var phoneNumber = $('#userPhone').val();
		var phoneRegex = /^010\d{8}$/; // 정규식
		if (!phoneRegex.test(phoneNumber)) {
			alert('전화번호는 010으로 시작하는 11자리 숫자여야 합니다.');
			$('#userPhone').focus();
			return;
		}
		
		// 검증 통과 시 회원가입 api 실행
		var data = {
				userId:$('#userId').val(),
				userPw:$('#userPw').val(),
				userName:$('#userName').val(),
				userPhone:$('#userPhone').val()
		};
		$.ajax({
			url:'<c:url value="/api/user/register.do"/>',
			type:'POST',
			contentType:'application/json',
			data:JSON.stringify(data),
			success:function(res){
				if(res.status=='OK') {
					alert('가입 완료!');
					// 로그인 페이지로
					postTo('${loginUrl}', {});
				} else {
					alert('오류: ' + res.error);
				}
			},
	        error: function(xhr, status, error) {
            	alert('서버 오류 발생!');
            }
		});
    });
	</script>
</body>
</html>