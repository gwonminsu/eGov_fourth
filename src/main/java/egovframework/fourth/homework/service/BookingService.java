package egovframework.fourth.homework.service;

import java.util.List;

//Service 인터페이스
public interface BookingService {
	
	// 프로그램 일정에 대한 예약 등록
	void createBooking(BookingVO vo) throws Exception;
	  
	// 프로그램 일정에 대한 예약 목록 조회
	List<BookingVO> getProgramScheduleBookingList(String programScheduleIdx) throws Exception;
	  
	// 예약 상세 조회
	BookingVO getBooking(String idx) throws Exception;
	  
	// 예약 삭제
	void removeBooking(String idx) throws Exception;
  
}
