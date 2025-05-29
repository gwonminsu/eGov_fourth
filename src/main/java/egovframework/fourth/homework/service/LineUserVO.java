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
public class LineUserVO {

    private String idx;
    
    private String lineIdx; // 결재 라인 idx
    
    private String approvalUserIdx; // 결재할 사용자 idx
    
    private String userName; // 결재할 사용자 이름
    
    private String userPosition; // 결재할 사용자 직급
    
    private String type; // 결재자 타입(결재자, 협조자, 참고자)
    
    private Integer seq; // 순서
    
    private Timestamp createdAt; // 등록일
    
    private Timestamp updatedAt; // 수정일
	
}