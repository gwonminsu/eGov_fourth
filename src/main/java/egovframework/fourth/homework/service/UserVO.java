package egovframework.fourth.homework.service;

import java.sql.Timestamp;

import org.springmodules.validation.bean.conf.loader.annotation.handler.NotBlank;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import lombok.ToString;

@Getter
@Setter
@ToString
@NoArgsConstructor
public class UserVO {

    private String idx;
    
    private String userName; // 사용자 이름
    
    private String userPhone; // 사용자 전화번호
    
    private String userId; // 아이디
    
    private String userPw; // 비밀번호
    
    private Boolean isAdmin = false; // 관리자 권한
    
    private String department; // 부서
    
    private String position; // 직급

    private Timestamp createdAt; // 등록일
	
}
