SELECT TOP 1
      KPUPRKZ_DTV AS LAST_DTV,
      KpuPrkz_Cd AS LAST_CD,            
      MIN_KPUPRKZ_DTV AS MIN_DTV,
      MIN_KpuPrkz_Cd AS MIN_CD,
	  PER_KPUPRKZ_DTV AS PER_DTV,
	  PER_KpuPrkz_Cd AS PER_CD
FROM KPUPRK1 
LEFT JOIN SPRPDR1 ON KpuPrkz_PdRcd = SprPdr_Rcd and KPUPRKZ_DTV between SprPdr_DatN and SprPdr_DatK
LEFT JOIN SPRDOL D on KpuPrk1.KpuPrkz_Dol = D.SprD_cd
LEFT JOIN SPRPRF P on KpuPrk1.KpuPrkz_Prf = P.Sp_cd
LEFT JOIN PSPR on KPUPRK1.KPUPRKZ_NZN=PSPR.SPR_CD and PSPR.SPRSPR_CD=680989
LEFT JOIN kpuc1 on kpuc1.Kpu_Rcd=KPUPRK1.KPU_RCD
LEFT JOIN 
       (SELECT TOP 1 
			KPUPRKZ_DTV AS MIN_KPUPRKZ_DTV,  
			KpuPrkz_Cd AS MIN_KpuPrkz_Cd, 
			KPUPRK1.Kpu_Rcd       
       FROM KPUPRK1 
       left join SPRDOL D on KpuPrk1.KpuPrkz_Dol = D.SprD_cd
       left join SPRPRF P on KpuPrk1.KpuPrkz_Prf = P.Sp_cd
       left join kpuc1 on kpuc1.Kpu_Rcd = KPUPRK1.KPU_RCD           
       where KPUPRK1.Kpu_Rcd=(SELECT KPU_RCD FROM KPUX WHERE KPU_TN =5070)
			and {fn Year(kpuprk1.kpuprkz_dtv)}>1900
			and KPUPRKZ_DTV>=Kpu_DtPst
			and KPUPRKZ_DTV<=getdate()    
       group by lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')), 
                lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),
                KPUPRK1.KPU_RCD, KpuPrkz_Cd, KPUPRKZ_DTV
       order by KPUPRKZ_DTV ASC ) PST ON KPUPRK1.Kpu_Rcd = PST.Kpu_Rcd                               

LEFT JOIN 
       (SELECT TOP 1 
			KPUPRKZ_DTV AS PER_KPUPRKZ_DTV,  
			KpuPrkz_Cd AS PER_KpuPrkz_Cd,
			KPU.Kpu_Rcd       
       FROM KPUPRK1 KPU
       left join SPRDOL D on Kpu.KpuPrkz_Dol = D.SprD_cd
       left join SPRPRF P on Kpu.KpuPrkz_Prf = P.Sp_cd
       left join kpuc1 on kpuc1.Kpu_Rcd=KPU.KPU_RCD 
	   LEFT JOIN (SELECT COALESCE(lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')),'') AS DOL, 
						 COALESCE(lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),'') AS PRF, 
						 K.KpuPrkz_Pd, 
						 K.KpuPrkz_Raz as RAZ,
						 KPU_RCD 
				  FROM KPUPRK1 K 
				  left join SPRDOL D on K.KpuPrkz_Dol = D.SprD_cd
                  left join SPRPRF P on K.KpuPrkz_Prf = P.Sp_cd
				  WHERE K.bookmark =
					(
					SELECT max(P1.bookmark) FROM KpuPrk1 P1
					WHERE P1.Kpu_Rcd = (SELECT KPU_RCD FROM KPUX WHERE KPU_TN =5070)			
					)
					)MAXPRK ON KPU.Kpu_Rcd = MAXPRK.KPU_RCD
       where KPU.Kpu_Rcd=(SELECT KPU_RCD FROM KPUX WHERE KPU_TN =5070)
			and {fn Year(kpu.kpuprkz_dtv)}>1900
			and KPUPRKZ_DTV>=Kpu_DtPst
			and KPUPRKZ_DTV<=getdate() 
			and COALESCE(lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')),'') = MAXPRK.DOL
			and COALESCE(lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),'') = MAXPRK.PRF
			and Kpu.KpuPrkz_Pd = MAXPRK.KpuPrkz_Pd
			and Kpu.KpuPrkz_Raz = MAXPRK.RAZ
			AND KPUPRKZ_DTV >= 
				(SELECT MAX(K.KPUPRKZ_DTV) 
				FROM KPUPRK1 K 
				left join SPRDOL D on K.KpuPrkz_Dol = D.SprD_cd
				left join SPRPRF P on K.KpuPrkz_Prf = P.Sp_cd
				WHERE 
				K.Kpu_Rcd = (SELECT KPU_RCD FROM KPUX WHERE KPU_TN =5070) AND
				(K.KpuPrkz_Pd <> MAXPRK.KpuPrkz_Pd OR 
				COALESCE(lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')),'') <> MAXPRK.DOL OR
				COALESCE(lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),'') <> MAXPRK.PRF OR
				K.KpuPrkz_Raz <> MAXPRK.RAZ)			
				)
       group by lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')), 
                lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),
                KPU.KPU_RCD, KpuPrkz_Cd, KPUPRKZ_DTV
       order by KPUPRKZ_DTV ASC ) PEREVOD ON KPUPRK1.Kpu_Rcd=PEREVOD.Kpu_Rcd    
	 
where KPUPRK1.Kpu_Rcd = (SELECT KPU_RCD FROM KPUX WHERE KPU_TN =5070)
and {fn Year(kpuprk1.kpuprkz_dtv)}>1900
and KPUPRKZ_DTV>=Kpu_DtPst
and KPUPRKZ_DTV<=getdate()    
group by lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')), 
         lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),
         KPUPRK1.KPU_RCD,
         KpuPrk1.KpuPrkz_Pd,
         KpuPrk1.KpuPrkz_Dol,  
         KpuPrk1.KpuPrkz_Prf,  
         KPUPRKZ_DTV,                                       
         lower(REPLACE(REPLACE(REPLACE(D.SprD_NmR, char(10), ''), char(13),''), '  ',' ')), 
	     lower(REPLACE(REPLACE(P.SP_NmR, char(10), ''), char(13),'')) ,            
         KpuPrkz_Cd,
         MIN_KPUPRKZ_DTV,
         MIN_KpuPrkz_Cd,
         PER_KPUPRKZ_DTV,
         PER_KpuPrkz_Cd           
order by KPUPRKZ_DTV  desc

/*
select * from kpuc1
select * from Pspr       
left join [NOV11_SYS].[dbo].[SSPR] sspr on sspr.Spr_NmShort='ÃÐÏ' and sspr.SprSpr_Cd=680999 
and sspr.Spr_CdLng=2 and ROUND(sspr.Spr_Cd,-2)=ROUND(CAST(case when len(Pspr.Spr_NmShort)>1 then Pspr.Spr_NmShort else '0' end AS int),-2)
where Pspr.SprSpr_Cd   = 570
*/