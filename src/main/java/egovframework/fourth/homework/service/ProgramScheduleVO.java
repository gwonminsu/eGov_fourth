package egovframework.fourth.homework.service;

import java.sql.Timestamp;
import java.time.LocalDate;

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
    
    private Timestamp startDatetime; // 시작 날짜 + 시간
    
    private Timestamp endDatetime; // 끝 날짜 + 시간
    
    private int capacity; // 예약자 제한 인원 
    
    private Timestamp createdAt; // 등록일
    
    private Timestamp updatedAt; // 수정일
	
}