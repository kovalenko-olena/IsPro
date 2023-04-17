Select KpuC1.Kpu_Rcd,KpuC1.Kpu_Fio,KpuC1.Kpu_CdNlp, KPUWAR1.KpuWar_NmrSp, KPUWAR1.KpuWar_DocN, KPUWAR1.KpuWar_DtDoc,KPUWAR1.KpuWar_RVRNm,
PSPR.Spr_Nm,KpuC1.Kpu_DtRoj,KpuC1.Kpu_DtPst, KPUC1.Kpu_DtUvl
,KpuAdr1.KpuAdr_S,PrkzGet.KpuPrkz_Dt,KPUWAR1.KpuWar_RVNm
  ,PrkzGet.KpuPrkz_Cd,

REPLACE(
--индекс    
case when(KPUADR_INDEX)<>'' then KPUADR_INDEX else ' ' end
+
--страна 
case when(COALESCE(SPRADRCNT.SADRCNT_NM,KPUADR_CNTNM,''))<>'' then 
+', '
+ COALESCE(SPRADRCNT.SADRCNT_NM,KPUADR_CNTNM,'') else '' end
+
--регион
case when(COALESCE(SPRADRREG.SADRREG_NM,KPUADR_REGNM,''))<>'' then 
+', '
+ COALESCE(SPRADRREG.SADRREG_NM,KPUADR_REGNM,'') else '' end
+
--район
case when(COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,''))<>'' then 
+', '
+ COALESCE(SPRADRRAI.SADRRAI_NM,KPUADR_ZONEN,'') else '' end
+
--город
case when(COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,''))<>'' then 
+', '
+ COALESCE(SPRADRTOW.SADRTOW_NM,KPUADR_TOWNN,'') else '' end
+
--населенный пункт
case when(COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,''))<>'' then 
+', '
+ COALESCE(SPRADRNAS.SADRNAS_NM,KPUADR_PLACN,'') else '' end
+
--улица
case when(COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,''))<>'' then 
+', '
+ COALESCE(SPRADRSTR.SADRSTR_NM,KPUADR_STRN,'') else '' end
+
--дом
case when(KPUADR_HOUSE)<>'' then 
+', '
+ KPUADR_HOUSE else '' end
+
--корпус
case when(KPUADR_KORP)<>'' then 
+', '
+ KPUADR_KORP else '' end
+
--квартира
case when(KPUADR_FLAT)<>'' then 
+', '
+ KPUADR_FLAT else '' end
 ,' , ','')
as adress

from kpuc1 
join kpux on KpuC1.Kpu_Rcd=kpux.Kpu_Rcd
inner join KPUWAR1 on KpuC1.Kpu_Rcd = KpuWar1.Kpu_Rcd
left join PSPR on KPUWAR1.KpuWar_CdZvn=PSPR.Spr_Cd  and PSPR.SprSpr_Cd =531
left join KpuAdr1 on KpuC1.Kpu_Rcd = KpuAdr1.Kpu_Rcd and KpuAdr1.KpuAdr_Add = 0 and KpuAdr1.KpuAdr_Cd=2

LEFT JOIN "VWSADRSTR" SPRADRSTR ON SPRADRSTR.SADRSTR_RCD =KPUADR_STR
LEFT JOIN "VWSADRCNT" SPRADRCNT ON SPRADRCNT.SADRCNT_RCD =KPUADR_CNT 
LEFT JOIN "VWSADRREG" SPRADRREG ON SPRADRREG.SADRREG_RCD =KPUADR_REG 
LEFT JOIN "VWSADRRAI" SPRADRRAI ON SPRADRRAI.SADRRAI_RCD =KPUADR_ZONE 
LEFT JOIN "VWSADRTOW" SPRADRTOW ON SPRADRTOW.SADRTOW_RCD =KPUADR_TOWN 
LEFT JOIN "VWSADRNAS" SPRADRNAS ON SPRADRNAS.SADRNAS_RCD =KPUADR_PLAC 

left join (
	  select 
		KpuC1.Kpu_Rcd,
		KpuPrk1.KpuPrkz_Dt,
		KpuPrk1.KpuPrkz_Cd
	 FROM    kpuc1
	 JOIN KPUPRK1 ON KpuPrk1.bookmark =
	  (
		SELECT max(P1.bookmark) FROM KpuPrk1 P1
		WHERE P1.Kpu_Rcd = KpuC1.Kpu_Rcd 
		AND P1.KpuPrkz_Dtv =KpuC1.Kpu_DtPst	
	  )
  ) PrkzGet on  PrkzGet.Kpu_Rcd=KPUX.Kpu_Rcd
--WHERE KpuC1.Kpu_Rcd IN (SELECT ServerMrk_Rcd FROM ServerMrk WHERE ServerMrk_Type = 150 AND ServerMrk_Sess = 131072001)
where Year(KPUC1.Kpu_DtUvl)<1900
order by adress