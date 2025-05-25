package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.BookingService;
import egovframework.fourth.homework.service.BookingVO;

@Service("bookingService")
public class BookingServiceImpl extends EgovAbstractServiceImpl implements BookingService {
	
	private static final Logger log = LoggerFactory.getLogger(BookingServiceImpl.class);
	
	@Resource(name = "bookingDAO")
	private BookingDAO bookingDAO;

	// 프로그램 일정에 대한 예약 등록
	@Override
	public void createBooking(BookingVO vo) throws Exception {
		bookingDAO.insertBooking(vo);
		log.info("INSERT 프로그램 일정({})에 예약({}) 등록 성공", vo.getProgramScheduleIdx(), vo.getIdx());
	}
	
	// 프로그램 일정에 대한 예약 목록 조회
	@Override
	public List<BookingVO> getProgramScheduleBookingList(String programScheduleIdx) throws Exception {
		List<BookingVO> list = bookingDAO.selectBookingListByProgramScheduleIdx(programScheduleIdx);
		log.info("SELECT 프로그램의 일정({})의 예약 목록 조회 완료", programScheduleIdx);
		return list;
	}

	// 예약 상세 조회
	@Override
	public BookingVO getBooking(String idx) throws Exception {
		BookingVO vo = bookingDAO.selectBooking(idx);
		log.info("SELECT 에약({}) 조회 완료", idx);
		return vo;
	}

	// 예약 삭제
	@Override
	public void removeBooking(String idx) throws Exception {
		bookingDAO.deleteBooking(idx);
		log.info("DELETE 예약({}) 삭제 완료", idx);
	}

}
