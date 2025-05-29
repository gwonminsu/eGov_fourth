package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.ApprovalLineVO;

@Repository("approvalLineDAO")
public class ApprovalLineDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 결재 라인 등록
	public void insertApprovalLine(ApprovalLineVO vo) throws Exception {
		sqlSession.insert("approvalLineDAO.insertApprovalLine", vo);
	}
    
    // 관리자의 결재 라인 목록 조회
    public List<ApprovalLineVO> selectApprovalLineListByCreateUserIdx(String createUserIdx) throws Exception {
        return sqlSession.selectList("approvalLineDAO.selectApprovalLineListByCreateUserIdx", createUserIdx);
    }
    
    // 결재 라인 하나 조회
    public ApprovalLineVO selectApprovalLine(String idx) throws Exception {
        return sqlSession.selectOne("approvalLineDAO.selectApprovalLine", idx);
    }
    
    // 결재 라인 업데이트(라인 이름)
    public void updateApprovalLine(String idx) throws Exception {
        sqlSession.update("approvalLineDAO.updateApprovalLine", idx);
    }
    
    // 결재 라인 삭제
    public void deleteApprovalLine(String idx) throws Exception {
        sqlSession.delete("approvalLineDAO.deleteApprovalLine", idx);
    }
}
