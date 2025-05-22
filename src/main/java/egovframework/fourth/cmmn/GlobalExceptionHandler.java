package egovframework.fourth.cmmn;

import java.util.Collections;
import java.util.Map;

import org.springframework.http.HttpStatus;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ResponseBody
    public Map<String,String> handleForeignKey(DataIntegrityViolationException ex) {
        return Collections.singletonMap("error", "외래키 제약 위반 오류가 발생했습니다");
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    @ResponseBody
    public Map<String,String> handleOther(Exception ex) {
        return Collections.singletonMap("error", ex.getMessage());
    }
}