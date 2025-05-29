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
public class ApprovalLineVO {

    private String idx;
    
    private String createUserIdx; // 결재 라인 생성한 사용자 idx
    
    private String lineName; // 라인 이름
    
    private Timestamp createdAt; // 등록일
    
    private Timestamp updatedAt; // 수정일
    
    private List<LineUserVO> lineUserList; // 결재할 사용자 목록
	
}