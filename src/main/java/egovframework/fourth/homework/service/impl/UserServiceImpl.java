package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.LoginVO;
import egovframework.fourth.homework.service.UserService;
import egovframework.fourth.homework.service.UserVO;

//Service 구현체
@Service("userService")
public class UserServiceImpl extends EgovAbstractServiceImpl implements UserService {

	 // 로거
	 private static final Logger log = LoggerFactory.getLogger(UserServiceImpl.class);
	
	 @Resource(name = "userDAO")
	 private UserDAO userDAO;
	 
	 @Resource(name="passwordEncoder")
	 private PasswordEncoder passwordEncoder;
	
	 // 데이터 리스트 조회
	 @Override
	 public List<UserVO> getUserList() throws Exception {
	     return userDAO.selectUserList();
	 }

	 // 회원가입
	 @Override
	 public void registerUser(UserVO user) throws Exception {
         // 중복 검사(사용자 id가 있는지 검사)
         if (userDAO.selectByUserId(user.getUserId()) != null) {
        	 log.info("회원가입 실패: " + user.getUserId() + "는 이미 존재하는 아이디입니다");
        	 throw new RuntimeException("이미 존재하는 아이디입니다");
         }
         // 비밀번호 암호화 텍스트로 변환
         String raw = user.getUserPw(); // 평문
         String enc = passwordEncoder.encode(raw); // 비밀번호 해시 생성
         user.setUserPw(enc); // 생성한 해시를 비밀번호로 교체
         userDAO.insertUser(user);
	 }

	 // 로그인(입력 비밀번호와 DB 해시가 일치하는지 검사)
	 @Override
	 public UserVO authenticate(LoginVO user) throws Exception {
		 UserVO dbUser = userDAO.selectByUserId(user.getUserId()); // 아이디로 DB 조회
		 if (dbUser == null) {
			 log.info("로그인 실패: DB에 아이디(" + user.getUserId() + ")가 존재하지 않음");
			 return null; // 아이디 자체가 없으면 로그인 실패
		 }
		 
		 boolean ok = passwordEncoder.matches(user.getUserPw(), dbUser.getUserPw()); // 평문해시와 저장된해시 일치하는지 검사
		 if (!ok) return null; // 비밀번호 불일치
		 
		 return dbUser;
	 }
}
