package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.ApprovalReqVO;
import egovframework.fourth.homework.service.ApprovalResVO;

@Repository("approvalResDAO")
public class ApprovalResDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 기안문 응답 등록
	public void insertApprovalRes(ApprovalResVO vo) throws Exception {
		sqlSession.insert("approvalResDAO.insertApprovalRes", vo);
	}
	
    // 기안문 응답 하나 조회
    public ApprovalResVO selectApprovalRes(String idx) throws Exception {
        return sqlSession.selectOne("approvalResDAO.selectApprovalRes", idx);
    }
    
    // 기안문의 기안문 응답 목록 조회
    public List<ApprovalResVO> selectApprovalResListByApprovalReqIdx(String approvalReqIdx) throws Exception {
        return sqlSession.selectList("approvalResDAO.selectApprovalResListByApprovalReqIdx", approvalReqIdx);
    }
    
    // 사용자의 기안문 응답 목록 조회
    public List<ApprovalResVO> selectApprovalResListByUserIdx(String userIdx) throws Exception {
        return sqlSession.selectList("approvalResDAO.selectApprovalResListByUserIdx", userIdx);
    }
    
    // 기안문 응답 삭제
    public void deleteApprovalRes(String idx) throws Exception {
        sqlSession.delete("approvalResDAO.deleteApprovalRes", idx);
    }
    
    // 기안문에 있는 모든 기안문 응답 삭제
    public void deleteApprovalResByApprovalReqIdx(String approvalReqIdx) throws Exception {
        sqlSession.delete("approvalResDAO.deleteApprovalResByApprovalReqIdx", approvalReqIdx);
    }
}
