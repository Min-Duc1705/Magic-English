package vn.nhomx.magic_english.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import vn.nhomx.magic_english.model.Achievement;
import vn.nhomx.magic_english.model.User;
import vn.nhomx.magic_english.model.UserAchievement;
import vn.nhomx.magic_english.repository.UserRepository;
import vn.nhomx.magic_english.service.UserAchievementService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/user-achievements")
public class UserAchievementController {

   
}
