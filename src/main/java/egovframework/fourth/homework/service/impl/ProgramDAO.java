package egovframework.fourth.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.ProgramVO;

@Repository("programDAO")
public class ProgramDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 프로그램 등록
	public void insertProgram(ProgramVO vo) throws Exception {
		sqlSession.insert("programDAO.insertProgram", vo);
	}
    
    // 프로그램 목록 조회
    public List<ProgramVO> selectProgramList() throws Exception {
        return sqlSession.selectList("programDAO.selectProgramList");
    }
    
    // 프로그램 상세 조회
    public ProgramVO selectProgram(String idx) throws Exception {
        return sqlSession.selectOne("programDAO.selectProgram", idx);
    }
    
    // 프로그램 수정
    public void updateProgram(ProgramVO vo) throws Exception {
        sqlSession.update("programDAO.updateProgram", vo);
    }
    
    // 프로그램 삭제
    public void deleteProgram(String idx) throws Exception {
        sqlSession.delete("programDAO.deleteProgram", idx);
    }
}
