package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ApprovalLineService;
import egovframework.fourth.homework.service.ApprovalLineVO;
import egovframework.fourth.homework.service.LineUserService;
import egovframework.fourth.homework.service.LineUserVO;

@Service("approvalLineService")
public class ApprovalLineServiceImpl extends EgovAbstractServiceImpl implements ApprovalLineService {
	
	private static final Logger log = LoggerFactory.getLogger(ApprovalLineServiceImpl.class);
	
	@Resource(name = "approvalLineDAO")
	private ApprovalLineDAO approvalLineDAO;
	
	@Resource(name = "lineUserService")
	private LineUserService lineUserService;

	// 결재 라인 생성 + 결재할 사용자 목록 생성
	@Override
	public void createApprovalLine(ApprovalLineVO vo) throws Exception {
		List<LineUserVO> lineUserList = vo.getLineUserList();
		approvalLineDAO.insertApprovalLine(vo); // 라인 생성 후
		for (LineUserVO lineUser : lineUserList) {
			lineUser.setLineIdx(vo.getIdx()); // 각 라인 유저의 라인 idx 설정하고
			lineUserService.createLineUser(lineUser); // 각 라인 유저 생성
		}
		log.info("INSERT 사용자({})의 결재 라인({}) 등록 성공", vo.getCreateUserIdx(), vo.getIdx());
	}
	
	// 관리자의 결재 라인 목록 조회
	@Override
	public List<ApprovalLineVO> getUserApprovalLineList(String createUserIdx) throws Exception {
		List<ApprovalLineVO> list = approvalLineDAO.selectApprovalLineListByCreateUserIdx(createUserIdx);
		for (ApprovalLineVO vo : list) {
			List<LineUserVO> lineUser = lineUserService.getLineLineUserList(vo.getIdx());
			vo.setLineUserList(lineUser); // 라인 유저 목록을 라인에 삽입
		}
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

	// 결재 라인 수정(라인 이름) + 라인 유저 전부 삭제 후 재생성
	@Override
	public void editApprovalLine(ApprovalLineVO vo) throws Exception {
		List<LineUserVO> lineUserList = vo.getLineUserList();
		lineUserService.removeLineLineUser(vo.getIdx()); // 결재 라인에 소속된 라인 유저들 삭제하고
		approvalLineDAO.updateApprovalLine(vo); // 라인 이름 수정 후
		for (LineUserVO lineUser : lineUserList) {
			lineUser.setLineIdx(vo.getIdx()); // 각 라인 유저의 라인 idx 설정하고
			lineUserService.createLineUser(lineUser); // 각 라인 유저 생성
		}
		log.info("INSERT 사용자({})의 결재 라인({}) 수정 성공", vo.getCreateUserIdx(), vo.getIdx());
	}
	
	// 결재 라인 삭제
	@Override
	public void removeApprovalLine(String idx) throws Exception {
		lineUserService.removeLineLineUser(idx); // 결재 라인에 소속된 라인 유저들 삭제하고
		approvalLineDAO.deleteApprovalLine(idx); // 라인 삭제
		log.info("DELETE 결재 라인({}) 삭제 완료", idx);
	}

}
