package egovframework.fourth.homework.service.impl;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.AttachVO;

@Repository("attachDAO")
public class AttachDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 첨부 파일 등록
	public void insertAttach(AttachVO vo) throws Exception {
		sqlSession.insert("attachDAO.insertAttach", vo);
	}
    
    // 프로그램 idx로 첨부 이미지 파일 조회
    public AttachVO selectAttachByProgramIdx(String questionIdx) {
        return sqlSession.selectOne("attachDAO.selectAttachByProgramIdx", questionIdx);
    }
    
    // 첨부 파일 단일 조회
    public AttachVO selectAttach(String idx) {
        return sqlSession.selectOne("attachDAO.selectAttach", idx);
    }
    
    // 첨부 파일 삭제
    public void deleteAttach(String idx) {
        sqlSession.delete("attachDAO.deleteAttach", idx);
    }
        
    // 프로그램에 있는 이미지 첨부파일 삭제
    public void deleteAttachByProgramIdx(String programIdx) {
        sqlSession.update("attachDAO.deleteAttachByProgramIdx", programIdx);
    }
}
