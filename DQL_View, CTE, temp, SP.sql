USE QLSV_051124
GO 

-- Tạo View chứa các thông tin sau: tên khoa, số lượng sinh viên nam, số lượng sinh viên nữ.
CREATE VIEW V_SLSV 
	AS  ( 
		 SELECT A.TenKhoa, SUM ( CASE WHEN B.PhaiNu = 1 THEN 1 ELSE 0 END ) AS SLSV_Nu,
						   SUM ( CASE WHEN B.PhaiNu = 0 THEN 1 ELSE 0 END )  AS  SLSV_Nam           
		 FROM DBO.KHOA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MaKhoa = B.MaKhoa
		 GROUP BY A.TenKhoa
	    );
		
-- Tạo View chứa danh sách sinh viên (gồm MSSV, Ten, MaMH, DiemKhoaHoc) không thuộc khoa “CNTT” có điểm 
--thi môn “CSDL” lớn hơn điểm thi môn “CSDL” của ít nhất một sinh viên thuộc khoa “CNTT”.
-- Yêucầuthựchiện:
--(i).- Tạo View v_Cau02A chứa DiemKhoaHoc môn ‘CSDL’ của những sinh viên thuộc khoa CNTT.
CREATE VIEW v_Cau02A 
AS 
	SELECT A.MSSV, B.Ten, C.MaMH, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
						 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	WHERE C.MaMH = 'CSDL' AND B.MaKhoa = 'CNTT'
	GROUP BY A.MSSV, B.Ten, C.MaMH, A.DiemKhoaHoc

--(ii).- Tạo View v_Cau02B gồm các field MSSV, Ten, MaMH, DiemKhoaHoc
--chứa kết quả môn ‘CSDL’ của những sinh viên KHÔNG thuộc khoa CNTT.

CREATE VIEW v_Cau2B 
AS 
	SELECT A.MSSV, B.Ten, C.MaMH, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
						 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	WHERE C.MaMH = 'CSDL' AND B.MaKhoa NOT LIKE 'CNTT'
	GROUP BY A.MSSV, B.Ten, C.MaMH, A.DiemKhoaHoc;

--(iii).-Viết lệnh truy vấn dữ liệu từ 2 view trên để có kết quả mong muốn.
SELECT * FROM v_Cau2B AS B
WHERE EXISTS (
			SELECT * FROM v_Cau02A AS A
			WHERE B.DiemKhoaHoc > A.DiemKhoaHoc
			)

--Tạo View chứa danh sách sinh viên không thuộc khoa “CNTT” có điểm trung bình (DTB) lớn hơn ít nhất một sinh viên thuộc khoa “CNTT”.
-- Yêucầuthựchiện:
--(i).- Tạo View v_Cau03A chứa DTB của những sinh viên thuộc khoa CNTT.
CREATE VIEW v_Cau03A 
AS 
	SELECT A.MSSV, B.Ten, B.MaKhoa, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	WHERE B.MaKhoa = 'CNTT'
	GROUP BY A.MSSV, B.Ten, B.MaKhoa, A.DiemKhoaHoc

--(ii).- Tạo View v_Cau03B gồm các field MSSV, Ten, MaKhoa, DTB) của những sinh viên KHÔNG thuộc khoa CNTT.
CREATE VIEW v_Cau03B 
AS 
	SELECT A.MSSV, B.Ten, B.MaKhoa, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	WHERE B.MaKhoa NOT LIKE 'CNTT'
	GROUP BY A.MSSV, B.Ten, B.MaKhoa, A.DiemKhoaHoc

--(iii).-Viết lệnh truy vấn dữ liệu từ 2 view trên để có kết quả mong muốn.
SELECT * FROM v_Cau03B AS B
WHERE EXISTS (
			SELECT * FROM v_Cau03A AS A
			WHERE B.DiemKhoaHoc > A.DiemKhoaHoc
			)

--Tạo View chứa danh sách sinh viên đã thi tất cả các môn học có trong danh mục môn học 
--(không tính đến học kỳ).
CREATE VIEW v_HSMH
AS
SELECT A.Ten, COUNT (C.MaMH) AS SL_MH
FROM DBO.SINHVIEN AS A LEFT JOIN  DBO.KETQUA AS B ON A.MSSV = B.MSSV
                     LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc
GROUP BY A.Ten
HAVING COUNT (C.MaMH) = (SELECT COUNT (MaMH) FROM DBO.MONHOC)

-- Tạo View chứa danh sách giáo viên đã dạy tất cả các môn học (không tính đến học kỳ).
CREATE VIEW v_GVMH
AS
SELECT B.TenGV, COUNT (C.MaMH) AS SL_MH
FROM DBO.GIANGDAY AS A  LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
                        LEFT JOIN DBO.MONHOC AS C ON A.MaMH = C.MaMH
GROUP BY B.TenGV
HAVING COUNT (C.MaMH) = (SELECT COUNT (MaMH) FROM DBO.MONHOC) 

--Tạo View chứa thông tin về số lượng các môn học đã được giảng dạy trong từng học kỳ, từng năm học.
CREATE VIEW v_SLMH
AS
	SELECT  HocKy, NienKhoa, COUNT(MaMH) AS SLMH
	FROM  DBO.GIANGDAY 
	GROUP BY HocKy, NienKhoa

-- Thống kê tỷ lệ đậu, rớt của từng môn học.
WITH CTE1 
AS (
	SELECT MaKhoaHoc,
		   SUM (CASE WHEN DiemKhoaHoc >= 5 THEN 1 ELSE 0 END) AS SLDau,
		   SUM (CASE WHEN DiemKhoaHoc < 5 THEN 1 ELSE 0 END) AS SLRot
	FROM DBO.KETQUA
	GROUP BY MaKhoaHoc
   ) 
SELECT A.MaMH, B.TenMH, SLDau, SLRot
FROM DBO.GIANGDAY AS A LEFT JOIN DBO.MONHOC AS B ON A.MaMH = B.MaMH
                       LEFT JOIN CTE1 ON A.MaKhoaHoc = CTE1.MaKhoaHoc
GROUP BY A.MaKhoaHoc, A.MaMH, B.TenMH, SLDau, SLRot

--Tạo View thống kê tỷ lệ sinh viên nam, sinh viên nữ theo từng xếp loại của từng khoa.
DROP TABLE IF EXISTS #TempXH
SELECT SV.MSSV, SV.MaKhoa, PhaiNu,
       CASE WHEN AVG(DiemKhoaHoc) >= 9 THEN N'Xuất sắc'
            WHEN AVG(DiemKhoaHoc) >= 8 AND  AVG(DiemKhoaHoc) <9 THEN N'Giỏi' 
            WHEN AVG(DiemKhoaHoc) >= 7 AND  AVG(DiemKhoaHoc) <8 THEN N'Khá' 
            WHEN AVG(DiemKhoaHoc) >= 5 AND  AVG(DiemKhoaHoc) <7 THEN N'Trung bình' 
       ELSE N'Yếu'
       END AS [XepHang]
INTO #TempXH
FROM SinhVien SV LEFT JOIN KetQua KQ ON SV.MSSV = KQ.MSSV
GROUP BY SV.MSSV, SV.MaKhoa, PhaiNu;

WITH CTE_Nu AS(
				 SELECT XepHang,COUNT(PhaiNu) AS [SL Nữ] 
				 FROM #TempXH
				 WHERE PhaiNu = 1
				 GROUP BY XepHang
			  ),
	 CTE_Nam AS (
				 SELECT XepHang,COUNT(PhaiNu) AS [SL Nam] 
				 FROM #TempXH
				 WHERE PhaiNu = 0
				 GROUP BY XepHang
	            )
	SELECT A.MaKhoa, A.XepHang AS [Xếp loại], 
			ISNULL(B.[SL Nữ],0) AS [SL Nữ],
			COALESCE(C.[SL Nam] ,0) AS [SL Nam]
	FROM #TempXH A LEFT JOIN CTE_Nu B ON A.XepHang = B.XepHang
			LEFT JOIN CTE_Nam C ON A.XepHang = C.XepHang
	GROUP BY A.MaKhoa, A.XepHang, [SL Nữ], [SL Nam]
 

--Tạo View cho biết sĩ số của các khoa trong trường . Kết xuất có dạng:
--Lưu ý: chỉ tính sĩ số đối với các sinh viên hiện còn đang học
--(NgayRaTruong=NULL).
SELECT A.MaKhoa, A.TenKhoa,
       COUNT (B.MSSV) AS Siso
FROM  DBO.SINHVIEN AS B LEFT JOIN DBO.KHOA AS A ON A.MaKhoa = B.MaKhoa
WHERE B.NgayRaTruong IS NULL
GROUP BY A.MaKhoa, A.TenKhoa

--Thực hiện lại câu 29 (Lesson4) nhưng sử dụng CTE: Cho biết tên các môn học có nhiều
--sinh viên tham gia nhất (tên môn, số lượng sinh viên)
WITH CTE_C10
AS (
	SELECT C.TenMH,  COUNT (A.MSSV) AS 'SL_SV'
	FROM DBO.KETQUA AS A
			LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
			LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH
	GROUP BY C.TenMH
   )
SELECT TOP 1 *
FROM CTE_C10
ORDER BY SL_SV DESC;

--Thực hiện lại câu 30 (Lesson4) nhưng sử dụng CTE: Học kỳ nào có nhiều môn học
--được giảng dạy nhất (không quan tâm đến năm học).
WITH CTE_C11
AS (
	SELECT DBO.GIANGDAY.HocKy, COUNT (DBO.GIANGDAY.MaMH) AS 'So luong mon hoc MAX'
	FROM DBO.GIANGDAY
	GROUP BY DBO.GIANGDAY.HocKy
   )
SELECT TOP 1 * 
FROM CTE_C11
ORDER BY [So luong mon hoc MAX] DESC;

--Thực hiện lại câu 31 (Lesson4) nhưng sử dụng CTE: Cho biết tên các sinh viên có
--nhiều điểm (DiemKhoaHoc) >=7 nhất. (bao gồm tên sinh viên, số lượng điểm >= 7).
WITH CTE_C12
AS (
	SELECT  A.MSSV, B.Ten,  COUNT (A.DiemKhoaHoc) AS 'SL diem >= 7'
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	WHERE A.DiemKhoaHoc >= 7
	GROUP BY A.MSSV , B.Ten
   )
SELECT TOP 1 *
FROM CTE_C12
ORDER BY [SL diem >= 7] DESC;

--Thực hiện lại câu 32 (Lesson4) nhưng sử dụng CTE: Cho biết tên các sinh viên có số lượng tín chỉ đạt 
--(DiemKhoaHoc >=5) nhiều nhất. Thông tin hiển thị bao gồm tên sinh viên, số lượng tín chỉ).
WITH CTE_C13
AS (
	SELECT B.Ten, SUM(C.TongSoTC) AS TongSoTC_DatDK
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
						 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	WHERE A.DiemKhoaHoc >=5
	GROUP BY B.Ten
   )
SELECT TOP 1 *
FROM CTE_C13
ORDER BY TongSoTC_DatDK DESC;

--Thực hiện lại câu 11 (Lesson5) nhưng sử dụng CTE: Cho biết các SV chưa học môn ‘LTC trên Windows’.
WITH CTE_C14
AS (
	SELECT Ten
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
						LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
						LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH
	WHERE TenMH IN ('Lap Trinh C Tren Window')
   )
SELECT TEN
FROM DBO.SINHVIEN
WHERE Ten NOT IN (  SELECT Ten FROM CTE_C14 )

--Thực hiện lại câu 12 (Lesson5) nhưng sử dụng CTE: Tên các giáo viên không tham gia
--giảng dạy trong năm 2011 (bao gồm cả 2 trường hợp niên khóa = 2010-2011 và niên khóa = 2011- 2012).
WITH CTE_C15
AS (
	SELECT TenGV
	FROM DBO.GIAOVIEN AS A LEFT JOIN DBO.GIANGDAY AS B ON  A.MaGV = B.MaGV
	WHERE NienKhoa  LIKE '%2011%'
   )
SELECT TenGV
FROM DBO.GIAOVIEN
WHERE TenGV NOT IN ( SELECT TenGV FROM CTE_C15 )

--Thực hiện lại câu 13 (Lesson5) nhưng sử dụng CTE: Cho biết tên các môn học không được
--tổ chức trong năm 2011 (bao gồm cả 2 trường hợp niên khóa = 2010-2011 và niên khóa = 2011-2012).
WITH CTE_C16
AS (
	SELECT TenMH
	FROM DBO.MONHOC AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
	WHERE  NienKhoa LIKE '%2011%' 
   )
SELECT TenMH
FROM DBO.MONHOC
WHERE TenMH NOT IN ( SELECT TenMH FROM CTE_C16 );

--Cho biết tên các khoa chưa được nhập danh sách sinh viên.
	SELECT TenKhoa
	FROM DBO.KHOA
	WHERE MaKhoa NOT IN (SELECT MaKhoa FROM DBO.SINHVIEN)

--Cho biết (Masv, Hoten, Phai ) của các sinh viên chưa được nhập (hoặc chưa có) điểm.
	SELECT MSSV, Ten, PhaiNu
	FROM DBO.SINHVIEN
	WHERE MSSV NOT IN ( SELECT MSSV FROM DBO.KETQUA) 

--Thống kê số sinh viên nam, số sinh viên nữ của các khoa. Kết xuất có dạng:
-- MaKhoa - TenKhoa - SoSVNam - SoSVNu
WITH CTE_C19
AS ( 
     SELECT MaKhoa, PhaiNu
	 FROM DBO.SINHVIEN
	 WHERE NgayRaTruong IS NULL
	)
SELECT A.MaKhoa, A.TenKhoa, 
       SUM ( CASE WHEN B.PhaiNu = 1 THEN 1 ELSE 0 END ) AS SoSVNu,
	   SUM ( CASE WHEN B.PhaiNu = 0 THEN 1 ELSE 0 END )  AS  SoSVNam 
FROM CTE_C19 AS B LEFT JOIN DBO.KHOA AS A ON A.MaKhoa = B.MaKhoa
GROUP BY A.MaKhoa, A.TenKhoa

--Cho biết danh sách sinh viên trong trường có học tất cả các môn trong danh sách môn
--học. Kết xuất có dạng: MaKhoa - MaSV - MaMH - TenMH
WITH CTE_C20 
AS (
	SELECT B.MaKhoa, B.MSSV, C.MaMH
		   --COUNT (C.MaMH) AS 'SL Khoa hoc'
	FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
						 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	GROUP BY B.MaKhoa, B.MSSV, C.MaMH
	HAVING COUNT (C.MaMH) = (SELECT COUNT (MaMH) FROM DBO.MONHOC)
   )
SELECT A.MaKhoa, A.MSSV, B.MaMH, B.TenMH
FROM CTE_C20 AS A LEFT JOIN DBO.MONHOC AS B ON A.MaMH = B.MaMH

--Thống kê số sinh viên nam, số sinh viên nữ của các khoa. Kết xuất có dạng: 
--MaKhoa - TenKhoa - SoSVNam - SoSVNu
WITH CTE_C19
AS ( 
     SELECT MaKhoa, PhaiNu
	 FROM DBO.SINHVIEN
	 WHERE NgayRaTruong IS NULL
	)
SELECT A.MaKhoa, A.TenKhoa, 
       SUM ( CASE WHEN B.PhaiNu = 1 THEN 1 ELSE 0 END ) AS SoSVNu,
	   SUM ( CASE WHEN B.PhaiNu = 0 THEN 1 ELSE 0 END )  AS  SoSVNam 
FROM CTE_C19 AS B LEFT JOIN DBO.KHOA AS A ON A.MaKhoa = B.MaKhoa
GROUP BY A.MaKhoa, A.TenKhoa

--Thống kê tỷ lệ sinh viên nam, sinh viên nữ theo từng xếp loại của từng khoa.
WITH CTE_Nu AS(
				 SELECT XepHang,COUNT(PhaiNu) AS [SL Nữ] 
				 FROM #TempXH
				 WHERE PhaiNu = 1
				 GROUP BY XepHang
			  ),
	 CTE_Nam AS (
				 SELECT XepHang,COUNT(PhaiNu) AS [SL Nam] 
				 FROM #TempXH
				 WHERE PhaiNu = 0
				 GROUP BY XepHang
	            )
SELECT A.MaKhoa, A.XepHang AS [Xếp loại], 
		ISNULL(B.[SL Nữ],0) AS [SL Nữ],
		COALESCE(C.[SL Nam] ,0) AS [SL Nam]
FROM #TempXH A LEFT JOIN CTE_Nu B ON A.XepHang = B.XepHang
		LEFT JOIN CTE_Nam C ON A.XepHang = C.XepHang
GROUP BY A.MaKhoa, A.XepHang, [SL Nữ], [SL Nam]

--Cho biết sĩ số của các khoa trong trường . Kết xuất có dạng: MaKhoa - TenKhoa - Siso
--Lưu ý: chỉ tính sĩ số đối với các sinh viên hiện còn đang học (NgayRaTruong=NULL).
WITH CTE_C23
AS (
	SELECT MaKhoa,
		   COUNT (MSSV) AS Siso
	FROM  DBO.SINHVIEN 
	WHERE NgayRaTruong IS NULL
	GROUP BY MaKhoa
   )
SELECT A.MaKhoa, B.TenKhoa, Siso 
FROM CTE_C23 AS A LEFT JOIN DBO.KHOA AS B ON A.MaKhoa = B.MaKhoa

--Cho biết danh sách sinh viên trong trường có học tất cả các môn trong danh sách môn
--học. Kết xuất có dạng: MaKhoa - MaSV - MaMH - TenMH
WITH CTE_C24
AS (
	SELECT A.MaKhoa, C.MaKhoaHoc, A.MSSV, COUNT (C.MaMH) AS SL_MH
	FROM DBO.SINHVIEN AS A LEFT JOIN  DBO.KETQUA AS B ON A.MSSV = B.MSSV
							LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc
	GROUP BY A.MaKhoa, C.MaKhoaHoc, A.MSSV
	HAVING COUNT (C.MaMH) = (SELECT COUNT (MaMH) FROM DBO.MONHOC)
   )
SELECT A.MaKhoa, A.MSSV, C.MaMH, C.TenMH
FROM CTE_C24 AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
                  LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH

--Cho biết tên các khoa không có sinh viên.
	SELECT TenKhoa
	FROM DBO.KHOA
	WHERE MaKhoa NOT IN (SELECT MaKhoa FROM DBO.SINHVIEN)
--Nhận tham số là mã số môn học, in ra tên môn học, số lượng sinh viên đã có điểm môn học đó, 
--và các điểm nhỏ nhất, điểm lớn nhất, điểm trung bình của môn học.
DROP PROCEDURE IF EXISTS SP_C26
GO
CREATE PROCEDURE SP_C26
       @MaMH VARCHAR (4) 
AS
BEGIN
     SELECT A.TenMH, COUNT ([MSSV]) AS SL_SV,
	                 MIN ([DiemKhoaHoc]) AS 'Diem thap nhat',
					 MAX ([DiemKhoaHoc]) AS 'Diem cao nhat',
					 AVG ([DiemKhoaHoc]) AS 'DiemTB'
	 FROM DBO.MONHOC AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
	                      LEFT JOIN DBO.KETQUA AS C ON B.MaKhoaHoc = C.MaKhoaHoc
	 WHERE A.MaMH = @MaMH
	 GROUP BY A.TenMH
END

EXEC SP_C26 @MaMH = 'CTDL'

--Liệt kê các sinh viên thuộc khoa @MaKhoa có DiemKhoaHoc cao nhất của môn @MaMonHoc. 
--Với @MaKhoa và @MaMonHoc là 2 tham số được truyền vào cho SP.
DROP PROCEDURE IF EXISTS SP_C27
GO
CREATE PROCEDURE SP_C27
       @MaKhoa VARCHAR (4),
	   @MaMH VARCHAR (4) 
AS
BEGIN
	WITH CTE27 AS (
				SELECT A.MaKhoa, C.MaMH, A.Ten, B.DiemKhoaHoc AS 'Diem cao nhat',
					   DENSE_RANK () OVER (PARTITION BY A.MaKhoa ORDER BY B.DiemKhoaHoc DESC) AS RNK
				FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
									   LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc               
				WHERE A.MaKhoa = @MaKhoa AND C.MaMH = @MaMH
				GROUP BY A.MaKhoa, C.MaMH, A.Ten, B.DiemKhoaHoc
		        )
	SELECT MaKhoa, MaMH, Ten, [Diem cao nhat]
	FROM CTE27 
	WHERE RNK = 1 
END
EXEC SP_C27 @MaKhoa = 'CNTT', @MaMH = 'CTDL'	

--Nhận 2 tham số là @MaKhoa và @MaMonHoc, liệt kê danh sách sinh viên thuộc khoa @MaKhoa 
--bị thi lại (DiemKhoaHoc<5) của môn @MaMonHoc. Kết xuất có dạng: MaSV - HoTen - NgaySinh - DiemThi
DROP PROCEDURE IF EXISTS SP_C28
GO
CREATE PROCEDURE SP_C28
       @MaKhoa VARCHAR (4),
	   @MaMH VARCHAR (4) 
AS
BEGIN
     SELECT A.MSSV, A.Ten, A.NgaySinh, B.DiemKhoaHoc
	 FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KETQUA AS B ON A.MSSV = B.MSSV
	                        LEFT JOIN DBO.GIANGDAY AS C ON B.MaKhoaHoc = C.MaKhoaHoc
	 WHERE A.MaKhoa = @MaKhoa AND C.MaMH = @MaMH AND B.DiemKhoaHoc <5
END
EXEC SP_C28 @MaKhoa = 'CNTT', @MaMH = 'CTDL'

--Thống kê tỷ lệ đậu, rớt của từng môn học. MaMH - TenMH - SLDau - SLRot
DROP PROCEDURE IF EXISTS SP_C29
GO
CREATE PROCEDURE SP_C29 
	   @MaMH VARCHAR (4) 
AS
BEGIN
	WITH CTE1 
	AS (
		SELECT MaKhoaHoc,
			   SUM (CASE WHEN DiemKhoaHoc >= 5 THEN 1 ELSE 0 END) AS SLDau,
			   SUM (CASE WHEN DiemKhoaHoc < 5 THEN 1 ELSE 0 END) AS SLRot
		FROM DBO.KETQUA
		GROUP BY MaKhoaHoc
	   ) 
	SELECT A.MaMH, B.TenMH, SLDau, SLRot
	FROM DBO.GIANGDAY AS A LEFT JOIN DBO.MONHOC AS B ON A.MaMH = B.MaMH
						   LEFT JOIN CTE1 ON A.MaKhoaHoc = CTE1.MaKhoaHoc
    WHERE A.MaMH = @MaMH
	GROUP BY A.MaKhoaHoc, A.MaMH, B.TenMH, SLDau, SLRot
END

EXEC SP_C29 @MaMH = 'CWIN'

--Tạo Stored Procedure với OUTPUT Parameter cho các câu sau đây:
--Tạo SP nhận tham số là mã số sinh viên, SP trả về họ và tên của sinh viên đó.
DROP PROCEDURE IF EXISTS SP_C30
GO
CREATE PROCEDURE SP_C30 
	   @MSSV VARCHAR (6),
	   @Ten VARCHAR (50) OUTPUT  
AS
BEGIN
	SELECT @Ten = Ten
	FROM DBO.SINHVIEN
    WHERE MSSV = @MSSV
END
GO
DECLARE @SV VARCHAR(50)
EXEC SP_C30 @MSSV = 'T0005M', @Ten = @SV OUTPUT 
SELECT @SV AS  'Ho va ten SV'

--Tạo SP nhận tham số là mã số sinh viên, SP trả về số lượng khóa học mà sinh viên không đạt (DiemKhoaHoc<5).
DROP PROCEDURE IF EXISTS SP_C31
GO
CREATE PROCEDURE SP_C31 
	   @MSSV VARCHAR (6),
	   @SL_KH INT OUTPUT
AS
BEGIN
	SELECT @SL_KH = COUNT (MSSV) 
	FROM DBO.KETQUA 
    WHERE MSSV = @MSSV AND DiemKhoaHoc <5
END
GO
DECLARE @KQ VARCHAR(6)
EXEC SP_C31 @MSSV = 'T0003M', @SL_KH = @KQ OUTPUT 
SELECT @KQ AS  'SL_KH khong dat'

--Tạo SP nhận 2 tham số là tên giáo viên (X) và tên sinh viên (Y), SP trả về kết quả cho biết
--sinh viên Y có từng học những khóa học do giáo viên Y giảng dạy hay không?
DROP PROCEDURE IF EXISTS SP_C32
GO
CREATE PROCEDURE SP_C32
       @TenGV VARCHAR (50),
	   @TenSV VARCHAR (50),
	   @ANS VARCHAR (50) OUTPUT
AS
BEGIN
	SELECT @ANS = CASE WHEN COUNT (*) >0 THEN 'CÓ' ELSE 'KHÔNG' END
	FROM DBO.GIAOVIEN AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MaKhoa = B.MaKhoa
	WHERE A.TenGV = @TenGV AND B.Ten = @TenSV
END
GO
DECLARE @KQ NVARCHAR (50)
EXEC SP_C32 @TenGV = 'PHAM THI THAO', 
            @TenSV = 'NGUYEN THANH TUNG',
			@ANS   = @KQ OUTPUT
SELECT @KQ AS 'SV có học khóa mà GV này dạy không?'

--Tạo SP nhận tham số là mã khoa, SP trả về tên khoa, số lượng SV đạt được của mỗi loại Xuất sắc/Giỏi/Khá/Trung bình/ Yếu 
--(dựa trên field DTBTichLuy trong table SinhVien). Biết rằng việc phân loại dựa trên quy định như sau:
DROP PROCEDURE IF EXISTS SP_C33
GO
CREATE PROCEDURE SP_C33
    @MaKhoa NVARCHAR(4),          
    @TenKhoa NVARCHAR(50)OUTPUT, 
    @XuatSac INT OUTPUT,           
    @Gioi INT OUTPUT,              
    @Kha INT OUTPUT,               
    @TrungBinh INT OUTPUT,         
    @Yeu INT OUTPUT                
AS
BEGIN    
    SELECT @TenKhoa = TenKhoa
    FROM DBO.KHOA
    WHERE MaKhoa = @MaKhoa

    SELECT 
        @XuatSac = COUNT(CASE WHEN DTBTichLuy BETWEEN 9 AND 10 THEN 1 END),
        @Gioi = COUNT(CASE WHEN DTBTichLuy BETWEEN 8 AND 9 THEN 1 END),
        @Kha = COUNT(CASE WHEN DTBTichLuy BETWEEN 6.5 AND 8 THEN 1 END),
        @TrungBinh = COUNT(CASE WHEN DTBTichLuy BETWEEN 5 AND 6.5 THEN 1 END),
        @Yeu = COUNT(CASE WHEN DTBTichLuy < 5 OR DTBTichLuy IS NULL THEN 1 END)
    FROM DBO.SINHVIEN
    WHERE MaKhoa = @MaKhoa;
END
GO  
DECLARE @TK NVARCHAR(30),   @XS INT,  @G INT, 
		@K INT,  @TB INT,  @Y INT
EXEC SP_C33 @MaKhoa = 'CNTT' , @TenKhoa = @TK OUTPUT,
							   @XuatSac = @XS OUTPUT, 
							   @Gioi = @G OUTPUT, 
							   @Kha = @K OUTPUT, 
							   @TrungBinh = @TB OUTPUT ,
							   @Yeu = @Y OUTPUT 
SELECT @TK AS TenKhoa,@XS AS 'Xuất sắc', @G AS 'Giỏi', @K AS 'Khá', @TB AS 'Trung bình', @Y AS 'Yếu'
 SELECT * FROM DBO.SINHVIEN

-- Sử dụng kết quả thực hiện của stored procedure qua temporary table cho các câu sau đây:
--Nhận tham số @SoLuong, in ra các khoa có số lượng sinh viên <=@SoLuong. Kết xuất có dạng như sau. 
--Lưuý: chỉ tính sĩ số lớp đối với các sinh viên hiện còn đang học (NgayRaTruong=NULL). MaKhoa - TenKhoa - Siso
DROP PROCEDURE IF EXISTS SP_C34
GO
CREATE PROCEDURE SP_C34
	@SoLuong INT
AS 
BEGIN 
    SELECT DISTINCT A.MaKhoa, A.TenKhoa,  COUNT (B.MSSV) AS Siso
	FROM  DBO.SINHVIEN AS B LEFT JOIN DBO.KHOA AS A ON A.MaKhoa = B.MaKhoa
	WHERE B.NgayRaTruong IS NULL
	GROUP BY A.MaKhoa, A.TenKhoa
	HAVING COUNT(B.MSSV) <= @SoLuong
END
CREATE TABLE #TEMP34 (
					   MaKhoa VARCHAR (4),
					   TenKhoa NVARCHAR (50),
					   Siso INT 
					 )
INSERT INTO #TEMP34
EXEC SP_C34 @SoLuong = 5
SELECT DISTINCT * FROM #TEMP34

--Cho biết (Masv, Hoten, Phai ) của các sinh viên chưa được nhập (hoặc chưa có) điểm.
SELECT MSSV, Ten, PhaiNu, DiaChi
FROM DBO.SINHVIEN 
WHERE MSSV NOT IN (SELECT MSSV FROM DBO.KETQUA WHERE DiemKhoaHoc > 0)

--Liệt kê danh sách sinh viên của khoa có mã khoa là X. Kết xuất có dạng: MASV - HO TEN - PHAI - DIACHI
DROP PROCEDURE IF EXISTS SP_C36
GO
CREATE PROCEDURE SP_C36
	   @X NVARCHAR(4)
AS 
BEGIN 
	SELECT MSSV, Ten, PhaiNu, DiaChi
	FROM DBO.SINHVIEN 
	WHERE MaKhoa = @X
END
EXEC SP_C36 @X = 'CNTT'

--Tạo SP nhận tham số là mã số môn học, in ra tên môn học, số lượng sinh viên đã kiểm tra
--môn học đó, điểm nhỏ nhất, điểm lớn nhất, điểm trung bình.
DROP PROCEDURE IF EXISTS SP_C37
GO
CREATE PROCEDURE SP_C37
	   @MaMH VARCHAR(4)
AS 
BEGIN
	SELECT TenMH, COUNT (MSSV) AS SL_SV, 
	              MIN (DiemKhoaHoc) AS 'Diem thap nhat',
				  MAX (DiemKhoaHoc) AS 'Diem cao nhat',
				  AVG (DiemKhoaHoc) AS 'DiemTB'
	FROM DBO.MONHOC AS A LEFT JOIN  DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
	                     LEFT JOIN DBO.KETQUA AS C ON B.MaKhoaHoc = C.MaKhoaHoc
	WHERE A.MaMH =  @MaMH
	GROUP BY TenMH 
END
EXEC SP_C37  @MaMH = 'CSDL'

--Sử dụng kết quả thực hiện của stored procedure qua biến có kiểu là table cho các câu sau đây:
--Tạo SP nhận tham số là mã khoa, in ra tên khoa, số lượng sinh viên có điểm (DiemKhoaHoc) của sinh viên trong khoa 
--và dựa trên DiemKhoaHoc để tìm điểm nhỏ nhất, điểm lớn nhất, điểm trung bình của toàn khoa.
DROP PROCEDURE IF EXISTS SP_C38
GO
CREATE PROCEDURE SP_C38
	   @MaKhoa VARCHAR(4)
AS 
BEGIN
	SELECT TenKhoa, COUNT(DISTINCT (CASE WHEN  DiemKhoaHoc IS NOT NULL OR DiemKhoaHoc IS NULL THEN B.MSSV  END)) AS SL_SV,
	                MIN (DiemKhoaHoc) AS 'Diem thap nhat',
				    MAX (DiemKhoaHoc) AS 'Diem cao nhat',
				    AVG (DiemKhoaHoc) AS 'DiemTB'
	FROM DBO.KHOA AS A LEFT JOIN  DBO.SINHVIEN AS B ON A.MaKhoa = B.MaKhoa
	                   LEFT JOIN DBO.KETQUA AS C ON B.MSSV = C.MSSV
	--WHERE A.[MaKhoa]=@MaKhoa
	GROUP BY TenKhoa
END
EXEC SP_C38  @MaKhoa = 'CNTT'

--Tạo SP nhận tham số là mã số của giáo viên, in ra tên giáo viên, số lượng sinh viên đã theo học (đã có DiemKhoaHoc trong tbale KetQua) 
--trong các khóa học mà giáo viên đó phụ trách.
DROP PROCEDURE IF EXISTS SP_C39
GO
CREATE PROCEDURE SP_C39
       @MaGV VARCHAR (4)
AS
BEGIN
	SELECT A.TenGV, COUNT (DISTINCT C.MSSV) AS SL_SV
	FROM DBO.GIAOVIEN AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaGV = B.MaGV
	                       LEFT JOIN DBO.KETQUA AS C ON B.MaKhoaHoc = C.MaKhoaHoc
	WHERE A.MaGV = @MaGV AND  C.DiemKhoaHoc IS NOT NULL
	GROUP BY  A.TenGV
END
GO
EXEC SP_C39 @MaGV = 'C03M'

--Sử dụng các table của hệ thống trong System catalog views
--Tạo 1 SP trả về danh sách các tên field của 1 table @tenTable trong cơ sở dữ liệu QLSV.
DROP PROCEDURE IF EXISTS SP_C40
GO
CREATE PROCEDURE SP_C40
	@tenTable VARCHAR(10)
AS 
BEGIN 
	WITH CTE 
	AS (  
		SELECT object_id
		FROM sys.tables 
		WHERE sys.tables.name = @tenTable
	   )
	SELECT sys.columns.name AS Field_Name
	FROM sys.columns 
	where sys.columns.object_id = (SELECT object_id FROM CTE)
END

EXEC SP_C40 @tenTable = 'KETQUA'

--Tạo 1 SP trả về thông tin của field có trong table gồm tên, số thứ tực field khi tạo lập, kiểu dữ liệu. Biết SP nhận 2 tham số 
--là @tenTable và số thứ tự của field @stt.
DROP PROCEDURE IF EXISTS SP_C42
GO
CREATE PROCEDURE SP_C42
	@tenTable VARCHAR(10),
	@STT TINYINT
AS 
BEGIN  -- cách khác câu 40, inner join
	SELECT B.name AS TenCot, B.column_id AS STT, C.name as KieuDL
	FROM sys.tables AS A INNER JOIN sys.columns AS B ON A.object_id = B.object_id
	                     INNER JOIN sys.types AS C ON B.system_type_id = C.system_type_id
	WHERE A.name = @tenTable AND B.column_id = @STT
END

EXEC SP_C42 @tenTable = SINHVIEN , @STT = 3

--Update/delete stored procedure
--Thực hiện cập nhật lại dữ liệu cho cột DiemKhoaHoc trong table KetQua với công thức tính DiemKhoaHoc được thay đổi là:
--     DiemKhoaHoc = (40% X DiemKTGiuaKy) + (60% X MAX(DiemThiLan1, DiemThiLan2)
DROP PROCEDURE IF EXISTS SP_C44
GO
CREATE PROCEDURE SP_C44
AS 
BEGIN
    UPDATE DBO.KETQUA
	SET DiemKhoaHoc = (0.4 * DiemKTGiuaKy + 0.6 * GREATEST(DiemThiLan1, DiemThiLan2) )
END

EXEC SP_C44
SELECT * FROM DBO.KETQUA

-- Cập nhật dữ liệu cho field ConDangHoc, dựa vào tham số gửi vào là @MaSV, @ConDangHoc.
ALTER TABLE DBO.SINHVIEN
	ALTER COLUMN ConDangHoc VARCHAR (50)

DROP PROCEDURE IF EXISTS SP_C46
GO
CREATE PROCEDURE SP_C46
	@MaSV VARCHAR(6),
	@ConDangHoc VARCHAR (50)
AS 
BEGIN
	UPDATE DBO.SINHVIEN
	SET ConDangHoc = @ConDangHoc WHERE MSSV = @MaSV
END
EXEC SP_C46 @MaSV = 'C0001F', @ConDangHoc = 'Da tot nghiep'
SELECT * FROM DBO.SINHVIEN

-- Tạo SP nhận tham số là mã số sinh viên, thực hiện việc hủy kết quả học tập của sinh viên đó trong bảng KetQua.
DROP PROCEDURE IF EXISTS SP_C47
GO
CREATE PROCEDURE 
	@MaSV VARCHAR(6),
AS 
BEGIN
	DELETE FROM DBO.KETQUA
	WHERE MSSV = @MaSV
END
EXEC SP_C47 @MaSV = 'C0001F'
SELECT * FROM DBO.SINHVIEN

-- Xóa điểm thi môn @MaMonHoc của sinh viên có mã @MaSV. Sử dụng RAISERROR để hiển thị thông báo dạng: 
--   ‘Đã xóa thành công kết quả môn thi @MaMonHoc của sinh viên @MaSV’.
DROP PROCEDURE IF EXISTS SP_C48
GO
CREATE PROCEDURE SP_C48
	@MaMH VARCHAR(10),
	@MaSV CHAR(6)
AS 
BEGIN
	WITH CTE AS (
					SELECT DISTINCT A.MaKhoaHoc
					FROM DBO.KETQUA AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
					WHERE MaMH = @MaMH
	            )
	DELETE FROM DBO.KETQUA 
	WHERE MSSV = @MaSV AND MaKhoaHoc = ( SELECT MaKhoaHoc FROM CTE )
	RAISERROR ('Đã xóa thành công kết quả môn học %s của sinh viên %s.', 15, 1, @MaMH, @MaSV);
END

EXEC SP_C48 @MaMH = 'CSDL', @MaSV = 'C0001F'
SELECT * FROM [dbo].[ketqua]

-- Xóa toàn bộ điểm trong table KetQua của sinh viên có mã @MaSV.
DROP PROCEDURE IF EXISTS SP_C49
GO
CREATE PROCEDURE 
	@MaSV VARCHAR(6),
AS 
BEGIN
	DELETE FROM DBO.KETQUA
	WHERE MSSV = @MaSV
END
EXEC SP_C49 @MaSV = 'C0001F'
SELECT * FROM DBO.SINHVIEN

-- Xóa toàn bộ thông tin của sinh viên có mã @MaSV.
DROP PROCEDURE IF EXISTS SP_C50
GO
CREATE PROCEDURE 
	@MaSV VARCHAR(6),
AS 
BEGIN
	DELETE FROM DBO.SINHVIEN
	WHERE MSSV = @MaSV
END
EXEC SP_C50 @MaSV = 'C0001F'
SELECT * FROM DBO.SINHVIEN

-- Xóa toàn bộ thông tin của khoa có mã @MaKhoa..
DROP PROCEDURE IF EXISTS SP_C51
GO
CREATE PROCEDURE 
	@MaKhoa VARCHAR(6),
AS 
BEGIN
	DELETE FROM DBO.KHOA
	WHERE MaKhoa= @MaKhoa
END
EXEC SP_C51 @MaKhoa = ' '
SELECT * FROM DBO.KHOA

-- Xóa kết quả học tập sau khi nhận 2 tham số Mã khóa học và mã sinh viên.
DROP PROCEDURE IF EXISTS SP_C52
GO
CREATE PROCEDURE 
	@MaKhoaHoc VARCHAR(4),
	@MaSV VARCHAR(6)
AS 
BEGIN
		DELETE FROM DBO.KETQUA WHERE MaKhoaHoc = @MaKhoaHoc AND MSSV = @MaSV
END
EXEC SP_C52 @MaKhoaHoc = 'K001', @MaSV = 'T0001F'
SELECT * FROM DBO.KETQUA


