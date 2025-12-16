package vn.nhomx.magic_english.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.nhomx.magic_english.model.Vocabulary;

import java.util.List;

@Repository
public interface VocabularyRepository extends JpaRepository<Vocabulary, Long>, JpaSpecificationExecutor<Vocabulary> {

    
}
