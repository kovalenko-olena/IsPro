SELECT *
FROM KPURLO1
where Kpu_Tn = 10103 and KpuRl_DatUp = {d'2023-03-01'} and KpuRl_CdVo = 375
--(select * from payvo1 where vo_cdchr = '270'  )
/*
update KPURLO1
set KpuRl_AddMsk = 6192
where Kpu_Tn = 66159 and KpuRl_DatRp = {d'2022-11-01'} and KpuRl_AddMsk=101455920*/

select 1288486912&1365 as result
select 16777216&268435456 as result
select 10066329|268435456 as result

select 1288486912|1365

--query1 begin
select db.Kpu_Tn,	db.KpuRl_DatRp, db.KpuRl_AddMsk
from
(
select distinct KPURLO1.Kpu_Tn,	KPURLO1.KpuRl_DatRp, KPURLO1.KpuRl_AddMsk
from KPURLO1
where KpuRl_AddMsk>0 and KpuRl_CdVo <> 0  and KpuRl_Sm<>0 and KpuRl_CdVo=375
and kpu_tn=10103

union all
select distinct KPURLO1.Kpu_Tn,	KPURLO1.KpuRl_DatRp, KPURLO1.KpuRl_AddMsk
from KPURLO1
where KpuRl_AddMsk>0 and KpuRl_CdVo <> 0  and KpuRl_Sm<>0 and KpuRl_CdVo<>375
and kpu_tn=10103
) db 

where db.Kpu_Tn in
(select kpu_tn from
(select r.Kpu_Tn
from KPURLO1 r
where r.KpuRl_AddMsk>0 and r.KpuRl_CdVo <> 0  and r.KpuRl_Sm<>0
and r.Kpu_Tn=db.Kpu_Tn and r.KpuRl_DatRp=db.KpuRl_DatRp
group by r.KpuRl_AddMsk,  r.KpuRl_DatRp, r.Kpu_Tn) f
group by f.Kpu_tn
having count(f.Kpu_tn)>1)
order by db.KpuRl_DatRp, db.Kpu_Tn, db.KpuRl_AddMsk

--query1 end


select Kpu_tn from
(
select r.Kpu_tn
from KPURLO1 r
where r.KpuRl_AddMsk>0 and r.KpuRl_CdVo <> 0  and r.KpuRl_Sm<>0
and r.Kpu_Tn=10103 and r.KpuRl_DatRp= {d'2023-03-01'} 
group by r.KpuRl_AddMsk,  r.KpuRl_DatRp, r.Kpu_tn) f 
group by f.Kpu_tn
having count(f.Kpu_tn)>1


--BigIntToBin
DECLARE @input BIGINT = :rcd;
WITH N(N)AS 
(
  SELECT top 63
    POWER(cast(2 as bigint),
      ROW_NUMBER()over(ORDER BY (SELECT 1))-1)
  FROM
    (VALUES(1),(1),(1),(1))M(a),
    (VALUES(1),(1),(1),(1))L(a),
    (VALUES(1),(1),(1),(1))K(a)
)
SELECT
  COALESCE
  (
    REVERSE
    (
      ( 
        SELECT CAST(@input/N%2 as CHAR(1))
        FROM N 
        WHERE N <= @input
        for xml path(''), type 
      ).value('.', 'varchar(max)')
    )
    , '0'
  )  as result


  --BitToBigInt
DECLARE @input varchar(max) = :rcd  ;
WITH N(V) AS 
(
  SELECT
    ROW_NUMBER()over(ORDER BY (SELECT 1))
  FROM
    (VALUES(1),(1),(1),(1))M(a),
    (VALUES(1),(1),(1),(1))L(a),
    (VALUES(1),(1),(1),(1))K(a)
)
SELECT SUM(SUBSTRING(REVERSE(@input),V,1)*POWER(CAST(2 as BIGINT), V-1)) as result
FROM   N
WHERE  V <= LEN(@input)