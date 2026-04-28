/*
校验目标：
- 校验 IE_001_101 机构信息表、IE_001_102 员工表草案装载结果。

参数：
- ${biz_date}：采集日期，格式 YYYYMMDD。
*/

-- IE_001_101 行数检查
select count(*) as ie_001_101_count
from IE_001_101
where CJRQ = ${biz_date};

-- IE_001_101 主键重复检查：采集日期 + 内部机构号
select
    CJRQ,
    NBJGH,
    count(*) as cnt
from IE_001_101
where CJRQ = ${biz_date}
group by CJRQ, NBJGH
having count(*) > 1;

-- IE_001_101 必填/核心字段为空检查
select
    sum(case when NBJGH is null or trim(NBJGH) = '' then 1 else 0 end) as null_nbjgh_count,
    sum(case when YHJGMC is null or trim(YHJGMC) = '' then 1 else 0 end) as null_yhjgmc_count,
    sum(case when CJRQ is null or trim(CJRQ) = '' then 1 else 0 end) as null_cjrq_count
from IE_001_101
where CJRQ = ${biz_date};

-- IE_001_101 代码/枚举结果检查
select JGLB, count(*) as cnt
from IE_001_101
where CJRQ = ${biz_date}
group by JGLB
order by JGLB;

select YYZT, count(*) as cnt
from IE_001_101
where CJRQ = ${biz_date}
group by YYZT
order by YYZT;

-- IE_001_102 行数检查
select count(*) as ie_001_102_count
from IE_001_102
where CJRQ = ${biz_date};

-- IE_001_102 主键重复检查：采集日期 + 工号
select
    CJRQ,
    GH,
    count(*) as cnt
from IE_001_102
where CJRQ = ${biz_date}
group by CJRQ, GH
having count(*) > 1;

-- IE_001_102 必填/核心字段为空检查
select
    sum(case when GH is null or trim(GH) = '' then 1 else 0 end) as null_gh_count,
    sum(case when XM is null or trim(XM) = '' then 1 else 0 end) as null_xm_count,
    sum(case when CJRQ is null or trim(CJRQ) = '' then 1 else 0 end) as null_cjrq_count
from IE_001_102
where CJRQ = ${biz_date};

-- IE_001_102 代码/枚举结果检查
select YGLX, count(*) as cnt
from IE_001_102
where CJRQ = ${biz_date}
group by YGLX
order by YGLX;

select YGZT, count(*) as cnt
from IE_001_102
where CJRQ = ${biz_date}
group by YGZT
order by YGZT;

select SFGG, count(*) as cnt
from IE_001_102
where CJRQ = ${biz_date}
group by SFGG
order by SFGG;
