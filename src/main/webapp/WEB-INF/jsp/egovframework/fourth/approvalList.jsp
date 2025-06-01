<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>결재 목록 페이지</title>
	<link rel="stylesheet" href="<c:url value='/css/approvalList.css'/>" />
	<script src="<c:url value='/js/jquery-3.6.0.min.js'/>"></script>
	
	<!-- 요청받은 결재 리스트 호출 api -->
	<c:url value="/api/approval/getSnapUserReqList.do" var="getSnapUserReqListUrl"/>
	<!-- 사용자가 이 기안에 응답한 데이터 조회 api -->
	<c:url value="/api/approval/getUserAndReqRes.do" var="getUserReqResApi" />
	<!-- 로그인 페이지 url -->
	<c:url value="/login.do" var="loginUrl"/>
	<!-- 로그아웃 api 호출 url -->
	<c:url value="/api/user/logout.do" var="logoutUrl" />
	<!-- 예약 관리 페이지 URL -->
	<c:url value="/bookManage.do" var="bookManageUrl"/>
	<!-- 결재 페이지 URL -->
	<c:url value="/approvalRes.do" var="approvalResUrl"/>
	
	<!-- 페이지네이션 버튼 이미지 url -->
	<c:url value="/images/egovframework/cmmn/btn_page_pre10.gif" var="firstImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_pre1.gif"  var="prevImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_next1.gif" var="nextImgUrl"/>
	<c:url value="/images/egovframework/cmmn/btn_page_next10.gif" var="lastImgUrl"/>
	
	<!-- 세션에 담긴 사용자 이름을 JS 변수로 -->
	<script>
		// 서버에서 렌더링 시점에 loginUser.userName 이 없으면 빈 문자열로
		var loginUserName = '<c:out value="${sessionScope.loginUser.userName}" default="" />';
		var isAdmin = '<c:out value="${sessionScope.loginUser.isAdmin}" default="" />';
		var sessionUserIdx = '<c:out value="${sessionScope.loginUser.idx}" default="" />';
		
	    var PAGE_SIZE = ${pageSize} // 한 그룹당 페이지 버튼 개수
	    console.log(PAGE_SIZE);
	    var PAGE_UNIT = ${pageUnit} // 한 페이지당 레코드 수
	    console.log(PAGE_UNIT);
	    var FIRST_IMG_URL = '${firstImgUrl}';
	    var PREV_IMG_URL = '${prevImgUrl}';
	    var NEXT_IMG_URL = '${nextImgUrl}';
	    var LAST_IMG_URL = '${lastImgUrl}';
	    

		// 페이지네이션 UI
		function renderPagination(totalCount, currentPage) {
			var $pg = $('#paginationArea').empty();
			var totalPages = Math.ceil(totalCount / PAGE_UNIT);
			
			// 현재 묶음 인덱스, 시작/끝 페이지 계산
			var groupIndex = Math.floor((currentPage - 1) / PAGE_SIZE);
			var startPage  = groupIndex * PAGE_SIZE + 1;
			var endPage = Math.min(startPage + PAGE_SIZE - 1, totalPages);

			
			// '처음으로' 버튼
			if (currentPage > 1) {
				$pg.append('<a href="#" onclick="loadSurveyList(1);return false;">' + '<img src="' + FIRST_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + FIRST_IMG_URL + '" border="0" class="disabled"/>&#160;');
			}
			
			// '이전 10페이지' 버튼
			if (startPage > 1) {
			    $pg.append('<a href="#" onclick="loadSurveyList(' + (startPage - 1) + ');return false;">' + '<img src="' + PREV_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + PREV_IMG_URL + '" border="0" class="disabled"/>&#160;');
			}
			
			// 개별 페이지 번호 링크
			for (var i = startPage; i <= endPage; i++) {
			    if (i === currentPage) {
			        $pg.append('<strong>' + i + '</strong>&#160;'); // 선택된 페이지만 굵게
			    } else {
			        $pg.append(
			          '<a href="#" onclick="loadSurveyList(' + i + ');return false;">' +
			           i +
			          '</a>&#160;'
			        );
			    }
			}
			
			// '다음 10페이지' 버튼
			if (endPage < totalPages) {
			    $pg.append('<a href="#" onclick="loadSurveyList(' + (endPage + 1) + ');return false;">' + '<img src="' + NEXT_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + NEXT_IMG_URL + '" border="0" class="disabled"/>&#160;');
			}
			
			// '마지막으로' 버튼
			if (currentPage < totalPages) {
			    $pg.append('<a href="#" onclick="loadSurveyList(' + totalPages + ');return false;">' + '<img src="' + LAST_IMG_URL + '" border="0"/></a>&#160;');
			} else {
				$pg.append('<img src="' + LAST_IMG_URL + '" border="0" class="disabled"/>&#160;');
			}
		}
		
		// GET아닌 POST로 진입하기
		function postTo(url, params) {
		    // 폼 요소 생성
		    var form = $('<form>').attr({ method: 'POST', action: url });
		    // hidden input으로 파라미터 삽입
		    $.each(params, function(name, value) {
		        $('<input>').attr({ type: 'hidden', name: name, value: value }).appendTo(form);
		    });
		    // body에 붙이고 제출
		    form.appendTo('body').submit();
		}
	</script>
</head>
<body>
    <h2>결재 요청받은 기안문 목록</h2>
    
	<!-- 사용자 로그인 상태 영역 -->
	<div id="userInfo">
		<span id="loginMsg"></span>
		<button type="button" id="btnGoLogin">로그인하러가기</button>
		<button type="button" id="btnLogout">로그아웃</button>
	</div>
	
	<p class="info-desc">
		※ 응답 이력: 본인이 기안문에 결재 응답한 이력이 존재하는지 여부
	</p>
	
	<p>전체: <span class="count-red"></span>건</p>
	
    <table id="approvalListTbl" border="1">
    	<thead>
	        <tr>
	            <th>순번</th>
	            <th>제목</th>
	            <th>작성자</th>
	            <th>응답 이력</th>
	            <th>최종 결재 상태</th>
	            <th>등록일</th>
	        </tr>
    	</thead>
    	<tbody></tbody>
    </table>
    
    <div id="paginationArea"></div>
    
    <button id="btnPrev">돌아가기</button>
    
    <script>
    	var programIdx = '${param.programIdx}'; // 프로그램 idx
    	
	    // 검색 변수(파라미터에서 값 받아와서 검색 상태 유지)
		var currentPageIndex = parseInt('<c:out value="${param.pageIndex}" default="1"/>');
    	
		// AJAX 로 페이징/리스트를 불러오는 함수
		function loadApprovalList(pageIndex) {
			currentPageIndex = pageIndex;
		    
			var req = {
					userIdx: sessionUserIdx,
					pageIndex: currentPageIndex,
					recordCountPerPage: PAGE_UNIT,
			};

	        $.ajax({
	            url: '${getSnapUserReqListUrl}',
	            type: 'POST',
	            contentType: 'application/json',
	            data: JSON.stringify(req),
	            dataType: 'json',
	            success: function(res) {
	            	console.log(JSON.stringify(res));
	            	var data = res.list;
		            var totalCount = res.totalCount;
	            	console.log('받아온 데이터=', data, '총건수=', totalCount);
		            $('.count-red').text(totalCount); // 기안문 수 표시
	                var $tbody = $('#approvalListTbl').find('tbody');
	                $tbody.empty();
	                if (totalCount === 0) {
	                	var $noDataRow = $('<tr>').append($('<td>').attr('colspan', '5').append($('<div>').addClass('no-data-text').text('아직 요청받은 기안문이 없습니다.')));
	                	$tbody.append($noDataRow);
	                	return;
	                }
	                $.each(data, function(i, item) {
	                	// console.log(JSON.stringify(item));
	                	// 결재할 유저가 이 기안에 응답한 데이터를 조회
						$.ajax({
							url: '${getUserReqResApi}',
							type:'POST',
							contentType: 'application/json',
							dataType: 'json',
							data: JSON.stringify({ approvalReqIdx: item.idx, userIdx: sessionUserIdx }),
							success: function(list){
			                	var $tr = $('<tr>');
			                    var $linkTitle = $('<a>').attr('href', 'javascript:void(0)').text(item.title).on('click', function() {
			                    	postTo('${approvalResUrl}', { idx: item.idx, programIdx: programIdx, pageIndex: currentPageIndex });
			                    })

			                    // td 추가
			                	$tr.append($('<td>').text(item.number));
			                    $tr.append($('<td>').append($linkTitle));
			                    $tr.append($('<td>').text(item.userName));
			                    $tr.append($('<td>').text((list && list.length > 0) ? 'O' : 'X'));
			                    var statusText = '';
			                    if (item.status === 'PENDING') {
			                    	statusText = '결재 진행 중';
			                    } else if (item.status === 'APPROVED') {
			                    	statusText = '결재 완료';
			                    } else if (item.status === 'REJECTED') {
			                    	statusText = '반려됨';
			                    } else {
			                    	statusText = '알 수 없음';
			                    }
			                    $tr.append($('<td>').text(statusText));
			                    $tr.append($('<td>').text(item.createdAt));
								$tbody.append($tr);
							},
							error: function(){
								alert('응답 조회 중 에러 발생');
								callback(null);
							}
						});
	                });
	                renderPagination(totalCount, pageIndex);
	            },
	            error: function(xhr, status, error) {
	                console.error('기안문 목록을 불러오는 중 에러 발생:', error);
	            }
	        });
		}
    
	    $(function(){
	    	loadApprovalList(currentPageIndex);
	    	
	        // 로그인 여부에 따라 버튼 토글
	        if (loginUserName) {
				$('#loginMsg').text('현재 로그인 중인 사용자: ' + loginUserName);
				$('#btnGoLogin').hide();
				$('#btnLogout').show();
	        } else {
				$('#btnGoLogin').show();
				$('#btnLogout').hide();
	        }
	    	
	    	// 로그인 버튼 핸들러
	    	$('#btnGoLogin').click(function() {
	    		// 로그인 페이지 이동
	    		postTo('${loginUrl}', {});
	    	});
	    	
	        // 로그아웃
	        $('#btnLogout').click(function(){
				$.ajax({
					url: '${logoutUrl}',
					type: 'POST',
					success: function(){
						location.reload();
					},
					error: function(){
						alert('로그아웃 중 오류 발생');
					}
				});
	        });
	        
	        // 돌아가기 버튼 핸들러
	        $('#btnPrev').click(function() {
	        	// 예약 관리 페이지 이동
	        	postTo('${bookManageUrl}', { programIdx: programIdx });

			});
	        
	    });
    </script>
</body>
</html>