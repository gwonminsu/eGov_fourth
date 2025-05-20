package egovframework.fourth.cmmn.web;

import java.util.Collections;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.fourth.homework.service.UserVO;

public class PermissionInterceptor implements HandlerInterceptor {

	private static final Logger log = LoggerFactory.getLogger(PermissionInterceptor.class);
 	
	@Override
	public boolean preHandle(HttpServletRequest req, HttpServletResponse res, Object handler) throws Exception {
		// 로그인 여부 확인
		UserVO me = (UserVO) req.getSession().getAttribute("loginUser");
		ObjectMapper mapper = new ObjectMapper();
		if (me == null) {
			// 미로그인 시 401
			log.info("Permission 거부: 세션에 로그인 정보 없음(401)");
            res.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            res.setContentType("application/json; charset=UTF-8");
            mapper.writeValue(res.getWriter(), 
                Collections.singletonMap("error", "로그인이 필요합니다.")
            );
			return false;
 		}
 		
 		// 관리자 권한 여부 체크
 		if (!me.getIsAdmin() == true) {
            log.info("Permission 거부: 관리자 권한 없음. isRole={} (403)", me.getIsAdmin());
            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
            res.setContentType("application/json; charset=UTF-8");
            mapper.writeValue(res.getWriter(),
                Collections.singletonMap("error", "관리자 권한이 필요합니다.")
            );
 		    return false;
 		}
 		
 		// 모두 통과하면 컨트롤러로
 		log.info("Permission 허가: 사용자({})의 요청 허용", me.getIdx());
		return true;
	}

}
