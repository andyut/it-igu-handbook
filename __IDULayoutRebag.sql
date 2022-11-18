SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROC [dbo].[__IDULayoutRebag] 
(
	@Id BIGINT 
)
AS
BEGIN

	DECLARE @SapDb NVARCHAR(30);
	SELECT @SapDb=DBO.[SpSysGetSapDb]();
	DECLARE @Company NVARCHAR(200)
	--DECLARE @ArPerson NVARCHAR(200)
	DECLARE @SQL NVARCHAR(MAX);

	SET @SQL=N'SELECT TOP 1 @Company = UPPER(T0.CompnyName) 
			   FROM ['+@SapDb+'].DBO.OADM T0 (NOLOCK)'
					EXECUTE sp_executesql
						@SQL,
							N'@Company varchar(200) OUTPUT',
							@Company=@Company OUTPUT;

	CREATE TABLE #TBLRebag (
		CompanyName NVARCHAR(200) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		TransNo NVARCHAR(50) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		TransDate DATETIME,
		Status NVARCHAR(50) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		Remarks NVARCHAR(1000) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		TypeBahan CHAR(1),
		ItemCode NVARCHAR(50) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		ItemName NVARCHAR(200) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		Quantity NUMERIC(19,4),
		CostPercent NUMERIC(19,4),
		Uom NVARCHAR(50) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		Brand NVARCHAR(50) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		Tanggal NVARCHAR(50) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		CreatedUser NVARCHAR(200) COLLATE SQL_Latin1_General_CP850_CI_AS, 
		PostedUser NVARCHAR(200)  COLLATE SQL_Latin1_General_CP850_CI_AS
	)

	SET @SQL=N'SELECT 
						@Company As CompanyName 
						, T0.TransNo, 
						T0.TransDate, 
						T4.Name AS Status,
						T0.Remarks,
						''1'',
						T1.ItemCode,
						T1.ItemName,
						T1.Quantity,
						NULL,
						T1.Uom,
						ISNULL(T5.U_Brand,''''),
						RIGHT(CONVERT(VARCHAR(10), T0.DocDate, 111), 2) + '' '' +dbo.[__IDU_fnFormatMonth](MONTH(T0.DocDate)) + '' '' + LEFT(CONVERT(VARCHAR(10), T0.DocDate, 111), 4) AS Tanggal,
						T2.UserName,
						T3.UserName
				FROM Tx_Rebag T0
				INNER JOIN Tx_Rebag_Issue T1 ON T0.Id = T1.Id
				LEFT JOIN Tm_User T2 ON T2.Id = T0.CreatedUser
				LEFT JOIN Tm_User T3 ON T3.Id = T0.PostedUser
				LEFT JOIN Ts_List T4 ON T4.[Type] = ''GoodIssue_Status'' AND T0.Status = T4.Code 
			    LEFT JOIN ['+@SapDb+'].DBO.OITM T5 (NOLOCK)	 ON T1.ItemCode = T5.ItemCode
				WHERE T0.Id = @P_Id AND T0.Status <> ''Cancel''
				UNION ALL
				SELECT 
						@Company As CompanyName 
						, T0.TransNo, 
						T0.TransDate, 
						T4.Name AS Status,
						T0.Remarks,
						''2'',
						T1.ItemCode,
						T1.ItemName,
						T1.Quantity,
						T1.CostPercent,
						T1.Uom,
						ISNULL(T5.U_Brand,''''),
						RIGHT(CONVERT(VARCHAR(10), T0.DocDate, 111), 2) + '' '' +dbo.[__IDU_fnFormatMonth](MONTH(T0.DocDate)) + '' '' + LEFT(CONVERT(VARCHAR(10), T0.DocDate, 111), 4) AS Tanggal,
						T2.UserName,
						T3.UserName
				FROM Tx_Rebag T0
				INNER JOIN Tx_Rebag_Receipt T1 ON T0.Id = T1.Id
				LEFT JOIN Tm_User T2 ON T2.Id = T0.CreatedUser
				LEFT JOIN Tm_User T3 ON T3.Id = T0.PostedUser
				LEFT JOIN Ts_List T4 ON T4.[Type] = ''GoodIssue_Status'' AND T0.Status = T4.Code 
			    LEFT JOIN ['+@SapDb+'].DBO.OITM T5 (NOLOCK)	 ON T1.ItemCode = T5.ItemCode
				WHERE T0.Id = @P_Id AND T0.Status <> ''Cancel''

			   '

	INSERT INTO #TBLRebag
	EXEC SP_EXECUTESQL @SQL,
							N'@P_Id BIGINT, @Company NVARCHAR(200)',
							@P_Id=@Id, @Company = @Company;

	SELECT * FROM #TBLRebag;

	DROP TABLE #TBLRebag ;

END
GO
