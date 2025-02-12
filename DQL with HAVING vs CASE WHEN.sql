USE QLSV_051124
GO

--Có bao nhiêu SV.
SELECT COUNT(dbo.SINHVIEN.Ten ) AS 'Số lượng SV'
FROM dbo.SINHVIEN;

--Có bao nhiêu GV.
SELECT COUNT(DBO.GIAOVIEN.TenGV) AS 'Số lượng GV'
FROM DBO.GIAOVIEN;

--Có bao nhiêu giáo viên khoa CNTT.
SELECT COUNT(DBO.GIAOVIEN.TenGV) AS 'Số lượng GV khoa CNTT'
FROM DBO.GIAOVIEN
WHERE DBO.GIAOVIEN.MaKhoa = 'CNTT';

--Có bao nhiêu SV nữ thuộc khoa “CNTT”.
SELECT COUNT(dbo.SINHVIEN.Ten ) AS 'Số lượng SV khoa CNTT'
FROM dbo.SINHVIEN
WHERE DBO.SINHVIEN.MaKhoa = 'CNTT';

--Có bao nhiêu môn học được giảng dạy trong học kỳ I năm 2011-2012.
SELECT COUNT(DBO.GIANGDAY.MaMH ) AS 'Số lượng MH - HK I 2011-2012 '
FROM DBO.GIANGDAY
WHERE DBO.GIANGDAY.HocKy = 1
      AND DBO.GIANGDAY.NienKhoa = '2011-2012' ;

--Có bao nhiêu SV học môn CSDL.
SELECT COUNT (C.Ten ) AS 'Số lượng SV học môn CSDL'
FROM DBO.KETQUA AS A 
	LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	LEFT JOIN DBO.SINHVIEN AS C ON A.MSSV = C.MSSV 
WHERE  B.MaMH = 'CSDL';

--Cho biết số lượng môn học đã tham gia và điểm TB của tất cả các DiemKhoaHoc của SV có mã số ‘T0003M’.
SELECT COUNT (B.MaMH) AS 'SL môn học của MSSV-T0003M', 
       AVG (A.DiemKhoaHoc) as 'Điểm TB của MSSV-T0003M'
FROM DBO.KETQUA AS A 
	LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
WHERE A.MSSV = 'T0003M'

--Cho biết mã, tên, địa chỉ và điểm TB của tất cả các DiemKhoaHoc của từng SV.
SELECT A.MSSV, C.Ten, 
       AVG (A.DiemKhoaHoc) as 'Điểm TB các môn', C.DiaChi
FROM DBO.KETQUA AS A 
	LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	LEFT JOIN DBO.SINHVIEN AS C ON A.MSSV = C.MSSV
GROUP BY A.MSSV, C.Ten, C.DiaChi;

--Cho biết số lượng DiemKhoaHoc >=8 của từng sinh viên (chỉ xuất kết quả cho những sinh viên có DiemKhoaHoc >=8).
SELECT C.Ten, 
       AVG (A.DiemKhoaHoc) as 'Điểm TB các môn >=8'
FROM DBO.KETQUA AS A 
	LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	LEFT JOIN DBO.SINHVIEN AS C ON A.MSSV = C.MSSV
GROUP BY C.Ten
HAVING AVG (A.DiemKhoaHoc) >= 8;

--Cho biết tên khoa, số lượng sinh viên có trong từng khoa (chỉ xuất kết quả cho những khoa có sinh viên).
SELECT B.TenKhoa AS 'Tên Khoa', 
       COUNT (DISTINCT A.Ten) AS 'Số Lượng SV trong khoa'
FROM DBO.SINHVIEN AS A
     LEFT JOIN DBO.KHOA AS B ON A.MaKhoa = B.MaKhoa
GROUP BY B.TenKhoa;

select* from dbo.KHOA;

--Cho biết tên khoa, số lượng khóa học mà giáo viên của khoa có tham gia giảng dạy (chỉ
--xuất kết quả cho những khoa có giáo viên tham gia giảng dạy trong các khóa học).
SELECT C.TenKhoa, 
       COUNT (DISTINCT A.MaKhoaHoc) AS 'SL Khóa học'
FROM DBO.GIANGDAY AS A
     LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
	 LEFT JOIN DBO.KHOA AS C ON B.MaKhoa = C.MaKhoa
GROUP BY C.TenKhoa;

--Cho biết số lượng tín chỉ lý thuyết, số lượng tín chỉ thực hành mà từng sinh viên đã tham
--gia (gồm MSSV, tên SV, số lượng tín chỉ lý thuyết, số lượng tín chỉ thực hành).
SELECT A.MSSV, C.Ten, 
       SUM ( B.SoTCLT) AS 'số lượng tín chỉ lý thuyết', 
       SUM (B.SoTCTH) AS 'số lượng tín chỉ thực hành'
FROM DBO.KETQUA AS A
     LEFT JOIN  DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc 
	 LEFT JOIN DBO.SINHVIEN AS C ON A.MSSV = C.MSSV
GROUP BY A.MSSV, C.Ten;

--Cho biết tên tất cả các giáo viên cùng với số lương khóa học, số lượng tín chỉ (lý thuyết
--+ thực hành) mà từng giáo viên đã tham gia giảng dạy.
SELECT B.TenGV, 
       COUNT (A.MaKhoaHoc) AS 'số lương khóa học', 
	   SUM ( A.SoTCLT) AS 'số lượng tín chỉ lý thuyết', 
       SUM (A.SoTCTH) AS 'số lượng tín chỉ thực hành'
FROM DBO.GIANGDAY AS A
     LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
GROUP BY B.TenGV

--Giả sử người ta muốn thống kê số lượng sinh viên theo từng nhóm điểm (với nhóm điểm
--được làm tròn không lấy số lẻ từ DiemKhoaHoc trong table Kết quả):
--➢ Yêu cầu: Đếm xem mỗi nhóm trong DiemKhoaHoc_PhanNhom có bao nhiêu sinh viên.

SELECT ROUND (DiemKhoaHoc,0) AS 'DiemKhoaHoc_PhanNhom', 
       COUNT (MSSV) AS 'SLSV'
FROM DBO.KETQUA
GROUP BY ROUND (DiemKhoaHoc,0);

--Cho biết tên những sinh viên chỉ mới thi đúng một môn.
SELECT DISTINCT B.Ten,
                COUNT (A.MaKhoaHoc) AS 'So lan thi'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.Ten
HAVING COUNT (A.MaKhoaHoc) = 1;

--Cho biết mã, tên, địa chỉ và điểm của các SV có điểm trung bình (của tất cả các
--DiemKhoaHoc) >8.5.
SELECT DISTINCT B.MSSV, B.Ten, B.DiaChi,
       AVG ( A.DiemKhoaHoc) AS 'Diem TB'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.MSSV, B.Ten, B.DiaChi
HAVING AVG (A.DiemKhoaHoc) >7.5;

--Cho biết Mã khóa học, học kỳ, năm, số lượng SV tham gia của những khóa học có số
--lượng SV tham gia từ 2 đến 4 người.
SELECT DISTINCT B.MSSV, B.Ten, B.DiaChi,
       AVG ( A.DiemKhoaHoc) AS 'Diem TB'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.MSSV, B.Ten, B.DiaChi
HAVING AVG (A.DiemKhoaHoc) >7.5;

--Cho biết các SV đã học 1 trong 2 môn ‘CSDL’ & ’CTDL’ hoặc có DiemKhoaHoc của
--1 trong 2 môn này >=8. Yêu cầu thực hiện bằng 2 cách:
--➢ Sử dụng duy nhất 1 lệnh SELECT.
SELECT B.Ten, C.MaMH, A.DiemKhoaHoc
FROM DBO.KETQUA AS A 
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
GROUP BY B.Ten, C.MaMH, A.DiemKhoaHoc
HAVING C.MaMH IN ('CSDL','CTDL')
       OR A.DiemKhoaHoc >= 8;

--➢ Sử dụng phép UNION giữa kết quả của 2 lệnh SELECT.
	SELECT B.Ten, C.MaMH, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A 
		 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
		 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	GROUP BY B.Ten, C.MaMH, A.DiemKhoaHoc
	HAVING C.MaMH IN ('CSDL','CTDL')
UNION
	SELECT B.Ten, C.MaMH, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A 
		 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
		 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	GROUP BY B.Ten, C.MaMH, A.DiemKhoaHoc
	HAVING  A.DiemKhoaHoc >= 8;

--Cho biết sinh viên có mã số ‘C0001F’ có tham gia khóa học ‘K1’ hay không?
SELECT DBO.KETQUA.MSSV,
     CASE WHEN DBO.KETQUA.MaKhoaHoc = 'K001' THEN 'CÓ' ELSE 'KHÔNG'
     END AS 'Tham gia khoa hoc K001'
FROM DBO.KETQUA
WHERE DBO.KETQUA.MSSV ='C0001F'
      AND DBO.KETQUA.MaKhoaHoc = 'K001';

--Cho biết khóa học K1 có sinh viên bị thi lại (DiemKhoaHoc <5) hay không?
SELECT MaKhoaHoc, MSSV, DiemKhoaHoc,
      CASE WHEN DBO.KETQUA.DiemKhoaHoc <5  THEN 'Qua mon' ELSE 'Thi lai'
	  END AS 'Danh gia KQ'
FROM DBO.KETQUA
WHERE DBO.KETQUA.MaKhoaHoc = 'K001';


--Cho biết Khoa CNTT có sinh viên Nữ đạt DiemKhoaHoc cả 2 môn ‘CSDL’ & ’CTDL’ >=5 hay không?
SELECT B.Ten, B. PhaiNu, C.MaMH, A.DiemKhoaHoc,
      CASE WHEN A.DiemKhoaHoc >= 5 THEN 'Dat' ELSE 'Khong dat'
	  END AS 'Danh gia KQ'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
WHERE B.PhaiNu = 1 
      AND C.MaMH IN ('CSDL','CTDL');

--Cho biết giáo viên tên 'THAO' có dạy môn học nào trong năm 2011-2012 hay không?
SELECT B.TenGV, A.NienKhoa, 
     CASE WHEN A.NienKhoa = '2011-2012' THEN 'Co giang day' ELSE 'Khong giang day'
	 END AS 'Trang thai giang day'
FROM DBO.GIANGDAY AS A
     LEFT JOIN  DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
WHERE B.TenGV LIKE '%THAO'
      AND A.NienKhoa = '2011-2012' ;

--Giả sử cần tạo dữ liệu gồm 3 cột MSSV, Họ tên, Học bổng. Trong đó những sinh viên có
--điểm trung bình của tất cả các môn đều phải >=7 sẽ nhận học bổng là 1tr, ngược lại, học bổng =0.
SELECT B.MSSV, B.Ten, AVG (A.DiemKhoaHoc) AS 'Diem TB',
      CASE WHEN AVG (A.DiemKhoaHoc) >=7 THEN '1 Trieu' ELSE '0'
	  END AS 'Hoc bong'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.MSSV, B.Ten;


--Giả sử cần tạo dữ liệu gồm 3 cột MSSV, Họ tên, Xếp loại. Trong đó cột Xếp loại căn
--cứ trên điểm trung bình (của tất cả các DiemKhoaHoc) theo quy định xếp loại như sau:
SELECT B.MSSV, B.Ten, AVG (A.DiemKhoaHoc) AS 'Diem TB',
	  CASE WHEN AVG(A.DiemKhoaHoc) >=9 THEN 'Xuat sac'
		   WHEN AVG(A.DiemKhoaHoc) >=8 THEN 'Gioi'
		   WHEN AVG(A.DiemKhoaHoc) >=7 THEN 'Kha'
	       WHEN AVG(A.DiemKhoaHoc) >=5 THEN 'Trung binh'
		   WHEN AVG(A.DiemKhoaHoc) < 5 THEN 'Yeu'
	  END AS 'Xep loai'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.MSSV, B.Ten;

--Thống kê sinh viên theo xếp loại học tập
SELECT ABC.[XEP LOAI], 
       COUNT (ABC.Ten) AS 'TONG SO',
	   SUM ( CASE WHEN ABC.PhaiNu = 1 THEN 1 ELSE 0 END ) AS 'SO LUONG NU',
	   SUM ( CASE WHEN ABC.PhaiNu = 0 THEN 1 ELSE 0 END )  AS 'SO LUONG NAM'
FROM (
		SELECT B.MSSV, B.Ten, B.PhaiNu,
			  CASE WHEN AVG(A.DiemKhoaHoc) >=9 THEN 'Xuat sac'
				   WHEN AVG(A.DiemKhoaHoc) >=8 THEN 'Gioi'
				   WHEN AVG(A.DiemKhoaHoc) >=7 THEN 'Kha'
				   WHEN AVG(A.DiemKhoaHoc) >=5 THEN 'Trung binh'
				   ELSE 'Yeu'
			  END AS 'XEP LOAI'
		FROM DBO.KETQUA AS A
			 RIGHT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
		GROUP BY B.MSSV, B.Ten, B.PhaiNu
     ) AS ABC
GROUP BY ABC.[XEP LOAI];

---CACH 1 - =======================================:

DROP TABLE IF EXISTS #TempXH

-- Tạo bảng TEMP xếp hạng theo điểm trung bình các khóa học của từng SV
SELECT SV.MSSV, PhaiNu
 ,CASE WHEN AVG(DiemKhoaHoc) >= 9 THEN N'Xuất sắc' 
   WHEN AVG(DiemKhoaHoc) >= 8 AND  AVG(DiemKhoaHoc) <9 THEN N'Giỏi' 
    WHEN AVG(DiemKhoaHoc) >= 7 AND  AVG(DiemKhoaHoc) <8 THEN N'Khá' 
     WHEN AVG(DiemKhoaHoc) >= 5 AND  AVG(DiemKhoaHoc) <7 THEN N'Trung bình' 
 ELSE N'Yếu'
 END AS [XepHang]
INTO #TempXH
FROM SinhVien SV LEFT JOIN KetQua KQ ON SV.MSSV = KQ.MSSV
GROUP BY SV.MSSV,PhaiNu

DROP TABLE IF EXISTS #TempNu
DROP TABLE IF EXISTS #TempNam

SELECT XepHang,COUNT(PhaiNu) AS [SL_Nu] -- Tạo bảng TEMP tính số lượng NỮ theo từng xếp hạng
INTO #TempNu
FROM #TempXH
WHERE PhaiNu = 1
GROUP BY XepHang

SELECT XepHang,COUNT(PhaiNu) AS [SL_Nam] -- Tạo bảng TEMP tính số lượng NAM theo từng xếp hạng
INTO #TempNam
FROM #TempXH
WHERE PhaiNu = 0
GROUP BY XepHang

SELECT A.XepHang AS [Xếp loại],  -- Thống kê sinh viên theo xếp loại học tập
  COUNT(A.MSSV) AS [Tổng số],
  ISNULL([SL_Nu],0) AS [SL_Nu],
  COALESCE([SL_Nam],0) AS [SL_Nam]
FROM #TempXH A
 LEFT JOIN #TempNu B ON A.XepHang = B.XepHang
 LEFT JOIN #TempNam C ON A.XepHang = C.XepHang
GROUP BY A.XepHang,[SL_Nu],[SL_Nam]

---- CACH 2  =======================================:

---2A
SELECT A.XepHang AS [Xếp loại],  -- Thống kê sinh viên theo xếp loại học tập
  COUNT(A.MSSV) AS [Tổng số],
  ISNULL(B.[SL Nữ],0) AS [SL Nữ],
  COALESCE(C.[SL Nam] ,0) AS [SL Nam]
FROM #TempXH A LEFT JOIN (SELECT XepHang, COUNT(PhaiNu) AS [SL Nữ] FROM #TempXH WHERE PhaiNu = 1 GROUP BY XepHang) B ON A.XepHang = B.XepHang
      LEFT JOIN (SELECT XepHang, COUNT(PhaiNu) AS [SL Nam] FROM #TempXH WHERE PhaiNu = 0 GROUP BY XepHang) C ON A.XepHang = C.XepHang
GROUP BY A.XepHang,[SL Nữ],[SL Nam]


---2B

SELECT [XepHang] AS N'XẾP LOẠI',COUNT(MSSV) AS N'TỔNG SỐ',
 SUM(CASE WHEN PhaiNu = 1 THEN 1 ELSE 0 END) AS N'SL NỮ',
 SUM(CASE WHEN PhaiNu = 0 THEN 1 ELSE 0 END) AS N'SL NAM'
FROM #TempXH
GROUP BY [XepHang]

--- CACH 3 ==========================================
DROP TABLE IF EXISTS #TempXH

SELECT SV.MSSV, PhaiNu
 ,CASE WHEN AVG(DiemKhoaHoc) >= 9 THEN N'Xuất sắc'
 WHEN AVG(DiemKhoaHoc) >= 8 AND  AVG(DiemKhoaHoc) <9 THEN N'Giỏi' 
    WHEN AVG(DiemKhoaHoc) >= 7 AND  AVG(DiemKhoaHoc) <8 THEN N'Khá' 
     WHEN AVG(DiemKhoaHoc) >= 5 AND  AVG(DiemKhoaHoc) <7 THEN N'Trung bình' 
 ELSE N'Yếu'
 END AS [XepHang]
INTO #TempXH
FROM SinhVien SV LEFT JOIN KetQua KQ ON SV.MSSV = KQ.MSSV
GROUP BY SV.MSSV,PhaiNu;

WITH CTE AS(
 SELECT XepHang,COUNT(PhaiNu) AS [SL Nữ] -- Tạo bảng TEMP tính số lượng NỮ theo từng xếp hạng
 FROM #TempXH
 WHERE PhaiNu = 1
 GROUP BY XepHang
),
CTE2 AS (
 SELECT XepHang,COUNT(PhaiNu) AS [SL Nam] -- Tạo bảng TEMP tính số lượng NAM theo từng xếp hạng
 FROM #TempXH
 WHERE PhaiNu = 0
 GROUP BY XepHang
)
SELECT A.XepHang AS [Xếp loại],  -- Thống kê sinh viên theo xếp loại học tập
  COUNT(A.MSSV) AS [Tổng số],
  ISNULL(B.[SL Nữ],0) AS [SL Nữ],
  COALESCE(C.[SL Nam] ,0) AS [SL Nam]
FROM #TempXH A LEFT JOIN CTE B ON A.XepHang = B.XepHang
      LEFT JOIN CTE2 C ON A.XepHang = C.XepHang
GROUP BY A.XepHang,[SL Nữ],[SL Nam]

--Yêu cầu thực hiện bằng 2 cách: có và không có sử dụng truy vấn con (sub Select).
--Cho biết mã số, tên và DiemKhoaHoc cao nhất của từng SV.
-- =========== Cách 1 ============
SELECT B.MSSV, B.Ten, 
      MAX(A.DiemKhoaHoc) AS 'Diem cao nhat'
FROM DBO.KETQUA AS A
     LEFT JOIN dbo.SINHVIEN AS B ON A.MSSV = B.MSSV
GROUP BY B.MSSV, B.Ten;

-- ========== Cách 2 ==============
SELECT A.MSSV, A.Ten, B.[Diem cao nhat]  
FROM DBO.SINHVIEN AS A
     RIGHT JOIN ( SELECT DBO.KETQUA.MSSV, 
	                    MAX (DBO.KETQUA.DiemKhoaHoc) AS 'Diem cao nhat'
	             FROM DBO.KETQUA
				 GROUP BY DBO.KETQUA.MSSV ) AS B
     ON A.MSSV = B.MSSV;

--Đối với từng môn học, cho biết tên môn học và DiemKhoaHoc cao nhất của môn học đó.
-- =========== Cách 1 ============
SELECT C.TenMH, 
       MAX (A.DiemKhoaHoc) AS 'Diem cao nhat'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH
GROUP BY C.TenMH;

-- =========== Cách 2 ============
SELECT C.TenMH, A.[Diem cao nhat]    
FROM (  SELECT DBO.KETQUA.MaKhoaHoc,
	           MAX (DBO.KETQUA.DiemKhoaHoc) AS 'Diem cao nhat'
	    FROM DBO.KETQUA 
	    GROUP BY DBO.KETQUA.MaKhoaHoc 
	 )AS A
     LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH;

--Cho biết tên của môn học có số tín chỉ tối thiểu (SoTC_ToiThieu) là nhiều nhất.
SELECT DBO.MONHOC.TenMH, DBO.MONHOC.SoTC_ToiThieu
FROM DBO.MONHOC
WHERE DBO.MONHOC.SoTC_ToiThieu = (SELECT MAX (DBO.MONHOC.SoTC_ToiThieu)
                                  FROM DBO.MONHOC );

--Cho biết tên của khoa có số lượng CBGD ít nhất.
SELECT DBO.KHOA.TenKhoa, DBO.KHOA.SL_CBGD
FROM DBO.KHOA
WHERE DBO.KHOA.SL_CBGD = (SELECT MIN (DBO.KHOA.SL_CBGD)
                          FROM DBO.KHOA );

--Cho biết mã, tên, địa chỉ của các SV có DiemKhoaHoc lớn nhất trong khóa học có mã là ‘K001’.
SELECT B.MSSV, B.Ten, B.DiaChi, A.MaKhoaHoc,
       MAX (A.DiemKhoaHoc) AS 'Diem cao nhat'
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
WHERE A.MaKhoaHoc = 'K001'
GROUP BY B.MSSV, B.Ten, B.DiaChi, A.MaKhoaHoc;

--Tên các sinh viên có DiemKhoaHoc cao nhất trong môn ‘Kỹ Thuật Lập Trình’.
SELECT D.Ten, C.TenMH, A.DiemKhoaHoc
FROM DBO.KETQUA AS A
	LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
	LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH
	LEFT JOIN DBO.SINHVIEN AS D ON A.MSSV = D.MSSV
WHERE C.TenMH = 'Ky Thuat Lap Trinh'
      AND A.DiemKhoaHoc = ( SELECT MAX(DiemKhoaHoc)
		                    FROM DBO.KETQUA AS C 
								 LEFT JOIN DBO.GIANGDAY AS D ON C.MaKhoaHoc = D.MaKhoaHoc
								 LEFT JOIN DBO.MONHOC AS E ON D.MaMH = E.MaMH
							WHERE E.TenMH = 'Ky Thuat Lap Trinh'  )
GROUP BY D.Ten, C.TenMH, A.DiemKhoaHoc;

--Cho biết tên những giáo viên tham gia giảng dạy nhiều khóa học nhất.
SELECT TOP 1 B.TenGV, 
			 COUNT (A.MaKhoaHoc) AS 'SLKH'
FROM DBO.GIANGDAY AS A
	 LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
	 LEFT JOIN DBO.KHOA AS C ON B.MaKhoa = C.MaKhoa
GROUP BY B.TenGV
ORDER BY COUNT (A.MaKhoaHoc) DESC;

--Học kỳ nào có nhiều môn học được giảng dạy nhất (không quan tâm đến năm học).
SELECT TOP 1 DBO.GIANGDAY.HocKy,
           COUNT (DBO.GIANGDAY.MaMH) AS 'So luong mon hoc MAX'
FROM DBO.GIANGDAY
GROUP BY DBO.GIANGDAY.HocKy
ORDER BY COUNT (DBO.GIANGDAY.MaMH) DESC;

--Cho biết tên các môn học có nhiều sinh viên tham gia nhất (tên môn, số lượng sinh viên).
SELECT TOP 1 C.TenMH,
			 COUNT (A.MSSV) AS 'SL_SV'
FROM DBO.KETQUA AS A
		LEFT JOIN DBO.GIANGDAY AS B ON A.MaKhoaHoc = B.MaKhoaHoc
		LEFT JOIN DBO.MONHOC AS C ON B.MaMH = C.MaMH
GROUP BY C.TenMH
ORDER BY COUNT (A.MSSV) DESC;

--Cho biết tên các sinh viên có nhiều điểm (DiemKhoaHoc) >= 7 nhất. (bao gồm tên sinh viên, số lượng điểm >=7).
SELECT TOP 1  A.MSSV, B.Ten,
			    COUNT (A.DiemKhoaHoc) AS 'SL diem >= 7'
FROM DBO.KETQUA AS A
		LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
WHERE A.DiemKhoaHoc >= 7
GROUP BY A.MSSV , B.Ten
ORDER BY COUNT(A.DiemKhoaHoc) DESC;

--Cho biết tên các sinh viên có số lượng tín chỉ tham gia học là nhiều nhất (có thể điểm của
--môn đó không đạt – DiemKhoaHoc <5), thông tin hiển thị bao gồm tên sinh viên, số lượng tín chỉ).
SELECT TOP 1 B.Ten,
             SUM(C.TongSoTC) AS TongSoTC_MAX
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
GROUP BY B.Ten
ORDER BY SUM(C.TongSoTC) DESC;

--Cho biết tên các sinh viên có số lượng tín chỉ đạt (DiemKhoaHoc >=5) nhiều nhất.
--Thông tin hiển thị bao gồm tên sinh viên, số lượng tín chỉ).
SELECT B.Ten,
       SUM(C.TongSoTC) AS TongSoTC_DatDK
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
WHERE A.DiemKhoaHoc >=5
GROUP BY B.Ten;

--Cho biết tên môn học, tên sinh viên, DiemKhoaHoc của các sinh viên học những môn
--học có số tín chỉ tối thiểu (SoTC_ToiThieu) là thấp nhất.
SELECT D.TenMH, B.Ten, A.DiemKhoaHoc, D.SoTC_ToiThieu
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH
WHERE D.SoTC_ToiThieu = ( SELECT MIN (DBO.MONHOC.SoTC_ToiThieu) 
                          FROM DBO.MONHOC 
						)
GROUP BY D.TenMH, B.Ten, A.DiemKhoaHoc, D.SoTC_ToiThieu;

--Tương tự yêu cầu của câu trên, cho biết tên môn học, tên sinh viên có điểm cao nhất của môn học đó
SELECT XH.TenMH, XH.Ten AS 'SV co diem cao nhat', XH.DiemKhoaHoc
FROM (
		SELECT D.TenMH, B.Ten, A.DiemKhoaHoc,
			   DENSE_RANK () OVER ( PARTITION BY D.TenMH ORDER BY A.DiemKhoaHoc DESC ) AS RNK
		FROM DBO.KETQUA AS A
			 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
			 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
			 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH 
		GROUP BY D.TenMH,C.MaKhoaHoc, B.Ten, A.DiemKhoaHoc
	 ) AS XH
WHERE RNK = 1;

--Cho biết tên Khoa, tên sinh viên thuộc Khoa và có điểm trung bình cao nhất.
SELECT XH.TenKhoa, XH.Ten AS 'Ten SV co diem cao nhat', 
       XH.DiemKhoaHoc AS DiemTB_Max
FROM (
		SELECT C.TenKhoa, B.Ten, A.DiemKhoaHoc,
				DENSE_RANK () OVER ( PARTITION BY C.TenKhoa ORDER BY A.DiemKhoaHoc DESC ) AS RNK
		FROM DBO.KETQUA AS A
			 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
			 LEFT JOIN DBO.KHOA AS C ON B.MaKhoa = C.MaKhoa
		GROUP BY C.TenKhoa, B.Ten, A.DiemKhoaHoc
	 ) AS XH
WHERE XH.RNK = 1
