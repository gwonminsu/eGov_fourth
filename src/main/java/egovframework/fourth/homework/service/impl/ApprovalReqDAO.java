package egovframework.fourth.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.ApprovalReqVO;

@Repository("approvalReqDAO")
public class ApprovalReqDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 예약 마감 기안문 등록
	public void insertApprovalReq(ApprovalReqVO vo) throws Exception {
		sqlSession.insert("approvalReqDAO.insertApprovalReq", vo);
	}
	
    // 관리자에게 결재 요청받은 예약 마감 기안문 목록 조회
    public List<ApprovalReqVO> selectApprovalReqListBySnapUserIdx(Map<String,Object> param) throws Exception {
        return sqlSession.selectList("approvalReqDAO.selectApprovalReqListBySnapUserIdx", param);
    }
    
    // 관리자의 예약 마감 기안문 목록 조회
    public int selectSnapApprovalReqCount(String userIdx) throws Exception {
        return sqlSession.selectOne("approvalReqDAO.selectSnapApprovalReqCount", userIdx);
    }
    
    // 관리자의 예약 마감 기안문 목록 조회
    public List<ApprovalReqVO> selectApprovalReqListByReqUserIdx(String reqUserIdx) throws Exception {
        return sqlSession.selectList("approvalReqDAO.selectApprovalReqListByReqUserIdx", reqUserIdx);
    }
    
    // 예약 마감 기안문 상세 조회
    public ApprovalReqVO selectApprovalReq(String idx) throws Exception {
        return sqlSession.selectOne("approvalReqDAO.selectApprovalReq", idx);
    }
    
    
    // 프로그램 일정의 예약 마감 기안문 상세 조회
    public ApprovalReqVO selectApprovalReqByProgramScheduleIdx(String programScheduleIdx) throws Exception {
        return sqlSession.selectOne("approvalReqDAO.selectApprovalReqByProgramScheduleIdx", programScheduleIdx);
    }
    
    // 예약 마감 기안문 상태 업데이트
    public void updateApprovalReq(String idx) throws Exception {
        sqlSession.update("approvalReqDAO.updateApprovalReq", idx);
    }
    
    // 예약 마감 기안문 삭제
    public void deleteApprovalReq(String idx) throws Exception {
        sqlSession.delete("approvalReqDAO.deleteApprovalReq", idx);
    }
}
