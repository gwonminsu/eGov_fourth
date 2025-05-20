package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.ProgramService;
import egovframework.fourth.homework.service.ProgramVO;

@Service("programService")
public class ProgramServiceImpl extends EgovAbstractServiceImpl implements ProgramService {
	
	private static final Logger log = LoggerFactory.getLogger(ProgramServiceImpl.class);
	
	@Resource(name = "programDAO")
	private ProgramDAO programDAO;

	// 프로그램 등록
	@Override
	public void createprogram(ProgramVO vo) throws Exception {
		programDAO.insertProgram(vo);
		log.info("INSERT 프로그램({}) 등록 성공", vo.getIdx());
	}

	// 프로그램 목록 조회
	@Override
	public List<ProgramVO> getProgramList() throws Exception {
		List<ProgramVO> list = programDAO.selectProgramList();
		log.info("SELECT 프로그램 목록 조회 완료");
		return list;
	}

	// 프로그램 단일 조회
	@Override
	public ProgramVO getProgram(String idx) throws Exception {
		ProgramVO vo = programDAO.selectProgram(idx);
		log.info("SELECT 프로그램({}) 조회 완료", idx);
		return vo;
	}

	// 프로그램 수정
	@Override
	public void modifyProgram(ProgramVO vo) throws Exception {
		programDAO.updateProgram(vo);
		log.info("UPDATE 프로그램({}) 수정 완료", vo.getIdx());
	}

	// 프로그램 삭제
	@Override
	public void removeProgram(String idx) throws Exception {
		programDAO.deleteProgram(idx);
		log.info("DELETE 프로그램({}) 삭제 완료", idx);
	}

}
