package egovframework.fourth.homework.service.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import egovframework.fourth.homework.service.ProgramScheduleVO;

@Repository("programScheduleDAO")
public class ProgramScheduleDAO {
	
    @Resource(name = "sqlSession")
    protected SqlSessionTemplate sqlSession;
    
	// 프로그램 일정 등록
	public void insertProgramSchedule(ProgramScheduleVO vo) throws Exception {
		sqlSession.insert("programScheduleDAO.insertProgramSchedule", vo);
	}
	
    // 겹치는 프로그램 일정 개수 조회(검증용)
    public int countOverlap(Map<String,Object> param) throws Exception {
        return sqlSession.selectOne("programScheduleDAO.countOverlap", param);
    }
    
    // 프로그램 idx로 프로그램 일정 목록 조회
    public List<ProgramScheduleVO> selectProgramScheduleListByProgramIdx(String programIdx) throws Exception {
        return sqlSession.selectList("programScheduleDAO.selectProgramScheduleListByProgramIdx", programIdx);
    }
    
    // 특정 날짜의 프로그램 일정 목록 조회
    public List<ProgramScheduleVO> selectProgramScheduleListByProgramIdxAndDate(Map<String,Object> param) throws Exception {
        return sqlSession.selectList("programScheduleDAO.selectProgramScheduleListByProgramIdxAndDate", param);
    }
    
    
    // 프로그램 일정 상세 조회
    public ProgramScheduleVO selectProgramSchedule(String idx) throws Exception {
        return sqlSession.selectOne("programScheduleDAO.selectProgramSchedule", idx);
    }
    
    // 프로그램 일정 수정
    public void updateProgramSchedule(ProgramScheduleVO vo) throws Exception {
        sqlSession.update("programScheduleDAO.updateProgramSchedule", vo);
    }
    
    // 프로그램 일정 삭제(요구사항에는 없긴한데)
    public void deleteProgramSchedule(String idx) throws Exception {
        sqlSession.delete("programScheduleDAO.deleteProgramSchedule", idx);
    }
}
