USE QLSV_051124
GO

--============= Truy xuất data theo điều kiện =========================
SELECT Ten, DiaChi, DienThoai
FROM DBO.SINHVIEN;

--Cho biết tên các môn học và số tín chỉ tối thiểu của từng môn học.
SELECT TenMH, SoTC_ToiThieu
FROM DBO.MONHOC;

--Cho biết kết quả học tập của sinh viên có Mã số “T0003M”.
SELECT *
FROM DBO.KETQUA
WHERE [MSSV] = 'T0003M'; 

--Cho biết tên các giáo viên có ký tự thứ 3 của họ và tên là “A”.
SELECT TenGV
FROM DBO.GIAOVIEN 
WHERE TenGV LIKE '%__A%';

--Cho biết tên những môn học có chứa chữ “dữ” (ví dụ như các môn Cơ sở dữ liệu, Cấu trúc dữ liệu,...).
SELECT TenMH
FROM DBO.MONHOC
WHERE TenMH LIKE  '%DU%';

--Cho biết tên các giáo viên có ký tự đầu tiên của họ và tên là các ký tự “P” hoặc “L”.
SELECT TenGV
FROM DBO.GIAOVIEN
WHERE TenGV LIKE '[PL]%';      --% bất kỳ ký tự nào, _1 ký tự bất kỳ
                              --WHERE TenGV LIKE '[P]%' AND TenGV LIKE '[L]%'

--Cho biết tên, địa chỉ của những sinh viên có địa chỉ trên đường “Cống Quỳnh”.
SELECT Ten, DiaChi
FROM DBO.SINHVIEN
WHERE DiaChi LIKE '%Cong Quynh%';

--Cho biết mã môn học, tên môn học, mã khóa học và tổng số tín chỉ (TongSoTC) của 
--   những môn học có cấu trúc của mã môn học như sau: ký tự thứ 1 là “C”, ký tự thứ 3 là “D”.

SELECT A.MaMH, A.TenMH, B.MaKhoaHoc, B.TongSoTC
FROM DBO.MONHOC AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
WHERE B.MaMH LIKE 'C_D_';

--Cho biết tên các môn học được dạy trong niên khóa 2011-2012.

SELECT A.TenMH, B.NienKhoa
FROM DBO.MONHOC AS A LEFT JOIN DBO.GIANGDAY AS B ON A.MaMH = B.MaMH
WHERE B.NienKhoa = '2011-2012';

--Cho biết tên khoa, mã số sinh viên, tên, địa chỉ của các SV theo từng Khoa sắp theo thứ tự A-Z của tên sinh viên.

SELECT  A.MSSV, A.Ten, A.DiaChi, A.MaKhoa, B.TenKhoa
FROM DBO.SINHVIEN AS A LEFT JOIN DBO.KHOA AS B ON A.MaKhoa = B.MaKhoa
ORDER BY A.Ten;

--Cho biết tên môn học, tên sinh viên, điểm tổng kết (DiemKhoaHoc) của sinh viên qua từng khóa học.

SELECT B.Ten, A.DiemKhoaHoc, C.MaKhoaHoc, D.TenMH 
FROM DBO.KETQUA AS A 
       LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV 
	   LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	   LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH;

--Cho biết tên và điểm tổng kết của sinh viên qua từng khóa học (DiemKhoaHoc) của các
--SV học môn ‘CSDL’ với DiemKhoaHoc từ 6 đến 7.

SELECT B.Ten, A.DiemKhoaHoc, C.MaKhoaHoc, D.TenMH 
FROM  DBO.KETQUA AS A 
       LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV 
	   LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	   LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH 
WHERE   C.MaMH = 'CSDL' 
     AND A.DiemKhoaHoc BETWEEN 6.0 AND 7.9;

--Cho biết Tên sinh viên, tên môn học, mã khóa học, điểm tổng kết của sinh viên qua từng khóa học (DiemKhoaHoc) của SV có tên là ‘TUNG’.

SELECT B.Ten, A.DiemKhoaHoc, A.DiemKhoaHoc, A.MaKhoaHoc, D.TenMH 
FROM DBO.KETQUA AS A 
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV  
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH                                                    
WHERE 	B.Ten like '%tung%'	;	

--Cho biết tên khoa, tên môn học mà những sinh viên trong khoa đã học. Yêu cầu khi kết
--quả có nhiều dòng trùng nhau, chỉ hiển thị 1 dòng làm đại diện

SELECT DISTINCT E.TenKhoa, D.TenMH 
FROM  DBO.KETQUA AS A 
		LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV  
		LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
		LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH  
		LEFT JOIN DBO.KHOA AS E  ON B.MaKhoa = E.MaKhoa ;

--Cho biết tên khoa, mã khóa học mà giáo viên của khoa có tham gia giảng dạy.

SELECT C.TenKhoa, A.MaKhoaHoc, B.TenGV
FROM  DBO.GIANGDAY AS A 
     LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV 
	 LEFT JOIN DBO.KHOA AS C ON B.MaKhoa = C.MaKhoa;
	

--Cho biết tên những giáo viên tham gia giảng dạy môn “Ky thuat lap trinh”.
SELECT B.TenGV, C.TenMH
FROM  DBO.GIANGDAY AS A 
      LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV
	  LEFT JOIN DBO.MONHOC AS C ON A.MaMH = C.MaMH	 
WHERE C.TenMH = 'Ky thuat lap trinh';

--Cho biết mã, tên các SV có DiemKhoaHoc của 1 môn học nào đó trên 8 (kết quả các môn khác có thể <=8).
SELECT B.Ten, B.MSSV, D.TenMH, A.DiemKhoaHoc 
FROM DBO.KETQUA AS A 
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV  
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH                                                    
WHERE A.DiemKhoaHoc >=8;

--Cho biết tên sinh viên, mã môn học, tên môn học, DiemKhoaHoc của những SV đã học môn ‘CSDL’ hoặc ‘CTDL’.

-- ========================== i. Sử dụng 1 lệnh SELECT ========================================
SELECT B.Ten, C.MaMH, D.TenMH, A.DiemKhoaHoc
FROM DBO.KETQUA AS A 
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV  
	 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH 
WHERE C.MaMH IN ('CSDL', 'CTDL');

--===================== ii. Sử dụng UNION. ====================================================
	SELECT B.Ten, C.MaMH, D.TenMH, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A 
		 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV  
		 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
		 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH 
	WHERE C.MaMH = 'CSDL' 
UNION
	SELECT B.Ten, C.MaMH, D.TenMH, A.DiemKhoaHoc
	FROM DBO.KETQUA AS A 
		 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV  
		 LEFT JOIN DBO.GIANGDAY AS C ON A.MaKhoaHoc = C.MaKhoaHoc
		 LEFT JOIN DBO.MONHOC AS D ON C.MaMH = D.MaMH 
	WHERE C.MaMH = 'CTDL';

--Cho biết tên môn học mà giáo viên “Tran Van Tien” tham gia giảng dạy trong học kỳ 1 niên khóa 2012-2013.

--================= i. Sử dụng 1 lệnh SELECT ===========================================
SELECT C.TenMH, B.TenGV, A.HocKy, A.NienKhoa
FROM  DBO.GIANGDAY AS A 
      LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV 
	  LEFT JOIN DBO.MONHOC AS C ON A.MaMH = C.MaMH
WHERE B.TenGV = 'Tran Van Tien' AND 
      A.HocKy = 1 AND
	  A.NienKhoa = '2012-2013';

--================== ii. Sử dụng INTERSECT ====================================
	SELECT C.TenMH, B.TenGV, A.HocKy, A.NienKhoa
	FROM  DBO.GIANGDAY AS A 
		  LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV 
		  LEFT JOIN DBO.MONHOC AS C ON A.MaMH = C.MaMH
	WHERE B.TenGV = 'Tran Van Tien' AND A.HocKy = 1 

INTERSECT

	SELECT C.TenMH, B.TenGV, A.HocKy, A.NienKhoa
	FROM  DBO.GIANGDAY AS A 
		  LEFT JOIN DBO.GIAOVIEN AS B ON A.MaGV = B.MaGV 
		  LEFT JOIN DBO.MONHOC AS C ON A.MaMH = C.MaMH
	WHERE A.NienKhoa = '2012-2013';

--Cho biết tên những sinh viên đã có điểm trong table Kết quả (yêu cầu loại bỏ các tên trùng nhau nếu có).
SELECT DISTINCT B.Ten
FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
WHERE A.DiemKhoaHoc IS NOT NULL;

--Cho hiển thị 35% dữ liệu có trong table table kết quả.
SELECT TOP 35 PERCENT *
FROM DBO.KETQUA;

--Cho biết tên 3 sinh viên có DiemKhoaHoc cao nhất trong table kết quả.

--===== cách 1
SELECT TOP 3  TenSV ,  MaxDiemKhoaHoc
FROM (
		SELECT B.Ten AS TenSV, MAX ( A.DiemKhoaHoc) AS MaxDiemKhoaHoc
		FROM DBO.KETQUA AS A
			 INNER JOIN DBO.SINHVIEN AS B ON B.MSSV = A.MSSV
		GROUP BY B.Ten 
	 ) AS MaxScores
ORDER BY 
    MaxDiemKhoaHoc DESC;

--===== Cách 2
SELECT TOP 3 A.*
FROM (SELECT DISTINCT A.MSSV, Ten,DiemKhoaHoc
		,DENSE_RANK() OVER (PARTITION BY B.Ten ORDER BY A.DiemKhoaHoc DESC) AS RNK
		FROM DBO.KETQUA AS A LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
		) A
WHERE RNK=1
ORDER BY DiemKhoaHoc DESC;
--=====
		
--(*) Cho biết tên những sinh viên có tháng sinh trùng nhau. Kết quả hiển thị gồm tháng, tên sinh viên và ngày sinh.

SELECT DBO.SINHVIEN.Ten, MONTH(NgaySinh) AS ThangSinh, NgaySinh
FROM DBO.SINHVIEN 
WHERE MONTH(NgaySinh) in (
						  SELECT MONTH (NgaySinh)
						  FROM DBO.SINHVIEN 
						  GROUP BY MONTH (NgaySinh)
						  HAVING COUNT( MONTH(NgaySinh) )>1
	                     );

SELECT DBO.KETQUA.MSSV, DBO.KETQUA.DiemKhoaHoc,
       ROW_NUMBER () OVER ( ORDER BY DiemKhoaHoc DESC) AS XepHang
FROM DBO.KETQUA

SELECT DBO.KETQUA.MSSV, DBO.KETQUA.DiemKhoaHoc,
       DENSE_RANK () OVER ( ORDER BY DiemKhoaHoc DESC) AS XepHang
FROM DBO.KETQUA

SELECT ROW_NUMBER () OVER (ORDER BY AB.Ten) AS STT,
      AB.Ten, AB.MSSV
FROM (
		SELECT DISTINCT B.Ten, B.MSSV
		FROM DBO.KETQUA AS A
			 LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 ) AB

SELECT  B.MSSV, B.Ten, A.DiemKhoaHoc,
        DENSE_RANK () OVER (PARTITION BY B.Ten ORDER BY A.DiemKhoaHoc DESC) AS 'XEP HANG'
FROM DBO.KETQUA AS A
		LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV

SELECT C.TenKhoa, E.TenMH, 
       DENSE_RANK () OVER (PARTITION BY C.TenKhoa, E.TenMH ORDER BY A.DiemKhoaHoc DESC) AS 'STT SV',
       B.Ten, A.DiemKhoaHoc
FROM DBO.KETQUA AS A
     LEFT JOIN DBO.SINHVIEN AS B ON A.MSSV = B.MSSV
	 LEFT JOIN DBO.KHOA AS C ON B.MaKhoa = C.MaKhoa
	 LEFT JOIN DBO.GIANGDAY AS D ON A.MaKhoaHoc = D.MaKhoaHoc
	 LEFT JOIN DBO.MONHOC AS E ON D.MaMH = E.MaMH
