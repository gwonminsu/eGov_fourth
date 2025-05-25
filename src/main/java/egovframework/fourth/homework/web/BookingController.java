package egovframework.fourth.homework.web;

import java.util.Collections;
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

@RestController
@RequestMapping("/api/booking")
public class BookingController {
	private static final Logger log = LoggerFactory.getLogger(BookingController.class);

	@Resource
	private ObjectMapper objectMapper;

	@Resource(name = "bookingService")
	private BookingService bookingService;

	// 프로그램 일정에 예약 등록
	@PostMapping(value = "/createBooking.do", consumes = "application/json", produces = "application/json")
	public Map<String, String> writeBooking(@RequestBody BookingVO vo) throws Exception {
		// 예약에 예약인 정보가 없으면 튕굼
		if (vo.getBookerList() == null) {
        	log.info("예약인 정보 없음: 예약 등록 거부");
        	return Collections.singletonMap("error","REJECTED");
		} else {
			bookingService.createBooking(vo); // 예약과 예약인 리스트 등록
			log.info("예약인 정보 존재 확인: 예약 등록 승인");
			return Collections.singletonMap("status", "OK");
		}
	}
	
//	{
//	  "userIdx": "USER-1",
//	  "programScheduleIdx": "PSCHD-1",
//	  "phone": "010-1234-5678",
//	  "isGroup": true,
//	  "groupName": "친구들",
//	  "bookerList": [
//	    {
//	      "bookerName": "김철수",
//	      "sex": "man",
//	      "userType": "청소년",
//	      "administrationArea": "경상북도",
//	      "city": "경산시",
//	      "isDisabled": false,
//	      "isForeigner": false
//	    },
//	    {
//	      "bookerName": "박영희",
//	      "sex": "woman",
//	      "userType": "성인",
//	      "administrationArea": "경상북도",
//	      "city": "경산시",
//	      "isDisabled": false,
//	      "isForeigner": false
//	    }
//	  ]
//	}

}
