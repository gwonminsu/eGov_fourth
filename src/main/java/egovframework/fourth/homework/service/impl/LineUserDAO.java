package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.LineUserVO;

@Repository("lineUserDAO")
public class LineUserDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 결재 라인의 결재할 사용자 등록
	public void insertLineUser(LineUserVO vo) throws Exception {
		sqlSession.insert("lineUserDAO.insertLineUser", vo);
	}
    
    // 결재 라인의 결재할 사용자 목록 조회
    public List<LineUserVO> selectLineUserListByLineIdx(String lineIdx) throws Exception {
        return sqlSession.selectList("lineUserDAO.selectLineUserListByLineIdx", lineIdx);
    }
    
    // 결재 라인의 결재할 사용자 조회
    public LineUserVO selectLineUser(String idx) throws Exception {
        return sqlSession.selectOne("lineUserDAO.selectLineUser", idx);
    }
    
    // 결재 라인의 결재할 사용자 하나 삭제
    public void deleteLineUser(String idx) throws Exception {
        sqlSession.delete("lineUserDAO.deleteLineUser", idx);
    }
    
    // 결재 라인의 결재할 사용자들 삭제
    public void deleteLineUserByLineIdx(String lineIdx) throws Exception {
        sqlSession.delete("lineUserDAO.deleteLineUserByLineIdx", lineIdx);
    }
}
