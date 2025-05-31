package egovframework.fourth.homework.web;

import javax.annotation.Resource;
import javax.servlet.http.HttpSession;

import org.egovframe.rte.fdl.property.EgovPropertyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import egovframework.fourth.homework.service.UserVO;

@Controller
public class ViewController {
	
	private static final Logger log = LoggerFactory.getLogger(ViewController.class);
	
    @Resource(name="propertiesService")
    private EgovPropertyService prop;

//    @Resource(name = "userService")
//    protected UserService userService;
	
	// 로그인 페이지
	@RequestMapping(value = "/login.do")
	public String loginPage() throws Exception {
		return "login";
	}
	
	// 회원가입 페이지
	@RequestMapping(value = "/register.do")
	public String registerPage() throws Exception {
		return "register";
	}
	
	// 예약(메인) 페이지
	@RequestMapping(value = "/booking.do")
	public String bookingPage() throws Exception {
		return "booking";
	}
	
	// 프로그램 예약하기 페이지
	@RequestMapping(value = "/programBooking.do")
	public String programBookingPage(HttpSession session, RedirectAttributes rt) throws Exception {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했으면
        if (me == null) {
            rt.addFlashAttribute("errorMsg", "로그인이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "programBooking";
	}
	
	// 예약 관리 페이지(관리자 페이지)
	@RequestMapping(value = "/bookManage.do")
	public String bookManagePage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "bookManage";
	}
	
	// 프로그램 폼 페이지
	@RequestMapping(value = "/programForm.do")
	public String programFormPage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "programForm";
	}
	
	// 예약 일정 등록 페이지
	@RequestMapping(value = "/scheduleCreate.do")
	public String scheduleCreatePage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "scheduleCreate";
	}
	
	// 예약 일정 관리(상세) 페이지
	@RequestMapping(value = "/scheduleDetail.do")
	public String scheduleDetailPage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "scheduleDetail";
	}
	
	// 예약 인원 직접 추가 페이지
	@RequestMapping(value = "/addBooker.do")
	public String addBookerPage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "addBooker";
	}
	
	// 예약 마감 기안문 작성 페이지
	@RequestMapping(value = "/approvalReq.do")
	public String approvalReqPage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "approvalReq";
	}
	
	// 예약 마감 기안문 확인(상세) 페이지
	@RequestMapping(value = "/approvalDetail.do")
	public String approvalDetailPage(HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
		return "approvalDetail";
	}
	
	// 결재 목록 페이지
	@RequestMapping(value = "/approvalList.do")
	public String approvalListPage(Model model, HttpSession session, RedirectAttributes rt) {
		UserVO me = (UserVO) session.getAttribute("loginUser");
        // 로그인 안 했거나, 관리자 아니면
        if (me == null || !me.getIsAdmin()) {
            rt.addFlashAttribute("errorMsg", "관리자 권한이 필요합니다.");
            return "redirect:/booking.do";
        }
	    model.addAttribute("pageUnit", prop.getInt("pageUnit"));
	    model.addAttribute("pageSize", prop.getInt("pageSize"));
		return "approvalList";
	}
}
