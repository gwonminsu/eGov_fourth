package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface BookerService {

	// 예약에 대한 예약인 등록
	void createBooker(BookerVO vo) throws Exception;
	  
	// 예약에 대한 예약인 목록 조회
	List<BookerVO> getBookingBookerList(String bookingIdx) throws Exception;
	  
	// 예약인 상세 조회
	BookerVO getBooker(String idx) throws Exception;
	  
	// 예약인 삭제
	void removeBooker(String idx) throws Exception;
  
}
