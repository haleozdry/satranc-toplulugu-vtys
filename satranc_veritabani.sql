-- ==========================================================
-- 1. BÖLÜM: VERİTABANI VE TABLOLARIN OLUŞTURULMASI
-- ==========================================================
CREATE DATABASE SatrancTopluluguDB;
GO

USE SatrancTopluluguDB;
GO

-- Uye Tablosu
CREATE TABLE Uye (
    UyeID INT IDENTITY(1,1) PRIMARY KEY,
    OgrenciNo VARCHAR(20) UNIQUE NOT NULL,
    Ad NVARCHAR(50) NOT NULL,
    Soyad NVARCHAR(50) NOT NULL,
    Eposta VARCHAR(100) UNIQUE NOT NULL,
    Telefon VARCHAR(15),
    KayitTarihi DATE DEFAULT GETDATE(),
    AktifMi BIT DEFAULT 1
);
GO

-- Yonetici Tablosu
CREATE TABLE Yonetici (
    YoneticiID INT IDENTITY(1,1) PRIMARY KEY,
    UyeID INT FOREIGN KEY REFERENCES Uye(UyeID) ON DELETE CASCADE,
    Unvan NVARCHAR(50) NOT NULL,
    GorevBaslangicTarihi DATE DEFAULT GETDATE(),
    GorevBitisTarihi DATE NULL
);
GO

-- EnvanterKategori Tablosu
CREATE TABLE EnvanterKategori (
    KategoriID INT IDENTITY(1,1) PRIMARY KEY,
    KategoriAd NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- OdaEnvanter Tablosu
CREATE TABLE OdaEnvanter (
    EnvanterID INT IDENTITY(1,1) PRIMARY KEY,
    KategoriID INT FOREIGN KEY REFERENCES EnvanterKategori(KategoriID),
    MalzemeAdi NVARCHAR(100) NOT NULL,
    ToplamAdet INT NOT NULL CHECK (ToplamAdet >= 0),
    KullanilabilirAdet INT NOT NULL CHECK (KullanilabilirAdet >= 0),
    HasarliAdet INT DEFAULT 0 CHECK (HasarliAdet >= 0),
    OdaKonumu NVARCHAR(50)
);
GO

-- TurnuvaKategori Tablosu
CREATE TABLE TurnuvaKategori (
    TurnuvaKategoriID INT IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi NVARCHAR(50) NOT NULL,
    ZamanKontrolu NVARCHAR(30)
);
GO

-- Turnuva Tablosu
CREATE TABLE Turnuva (
    TurnuvaID INT IDENTITY(1,1) PRIMARY KEY,
    TurnuvaKategoriID INT FOREIGN KEY REFERENCES TurnuvaKategori(TurnuvaKategoriID),
    TurnuvaAdi NVARCHAR(100) NOT NULL,
    BaslangicTarihi DATETIME NOT NULL,
    BitisTarihi DATETIME NOT NULL,
    Konum NVARCHAR(100) DEFAULT 'Topluluk Odası',
    HedefKatilimciSayisi INT CHECK (HedefKatilimciSayisi > 0),
    Durum NVARCHAR(20) DEFAULT 'Planlandi' CHECK (Durum IN ('Planlandi', 'Devam Ediyor', 'Tamamlandi', 'Iptal'))
);
GO

-- TurnuvaOdul Tablosu
CREATE TABLE TurnuvaOdul (
    OdulID INT IDENTITY(1,1) PRIMARY KEY,
    TurnuvaID INT FOREIGN KEY REFERENCES Turnuva(TurnuvaID) ON DELETE CASCADE,
    DereceVeyaKategori NVARCHAR(50) NOT NULL,
    OdulTuru NVARCHAR(50) NOT NULL,
    MaddiDegeri DECIMAL(10,2) DEFAULT 0.00
);
GO

-- TurnuvaKatilim Tablosu
CREATE TABLE TurnuvaKatilim (
    KatilimID INT IDENTITY(1,1) PRIMARY KEY,
    TurnuvaID INT FOREIGN KEY REFERENCES Turnuva(TurnuvaID) ON DELETE CASCADE,
    UyeID INT FOREIGN KEY REFERENCES Uye(UyeID) ON DELETE CASCADE,
    KayitTarihi DATETIME DEFAULT GETDATE(),
    Puan DECIMAL(3,1) DEFAULT 0.0,
    Siralama INT NULL,
    KazanilanOdulID INT NULL FOREIGN KEY REFERENCES TurnuvaOdul(OdulID)
);
GO

-- TurnuvaMalzemeGereksinimi Tablosu
CREATE TABLE TurnuvaMalzemeGereksinimi (
    GereksinimID INT IDENTITY(1,1) PRIMARY KEY,
    TurnuvaID INT FOREIGN KEY REFERENCES Turnuva(TurnuvaID) ON DELETE CASCADE,
    KategoriID INT FOREIGN KEY REFERENCES EnvanterKategori(KategoriID),
    GerekliAdet INT NOT NULL CHECK (GerekliAdet > 0)
);
GO


-- ==========================================================
-- 2. BÖLÜM: ÖRNEK VERİLER (INSERT)
-- ==========================================================
USE SatrancTopluluguDB;
GO

INSERT INTO Uye (OgrenciNo, Ad, Soyad, Eposta, Telefon, AktifMi) VALUES
('20211234', 'Ahmet', 'Yılmaz', 'ahmet.yilmaz@ogr.edu.tr', '05551112233', 1),
('20222345', 'Zeynep', 'Kaya', 'zeynep.kaya@ogr.edu.tr', '05552223344', 1),
('20213456', 'Mehmet', 'Demir', 'mehmet.demir@ogr.edu.tr', '05553334455', 1),
('20234567', 'Elif', 'Çelik', 'elif.celik@ogr.edu.tr', '05554445566', 1),
('20205678', 'Can', 'Arslan', 'can.arslan@ogr.edu.tr', '05555556677', 1),
('20226789', 'Selin', 'Koç', 'selin.koc@ogr.edu.tr', '05556667788', 1);
GO

INSERT INTO Yonetici (UyeID, Unvan, GorevBaslangicTarihi) VALUES
(1, 'Kulüp Başkanı', '2025-10-01'),
(2, 'Sayman & Turnuva Sorumlusu', '2025-10-01');
GO

INSERT INTO EnvanterKategori (KategoriAd) VALUES
('Masa'),
('Satranç Saati'),
('Satranç Takımı'),
('Gösterim Tahtası');
GO

INSERT INTO OdaEnvanter (KategoriID, MalzemeAdi, ToplamAdet, KullanilabilirAdet, HasarliAdet, OdaKonumu) VALUES
(1, 'Katlanır Ahşap Turnuva Masası', 15, 14, 1, 'Depo - Sol Raf'),
(2, 'DGT 2010 Dijital Satranç Saati', 10, 10, 0, 'Dolap A - Göz 2'),
(3, 'Plastik Staunton Satranç Takımı', 12, 11, 1, 'Dolap B - Alt Raf'),
(4, 'Mıknatıslı Duvar Gösterim Tahtası', 2, 2, 0, 'Ana Salon Asma Pano');
GO

INSERT INTO TurnuvaKategori (KategoriAdi, ZamanKontrolu) VALUES
('Rapid (Hızlı)', '10+5'),
('Blitz (Yıldırım)', '3+2'),
('Klasik', '90+30');
GO

INSERT INTO Turnuva (TurnuvaKategoriID, TurnuvaAdi, BaslangicTarihi, BitisTarihi, Konum, HedefKatilimciSayisi, Durum) VALUES
(1, 'Güz Dönemi Hızlı Satranç Turnuvası', '2026-11-10 13:00:00', '2026-11-10 18:00:00', 'Üniversite Merkez Kafeterya', 20, 'Planlandi'),
(2, 'Geleneksel Blitz Şampiyonası', '2026-12-15 14:00:00', '2026-12-15 19:00:00', 'Topluluk Odası', 16, 'Planlandi');
GO

INSERT INTO TurnuvaOdul (TurnuvaID, DereceVeyaKategori, OdulTuru, MaddiDegeri) VALUES
(1, '1.lik Ödülü', 'Kupa + Satranç Kitabı', 350.00),
(1, '2.lik Ödülü', 'Madalya', 150.00),
(1, 'En İyi Kadın Oyuncu', 'Plaket', 200.00),
(2, '1.lik Ödülü', 'Kupa + Hediye Çeki', 500.00);
GO

INSERT INTO TurnuvaKatilim (TurnuvaID, UyeID, Puan, Sıralama, KazanilanOdulID) VALUES
(1, 3, 4.5, 1, 1), 
(1, 4, 3.5, 2, 2), 
(1, 5, 3.0, 3, NULL),
(1, 6, 2.5, 4, NULL);
GO

INSERT INTO TurnuvaMalzemeGereksinimi (TurnuvaID, KategoriID, GerekliAdet) VALUES
(1, 1, 10), 
(1, 2, 10), 
(1, 3, 10);
GO