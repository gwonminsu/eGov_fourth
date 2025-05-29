package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface UserService {

	// 검색된 사용자 데이터 목록 조회
	List<UserVO> getUserList(String department, String userName, String position) throws Exception;
	
	// 회원가입
	void registerUser(UserVO user) throws Exception;

	// 로그인(사용자 아이디 비밀번호 일치 여부 조회)
	UserVO authenticate(LoginVO user) throws Exception;
}
