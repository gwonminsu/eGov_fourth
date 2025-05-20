package egovframework.fourth.homework.service.impl;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.AttachService;
import egovframework.fourth.homework.service.AttachVO;

@Service("attachService")
public class AttachserviceImpl extends EgovAbstractServiceImpl implements AttachService {
	
	private static final Logger log = LoggerFactory.getLogger(AttachserviceImpl.class);
	
	@Resource(name = "attachDAO")
	private AttachDAO attachDAO;

	// 첨부 파일 등록
	@Override
	public void createAttach(AttachVO vo) throws Exception {
		attachDAO.insertAttach(vo);
		log.info("INSERT 첨부파일({}) 등록 성공", vo.getIdx());
	}

	// 프로그램 idx로 첨부 이미지 파일 조회
	@Override
	public AttachVO getAttachByProgramIdx(String programIdx) throws Exception {
		AttachVO vo = attachDAO.selectAttachByProgramIdx(programIdx);
		log.info("SELECT 프로그램({})에 대한 이미지 첨부 파일 조회 완료", programIdx);
		return vo;
	}

	// 첨부 파일 단일 조회
	@Override
	public AttachVO getAttach(String idx) throws Exception {
		AttachVO vo = attachDAO.selectAttach(idx);
		log.info("SELECT 첨부 파일({}) 조회 완료", idx);
		return vo;
	}

	// 첨부 파일 삭제
	@Override
	public void removeAttach(String idx) throws Exception {
		attachDAO.deleteAttach(idx);
		log.info("DELETE 첨부 파일({}) 삭제 완료", idx);
	}
	
	// 프로그램에 있는 이미지 첨부파일 삭제
	@Override
	public void removeAttachByProgramIdx(String programIdx) throws Exception {
		AttachVO vo = attachDAO.selectAttachByProgramIdx(programIdx);
		attachDAO.deleteAttachByProgramIdx(programIdx);
		log.info("DELETE 프로그램({})에 대한 이미지 첨부 파일({}) 삭제 완료", programIdx, vo.getFileName());
	}

}
