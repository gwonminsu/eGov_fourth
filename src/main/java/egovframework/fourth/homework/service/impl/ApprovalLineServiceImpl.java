package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ApprovalLineService;
import egovframework.fourth.homework.service.ApprovalLineVO;

@Service("approvalReqService")
public class ApprovalLineServiceImpl extends EgovAbstractServiceImpl implements ApprovalLineService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalLineServiceImpl.class);
	
	@Resource(name = "approvalLineDAO")
	private ApprovalLineDAO approvalLineDAO;

	// 결재 라인 생성
	@Override
	public void createApprovalLine(ApprovalLineVO vo) throws Exception {
		approvalLineDAO.insertApprovalLine(vo);
		log.info("INSERT 사용자({})의 결재 라인({}) 등록 성공", vo.getCreateUserIdx(), vo.getIdx());
	}
	
	// 관리자의 결재 라인 목록 조회
	@Override
	public List<ApprovalLineVO> getUserApprovalLineList(String createUserIdx) throws Exception {
		List<ApprovalLineVO> list = approvalLineDAO.selectApprovalLineListByCreateUserIdx(createUserIdx);
		log.info("SELECT 사용자({})의 결재 라인 목록 조회 완료", createUserIdx);
		return list;
	}

	// 결재 라인 하나 조회
	@Override
	public ApprovalLineVO getApprovalLine(String idx) throws Exception {
		ApprovalLineVO vo = approvalLineDAO.selectApprovalLine(idx);
		log.info("SELECT 결재 라인({}) 조회 완료", vo.getIdx());
		return vo;
	}

	// 결재 라인 수정(라인 이름)
	@Override
	public void editApprovalLine(String idx) throws Exception {
		approvalLineDAO.updateApprovalLine(idx);
		log.info("DELETE 결재 라인({}) 이름 수정 완료", idx);
	}
	
	// 결재 라인 삭제
	@Override
	public void removeApprovalLine(String idx) throws Exception {
		approvalLineDAO.deleteApprovalLine(idx);
		log.info("DELETE 결재 라인({}) 삭제 완료", idx);
	}

}
