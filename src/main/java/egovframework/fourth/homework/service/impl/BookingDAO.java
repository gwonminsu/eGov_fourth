package egovframework.fourth.homework.service.impl;

import java.util.List;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.BookingVO;

@Repository("bookingDAO")
public class BookingDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 프로그램 일정에 대한 예약 등록
	public void insertBooking(BookingVO vo) throws Exception {
		sqlSession.insert("bookingDAO.insertBooking", vo);
	}
    
    // 프로그램 일정에 대한 예약 목록 조회
    public List<BookingVO> selectBookingListByProgramScheduleIdx(String programScheduleIdx) throws Exception {
        return sqlSession.selectList("bookingDAO.selectBookingListByProgramScheduleIdx", programScheduleIdx);
    }
    
    // 예약 상세 조회
    public BookingVO selectBooking(String idx) throws Exception {
        return sqlSession.selectOne("bookingDAO.selectBooking", idx);
    }
    
    // 예약 삭제
    public void deleteBooking(String idx) throws Exception {
        sqlSession.delete("bookingDAO.deleteBooking", idx);
    }
}
