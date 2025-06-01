package egovframework.fourth.homework.service;

import java.sql.Timestamp;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class ProgramScheduleVO {

    private String idx;
    
    private String createUserIdx; // 등록자 idx
    
    private String programIdx; // 프로그램 idx
    
    private String programName; //프로그램 이름
    
    private Timestamp startDatetime; // 시작 날짜 + 시간
    
    private Timestamp endDatetime; // 끝 날짜 + 시간
    
    private int capacity; // 예약자 제한 인원 
    
    private Integer bookingCount; // 일정에 예약된 총 예약 수
    
    private Integer bookerCount; // 일정에 예약된 총 예약인 수
    
    private String closeReqState; // 예약 마감 상태
    
    private Timestamp createdAt; // 등록일
    
    private Timestamp updatedAt; // 수정일
	
}