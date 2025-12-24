package vn.nhomx.magic_english.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import vn.nhomx.magic_english.model.TOEICUserAnswer;

@Repository
public interface TOEICUserAnswerRepository extends JpaRepository<TOEICUserAnswer, Long> {
}
