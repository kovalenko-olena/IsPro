select 
      KpuC1.Kpu_Rcd     Kpu_Rcd, 
      PRKZ.KpuPrkz_PdRcd     KpuPrkz_PdRcd, 
      Kpu_Flg     Kpu_Flg, 
	  RIGHT('                    '+Kpu_Nmr, 20)     Kpu_Nmr, 
      ( CASE WHEN KpuX.Kpu_Tn <4000000000 THEN KpuX.Kpu_Tn ELSE 0 END )     Kpu_Tn, 
      Kpu_Fio     Kpu_Fio, 
      KpuK1.Kpu_Fio3     Kpu_Fio3, 
      SPRPDR.SprPdr_Pd     KpuK_CdPd, 
      Kpu_DtRoj     Kpu_DtRoj, 
      case when Year(Kpu_DtRoj) <1900 then 0 
           else case when Month(Kpu_DtRoj) <Month(GetDate()) then  DATEDIFF(year,Kpu_DtRoj,GetDate())
					           when Month(Kpu_DtRoj) >Month(GetDate()) then  DATEDIFF(year,Kpu_DtRoj,GetDate())-1
					           else case when Day(Kpu_DtRoj) <= Day(GetDate()) then DATEDIFF(year,Kpu_DtRoj,GetDate())
                               else DATEDIFF(year,Kpu_DtRoj,GetDate())-1 end end end     Kpu_Age, 
      Kpu_DtUvl     Kpu_DtUvl, 
      Kpu_CdNlp     Kpu_CdNlp, 
      SprSmPl.Nm     sKdrLkSPlNm, 
      KpuX.Kpu_TnOsn     Kpu_TnOsn, 
      Kpu_Conf     Kpu_Conf, 
      WarSprKat.Nm       sKpuWarNmKat, 
      WarSprSos.Nm       sKpuWarNmSos, 
      WarSprZvn.Nm       sKpuWarNmZvn, 
      WarSprGdn.Nm       sKpuWarNmGdn, 
      KpuWar_NmrSp       KpuWar_NmrSp, 
      KpuWar_Spu       KpuWar_Spu, 
      { fn IFNULL( WarSprRV.Nm, KpuWar_RVNm ) }       KpuWar_RVNm,  

	  --образование
	   (SELECT 
		COALESCE( SprObr1.Nm+ ', ', '')+
		(SELECT 
         STUFF((SELECT ', '+T2.KpuObr_Zav+ ', ' 
                       +COALESCE(CASE WHEN OBRSPRSPC.NmLong<>'' THEN OBRSPRSPC.NmLong+', ' END,
                               CASE WHEN OBRSPRSPC.Nm<>'' THEN OBRSPRSPC.Nm+', ' END ,
			       '')
                       +COALESCE(CASE WHEN OBRSPRKVL.NmLong<>'' THEN OBRSPRKVL.NmLong+', ' END,
			       CASE WHEN OBRSPRKVL.Nm<>'' THEN OBRSPRKVL.Nm+', ' END,
			       '')
  		     +COALESCE(CAST(T2.KpuObr_End as VARCHAR)+', ','')
  		     +COALESCE(KpuObr_NmrD,'')
  		     +COALESCE(CASE WHEN YEAR(KPUOBR_DTVD)>1900 THEN ' від ' 
                                    + CONVERT(nvarchar(30), KPUOBR_DTVD, 104) ELSE null END,'')
            FROM KPUOBR1 T2 
              LEFT JOIN FNSYSREADISPR( 681003, 2, 1 ) OBRSPRSPC ON OBRSPRSPC.CD =T2.KPUOBR_SPCCD 
              LEFT JOIN FNSYSREADISPR( 681004, 2, 1 ) OBRSPRKVL ON OBRSPRKVL.CD =T2.KPUOBR_KVLCD 

              WHERE T2.KPU_RCD =T1.KPU_RCD AND 
                    T2.KPU_RCD=KPUC1.KPU_RCD FOR XML PATH('')), 1, 1, '') VALS 

		FROM KPUOBR1 T1 

		WHERE T1.KPU_RCD=KPUC1.KPU_RCD

		GROUP BY T1.KPU_RCD 

		) AS OBR 

		FROM KPUC1 C1 
		LEFT JOIN fnSysReadISpr( 680961, 0, 0) SprObr1 ON SprObr1.Cd =KPUK1.Kpu_CdObr AND C1.KPU_RCD=KPUK1.Kpu_Rcd
		where KPUC1.KPU_RCD=C1.KPU_RCD  ) osvita,  

	--паспорт
	(select  top 1
       replace(
       replace(KPUPSP_SER 
       +case when COALESCE(KPUPSP_SER,'')<>'' then ' ' else '' end
       +KPUPSP_NMR
       +case when COALESCE(KPUPSP_NMR,'')<>'' then ' ' else '' end
       +{ FN IFNULL( PSPSPRPTN.PTN_NMSH, KPUPSP_WHO ) }   
       +case when COALESCE({ FN IFNULL( PSPSPRPTN.PTN_NMSH, KPUPSP_WHO ) }   ,'')<>'' then ' ' else '' end
       +convert(char, KPUPSP_DAT, 104),CHAR(10),''),CHAR(13),'')
       from KPUPSP1
       LEFT JOIN PTNRK PSPSPRPTN ON PSPSPRPTN.PTN_RCD =KPUPSP_WHORCD 
       where KPUPSP1.KPU_RCD =KPUK1.KPU_RCD and KPUPSP1.KpuPsp_TypDoc=1
       and KpuPsp_Add=0) pasport,  
	   
	   
	   --прописка
	   (
       COALESCE(

       (SELECT top 1 case when KPUADR_S='' then null else KPUADR_S end
        from KPUADR1 
        where KPUADR1.KPU_RCD =KPUK1.KPU_RCD and KPUADR_CD=1
        and KpuAdr_Add =0  and KpuAdr_AddRcd =0) 

        , (
             (select top 1 
             REPLACE(
                          COALESCE(
             (CASE          
              WHEN KPUADR_INDUS <> 0 THEN  KPUADR_INDEX          
              WHEN KPUADR_STR <> 0 THEN  (SELECT SPRADRSTR1.SADRSTR_ZIP FROM VWSADRSTR SPRADRSTR1 WHERE SPRADRSTR1.SADRSTR_RCD =KPUADR_STR) 
              WHEN KPUADR_PLAC <> 0 THEN (SELECT SPRADRNAS1.SADRNAS_ZIP FROM VWSADRNAS SPRADRNAS1 WHERE SPRADRNAS1.SADRNAS_RCD =KPUADR_PLAC) 
              WHEN KPUADR_TOWN <> 0 THEN (SELECT SPRADRTOW1.SADRTOW_ZIP FROM VWSADRTOW SPRADRTOW1 WHERE SPRADRTOW1.SADRTOW_RCD =KPUADR_TOWN) 
              WHEN KPUADR_ZONE <> 0 THEN (SELECT SPRADRRAI1.SADRRAI_ZIP FROM VWSADRRAI SPRADRRAI1 WHERE SPRADRRAI1.SADRRAI_RCD =KPUADR_ZONE) 
              WHEN KPUADR_REG <> 0 THEN  (SELECT SPRADRREG1.SADRREG_ZIP FROM VWSADRREG SPRADRREG1 WHERE SPRADRREG1.SADRREG_RCD =KPUADR_REG) 
              ELSE KPUADR_INDEX END) ,'')
              +
              case when COALESCE(
             (CASE          
              WHEN KPUADR_INDUS <> 0 THEN  KPUADR_INDEX          
              WHEN KPUADR_STR <> 0 THEN  (SELECT SPRADRSTR1.SADRSTR_ZIP FROM VWSADRSTR SPRADRSTR1 WHERE SPRADRSTR1.SADRSTR_RCD =KPUADR_STR) 
              WHEN KPUADR_PLAC <> 0 THEN (SELECT SPRADRNAS1.SADRNAS_ZIP FROM VWSADRNAS SPRADRNAS1 WHERE SPRADRNAS1.SADRNAS_RCD =KPUADR_PLAC) 
              WHEN KPUADR_TOWN <> 0 THEN (SELECT SPRADRTOW1.SADRTOW_ZIP FROM VWSADRTOW SPRADRTOW1 WHERE SPRADRTOW1.SADRTOW_RCD =KPUADR_TOWN) 
              WHEN KPUADR_ZONE <> 0 THEN (SELECT SPRADRRAI1.SADRRAI_ZIP FROM VWSADRRAI SPRADRRAI1 WHERE SPRADRRAI1.SADRRAI_RCD =KPUADR_ZONE) 
              WHEN KPUADR_REG <> 0 THEN  (SELECT SPRADRREG1.SADRREG_ZIP FROM VWSADRREG SPRADRREG1 WHERE SPRADRREG1.SADRREG_RCD =KPUADR_REG) 
              ELSE KPUADR_INDEX END) ,'')<>'' then ', ' else '' end
              +
                           COALESCE(SPRADRCNT.SADRCNT_NM,KPUADR_CNTNM,'')
              +case when (COALESCE(SPRADRCNT.SADRCNT_NM,'')<>'') or (COALESCE(KPUADR_CNTNM,'')<>'') then ', ' else '' end
              +
                            COALESCE(SPRADRREG.SADRREG_NM,KPUADR_REGNM,'')
              +case when (COALESCE(SPRADRREG.SADRREG_NM,KPUADR_REGNM,'')<>'')
               and (   (COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'')<>'')
                     or (COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')<>'')
                     or (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                     or (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     ) 
               then ', ' else '' end
              +
                            COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'')
              +case when (COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'')<>'')
                 and (  (COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')<>'')
                     or (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                     or (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')
              +case when (COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')<>'')
                 and (  (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                     or (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')
              +case when (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                 and (  (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')
              +case when (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                 and (  (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(KPUADR_HOUSE,'')
              +case when (COALESCE(KPUADR_HOUSE,'')<>'')
                 and (  (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(KPUADR_KORP,'')
              +case when (COALESCE(KPUADR_KORP,'')<>'')
                 and ( (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(KPUADR_FLAT,'')              
               ,' ,','')
              as adress
       from KPUADR1 
       LEFT JOIN "VWSADRSTR" SPRADRSTR ON SPRADRSTR.SADRSTR_RCD =KPUADR_STR
       LEFT JOIN "VWSADRCNT" SPRADRCNT ON SPRADRCNT.SADRCNT_RCD =KPUADR_CNT 
       LEFT JOIN "VWSADRREG" SPRADRREG ON SPRADRREG.SADRREG_RCD =KPUADR_REG 
       LEFT JOIN "VWSADRRAI" SPRADRRAI ON SPRADRRAI.SADRRAI_RCD =KPUADR_ZONE 
       LEFT JOIN "VWSADRTOW" SPRADRTOW ON SPRADRTOW.SADRTOW_RCD =KPUADR_TOWN 
       LEFT JOIN "VWSADRNAS" SPRADRNAS ON SPRADRNAS.SADRNAS_RCD =KPUADR_PLAC 
       where KPUADR1.KPU_RCD =KPUK1.KPU_RCD and KPUADR_CD=1 
       and KpuAdr_Add =0  and KpuAdr_AddRcd =0) 
       )        
       )) Propiska,  
	   
	   --адрес проживания
	   (
        COALESCE(

       (SELECT top 1 case when KPUADR_S='' then null else KPUADR_S end
        from KPUADR1 
        where KPUADR1.KPU_RCD =KPUK1.KPU_RCD and KPUADR_CD=2
        and KpuAdr_Add =0  and KpuAdr_AddRcd =0) 

        , (
             (select top 1
             REPLACE(
                          COALESCE(
             (CASE          
              WHEN KPUADR_INDUS <> 0 THEN  KPUADR_INDEX          
              WHEN KPUADR_STR <> 0 THEN  (SELECT SPRADRSTR1.SADRSTR_ZIP FROM VWSADRSTR SPRADRSTR1 WHERE SPRADRSTR1.SADRSTR_RCD =KPUADR_STR) 
              WHEN KPUADR_PLAC <> 0 THEN (SELECT SPRADRNAS1.SADRNAS_ZIP FROM VWSADRNAS SPRADRNAS1 WHERE SPRADRNAS1.SADRNAS_RCD =KPUADR_PLAC) 
              WHEN KPUADR_TOWN <> 0 THEN (SELECT SPRADRTOW1.SADRTOW_ZIP FROM VWSADRTOW SPRADRTOW1 WHERE SPRADRTOW1.SADRTOW_RCD =KPUADR_TOWN) 
              WHEN KPUADR_ZONE <> 0 THEN (SELECT SPRADRRAI1.SADRRAI_ZIP FROM VWSADRRAI SPRADRRAI1 WHERE SPRADRRAI1.SADRRAI_RCD =KPUADR_ZONE) 
              WHEN KPUADR_REG <> 0 THEN  (SELECT SPRADRREG1.SADRREG_ZIP FROM VWSADRREG SPRADRREG1 WHERE SPRADRREG1.SADRREG_RCD =KPUADR_REG) 
              ELSE KPUADR_INDEX END) ,'')
              +
              case when COALESCE(
             (CASE          
              WHEN KPUADR_INDUS <> 0 THEN  KPUADR_INDEX          
              WHEN KPUADR_STR <> 0 THEN  (SELECT SPRADRSTR1.SADRSTR_ZIP FROM VWSADRSTR SPRADRSTR1 WHERE SPRADRSTR1.SADRSTR_RCD =KPUADR_STR) 
              WHEN KPUADR_PLAC <> 0 THEN (SELECT SPRADRNAS1.SADRNAS_ZIP FROM VWSADRNAS SPRADRNAS1 WHERE SPRADRNAS1.SADRNAS_RCD =KPUADR_PLAC) 
              WHEN KPUADR_TOWN <> 0 THEN (SELECT SPRADRTOW1.SADRTOW_ZIP FROM VWSADRTOW SPRADRTOW1 WHERE SPRADRTOW1.SADRTOW_RCD =KPUADR_TOWN) 
              WHEN KPUADR_ZONE <> 0 THEN (SELECT SPRADRRAI1.SADRRAI_ZIP FROM VWSADRRAI SPRADRRAI1 WHERE SPRADRRAI1.SADRRAI_RCD =KPUADR_ZONE) 
              WHEN KPUADR_REG <> 0 THEN  (SELECT SPRADRREG1.SADRREG_ZIP FROM VWSADRREG SPRADRREG1 WHERE SPRADRREG1.SADRREG_RCD =KPUADR_REG) 
              ELSE KPUADR_INDEX END) ,'')<>'' then ', ' else '' end
              +
                           COALESCE(SPRADRCNT.SADRCNT_NM,KPUADR_CNTNM,'')
              +case when (COALESCE(SPRADRCNT.SADRCNT_NM,'')<>'') or (COALESCE(KPUADR_CNTNM,'')<>'') then ', ' else '' end
              +
                            COALESCE(SPRADRREG.SADRREG_NM,KPUADR_REGNM,'')
              +case when (COALESCE(SPRADRREG.SADRREG_NM,KPUADR_REGNM,'')<>'')
               and (   (COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'')<>'')
                     or (COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')<>'')
                     or (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                     or (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     ) 
               then ', ' else '' end
              +
                            COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'')
              +case when (COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'')<>'')
                 and (  (COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')<>'')
                     or (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                     or (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')
              +case when (COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'')<>'')
                 and (  (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                     or (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')
              +case when (COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'')<>'')
                 and (  (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                     or (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')
              +case when (COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'')<>'')
                 and (  (COALESCE(KPUADR_HOUSE,'')<>'')
                     or (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(KPUADR_HOUSE,'')
              +case when (COALESCE(KPUADR_HOUSE,'')<>'')
                 and (  (COALESCE(KPUADR_KORP,'')<>'')
                     or (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(KPUADR_KORP,'')
              +case when (COALESCE(KPUADR_KORP,'')<>'')
                 and ( (COALESCE(KPUADR_FLAT,'')<>'')
                     )                
               then ', ' else '' end
              +
                            COALESCE(KPUADR_FLAT,'')              
               ,' ,','')
              as adress
       from KPUADR1 
       LEFT JOIN "VWSADRSTR" SPRADRSTR ON SPRADRSTR.SADRSTR_RCD =KPUADR_STR
       LEFT JOIN "VWSADRCNT" SPRADRCNT ON SPRADRCNT.SADRCNT_RCD =KPUADR_CNT 
LEFT JOIN "VWSADRREG" SPRADRREG ON SPRADRREG.SADRREG_RCD =KPUADR_REG 
LEFT JOIN "VWSADRRAI" SPRADRRAI ON SPRADRRAI.SADRRAI_RCD =KPUADR_ZONE 
LEFT JOIN "VWSADRTOW" SPRADRTOW ON SPRADRTOW.SADRTOW_RCD =KPUADR_TOWN 
LEFT JOIN "VWSADRNAS" SPRADRNAS ON SPRADRNAS.SADRNAS_RCD =KPUADR_PLAC 
       where KPUADR1.KPU_RCD =KPUK1.KPU_RCD and KPUADR_CD=2 
       and KpuAdr_Add =0  and KpuAdr_AddRcd =0) 
       )        
       )) mesto_zit,  
	   
	   --семейное состояние
	   (SELECT
		COALESCE(SPRSMPL.NM+ ', ', '') +
		(SELECT 
			STUFF((SELECT '; '+CAST(SemSprSRd2.Nm AS VARCHAR)+ ' - ' 
                     +T2.KpuSem_Fio+' '+
                     CONVERT(VARCHAR, T2.KpuSem_Dt,104)+''
              FROM KpuSem1 T2
              LEFT JOIN fnSysReadISpr( 680980, 0, 0 ) SemSprSRd2 
                   ON SemSprSRd2.Cd =T2.KpuSem_Cd 
              WHERE T2.Kpu_Rcd =T1.Kpu_Rcd 
               AND T2.KPU_RCD=KPUC1.KPU_RCD FOR XML PATH('')), 1, 1, '') vals
			FROM KPUSEM1 T1 
			WHERE T1.KPU_RCD=KPUC1.KPU_RCD
			GROUP BY T1.KPU_RCD 
			) AS SEMSOST 
			   
		FROM KPUC1 C1 
		WHERE KPUC1.KPU_RCD=C1.KPU_RCD  
		) simStan , 

		--должность, профессия
		(select top 1
		 COALESCE((select SprDol.SprD_NmFull from 
		 SprDol where  SprDol.SprD_Cd=KPUPRKZ_DOL)
		 ,( select SprPrf.Sp_NmFull from
			  SprPrf   where SprPrf.Sp_Cd=KpuPrkz_Prf) ) 
			 ) dol_prf,  
	 
	 --последний приказ о перемещении (смена должПроф)
		(SELECT top 1
		CONVERT(char(10), PRK.KPUPRKZ_DTV, 104) +
		' НАКАЗ '+
		PRK.KpuPrkz_Cd+
		case when year(PRK.KPUPRKZ_DT)>1900 then ' ВІД '+
		CONVERT(char(10), PRK.KPUPRKZ_DT, 104) 
		else '' end
		+
		case when PRK.TYP=5 then ' "ПРИЗНАЧЕННЯ/ПЕРЕМІЩЕННЯ"' else 
			case when PRK.TYP=4 then ' "ПРИЙОМ"' else '' end
		end 
    
		as osnPrkz
    
		FROM
		(SELECT  top 1 
			   min(KPUPRK.KPUPRKZ_DTV) as KPUPRKZ_DTV,
	   			   (select top 1 K1.KpuPrkz_Cd 
				   from KPUPRK1 k1 
				   where K1.KpuPrkz_DtV=min(KPUPRK.KPUPRKZ_DTV) 
				   and K1.KPU_RCD=KPUPRK.KPU_RCD
				   order by K1.KpuPrkz_Typ desc) as KpuPrkz_Cd,
	   			   (select top 1 K1.KPUPRKZ_DT 
				   from KPUPRK1 k1 
				   where K1.KpuPrkz_DtV=min(KPUPRK.KPUPRKZ_DTV) 
				   and K1.KPU_RCD=KPUPRK.KPU_RCD
				   order by K1.KpuPrkz_Typ desc) as KPUPRKZ_DT,
	   			   (select top 1 K1.KpuPrkz_Typ 
				   from KPUPRK1 k1 
				   where K1.KpuPrkz_DtV=min(KPUPRK.KPUPRKZ_DTV) 
				   and K1.KPU_RCD=KPUPRK.KPU_RCD
				   order by K1.KpuPrkz_Typ desc) as Typ
	   
			   FROM KPUPRK1  KPUPRK
			   left join SPRDOL D on KpuPrk.KpuPrkz_Dol =D.SprD_cd
			   left join SPRPRF P on KpuPrk.KpuPrkz_Prf =P.Sp_cd          
			   where KPUPRK.Kpu_Rcd=kpuc1.Kpu_Rcd
			   and {fn Year(kpuprk.kpuprkz_dtv)}>1900
			   and kpuprk.KPUPRKZ_DTV>=Kpu_DtPst
			   and kpuprk.KPUPRKZ_DTV<=getdate()   
			   group by lower(REPLACE(REPLACE(REPLACE(D.SPRD_NMFULL, char(10), ''), char(13),''), '  ',' ')), 
						lower(REPLACE(REPLACE(P.SP_NMFull, char(10), ''), char(13),'')),
						KPUPRK.KPU_RCD,
						KpuPrk.KpuPrkz_Pd
			   order by KPUPRKZ_DTV desc
		) PRK ) osnDol 


		--основной запрос
FROM KpuC1 
INNER JOIN KpuK1  ON KpuK1.Kpu_Rcd =KpuC1.Kpu_Rcd 
INNER JOIN KpuX   ON KpuX.Kpu_Rcd  =KpuC1.Kpu_Rcd 
LEFT  JOIN KpuPdr         ON KpuPdr.Kpu_Rcd =KpuC1.Kpu_Rcd AND getdate() BETWEEN KpuPdr_DatN AND KpuPdr_DatK 
LEFT  JOIN SprPdr1 SPRPDR ON SPRPDR.bookmark =dbo.fn_SprPdr_bookmark(COALESCE(KpuPdr_Rcd,0), COALESCE(NULLIF(KpuC1.Kpu_DtUvl, {d '1876-12-31'}), getdate()) ) 


LEFT JOIN KpuPrk1 PRKZ   ON PRKZ.bookmark =dbo.fnGetPrikaz_bookmark(KpuC1.Kpu_Rcd, getdate()) 
left join SprNpd1 
on PRKZ.KpuPrkz_NPD =SprNpd1.SprNpd_Rcd 
and getdate() between SprNpd1.SprNpd_DatN and SprNpd_DatK 
LEFT JOIN /*TABLEVALUED( TSysISprTable */fnSysReadISpr( 680979, 0,0 ) SprSmPl ON SprSmPl.Cd =Kpu_SmPl 
LEFT JOIN KpuWar1 ON KpuWar1.Kpu_Rcd =KpuC1.Kpu_Rcd 


LEFT JOIN fnSysReadISpr( 680974, 0, 2 ) WarSprKat ON WarSprKat.Cd =KpuWar1.KpuWar_CdKat 
LEFT JOIN /**/fnSysReadISpr( 680975,  0, 2) WarSprSos ON WarSprSos.Cd =KpuWar1.KpuWar_CdSos 
LEFT JOIN /**/fnSysReadISpr(    531,  0, 2) WarSprZvn ON WarSprZvn.Cd =KpuWar1.KpuWar_CdZvn 
LEFT JOIN /**/fnSysReadISpr( 680977,  0, 2) WarSprGdn ON WarSprGdn.Cd =KpuWar1.KpuWar_Godn 
LEFT JOIN /**/fnSysReadISpr( 680978, 0, 2)WarSprRV ON WarSprRV.Cd =KpuWar1.KpuWar_RV 

 where 
KpuC1.Kpu_Type =0 
