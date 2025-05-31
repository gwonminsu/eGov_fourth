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
public class ApprovalResVO {

    private String idx;
    
    private String lineSnapshotIdx; // 결재 라인의 결재자들 스냅샷 idx
    
    private String approvalReqIdx; // 예약 마감 결재 기안문 idx
    
    private String comment; // 결재 의견(아마 반려 사유에 쓰이지 않을까)
    
    private String approvalStatus; // 기안문에 대해 응답 내용(결재 or 반려)
    
    private Timestamp createdAt; // 등록일
    
    private String snapUserType; // 기안문 (라인 스냅샷) 결재자의 결재 타입
    
    private String snapUserSeq; // 결재자 타입별 우선순위
	
}