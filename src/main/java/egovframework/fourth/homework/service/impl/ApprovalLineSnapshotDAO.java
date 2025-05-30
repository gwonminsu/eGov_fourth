package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.ApprovalLineSnapshotVO;

@Repository("approvalLineSnapshotDAO")
public class ApprovalLineSnapshotDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 결재 기안문에 결재 라인에 등록된 결재할 사용자 등록
	public void insertApprovalLineSnapshot(ApprovalLineSnapshotVO vo) throws Exception {
		sqlSession.insert("approvalLineSnapshotDAO.insertApprovalLineSnapshot", vo);
	}
    
    // 결재 기안문의 결재할 사용자 목록 조회
    public List<ApprovalLineSnapshotVO> selectApprovalLineSnapshotListByApprovalReqIdx(String approvalReqIdx) throws Exception {
        return sqlSession.selectList("approvalLineSnapshotDAO.selectApprovalLineSnapshotListByApprovalReqIdx", approvalReqIdx);
    }
    
    // 결재 기안문에 등록된 결재할 특정 사용자 조회
    public ApprovalLineSnapshotVO selectApprovalLineSnapshot(String idx) throws Exception {
        return sqlSession.selectOne("approvalLineSnapshotDAO.selectApprovalLineSnapshot", idx);
    }
    
    // 결재 기안문에 등록된 결재할 특정 사용자 하나 삭제
    public void deleteApprovalLineSnapshot(String idx) throws Exception {
        sqlSession.delete("approvalLineSnapshotDAO.deleteApprovalLineSnapshot", idx);
    }
    
    // 결재 기안문에 등록된 결재할 사용자들 삭제
    public void deleteApprovalLineSnapshotByApprovalReqIdx(String approvalReqIdx) throws Exception {
        sqlSession.delete("approvalLineSnapshotDAO.deleteApprovalLineSnapshotByApprovalReqIdx", approvalReqIdx);
    }
}
