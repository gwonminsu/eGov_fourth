package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.fourth.homework.service.AttachService;
import egovframework.fourth.homework.service.BookerService;
import egovframework.fourth.homework.service.BookingService;
import egovframework.fourth.homework.service.ProgramScheduleService;
import egovframework.fourth.homework.service.ProgramScheduleVO;
import egovframework.fourth.homework.service.ProgramService;
import egovframework.fourth.homework.service.ProgramVO;

@Service("programService")
public class ProgramServiceImpl extends EgovAbstractServiceImpl implements ProgramService {
	
	private static final Logger log = LoggerFactory.getLogger(ProgramServiceImpl.class);
	
	@Resource(name = "programDAO")
	private ProgramDAO programDAO;
	
    @Resource(name="attachService")
    private AttachService attachService;
    
    @Resource(name="programScheduleService")
    private ProgramScheduleService programScheduleService;
    
    @Resource(name="bookingService")
    private BookingService bookingeService;
    
    @Resource(name="bookerService")
    private BookerService bookerService;

	// 프로그램 등록
	@Override
	public void createProgram(ProgramVO vo, MultipartFile file) throws Exception {
		programDAO.insertProgram(vo); // 프로그램 등록하고
		attachService.createProgramAttach(vo.getIdx(), file); // 첨부파일 저장
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
	public void modifyProgram(ProgramVO vo, MultipartFile file) throws Exception {
		programDAO.updateProgram(vo); // 프로그램 수정하고
		// 파일 변경 여부 판단
		if (Boolean.TRUE.equals(vo.getFileChanged())) {
			// 변경 플래그가 true일 때만 파일 교체 로직 수행
			attachService.removeAttachByProgramIdx(vo.getIdx());
			if (file != null && !file.isEmpty()) {
				attachService.createProgramAttach(vo.getIdx(), file);
				log.info("UPDATE 프로그램({}) → 첨부파일 교체 완료", vo.getIdx());
			} else {
				log.info("UPDATE 프로그램({}) → 첨부파일 삭제 완료", vo.getIdx());
			}
		} else {
			log.info("UPDATE 프로그램({}) → 첨부파일 변경 없음", vo.getIdx());
		}

		log.info("UPDATE 프로그램({}) 수정 완료", vo.getIdx());
	}

	// 프로그램 삭제
	@Override
	public void removeProgram(String idx) throws Exception {
		List<ProgramScheduleVO> programScheduleList = programScheduleService.getProgramScheduleList(idx);
		for (ProgramScheduleVO programSchedule : programScheduleList) {
			programScheduleService.removeProgramSchedule(programSchedule.getIdx()); // 프로그램의 일정들 삭제
		}
		attachService.removeAttachByProgramIdx(idx); // 이미지 삭제하고
		programDAO.deleteProgram(idx); // 프로그램 삭제
		log.info("DELETE 프로그램({}) 삭제 완료", idx);
	}
}
