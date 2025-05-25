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
public class BookerVO {

    private String idx;
    
    private String bookingIdx; // 예약 idx
    
    private String bookerName; // 예약인 이름
    
    private String sex; // 예약인 성별(man, woman)
    
    private String userType; // 대상 구분(연령대)
    
    private String administrationArea; // 거주 행정 구역
    
    private String city; // 거주 도시

    private Boolean isDisabled; // 장애 여부
    
    private Boolean isForeigner; // 외국인 여부
    
    private Timestamp createdAt; // 등록일
	
}