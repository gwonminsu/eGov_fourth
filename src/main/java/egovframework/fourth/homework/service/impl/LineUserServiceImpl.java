package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.LineUserService;
import egovframework.fourth.homework.service.LineUserVO;

@Service("lineUserService")
public class LineUserServiceImpl extends EgovAbstractServiceImpl implements LineUserService {
	
	private static final Logger log = LoggerFactory.getLogger(LineUserServiceImpl.class);
	
	@Resource(name = "lineUserDAO")
	private LineUserDAO lineUserDAO;

	// 결재 라인의 결재할 사용자 생성
	@Override
	public void createLineUser(LineUserVO vo) throws Exception {
		lineUserDAO.insertLineUser(vo);
		log.info("INSERT 결재 라인({})의 결재할 관리자({}) 등록 성공", vo.getLineIdx(), vo.getIdx());
	}
	
	// 결재 라인의 결재할 사용자 목록 조회
	@Override
	public List<LineUserVO> getLineLineUserList(String lineIdx) throws Exception {
		List<LineUserVO> list = lineUserDAO.selectLineUserListByLineIdx(lineIdx);
		log.info("SELECT 결재 라인({})의 결재할 관리자 목록 조회 완료", lineIdx);
		return list;
	}

	// 결재 라인의 결재할 사용자 조회
	@Override
	public LineUserVO getLineUser(String idx) throws Exception {
		LineUserVO vo = lineUserDAO.selectLineUser(idx);
		log.info("SELECT 결재할 관리자({}) 조회 완료", vo.getIdx());
		return vo;
	}

	// 결재 라인의 결재할 사용자 삭제
	@Override
	public void removeLineUser(String idx) throws Exception {
		lineUserDAO.deleteLineUser(idx);
		log.info("DELETE 결재할 관리자({}) 삭제 완료", idx);
	}
	
	// 결재 라인에 소속된 결재할 사용자들 삭제
	@Override
	public void removeLineLineUser(String lineIdx) throws Exception {
		lineUserDAO.deleteLineUserByLineIdx(lineIdx);
		List<LineUserVO> list = lineUserDAO.selectLineUserListByLineIdx(lineIdx);
		log.info("DELETE 결재 라인({})에 소속된 결재할 관리자들 삭제 완료(총 {}건)", lineIdx, list.size());
	}

}
