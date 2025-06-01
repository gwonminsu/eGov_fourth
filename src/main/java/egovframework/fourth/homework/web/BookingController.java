package egovframework.fourth.homework.web;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import egovframework.fourth.homework.service.BookingService;
import egovframework.fourth.homework.service.BookingVO;
import egovframework.fourth.homework.service.ProgramScheduleService;
import egovframework.fourth.homework.service.ProgramScheduleVO;

@RestController
@RequestMapping("/api/booking")
public class BookingController {
	private static final Logger log = LoggerFactory.getLogger(BookingController.class);

	@Resource
	private ObjectMapper objectMapper;

	@Resource(name = "bookingService")
	private BookingService bookingService;
	
	@Resource(name = "programScheduleService")
	private ProgramScheduleService programScheduleService;

	// 프로그램 일정에 예약 등록
	@PostMapping(value = "/createBooking.do", consumes = "application/json", produces = "application/json")
	public Map<String, String> writeBooking(@RequestBody BookingVO vo) throws Exception {
		// 예약에 예약인 정보가 없으면 튕굼
		if (vo.getBookerList().isEmpty()) {
        	log.info("예약 등록 거부: 예약인 정보 없음");
        	return Collections.singletonMap("error","예약인원 정보를 최소 하나 이상 등록하셔야 합니다.");
		}
		
		ProgramScheduleVO schedule = programScheduleService.getProgramSchedule(vo.getProgramScheduleIdx());
		// 일정의 capacity보다 기존 예약인 수 + 등록하는 예약인 수가 많으면 튕굼
		if (schedule.getBookerCount() + vo.getBookerList().size() > schedule.getCapacity() && vo.getWillCheck() == true) {
			log.info("예약 등록 거부: 제한 인원 수 초과");
			return Collections.singletonMap("error","예약하려는 인원 수가 현재 일정의 제한 인원 수를 초과했습니다. 전화로 예약 인원 추가 문의 바랍니다.");
		}
		
		bookingService.createBooking(vo); // 예약과 예약인 리스트 등록
		log.info("예약 등록 승인: 예약인 정보 존재 확인: ");
		return Collections.singletonMap("status", "OK");
	}
	
    // 프로그램 일정의 전체 예약 정보 조회
    @PostMapping(value="/getBookingList.do", consumes="application/json", produces="application/json")
    public List<BookingVO> getBookingList(@RequestBody Map<String,String> req) throws Exception {
        String programScheduleIdx = req.get("programScheduleIdx");
        List<BookingVO> list = bookingService.getProgramScheduleBookingList(programScheduleIdx);
        return list;
    }
    
    // 프로그램 일정의 전체 예약 정보 조회
    @PostMapping(value="/getUserBookingList.do", consumes="application/json", produces="application/json")
    public List<BookingVO> getUserBookingList(@RequestBody Map<String,String> req) throws Exception {
        String userIdx = req.get("userIdx");
        List<BookingVO> list = bookingService.getUserBookingList(userIdx);
        return list;
    }
    
    // 예약 삭제
    @PostMapping(value="/delete.do", consumes="application/json", produces="application/json")
    public Map<String,String> delete(@RequestBody Map<String,String> param) throws Exception {
    	bookingService.removeBooking(param.get("idx"));
        return Collections.singletonMap("status","OK");
    }

}
