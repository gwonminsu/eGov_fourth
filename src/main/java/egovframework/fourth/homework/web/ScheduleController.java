package egovframework.fourth.homework.web;

import javax.annotation.Resource;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

@RestController
@RequestMapping("/api/schedule")
public class ScheduleController {
	private static final Logger log = LoggerFactory.getLogger(ScheduleController.class);
	
	@Resource
	private ObjectMapper objectMapper;

	
}
