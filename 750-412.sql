select 
   Kpu_Tn, 
   kpuc1.Kpu_Fio,  
   payvo1.Vo_CdChr as Vo_Cd, 
   (select top 1 KpuNch_DatN         
       from kpunch1                      
       where kpunch1.Kpu_Rcd=kpux.Kpu_Rcd
       and kpunch1.KpuNch_Cd=493         
       and kpunch1.KpuNch_DatN<='20221130' and (kpunch1.KpuNch_DatK>='20221101' or YEAR(kpunch1.KpuNch_DatK)=1900)) as DatN,  
   0 as KPURL_SM,
   CASE WHEN KpuUdr1.KpuUdr_Rest IS NULL THEN 0 ELSE {fn convert(KpuUdr1.KpuUdr_Rest,SQL_DECIMAL)}/({fn Power(10,2)}) END AS KpuUdr_Rest,
   ptnrk.Ptn_Nm as NMKAG, 
   kpuudr1.KpuUdrPlc_PvGr as VED,  
   podr.SprPdr_Pd, 
   podr.SprPdr_NmFull,
   kpuudr1.KpuUdr_CdPr as isplst,   
   kpuudr1.KpuUdr_DtPr as DtPr,    
   kpuudr1.KpuUdr_Sm,                    
   kpuudr1.KpuUdr_MT,                    
   kpuudr1.KpuUdr_DatN,                  
   kpuudr1.KpuUdr_DatK,                  
   kpuudr1.KpuUdrPlc_Fio,                
   kpuudr1.KpuUdr_Adr,                   
   kpuudr1.KpuUdr_Ind,                   
   kpuudr1.KpuUdr_RS,                    
   kpuudr1.KpuUdr_LS,                    
   0 as ish_sm,
   0 as KpuRl_CdVo, 
   KpuUdr1.KpuUdr_Rcd, 
   kpuudr1.KpuUdrPlc_Typ,                
   kpuudr1.KpuUdrPlc_PvGr as VED,        
   0 as PRZ,
   0 as KpuRl_Rcd,
   getdate() as datup,
   0 as TAX,
   0 as nar,
   0 as TAXALL,
   0 as sld,
   KpuUdr_ExecDoc as Nazva 

from kpuudr1
left join kpux on kpuudr1.Kpu_Rcd=kpux.Kpu_Rcd
left join kpuc1 on kpux.Kpu_Rcd=kpuc1.Kpu_Rcd
left join payvo1 on kpuudr1.KpuUdr_Cd=payvo1.Vo_Cd
left join ptnrk on kpuudr1.KpuUdr_CdPlc=ptnrk.Ptn_Rcd
inner join kpuprk1 on kpuprk1.bookmark=
 (
 select max(p1.bookmark)
 from kpuprk1 p1
 where p1.Kpu_Rcd=kpuc1.Kpu_Rcd
 and p1.KpuPrkz_DtV=
 (
 select max(p2.KpuPrkz_DtV)
 from kpuprk1 p2
 where p2.KpuPrkz_DtV<='20221101'
 and p2.Kpu_Rcd=kpuc1.Kpu_Rcd
 )
 )
left join sprpdr1 podr on kpuprk1.KpuPrkz_PdRcd = podr.SprPdr_Rcd and '20221130' between podr.SprPdr_DatN and podr.SprPdr_DatK
where KpuUdr_Cd=110
and KpuUdr_DatK>='20221101'
and Kpu_Tn in 
(select distinct r1.kpu_tn
				from KPURLO1 r1
				inner join kpux x on r1.Kpu_Tn=x.Kpu_Tn
				inner join payvo1 vo on r1.KpuRl_CdVo=vo.Vo_Cd
				where  (r1.KpuRl_DatUp>='20221101' and  r1.KpuRl_DatUp<='20221130')
				and vo.Vo_Cd=493)
-- учитываем только тех, у кого нет в kpurlo1 реального 609 удержания
and kpuudr1.Kpu_Rcd not in (
				select x.Kpu_Rcd 
				from KPURLO1 r1
				inner join kpux x on r1.Kpu_Tn=x.Kpu_Tn
				inner join payvo1 vo on r1.KpuRl_CdVo=vo.Vo_Cd
				where  (r1.KpuRl_DatUp>='20221101' and  r1.KpuRl_DatUp<='20221130')
				and vo.Vo_Cd=110
				)
order by kpux.Kpu_Tn

--select * from PAYVO1 where Vo_CdChr='412' or Vo_CdChr='609'