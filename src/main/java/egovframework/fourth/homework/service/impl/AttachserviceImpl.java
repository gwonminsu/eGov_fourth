package egovframework.fourth.homework.service.impl;

import java.io.File;
import java.util.List;

import javax.annotation.Resource;

import org.egovframe.rte.fdl.cmmn.EgovAbstractServiceImpl;
import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import egovframework.fourth.homework.service.AttachService;
import egovframework.fourth.homework.service.AttachVO;

@Service("attachService")
public class AttachserviceImpl extends EgovAbstractServiceImpl implements AttachService {
	
	private static final Logger log = LoggerFactory.getLogger(AttachserviceImpl.class);
	
    @Resource(name = "propertiesService")
    private EgovPropertyService propertiesService;
	
	@Resource(name = "attachDAO")
	private AttachDAO attachDAO;

	// 첨부 파일 등록(프로그램)
	@Override
	public void createProgramAttach(String programIdx, MultipartFile file) throws Exception {
		if (file == null) return;
        String baseDir = propertiesService.getString("file.upload.dir");
        File uploadDir = new File(baseDir);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        
        String origName = file.getOriginalFilename();
        String ext = origName.substring(origName.lastIndexOf('.'));
        long size = file.getSize();
        
        // db에 프로그램 이미지 메타데이터 저장
        AttachVO vo = new AttachVO();
        vo.setProgramIdx(programIdx);
        vo.setFileName(origName);
        vo.setFilePath(baseDir);
        vo.setFileSize(size);
        vo.setExt(ext);
        attachDAO.insertAttach(vo);
        log.info("INSERT 프로그램({})에 이미지 첨부 파일({}) 등록 성공", vo.getProgramIdx(), vo.getIdx());
        
        // 실제 파일 물리 저장
        File dest = new File(uploadDir, vo.getFileUuid() + ext);
        file.transferTo(dest);
        log.info("로컬 저장소에 파일 저장 완료! : {}", vo.getFileUuid() + vo.getExt());		
	}
	
	// 첨부 파일 등록(기안문)
	@Override
	public void createApprovalReqAttach(String approvalReqIdx, List<MultipartFile> files) throws Exception {
		if (files.size() < 1) return;
        String baseDir = propertiesService.getString("file.upload.dir");
        File uploadDir = new File(baseDir);
        if (!uploadDir.exists()) uploadDir.mkdirs();
        
        for (MultipartFile file : files) {
            String origName = file.getOriginalFilename();
            String ext = origName.substring(origName.lastIndexOf('.'));
            long size = file.getSize();
            
            // db에 기안문 파일 메타데이터 저장
            AttachVO vo = new AttachVO();
            vo.setApprovalReqIdx(approvalReqIdx);
            vo.setFileName(origName);
            vo.setFilePath(baseDir);
            vo.setFileSize(size);
            vo.setExt(ext);
            attachDAO.insertAttach(vo);
            log.info("INSERT 예약 마감 기안문({})에 첨부 파일({}) 등록 성공", vo.getApprovalReqIdx(), vo.getIdx());
            
            // 실제 파일 물리 저장
            File dest = new File(uploadDir, vo.getFileUuid() + ext);
            file.transferTo(dest);
            log.info("로컬 저장소에 파일 저장 완료! : {}", vo.getFileUuid() + vo.getExt());	
        }
	}

	// 프로그램 idx로 첨부 이미지 파일 조회
	@Override
	public AttachVO getAttachByProgramIdx(String programIdx) throws Exception {
		AttachVO vo = attachDAO.selectAttachByProgramIdx(programIdx);
		log.info("SELECT 프로그램({})에 대한 이미지 첨부 파일 조회 완료", programIdx);
		return vo;
	}
	
	// 기안문 idx로 첨부 파일 목록 조회
	@Override
	public List<AttachVO> getAttachListByApprovalReqIdx(String approvalReqIdx) throws Exception {
		List<AttachVO> list = attachDAO.selectAttachListByApprovalReqIdx(approvalReqIdx);
		log.info("SELECT 기안문({})에 대한 첨부 파일 목록 조회 완료", approvalReqIdx);
		return list;
	}

	// 첨부 파일 단일 조회
	@Override
	public AttachVO getAttach(String idx) throws Exception {
		AttachVO vo = attachDAO.selectAttach(idx);
		log.info("SELECT 첨부 파일({}) 조회 완료", idx);
		return vo;
	}

	// 첨부 파일 삭제
	@Override
	public void removeAttach(String idx) throws Exception {
		AttachVO vo = attachDAO.selectAttach(idx);
		attachDAO.deleteAttach(idx); // DB에서 삭제
		log.info("DELETE 질문 이미지({}) 삭제 완료", vo.getFileName());
		// 물리 파일 삭제
		File file = new File(vo.getFilePath(), vo.getFileUuid() + vo.getExt());
		log.info("삭제되는 첨부파일 이름: {}", vo.getFileName());
		if (file.exists()) {
			file.delete();
			log.info("로컬 저장소에서 파일 삭제 완료! : {}", vo.getFileUuid() + vo.getExt());
		} else {
			log.info("로컬 저장소에서 삭제할 파일이 존재하지 않음 : {}", vo.getFileUuid() + vo.getExt());
		}
	}
	
	// 프로그램에 있는 이미지 첨부파일 삭제
	@Override
	public void removeAttachByProgramIdx(String programIdx) throws Exception {
		AttachVO vo = attachDAO.selectAttachByProgramIdx(programIdx);
	    // 기존 파일이 없으면 리턴
	    if (vo == null) return;
		
		attachDAO.deleteAttachByProgramIdx(programIdx); // DB에서 삭제
		log.info("DELETE 프로그램({})에 대한 이미지 첨부 파일({}) 삭제 완료", programIdx, vo.getFileName());
		// 물리 파일 삭제
		File file = new File(vo.getFilePath(), vo.getFileUuid() + vo.getExt());
		log.info("삭제될 프로그램({})에 소속된 삭제되는 첨부파일 이름: {}", programIdx, vo.getFileName());
		if (file.exists()) {
			file.delete();
			log.info("로컬 저장소에서 파일 삭제 완료! : {}", vo.getFileUuid() + vo.getExt());
		} else {
			log.info("로컬 저장소에서 삭제할 파일이 존재하지 않음 : {}", vo.getFileUuid() + vo.getExt());
		}
	}

}
