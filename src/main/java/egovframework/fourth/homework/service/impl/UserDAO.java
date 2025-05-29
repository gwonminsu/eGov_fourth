package egovframework.fourth.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.UserVO;

@Repository("userDAO")
public class UserDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;

    // 검색된 사용자 목록 조회
    public List<UserVO> selectUserList(Map<String,Object> param) throws Exception {
        return sqlSession.selectList("userDAO.selectUserList", param);
    }
    
    // id로 사용자 조회
    public UserVO selectByUserId(String userId) throws Exception {
        return sqlSession.selectOne("userDAO.selectUserByUserId", userId);
    }
    
    // 회원 가입
    public void insertUser(UserVO user) throws Exception {
        sqlSession.insert("userDAO.insertUser", user);
    }
    
}
