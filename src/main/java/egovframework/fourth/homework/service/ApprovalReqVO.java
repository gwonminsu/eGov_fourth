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
public class ApprovalReqVO {

    private String idx;
    
    private String approvalLineIdx; // 결재 라인 idx
    
    private String programScheduleIdx; // 프로그램 일정 idx
    
    private String reqUserIdx; // 기안문 작성자 idx
    
    private String userName; // 기안문 작성자 이름
    
    private String userDepartment; // 기안문 작성자 소속 부서
    
    private String userPosition; // 기안문 작성자 직급
    
    private String docId; // 문서 번호
    
    private String title; // 기안문 제목
    
    private String content; // 기안문 내용
    
    private String status = "PENDING"; // 결재 상태
    
    private Integer number; // 순번
    
    private Timestamp createdAt; // 등록일
	
}