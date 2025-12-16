package vn.nhomx.magic_english.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.nhomx.magic_english.model.Grammar;

@Repository
public interface GrammarRepository extends JpaRepository<Grammar, Long>, JpaSpecificationExecutor<Grammar> {

    // Find grammar checks by user ID with pagination
    Page<Grammar> findByUserId(Long userId, Pageable pageable);

    // Count grammar checks by user
    long countByUserId(Long userId);

}
