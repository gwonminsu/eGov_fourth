package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import egovframework.fourth.homework.service.BookerService;
import egovframework.fourth.homework.service.BookerVO;

@Service("bookerService")
public class BookerServiceImpl extends EgovAbstractServiceImpl implements BookerService {
	
	private static final Logger log = LoggerFactory.getLogger(BookerServiceImpl.class);
	
	@Resource(name = "bookerDAO")
	private BookerDAO bookerDAO;

	// 예약에 대한 예약인 등록
	@Override
	public void createBooker(BookerVO vo) throws Exception {
		bookerDAO.insertBooker(vo);
		log.info("INSERT 에약({})에 예약인({}) 등록 성공", vo.getBookingIdx(), vo.getIdx());
	}
	
	// 예약에 대한 예약인 목록 조회
	@Override
	public List<BookerVO> getBookingBookerList(String bookingIdx) throws Exception {
		List<BookerVO> list = bookerDAO.selectBookerListByBookingIdx(bookingIdx);
		log.info("SELECT 에약({})의 예약인 목록 조회 완료", bookingIdx);
		return list;
	}

	// 예약인 상세 조회
	@Override
	public BookerVO getBooker(String idx) throws Exception {
		BookerVO vo = bookerDAO.selectBooker(idx);
		log.info("SELECT 에약인({}) 조회 완료", idx);
		return vo;
	}

	// 예약인 삭제
	@Override
	public void removeBooker(String idx) throws Exception {
		bookerDAO.deleteBooker(idx);
		log.info("DELETE 예약인({}) 삭제 완료", idx);
	}

}
