USE QLSV_051124
GO

--Cho biết tên tất cả các giáo viên cùng với số lương khóa học mà từng giáo viên đã tham gia giảng dạy.
SELECT B.TenGV,
       COUNT (A.MaKhoaHoc) AS SL_KhoaHoc
FROM DBO.GIANGDAY AS A 
     LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
GROUP BY B.TenGV

--Cho biết tên tất cả các sinh viên, điểm trung bình (của tất cả các DiemKhoaHoc), số
--lượng khóa học đã tham gia học tập.
SELECT A.Ten, 
       AVG (B.DiemKhoaHoc) AS 'Diem TB',
	   COUNT (B.MaKhoaHoc) AS 'SL Khoa hoc'
FROM DBO.SINHVIEN AS A 
     LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
GROUP BY A.Ten

--Cho biết số lượng tín chỉ mà từng sinh viên đã tham gia (gồm MSSV, tên SV, số lượng tín chỉ).
SELECT B.MSSV, B.Ten,
       SUM (C.TongSoTC) AS 'SL tin chi'
FROM DBO.KETQUA AS A
      LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	  LEFT JOIN  DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
GROUP BY B.MSSV, B.Ten

--Cho biết tên tất cả các môn học và DiemKhoaHoc của môn học đó.
SELECT C.TenMH,
       AVG (A.DiemKhoaHoc) AS 'Diem TB'
FROM DBO.KETQUA AS A
	  LEFT JOIN  DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	  LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH
GROUP BY C.TenMH

--Cho biết tên khoa, số lượng sinh viên có trong từng khoa 
SELECT A.TenKhoa,
       COUNT (B.MaKhoa)  AS SL_SV
FROM DBO.KHOA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MaKhoa = B.MaKhoa
GROUP BY A.TenKhoa

--Cho biết tên khoa, số lượng khóa học mà giáo viên của khoa có tham gia giảng dạy
SELECT A.TenKhoa,
       COUNT (B.MaKhoa)  AS 'SL Khoa hoc co GV'
FROM DBO.KHOA AS A
     LEFT JOIN DBO.GIAOVIEN AS B ON A.MaKhoa = B.MaKhoa
GROUP BY A.TenKhoa

--(*) Cho biết số lượng DiemKhoaHoc >=8 của từng sinh viên 
SELECT A.Ten,
      SUM (CASE WHEN B.DiemKhoaHoc>= 8 THEN 1 ELSE 0 END) 
	       AS 'Sl mon hoc co diem TB >=8'
FROM DBO.SINHVIEN AS A
     LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
GROUP BY A.Ten

--Không/Chưa có : (sử dụng bằng 3 cách NOT IN, EXCEPT và LEFT/RIGHT JOIN)
--Cho biết tên khoa chưa có giáo viên.
----- CACH 1 - NOT IN -----
SELECT TenKhoa FROM DBO.KHOA
WHERE MaKhoa NOT IN ( SELECT MaKhoa FROM DBO.GIAOVIEN)

-----CACH 2 EXCEPT ------
	SELECT A.TenKhoa, A.MaKhoa
	FROM DBO.KHOA AS A
		 LEFT JOIN DBO.GIAOVIEN AS B ON A.MaKhoa = B.MaKhoa
EXCEPT
	SELECT A.TenKhoa, B.MaKhoa
	FROM DBO.KHOA AS A
		 LEFT JOIN DBO.GIAOVIEN AS B ON A.MaKhoa = B.MaKhoa

--Cho biết tên những môn học chưa được tổ chức cho các khóa học.
SELECT TenMH
FROM DBO.MONHOC 
WHERE MaMH NOT IN (SELECT MaMH FROM DBO.GIANGDAY)

--Cho biết tên những sinh viên chưa có bất kỳ điểm nào trong table KetQua.
SELECT Ten 
FROM DBO.SINHVIEN
WHERE MSSV NOT IN ( SELECT MSSV FROM DBO.KETQUA)

--Cho biết tên những khoa không có sinh viên theo học.
SELECT TenKhoa
FROM DBO.KHOA
WHERE MaKhoa NOT IN (SELECT MaKhoa FROM DBO.SINHVIEN)

--(*) Cho biết các SV chưa học môn ‘Lap Trinh C Tren Window’.
SELECT TEN
FROM DBO.SINHVIEN
WHERE Ten NOT IN (  SELECT Ten
					FROM DBO.KETQUA AS A
						 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
						 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
						 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH
					WHERE TenMH IN ('Lap Trinh C Tren Window')
				 )
			
--(*) Tên các giáo viên không tham gia giảng dạy trong năm 2011 (bao gồm cả 2 trường
--hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).
SELECT TenGV
FROM DBO.GIAOVIEN
WHERE TenGV NOT IN ( SELECT TenGV
					 FROM DBO.GIAOVIEN AS A LEFT JOIN DBO.GIANGDAY AS B ON  A.MaGV = B.MaGV
					 WHERE NienKhoa  LIKE '%2011%'
				   )

--(*) Cho biết tên các môn học không được tổ chức trong năm 2011 (bao gồm cả 2 trường
--hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).
SELECT TenMH
FROM DBO.MONHOC
WHERE TenMH NOT IN ( SELECT TenMH
					 FROM DBO.MONHOC AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
					 WHERE  NienKhoa LIKE '%2011%' 
				   )

-- (*) Cho biết mã, tên các SV có tất cả các DiemKhoaHoc đều trên 8. Kết quả sẽ không
--hiển thị những sinh viên chưa có điểm trong table kết quả. Lưu ý cần loại bỏ những SV
--chưa có điểm trong bất ký khóa học nào.
SELECT DISTINCT MSSV
FROM DBO.KETQUA 
WHERE MSSV NOT IN ( SELECT DISTINCT C.MSSV
					FROM DBO.KETQUA AS C LEFT JOIN DBO.SINHVIEN AS D  ON C.MSSV = D.MSSV
					WHERE  C.DiemKhoaHoc <8 
					)

-- (*) Cho biết mã, tên các GV chỉ tham gia giảng dạy trong học kỳ 1 (không quan tâm
--đến niên khóa). Lưu ý cần loại bỏ GV chưa có tham gia giảng dạy bất ký khóa học nào.
SELECT A.MaGV, B.TenGV
FROM DBO.GIANGDAY AS A LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
WHERE A.MaGV NOT IN ( SELECT MaGV
                    FROM DBO.GIANGDAY
					WHERE HocKy = 2 )
--Phép Bù NOT IN, EXCEPT, LEFT JOIN, NOT EXIST
-- Giả sử quy định mỗi giáo viên phải dạy đủ tất cả các môn học. Cho biết tên giáo viên, tên
--môn học mà giáo viên chưa dạy.
SELECT B1.TenGV, C.TenMH AS 'Mon hoc GV chua day' 
FROM (
		SELECT MaGV, TenGV, MaMH FROM dbo.GIAOVIEN CROSS JOIN DBO.MONHOC
		EXCEPT 
		SELECT A.MaGV, B.TenGV, A.MaMH FROM DBO.GIANGDAY AS A LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
	 ) AS B1 LEFT JOIN DBO.MONHOC AS C ON B1.MaMH = C.MaMH

--Tương tự, giả sử quy định mỗi sinh viên phải học đủ tất cả các môn học. Cho biết tên
--sinh viên, tên môn mà sinh viên chưa học.
SELECT T1.Ten, T2.TenMH AS 'MH ma SV chua hoc'
FROM (
		SELECT Ten, MaMH FROM DBO.SINHVIEN CROSS JOIN DBO.MONHOC
		EXCEPT 
		SELECT B.Ten, C.MaMH FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
		                                                  LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
     ) AS T1 LEFT JOIN DBO.MONHOC AS T2 ON T1.MaMH = T2.MaMH

--Phép Chia
--Cho biết tên những giáo viên tham gia dạy đủ tất cả các môn học.
SELECT B.TenGV, COUNT (C.MaMH) AS SL_MH
FROM DBO.GIANGDAY AS A  LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
                        LEFT JOIN DBO.MONHOC AS C ON A.MaMH = C.MaMH
GROUP BY B.TenGV
HAVING COUNT (C.MaMH) = (SELECT COUNT (MaMH) FROM DBO.MONHOC)                      

--Cho biết tên những môn học mà tất cả các giáo viên đều tham gia giảng dạy.
SELECT B.MaMH, COUNT (A.MaGV) AS SLGV 
FROM DBO.GIANGDAY AS A LEFT JOIN DBO.MONHOC AS B ON A.MaMH = B.MaMH
GROUP BY B.MaMH
HAVING COUNT (A.MaGV) = (SELECT COUNT (MaGV) FROM DBO.GIAOVIEN)

--Cho biết khóa học mà tất cả các sinh viên đều tham gia.
SELECT MaKhoaHoc, COUNT (MSSV) AS SL_SV
FROM DBO.KETQUA 
GROUP BY MaKhoaHoc
HAVING COUNT (MSSV) = (SELECT COUNT (MSSV) FROM DBO.SINHVIEN)

--Cho biết tên những sinh viên tham gia đủ tất cả các khóa học.
SELECT B.Ten, 
	   COUNT (A.MaKhoaHoc) AS 'SL Khoa hoc'
FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.Ten
HAVING COUNT (A.MaKhoaHoc) = (SELECT COUNT (MaKhoaHoc) FROM DBO.GIANGDAY)

--Cho biết tên môn học mà tất cả các sinh viên đều đã học.
SELECT A.TenMH, COUNT (C.MSSV) AS SL_SV
FROM DBO.MONHOC AS A LEFT JOIN  DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
                     LEFT JOIN DBO.KETQUA AS C ON B.MaKhoaHoc = C.MaKhoaHoc
GROUP BY A.TenMH
HAVING COUNT (C.MSSV) = (SELECT COUNT (MSSV) FROM DBO.SINHVIEN)

--Cho biết tên sinh viên đã học đủ tất cả các môn học.
SELECT A.Ten, COUNT (C.MaMH) AS SL_MH
FROM DBO.SINHVIEN AS A LEFT JOIN  DBO.KETQUA AS B ON A.MSSV = B.MSSV
                     LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc
GROUP BY A.Ten
HAVING COUNT (C.MaMH) = (SELECT COUNT (MaMH) FROM DBO.MONHOC)

--Cho biết tên những sinh viên đã học tất cả những môn mà sinh viên ‘T0003M’ đã học.
SELECT DISTINCT A.MSSV, C.Ten
FROM DBO.KETQUA AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
                     LEFT JOIN DBO.SINHVIEN AS C ON A.MSSV = C.MSSV
WHERE  B.MaMH IN ( SELECT  B.MaMH
				   FROM DBO.KETQUA AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
			       WHERE A.MSSV = 'T0003M' )
	  AND A.MSSV NOT IN (SELECT MSSV FROM DBO.SINHVIEN WHERE MSSV ='T0003M') 
				   
--Cho biết tên những giáo viên đã dạy tất cả những môn học mà giáo viên ‘C01F’ đã dạy
SELECT A.TenGV, MaMH
FROM DBO.GIAOVIEN AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaGV = B.MaGV
WHERE B.MaMH IN ( SELECT B.MaMH
				  FROM DBO.GIAOVIEN AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaGV = B.MaGV
				  WHERE A.MaGV = 'C01F' )
	  AND A.TenGV NOT IN (SELECT TenGV FROM DBO.GIAOVIEN WHERE MaGV = 'C01F')

--Update
-- Thêm các field SLMon(Số lượng môn), DTB (Điểm trung bình), DTBTichLuy (Điểm
--trung bình tích lũy), SoTCTichLuy(SoTCTichLuy), XL(Xếp loại) vào table SinhVien.
ALTER TABLE DBO.SINHVIEN
    ADD SLMon INT,
        DTB DECIMAL(3,1),
        DTBTichLuy DECIMAL(3,1),
        SoTCTichLuy INT,
        XL NVARCHAR(50);

--Cập nhật thông tin cho các field vừa tạo theo yêu cầu: 
--NgayNhapHoc: sinh viên khoa CNTT nhập học ngày 15/11/2011; sinh viên khoa TOAN nhập học ngày 22/10/2011.
UPDATE DBO.SINHVIEN
SET NgayNhapHoc = '2011/11/15' WHERE MaKhoa = 'CNTT'

UPDATE DBO.SINHVIEN
SET NgayNhapHoc = '2011/10/22' WHERE MaKhoa = 'TOAN'

--SLMon: tổng số lượng môn học mà sinh viên đã kiểm tra (có điểm).
UPDATE DBO.SINHVIEN
SET SLMon = (SELECT TB1.SL_MH )
FROM ( SELECT A.Ten, COUNT (C.MaMH) AS SL_MH
		FROM DBO.SINHVIEN AS A LEFT JOIN  DBO.KETQUA AS B ON A.MSSV = B.MSSV
                LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc
        GROUP BY A.Ten 
	 ) AS TB1
WHERE DBO.SINHVIEN.Ten = TB1.Ten

--DTB: điểm trung bình của tất cả các điểm mà sinh viên đã có (kể cả những DiemKhoaHoc<5).
UPDATE DBO.SINHVIEN
SET DTB = (SELECT TB1.[Diem TB])
FROM (	SELECT A.Ten,  AVG (B.DiemKhoaHoc) AS 'Diem TB'
		FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
		GROUP BY A.Ten
	 ) AS TB1
WHERE DBO.SINHVIEN.Ten = TB1.Ten

--DTBTichLuy: điểm trung bình của tất cả các điểm mà sinh viên đã có (chỉ tính cho những DiemKhoaHoc>=5).
UPDATE DBO.SINHVIEN
SET DTBTichLuy = (SELECT TB1.[Diem TB])
FROM (	SELECT A.Ten,  AVG (B.DiemKhoaHoc) AS 'Diem TB'
		FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
		WHERE B.DiemKhoaHoc >=5
		GROUP BY A.Ten
	 ) AS TB1
WHERE DBO.SINHVIEN.Ten = TB1.Ten

--SoTCTichLuy: tổng số các tín chỉ của những DiemKhoaHoc >=5.
UPDATE DBO.SINHVIEN
SET SoTCTichLuy = (SELECT TB1.[TS_TC])
FROM (	SELECT A.Ten,  AVG (C.TongSoTC) AS 'TS_TC'
		FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
		                       LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc
		WHERE B.DiemKhoaHoc >=5
		GROUP BY A.Ten
	 ) AS TB1
WHERE DBO.SINHVIEN.Ten = TB1.Ten

--XepLoai: nếu
UPDATE DBO.SINHVIEN
SET XL = N'Yếu' WHERE DTBTichLuy < 5.0
UPDATE DBO.SINHVIEN
SET XL = N'Trung bình' WHERE DTBTichLuy BETWEEN 5.0 AND 6.5
UPDATE DBO.SINHVIEN
SET XL = N'Khá' WHERE DTBTichLuy BETWEEN 6.5 AND 8.0
UPDATE DBO.SINHVIEN
SET XL = N'Giỏi' WHERE DTBTichLuy BETWEEN 8.0 AND 9.0
UPDATE DBO.SINHVIEN
SET XL = N'Xuất sắc' WHERE DTBTichLuy BETWEEN 9.0 AND 10.0

-- Thực hiện thêm mới cột Học bổng cho table SinhVien dựa trên cột DTBTichLuy với quy
--định 3 mức học bổng như sau:
ALTER TABLE DBO.SINHVIEN
    ADD Hocbong MONEY

UPDATE DBO.SINHVIEN
SET Hocbong = 2000000 WHERE DTBTichLuy >=9
UPDATE DBO.SINHVIEN
SET Hocbong = 1000000 WHERE DTBTichLuy BETWEEN 8 AND 9
UPDATE DBO.SINHVIEN
SET Hocbong = 0 WHERE DTBTichLuy < 8 OR DTBTichLuy IS NULL;

--Delete
-- Xóa tất cả kết quả học tập của sinh viên ‘C0002M’.
DELETE FROM  DBO.KETQUA 
WHERE MSSV = 'C0002M'

-- Xóa tên những sinh viên có điểm trung bình (DTBTichLuy) dưới 5 hoặc chưa có bất kỳ
--điểm nào trong table KetQua.
DELETE FROM  DBO.SINHVIEN
WHERE Ten IN (SELECT Ten FROM DBO.SINHVIEN
              WHERE DTBTichLuy <5 )
   OR Ten IN ( SELECT A.Ten FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
               WHERE B.DiemKhoaHoc IS NULL ) 

--Xóa những khoa không có sinh viên theo học.
DELETE FROM DBO.KHOA 
WHERE TenKhoa = ( SELECT TenKhoa
					FROM DBO.KHOA
					WHERE MaKhoa NOT IN (SELECT MaKhoa FROM DBO.SINHVIEN ) 
				)
