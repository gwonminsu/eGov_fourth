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
public class ProgramVO {

    private String idx;
    
    private String createUserIdx; // 등록자 idx
    
    private String programName; // 프로그램 이름
    
    private String userType; // 주요 대상 연령
    
    private String description; // 프로그램 개요
    
    private Timestamp createdAt; // 등록일
    
	private Timestamp updatedAt; // 수정일

	
}