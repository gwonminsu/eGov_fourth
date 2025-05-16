package egovframework.fourth.homework.service;

import java.sql.Timestamp;

import org.springmodules.validation.bean.conf.loader.annotation.handler.NotBlank;

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
    
    private String userId; // 아이디
    
    private String password; // 비밀번호
    
    private boolean role = false; // 역할(권한)

    private Timestamp createdAt; // 등록일
	
}
