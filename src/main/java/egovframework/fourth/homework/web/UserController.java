package egovframework.fourth.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;
import javax.validation.Valid;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.validation.BeanPropertyBindingResult;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springmodules.validation.commons.DefaultBeanValidator;

import egovframework.fourth.homework.service.LoginVO;
import egovframework.fourth.homework.service.UserService;
import egovframework.fourth.homework.service.UserVO;

// ajax 용 컨트롤러
@RestController
@RequestMapping("/api/user")
public class UserController {
	
	private static final Logger log = LoggerFactory.getLogger(UserController.class);

	@Resource(name = "userService")
	protected UserService userService;
	
	// 전자정부 검증 빈
    @Resource(name = "beanValidator")
    protected DefaultBeanValidator beanValidator;
	
	/*
	 * department: dept, name: name, position: position
	 */
	// 검색된 사용자 리스트 가져오기
	@PostMapping(value = "/searchUser.do", consumes="application/json", produces = "application/json")
	public List<UserVO> getUserList(@RequestBody Map<String,Object> req) throws Exception {
		String department = (String)req.get("department");
		String userName = (String)req.get("name");
		log.info(userName);
		String position = (String)req.get("position");
	    List<UserVO> list = userService.getUserList(department, userName, position);
	    log.info("AJAX 데이터: {}", list);
	    return list;
	}
	
    // 회원가입(JSON 요청 바디로 전달된 사용자 정보: userId, password, userName)
    @PostMapping(value="/register.do", consumes="application/json", produces="application/json")
    public Map<String,String> register(@RequestBody UserVO user) {
        // JSON 바디로 바인딩된 UserVO 에 대해 BindingResult 생성
        BindingResult bindingResult = new BeanPropertyBindingResult(user, "userVO");
        beanValidator.validate(user, bindingResult); // beanValidator 로 검증 수행
        // 검증 실패 시 에러 메시지 반환
        if (bindingResult.hasErrors()) {
            String msg = bindingResult.getFieldError().getDefaultMessage();
            log.warn("회원가입 검증 실패: {}", msg);
            return Collections.singletonMap("error", msg);
        }
        log.info("회원가입 검증 완료: userId={}, userName={}", user.getUserId(), user.getUserName());
    	
        try {
            userService.registerUser(user);
            log.info("사용자 " + user.getUserName() + "가 회원가입을 완료함");
            return Collections.singletonMap("status","OK");
        } catch(Exception e) {
        	log.info("사용자 " + user.getUserName() + " 회원가입 실패");
            return Collections.singletonMap("error", e.getMessage());
        }
    }

    // 로그인(JSON 요청 바디로 전달된 사용자 정보: userId, password)
    @PostMapping(value="/login.do", consumes="application/json", produces="application/json")
    public Map<String,Object> login(@RequestBody LoginVO param, HttpSession session) throws Exception {
        // JSON 바디로 바인딩된 UserVO 에 대해 BindingResult 생성
        BindingResult bindingResult = new BeanPropertyBindingResult(param, "loginVO");
        log.debug(">> objectName = {}", bindingResult.getObjectName());
        beanValidator.validate(param, bindingResult); // beanValidator 로 검증 수행
        // 검증 실패 시 에러 메시지 반환
        if (bindingResult.hasErrors()) {
            String msg = bindingResult.getFieldError().getDefaultMessage();
            log.warn("로그인 검증 실패: {}", msg);
            return Collections.singletonMap("error", msg);
        }
        log.info("로그인 검증 완료: userId={}", param.getUserId());
        
        // 인증 호출
        UserVO loginUser = userService.authenticate(param);
        if (loginUser == null) {
        	log.info("로그인 인증 실패: " + param);
            return Collections.singletonMap("error","로그인 인증에 실패하였습니다");
        }
        log.info("로그인 인증 성공: " + loginUser);
        session.setAttribute("loginUser", loginUser);  // 세션에 로그인 사용자 정보 저장
        return Collections.singletonMap("user", loginUser); // 사용자 정보 반환
    }

    // 로그아웃
    @PostMapping("/logout.do")
    public Map<String,String> logout(HttpSession session) {
    	UserVO loginUser = (UserVO) session.getAttribute("loginUser");
    	log.info(loginUser.getUserName() + " 로그아웃됨");
        session.invalidate(); // 세션 무효화
        return Collections.singletonMap("status","OK");
    }
	
}
