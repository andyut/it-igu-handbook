declare 
        @datefrom varchar(10),
        @dateto varchar(10) ,
        @strcustomer VARCHAR(500)

set @datefrom ='20230301' 
set @dateto ='20230301' 
set @strcustomer ='' 


declare   @invoice TABLE  ( idx smallint , docnentry int )

declare   @TABLE TABLE  (	COL_00 VARCHAR(500) ,COL_01 VARCHAR(500) , 
						COL_02 VARCHAR(500) ,
						COL_03 VARCHAR(500) ,
						COL_04 VARCHAR(500) ,
						COL_05 VARCHAR(500) ,
						COL_06 VARCHAR(500) ,
						COL_07 VARCHAR(500) ,
						COL_08 VARCHAR(500) ,
						COL_09 VARCHAR(500) ,
						COL_10 VARCHAR(500) ,
						COL_11 VARCHAR(500) ,
						COL_12 VARCHAR(500) ,
						COL_13 VARCHAR(500) ,
						COL_14 VARCHAR(500) ,
						COL_15 VARCHAR(500) ,
						COL_16 VARCHAR(500) ,
						COL_17 VARCHAR(500) ,
						COL_18 VARCHAR(500) ,
						COL_19 VARCHAR(500) ,
						COL_20 VARCHAR(500))

 
INSERT INTO @TABLE 
SELECT '000a', 'FK','KD_JENIS_TRANSAKSI','FG_PENGGANTI','NOMOR_FAKTUR','MASA_PAJAK','TAHUN_PAJAK','TANGGAL_FAKTUR','NPWP','NAMA','ALAMAT_LENGKAP','JUMLAH_DPP','JUMLAH_PPN','JUMLAH_PPNBM','ID_KETERANGAN_TAMBAHAN','FG_UANG_MUKA','UANG_MUKA_DPP','UANG_MUKA_PPN','UANG_MUKA_PPNBM','REFERENSI', 'KODE_DOKUMEN_PENDUKUNG'

INSERT INTO @TABLE 
SELECT '001b','LT','NPWP','NAMA',	'JALAN',	'BLOK',	'NOMOR','RT',	'RW',	'KECAMATAN',	'KELURAHAN',	'KABUPATEN',	'PROPINSI',	'KODE_POS',	'NOMOR','TELEPON','','','','', ''

INSERT INTO @TABLE 
SELECT '002c','OF',	'KODE_OBJEK',	'NAMA',	'HARGA_SATUAN',	'JUMLAH_BARANG',	'HARGA_TOTAL',	'DISKON',	'DPP',	'PPN',	'TARIF_PPNBM',	'PPNBM','','','','','','','','',''
 

INSERT INTO @TABLE 
select	  convert(Varchar,A.DOCENTRY)+'A','FK' i1 ,
		left(a.U_IDU_FPajak,2) i2, 
		'0' i3,
		right(replace(replace(a.U_IDU_FPajak,'.',''),'-',''),13) i4, 
		month(a.docdate) i5,
		year(a.docdate) i6,
		convert(varchar,a.docdate,103) i7,
		case when isnull(b.LicTradNum,'')='' then '000000000000000' else isnull(b.LicTradNum,'') end     i8,
		isnull(b.u_idu_namaNPWP, b.CardName)   i9,
		case isnull(d.u_IGU_Status,'N')  
            when 'N'  then REPLACE(REPLACE(isnull(b.U_Alamat_NPWP,a.address2),CHAR(13),' '),CHAR(10),' ') 
            when  'Y'  then replace(REPLACE(REPLACE(isnull(A.address2,a.address),CHAR(13),' '),CHAR(10),' ') ,'"','')
        else REPLACE(REPLACE(isnull(b.U_Alamat_NPWP,a.address2),CHAR(13),' '),CHAR(10),' ') 
        end  i10,
		CONVERT(NUMERIC(19,0),(a.DocTotal - a.VatSum )) i11,
		case left(a.U_IDU_FPajak,2) 
           when '08' then convert(numeric(19,0), c.vatsumLine - (a.discsum * 11/100)) 
            else   convert(numeric(19,0), c.vatsumLine )
        end   i12 ,
        --CONVERT(NUMERIC(19,0),case when left(a.U_IDU_FPajak,2) ='01' then   CONVERT(NUMERIC(19,0),A.VATSUM)else (a.DocTotal - a.VatSum) * 0.1 end)    i12,
--		CONVERT(NUMERIC(19,0),A.VATSUM)    i12,
		'0' i13,
		case left(a.U_IDU_FPajak,2) 
					when '08' then '17'  
					when '07' then '1'  
			else''
		end i14,
		'0' i15,
		'0' i16,
		'0' i17,
		'0' i18,
		a.NumAtCard i19,
		case left(a.U_IDU_FPajak,2) 
			when '08' then a.NumAtCard  
			when '07' then a.NumAtCard  
		else ''
		end i20 

from dbo.oinv (nolock) a 
	inner join dbo.ocrd  (nolock)  b on a.cardcode = b.cardcode 
    left outer join dbo.crd1 (nolock) d on b.cardcode = d.cardcode and d.address = a.shiptocode and d.adresType='S'
    inner join 
        (select a.docentry , sum(CONVERT(NUMERIC(19,0),case when left(a.U_IDU_FPajak,2) ='01' then   CONVERT(NUMERIC(19,0),b.VATSUM) else (b.linetotal) * 0.11 end))  vatsumLine
            from dbo.oinv (nolock) a 
            inner join dbo.inv1 (nolock) b on a.docentry = b.docentry 
           
          where convert(varchar,a.docdate,112) between @datefrom and @dateto 
                and a.cardcode + isnull(a.cardname ,'') + isnull(a.shiptocode,'') like '%' + isnull(@strcustomer,'') + '%'
                and a.CANCELED ='N'
                and isnull(a.U_IDU_FPajak,'')<>''
          group by a.docentry
        ) c on a.docentry = c.docentry
where 
  convert(varchar,a.docdate,112) between @datefrom and @dateto 
  and a.cardcode + isnull(a.cardname ,'') + isnull(a.shiptocode,'') like '%' + isnull(@strcustomer,'') + '%'
and a.CANCELED ='N'
and isnull(a.U_IDU_FPajak,'')<>''


INSERT INTO @TABLE 
select	 convert(Varchar,A.DOCENTRY) +'B' ,
		'OF' i1 ,
		'' i2, 
		(
                case ISNULL(replace(c.Dscription,'"','') ,'') 
                        when '' then replace(C.Dscription,'"','') 
                        else ISNULL(replace(c.Dscription,'"',''),'') 
            end + replace(isnull(C.FreeTxt,''),'"','') )   i3,
		 convert(numeric(19,0),C.U_Price_AR)  i4, 
		convert(numeric(19,2),C.U_Qty_AR) i5,
		convert(numeric(19,0),C.LineTotal) i6,
		convert(numeric(19,0), CASE A.DiscPrcnt WHEN 0 THEN 0 ELSE c.LineTotal * A.DiscPrcnt / 100 END)    i7,
		convert(numeric(19,0), CASE A.DiscPrcnt WHEN 0 THEN C.LineTotal  ELSE C.LINETOTAL-(c.LineTotal * A.DiscPrcnt / 100) END)    i8,
		CONVERT(NUMERIC(19,0),case when left(a.U_IDU_FPajak,2) ='01' then   CONVERT(NUMERIC(19,0),c.VATSUM)else (C.LINETOTAL-(c.LineTotal * A.DiscPrcnt / 100)) * 0.11 end) i9,
--		convert(numeric(19,0),C.VatSum) i9,
		'0'  i10,
		'0' i11,
		'' i12,
		'' i13,
		'' i14,
		'' i15,
		'' i16,
		'' i17,
		'' i18,
		'' i19,
		'' i20
from dbo.oinv  (nolock)  a 
	inner join dbo.ocrd  (nolock)  b on a.cardcode = b.cardcode 
	INNER JOIN DBO.INV1  (nolock)  C ON A.DOCENTRY = C.DOCENTRY 
	left outer JOIN DBO.OITM  (nolock)  D ON C.itemcode = d.itemcode 
where 
 CONVERT(VARCHAR,a.docdate,112) between @datefrom and @dateto
	AND a.CANCELED ='N'
	AND ISNULL(a.U_IDU_FPajak,'')<>''
	and a.cardcode + isnull(a.cardname ,'') + isnull(a.shiptocode,'') like '%' + isnull(@strcustomer,'') + '%'
 SELECT  
		COL_01 ,
		COL_02 ,
		COL_03 ,
		COL_04 ,
		COL_05 ,
		COL_06 ,
		COL_07 ,
		COL_08 ,
		COL_09 ,
		COL_10 ,
		COL_11 ,
		COL_12 ,
		COL_13 ,
		COL_14 ,
		COL_15 ,
		COL_16 ,
		COL_17 ,
		COL_18 ,
		COL_19 ,
		COL_20 FROM @TABLE order by COL_00

 