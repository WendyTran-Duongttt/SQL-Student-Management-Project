CREATE DATABASE QLSV_051124
USE QLSV_051124
GO
SET DATEFORMAT dmy

--============================================BẢNG 1 - SINHVIEN====================================

DROP TABLE IF EXISTS DBO.SINHVIEN
CREATE TABLE SINHVIEN (
	MSSV VARCHAR (6) PRIMARY KEY CHECK (MSSV LIKE '[A-Z][0-9][0-9][0-9][0-9][FM]'),
	Ten VARCHAR (50) NOT NULL,
	PhaiNu INT CHECK (PhaiNu IN (0,1)),
	DiaChi NVARCHAR (100) NOT NULL,
	DienThoai VARCHAR (10) CHECK(DienThoai LIKE ('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]') 
							  OR DienThoai LIKE ('[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
							  ),
	MaKhoa VARCHAR (4) NOT NULL,
	SoCMND VARCHAR (50) UNIQUE,
	NgaySinh DATE,
	NgayNhapHoc DATE NOT NULL ,
	NgayVaoDoan DATE,
	NgayVaoDang DATE,
	NgayRaTruong DATE
	);
ALTER TABLE SINHVIEN
     ADD CONSTRAINT NgayNhapHoc CHECK (DATEDIFF( YEAR, NgaySinh, NgayNhapHoc) >=18 ),
	     CONSTRAINT NgayVaoDoan CHECK (DATEDIFF( YEAR, NgaySinh, NgayVaoDoan) >=16),
		 CONSTRAINT NgayVaoDang CHECK (NgayVaoDoan < NgayVaoDang);

INSERT INTO SINHVIEN VALUES 
	('C0001F', 'BUI THUY AN', 1, '223 Tran Hung Dao,HCM', '38132202', 'CNTT', 135792468, '1992-08-14', '2010-10-01', NULL, NULL, '2012-11-15'),
	('C0002M', 'NGUYEN THANH TUNG', 0, '140 Cong Quynh,HCM', '38125678', 'CNTT', 987654321, '1992-11-23', '2010-10-01', NULL, NULL, NULL),
	('T0003M', 'NGUYEN THANH LONG', 0, '112/4 Cong Quynh,HCM', '0918345623', 'TOAN', 123456789, '1991-09-17', '2010-10-01', '2007-05-19', '2012-05-01', NULL),
	('C0004F', 'HOANG THI HOA', 1, '90 Nguyen Van Cu,HCM', '38320123', 'CNTT', 246813579, '1991-09-02', '2010-10-01', NULL, NULL, NULL),
	('T0005M', 'TRAN HONG SON', 0, '54 Cao Thang,HANOI', '38345987', 'TOAN', 864297531, '1993-04-24', '2011-10-15', '2010-09-02', NULL, NULL);
SELECT*FROM DBO.SINHVIEN

-- ============================================== BẢNG 2 - KHOA =========================================

DROP TABLE IF EXISTS DBO.KHOA
CREATE TABLE KHOA (
	MaKhoa VARCHAR (4) PRIMARY KEY ,
	TenKhoa NVARCHAR (50),
	SL_CBGD INT DEFAULT 0,
	);
ALTER TABLE KHOA
    ADD CONSTRAINT SL_CBGD CHECK (SL_CBGD BETWEEN 0 AND 4);

INSERT INTO KHOA VALUES 
	('CNTT', N'Công nghệ thông tin', 0),
	('TOAN', N'Toán', 0),
	('SINH', N'Sinh học', 0);
SELECT*FROM DBO.KHOA

--================================================= BANG 3 - GIAOVIEN =========================================

DROP TABLE IF EXISTS DBO.GIAOVIEN
CREATE TABLE GIAOVIEN (
	MaGV VARCHAR (4) PRIMARY KEY,
	TenGV VARCHAR (50) NOT NULL,
	MaKhoa VARCHAR (4),
	FOREIGN KEY (MaKhoa) REFERENCES KHOA (MaKhoa)
	);
ALTER TABLE GIAOVIEN
	ADD CONSTRAINT MaGV CHECK ( (MaGV LIKE '[A-Z][0-9][0-9][FM]')  
                        AND   (LEFT(MaGV,1) = LEFT(MaKhoa,1))
							  );
UPDATE KHOA
SET SL_CBGD = A.CNT FROM 
                        (
						   SELECT MaKhoa, COUNT (*) AS CNT
						   FROM GIAOVIEN
						   GROUP BY MaKhoa
						) A
WHERE KHOA.MaKhoa = A.MaKhoa;

INSERT INTO GIAOVIEN VALUES 
	('C01F', 'PHAM THI THAO', 'CNTT'),
	('T02M', 'LAM HOANG VU', 'TOAN'),
	('C03M', 'TRAN VAN TIEN', 'CNTT'),
	('C04M', 'HOANG VUONG', 'CNTT');
SELECT*FROM DBO.GIAOVIEN

--============================================ BANG 4 - MONHOC ======================================

DROP TABLE IF EXISTS DBO.MONHOC
CREATE TABLE MONHOC (
	MaMH VARCHAR (4) PRIMARY KEY,
	TenMH VARCHAR (100) NOT NULL,
	SoTC_ToiThieu INT DEFAULT 0  
	);
INSERT INTO MONHOC VALUES 
	('CSDL', 'Co So Du Lieu', 2),
	('CTDL', 'Cau Truc Du Lieu', 3),
	('KTLT', 'Ky Thuat Lap Trinh', 3),
	('CWIN', 'Lap Trinh C Tren Window', 3),
	('TRR', 'Toan roi rac', 2);
SELECT*FROM DBO.MONHOC

--============================================= BANG 5 - GIANGDAY ==================================

DROP TABLE IF EXISTS DBO.GIANGDAY
CREATE TABLE GIANGDAY (
	MaKhoaHoc VARCHAR(4) PRIMARY KEY CHECK ( MaKhoaHoc LIKE 'K[0-9][0-9][0-9]'),
	MaGV VARCHAR(4),
	MaMH VARCHAR(4),
	HocKy INT CHECK (HocKy BETWEEN 1 AND 3),
	NienKhoa VARCHAR(9) CHECK (NienKhoa LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
	NgayBatDauLyThuyet DATE,
	NgayBatDauThucHanh DATE,
	NgayKetThuc DATE,
	TongSoTC INT,
	SoTCLT INT CHECK (SoTCLT >= 0),
	SoTCTH INT CHECK (SoTCTH >= 0),
	SoTietLT INT  CHECK (SoTietLT >=0 ),
	SoTietTH INT CHECK (SoTietTH >= 0),
	FOREIGN KEY (MaGV) REFERENCES GIAOVIEN (MaGV),
	FOREIGN KEY (MaMH) REFERENCES MONHOC (MaMH)
	);
ALTER TABLE GIANGDAY
   ADD CONSTRAINT TongSoTC CHECK ( TongSoTC IN (2,3,4,5,6)
							   AND TongSoTC = SoTCLT+SoTCTH ),
       CONSTRAINT SoTietLT CHECK (SoTietLT = SoTCLT*15),
	   CONSTRAINT SoTCTH CHECK (SoTietTH >= 0 AND (SoTietTH / 45 <= SoTCTH OR SoTietTH % 45 = 0) );
INSERT INTO GIANGDAY VALUES 
	('K001', 'C01F', 'CSDL', 1, '2011-2012', '15/9/2011', '1/10/2011', '2/1/2012', 4, 3, 1, 45, 30),
	('K002', 'C04M', 'KTLT', 2, '2011-2012', '17/2/2012', '1/3/2012', '18/5/2012', 4, 3, 1, 45, 45), 
	('K003', 'C03M', 'CTDL', 1, '2012-2013', '11/9/2012', '14/3/2012', '3/1/2013', 4, 3, 1, 45, 30),
	('K004', 'C04M', 'CWIN', 1, '2012-2013', '13/9/2012', '13/10/2012', '14/1/2013', 4, 2, 2, 30, 60),
	('K005', 'T02M', 'TRR', 1, '2012-2013', '14/9/2012', '2/10/2012', '18/1/2013', 3, 3, 0, 45, 0);
SELECT*FROM DBO.GIANGDAY

--====================================================== BANG 6 - KETQUA =======================================================

DROP TABLE IF EXISTS DBO.KETQUA
CREATE TABLE KETQUA (
MSSV VARCHAR(6),
MaKhoaHoc VARCHAR(4),
DiemKTGiuaKy DECIMAL(3,1) CHECK (DiemKTGiuaKy BETWEEN 0.0 AND 10.0),
DiemThiLan1 DECIMAL(3,1) CHECK (DiemThiLan1 BETWEEN 0.0 AND 10.0),
DiemThiLan2 DECIMAL(3,1),
DiemKhoaHoc DECIMAL(3,1),
PRIMARY KEY (MSSV, MaKhoaHoc),
FOREIGN KEY (MSSV) REFERENCES SINHVIEN (MSSV),
FOREIGN KEY (MaKhoaHoc) REFERENCES GIANGDAY (MaKhoaHoc),
FOREIGN KEY (MSSV) REFERENCES SINHVIEN (MSSV)
);
ALTER TABLE KETQUA
   ADD CONSTRAINT DiemThiLan2 CHECK( (DiemThiLan2 BETWEEN 0.0 AND 10.0)
                               OR (DiemThiLan1 <5 AND DiemThiLan2 >0) 
                               AND ( (DiemThiLan1 >=5 AND DiemThiLan2 IS NULL))
							   );
UPDATE KETQUA
SET DiemKhoaHoc = ROUND(0.4 * DiemKTGiuaKy + 0.6 * 
                        CASE 
                            WHEN DiemThiLan1 >= DiemThiLan2 THEN DiemThiLan1
                            ELSE DiemThiLan2
                        END, 1);
INSERT INTO KETQUA VALUES 
	('C0001F', 'K001', 8.5, 5, NULL, 6.4),
	('C0001F', 'K003', 8.0, 9, NULL, 8.6),
	('T0003M', 'K004', 9.0, 7, NULL, 7.8),
	('C0001F', 'K002', 9.0, 9, NULL, 7.8),
	('T0003M', 'K003', 6.0, 2, 2.5, 3.9),
	('T0005M', 'K003', 9.0, 7, NULL, 7.8),
	('C0002M', 'K001', 7.0, 2, 5, 5.8),
	('T0003M', 'K002', 6.5, 2, 3, 4.4),
	('T0005M', 'K005', 7.0, 10, NULL, 8.8),
	('C0001F', 'K004', 8.0, 9, NULL, 8.6);
SELECT*FROM DBO.KETQUA

ALTER TABLE SINHVIEN
ADD FOREIGN KEY  (MaKhoa) REFERENCES KHOA (MaKhoa)
 
UPDATE DBO.SINHVIEN
SET NgaySinh = '14/08/1992'
WHERE  NgaySinh = '1992-08-14'
UPDATE DBO.SINHVIEN
SET NgaySinh = '23/11/1992'
WHERE  NgaySinh = '1992-11-23'
UPDATE DBO.SINHVIEN
SET NgaySinh = '17/08/1991' 
WHERE  NgaySinh = '1991-09-17'
UPDATE DBO.SINHVIEN
SET NgaySinh = '02/09/1991'   
WHERE  NgaySinh = '1991-09-02'
UPDATE DBO.SINHVIEN
SET NgaySinh = '24/04/1993'
WHERE  NgaySinh = '1993-04-24'

UPDATE DBO.SINHVIEN
SET NgayNhapHoc = '01/10/2010'
WHERE  NgayNhapHoc = '2010-10-01'
UPDATE DBO.SINHVIEN
SET NgayNhapHoc = '17/10/2010'
WHERE  NgaySinh = '02/09/1991'
UPDATE DBO.SINHVIEN
SET NgayNhapHoc = '15/10/2011'
WHERE  NgayNhapHoc = '2011-10-15'

--('C0001F', 'BUI THUY AN', 1, '223 Tran Hung Dao,HCM', '38132202', 'CNTT', 135792468, '1992-08-14', '2010-10-01', NULL, NULL, '2012-11-15'),
--('C0002M', 'NGUYEN THANH TUNG', 0, '140 Cong Quynh,HCM', '38125678', 'CNTT', 987654321, '1992-11-23', '2010-10-01', NULL, NULL, NULL),
--('T0003M', 'NGUYEN THANH LONG', 0, '112/4 Cong Quynh,HCM', '0918345623', 'TOAN', 123456789, '1991-09-17', '2010-10-01', '2007-05-19', '2012-05-01', NULL),
--('C0004F', 'HOANG THI HOA', 1, '90 Nguyen Van Cu,HCM', '38320123', 'CNTT', 246813579, '1991-09-02', '2010-10-01', NULL, NULL, NULL),
--('T0005M', 'TRAN HONG SON', 0, '54 Cao Thang,HANOI', '38345987', 'TOAN', 864297531, '1993-04-24', '2011-10-15', '2010-09-02', NULL, NULL);


SELECT *
FROM SINHVIEN