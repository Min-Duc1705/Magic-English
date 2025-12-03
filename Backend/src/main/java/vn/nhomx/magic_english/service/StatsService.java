package vn.project.magic_english.service;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import com.fasterxml.jackson.databind.ObjectMapper;

import lombok.RequiredArgsConstructor;
import vn.project.magic_english.model.User;
import vn.project.magic_english.repository.GrammarRepository;
import vn.project.magic_english.repository.UserRepository;
import vn.project.magic_english.repository.VocabularyRepository;

@Service
@RequiredArgsConstructor
public class StatsService {
    
}
