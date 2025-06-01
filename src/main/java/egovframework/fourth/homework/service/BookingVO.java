package egovframework.fourth.homework.service;

import java.sql.Timestamp;
import java.util.List;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class BookingVO {

    private String idx;
    
    private String userIdx; // 예약자 idx
    
    private String userName; // 예약자 이름
    
    private String programScheduleIdx; // 프로그램 일정 idx
    
    private Timestamp scheduleStart; // 프로그램 일정 시작 시간
    
    private String programName; // 프로그램 이름
    
    private String phone; // 예약자 대표 전화번호
    
    private Boolean isGroup = false; // 그룹 여부
    
    private String groupName; // 그룹 명
    
    private Timestamp createdAt; // 등록일
    
    private List<BookerVO> bookerList; // 예약인 목록
    
    private Boolean willCheck = true; // 검증할지 여부
	
}