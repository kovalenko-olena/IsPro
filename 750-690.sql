 select 
   KpuUdr1.KpuUdr_Rcd,              
   KpuRlo1.KpuRl_CdVo,                   
   payvo1.vo_cdchr as Vo_Cd,             
       (select top 1 KpuNch_DatN         
       from kpunch1                      
       where kpunch1.kpu_rcd=kpux.kpu_rcd
       and kpunch1.KpuNch_Cd=493         
       and kpunch1.KpuNch_DatN<='20221130' and (kpunch1.KpuNch_DatK>='20221101' or YEAR(kpunch1.KpuNch_DatK)=1900)) as DatN,  
   kpurlo1.kpu_tn,                       
   kpuc1.kpu_fio,                        
   {fn convert(kpurlo1.kpurl_sm,SQL_DECIMAL)}/({fn Power(10,2)}) as kpurl_sm, 
   kpurlo1.kpurl_datup as datup,         
   podr.sprpdr_pd,                       
   podr.sprpdr_nmfull,                   
   kpuudr1.kpuudr_cdpr as isplst,        
   kpuudr1.kpuudr_DtPr as DtPr,          
   kpuudr1.kpuudr_sm,                    
   kpuudr1.kpuudr_mt,                    
   kpuudr1.kpuudr_datn,                  
   kpuudr1.kpuudr_datk,                  
   kpuudr1.kpuudrplc_fio,                
   kpuudr1.kpuudr_adr,                   
   kpuudr1.kpuudr_ind,                   
   kpuudr1.kpuudr_rs,                    
   kpuudr1.kpuudr_ls,                    
   kpurlo1.kpurlpl_srz as ish_sm,        
   kpuudr1.kpuudrplc_typ,                
   kpuudr1.kpuudrplc_pvgr as VED,        
   ptnrk.ptn_nm as NMKAG,                
   {fn MOD({fn TRUNCATE(kpurlo1.kpurl_prz/2,0)},2)} as prz, 
   CASE WHEN KpuUdr1.KpuUdr_Rest IS NULL THEN 0 ELSE {fn convert(KpuUdr1.KpuUdr_Rest,SQL_DECIMAL)}/({fn Power(10,2)}) END AS KpuUdr_Rest,
   KpuRlo1.KpuRl_Rcd,                    
   TAX,                                  
   nar,                                  
   TAXALL,                               
   {fn convert(kpurlo1.kpurldu_sld,SQL_DECIMAL)}/({fn Power(10,2)}) as sld, 
   KpuUdr_ExecDoc as Nazva               
                                         
   from kpurlo1                          
   inner join kpux on kpurlo1.kpu_tn=kpux.kpu_tn
   inner join kpuc1 on kpux.kpu_rcd=kpuc1.kpu_rcd
 inner join kpuprk1 on kpuprk1.bookmark=
 (
 select max(p1.bookmark)
 from kpuprk1 p1
 where p1.kpu_rcd=kpuc1.kpu_rcd
 and p1.kpuprkz_dtv=
 (
 select max(p2.kpuprkz_dtv)
 from kpuprk1 p2
 where p2.kpuprkz_dtv<='20221101'
 and p2.kpu_rcd=kpuc1.kpu_rcd
 )
 )
 inner join payvo1 on kpurlo1.kpurl_cdvo=payvo1.vo_cd
 left join 
           (select sum ({fn convert(kpurl_sm,SQL_DECIMAL)})/{fn Power(10,2)} as nar, kpu_tn as tabn, kpurl_datup as datp
            from kpurlo1 
            inner join payvo1 on kpurl_cdvo=vo_cd 
            where (kpurl_datup>='20221101' and kpurl_datup<='20221130') and vo_grp<=127 and  vo_nur=0 
            and kpurl_cdvo in (select paytv_cdv from paytv where paytv_part=1 and paytv_cd=110 and paytv_nmr=33) 
            group by kpu_tn, kpurl_datup 
            ) kk
 on kpurlo1.kpu_tn=kk.tabn and kpurlo1.kpurl_datup=kk.datp 
 left join 
           (select sum ({fn convert(kpurl_sm,SQL_DECIMAL)})/{fn Power(10,2)} as taxALL, kpu_tn as tabn, kpurl_datup as datp
            from kpurlo1 
            inner join payvo1 on kpurl_cdvo=vo_cd
            where (kpurl_datup>='20221101' and kpurl_datup<='20221130') and vo_grp=128 group by kpu_tn, kpurl_datup
            ) pp
 on kpurlo1.kpu_tn=pp.tabn and kpurlo1.kpurl_datup=pp.datp 
 left join 
           (select sum ({fn convert(kpurl_sm,SQL_DECIMAL)})/{fn Power(10,2)} as TAX, kpu_tn as tabn, kpurl_datup as datp
            from kpurlo1 
            inner join payvo1 on kpurl_cdvo=vo_cd
            where (kpurl_datup>='20221101' and kpurl_datup<='20221130') and vo_grp<=127 and vo_nur=1 group by kpu_tn, kpurl_datup
            ) kkK
 on kpurlo1.kpu_tn=kkK.tabn and kpurlo1.kpurl_datup=kkK.datp 
 left join sprpdr1 podr on kpuprk1.kpuprkz_pdRcd = podr.sprpdr_Rcd and '20221130' between podr.sprpdr_datN and podr.sprpdr_datK
 left join kpuudr1 on kpuc1.kpu_rcd=kpuudr1.kpu_rcd
	and kpuudr1.kpuudr_Cd= payvo1.vo_cd 
	and kpuudr_Rcd = kpurllnk_ls 
 
 left join ptnrk on kpuudr1.kpuudr_cdplc=ptnrk.ptn_rcd
 where (payvo1.vo_met in (19,68))

 AND { fn MOD( { fn TRUNCATE( KpuRl_Prz / 65536,  0 ) }, 2 ) } = 0
 and (kpurlo1.kpurl_datup>='20221101' and  kpurlo1.kpurl_datup<='20221130')
 AND PayVo1.Vo_Cd = 110
 order by podr.sprpdr_pd, kpurlo1.kpu_tn