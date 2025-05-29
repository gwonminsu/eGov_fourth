package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.BookerVO;

@Repository("bookerDAO")
public class BookerDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 예약인 등록
	public void insertBooker(BookerVO vo) throws Exception {
		sqlSession.insert("bookerDAO.insertBooker", vo);
	}
    
    // 예약에 대한 에약인 목록 조회
    public List<BookerVO> selectBookerListByBookingIdx(String bookingIdx) throws Exception {
        return sqlSession.selectList("bookerDAO.selectBookerListByBookingIdx", bookingIdx);
    }
    
    // 예약인 상세 조회
    public BookerVO selectBooker(String idx) throws Exception {
        return sqlSession.selectOne("bookerDAO.selectBooker", idx);
    }
    
    // 예약인 삭제
    public void deleteBooker(String idx) throws Exception {
        sqlSession.delete("bookerDAO.deleteBooker", idx);
    }
}
