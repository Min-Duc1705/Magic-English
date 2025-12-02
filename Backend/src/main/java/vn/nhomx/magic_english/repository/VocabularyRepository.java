package vn.nhomx.magic_english.repository;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import vn.nhomx.magic_english.model.Vocabulary;


/**
 * Repository interface để thao tác với bảng Vocabulary trong database.
 * 
 * - Kế thừa JpaRepository: cung cấp các phương thức CRUD cơ bản (save,
 * findById, delete, findAll...)
 * - Kế thừa JpaSpecificationExecutor: cho phép thực hiện truy vấn động và phức
 * tạp với Specification
 * 
 * @Repository: Đánh dấu đây là Spring Bean thuộc tầng Repository (Data Access
 *              Layer)
 */
@Repository
public interface VocabularyRepository extends JpaRepository<Vocabulary, Long>, JpaSpecificationExecutor<Vocabulary> {

    /**
     * Đếm số lượng từ vựng theo loại từ (noun, verb, adj...) của một user cụ thể.
     * 
     * @param userId ID của user cần thống kê
     * @return Danh sách mảng [wordType, count] - ví dụ: [["noun", 10], ["verb", 5],
     *         ["adj", 3]]
     */
    @Query("SELECT v.wordType, COUNT(v) FROM Vocabulary v WHERE v.user.id = :userId GROUP BY v.wordType")
    List<Object[]> countByWordTypeForUser(@Param("userId") Long userId);

    /**
     * Đếm số lượng từ vựng theo trình độ CEFR (A1, A2, B1, B2, C1, C2) của một
     * user.
     * 
     * @param userId ID của user cần thống kê
     * @return Danh sách mảng [cefrLevel, count] - ví dụ: [["A1", 15], ["B1", 8],
     *         ["C1", 2]]
     */
    @Query("SELECT v.cefrLevel, COUNT(v) FROM Vocabulary v WHERE v.user.id = :userId GROUP BY v.cefrLevel")
    List<Object[]> countByCefrLevelForUser(@Param("userId") Long userId);

    /**
     * Đếm tổng số từ vựng của một user.
     * 
     * @param userId ID của user cần đếm
     * @return Tổng số từ vựng của user
     */
    @Query("SELECT COUNT(v) FROM Vocabulary v WHERE v.user.id = :userId")
    Long countByUserId(@Param("userId") Long userId);

    /**
     * Đếm số từ vựng mà user đã thêm trong ngày hôm nay.
     * Sử dụng CURRENT_DATE để lấy ngày hiện tại của database.
     * 
     * @param userId ID của user cần đếm
     * @return Số từ vựng đã thêm trong ngày hôm nay
     */
    @Query("SELECT COUNT(v) FROM Vocabulary v WHERE v.user.id = :userId AND DATE(v.createdAt) = CURRENT_DATE")
    Long countTodayVocabularyByUserId(@Param("userId") Long userId);

    /**
     * Đếm số từ vựng theo ngày trong khoảng thời gian.
     * 
     * @param userId    ID của user cần thống kê
     * @param startDate Ngày bắt đầu
     * @return Danh sách mảng [date, count] - ví dụ: [[2024-12-23, 5], [2024-12-24,
     *         3]]
     */
    @Query("SELECT DATE(v.createdAt), COUNT(v) FROM Vocabulary v WHERE v.user.id = :userId AND DATE(v.createdAt) >= :startDate GROUP BY DATE(v.createdAt) ORDER BY DATE(v.createdAt)")
    List<Object[]> countByUserIdGroupByDate(@Param("userId") Long userId, @Param("startDate") LocalDate startDate);
}
