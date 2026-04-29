/*
业务目标：
- 从一表通柜员表映射生成 EAST5.0 柜员表 IE_001_103。
- 报送截至采集日有效的柜员数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。
- 包含实体柜员和虚拟柜员，通过"柜员类型"字段区分。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_103-柜员表]]
- [[来源-一表通系统-1.7-柜员]]
- [[数据表-IE_001_103-柜员表-EAST5.0系统]]
- [[数据表-T_1_7-柜员-一表通系统]]
- [[数据表-T_1_1-机构信息-一表通系统]]
- [[概念-系统-EAST5.0系统]]
- [[概念-系统-一表通系统]]

源表：
- T_1_7：一表通柜员表，作为柜员明细主源。
- T_1_1：一表通机构信息，补金融许可证号和银行机构名称。

目标表：
- IE_001_103：EAST5.0 柜员表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。
- I_BATCH_NO：批次号/任务流水号。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 一表通柜员表 T_1_7 的机构ID截取第12位至最后一位生成内部机构号的规则，需与业务确认是否所有机构ID均符合此编码规范。
- 柜员状态码值 01=在岗、02=离岗，'00-***'→'其他-***'，是否还有其他枚举值待补。
- 柜员权限级别码值 01=高柜、02=低柜，'00-***'→'其他-***'，是否还有其他枚举值待补。
- 采集日期字段：一表通 T_1_7.A070011 为 date 类型，EAST IE_001_103.CJRQ 为 VARCHAR(8)，格式转换已实现。
- 上岗日期字段：一表通 T_1_7.A070007 为 date 类型，EAST IE_001_103.SGRQ 为 VARCHAR(8)，格式转换已实现；虚拟柜员可填写默认日期，当前未实现默认值兜底。
- "柜员状态转为注销、无效等时，可在报送该条数据最终状态的次月不再报送"规则：当前 SQL 已实现"在岗或失效日期>=当月月初"的过滤，注销/无效是否等于离岗(02)仍待确认。

开发说明：
- 本草案按 SQL 开发规范使用直接 select + left join 风格。
- 不使用 select *；派生表只查询实际使用字段。
- 不使用 CTE；机构表用派生表中的 not exists 去重。
- 日期统一输出 YYYYMMDD 格式。
- 字符字段使用 NULLIF(TRIM(col),'') 清洗空值。
- 码值转换使用 CASE WHEN。
- 日期函数使用 GBase 8a 风格：TO_DATE / TO_CHAR。
*/

CREATE PROCEDURE `PROC_EAST_IE_001_103`(
    IN I_DATE VARCHAR(8),
    IN I_BATCH_NO VARCHAR(64)
)
BEGIN
  #声明变量
  DECLARE P_DATA_DATE      DATE;
  DECLARE P_MONTH_BEGIN    DATE;
  DECLARE P_SQLCDE         VARCHAR(200);
  DECLARE P_STATE          VARCHAR(200);
  DECLARE P_SQLMSG         VARCHAR(2000);

  #声明异常
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    GET DIAGNOSTICS CONDITION 1
        P_SQLCDE = GBASE_ERRNO,
        P_SQLMSG = MESSAGE_TEXT,
        P_STATE  = RETURNED_SQLSTATE;
    ROLLBACK;
  END;

  #变量初始化
  SET P_DATA_DATE = TO_DATE(I_DATE, 'YYYYMMDD');
  SET P_MONTH_BEGIN = TO_DATE(CONCAT(SUBSTR(I_DATE, 1, 6), '01'), 'YYYYMMDD');

  #1.清除数据
  DELETE FROM IE_001_103
   WHERE CJRQ = I_DATE;
  COMMIT;

  #2.插入数据
  INSERT INTO IE_001_103 (
      JRXKZH,
      NBJGH,
      YHJGMC,
      GYH,
      GH,
      GYLX,
      SFSTGY,
      GWBH,
      GYQXJB,
      SGRQ,
      GYZT,
      BBZ,
      CJRQ
  )
  SELECT
      # 1. 金融许可证号：来源于一表通机构信息表的金融许可证号字段
      NULLIF(TRIM(o.A010003), '') AS JRXKZH,
      # 2. 内部机构号：从一表通柜员表的机构ID字段第12位开始截取至最后一位
      SUBSTR(NULLIF(TRIM(t.A070001), ''), 12) AS NBJGH,
      # 3. 银行机构名称：来源于一表通机构信息的银行机构名称字段
      NULLIF(TRIM(o.A010005), '') AS YHJGMC,
      # 4. 柜员号：直接取自一表通柜员表的柜员号字段
      NULLIF(TRIM(t.A070002), '') AS GYH,
      # 5. 工号：直接取自一表通柜员表的工号字段
      NULLIF(TRIM(t.A070003), '') AS GH,
      # 6. 柜员类型：直接取自一表通柜员表的柜员类型字段
      NULLIF(TRIM(t.A070004), '') AS GYLX,
      # 7. 是否实体柜员：1='是'；0='否'
      CASE
          WHEN t.A070012 = '1' THEN '是'
          WHEN t.A070012 = '0' THEN '否'
          ELSE NULLIF(TRIM(t.A070012), '')
      END AS SFSTGY,
      # 8. 岗位编号：直接取自一表通柜员表的岗位编号字段
      NULLIF(TRIM(t.A070005), '') AS GWBH,
      # 9. 柜员权限级别：01=高柜；02=低柜；'00-***'替换为'其他-***'
      CASE
          WHEN t.A070006 = '01' THEN '高柜'
          WHEN t.A070006 = '02' THEN '低柜'
          WHEN t.A070006 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(t.A070006, 4))
          ELSE NULLIF(TRIM(t.A070006), '')
      END AS GYQXJB,
      # 10. 上岗日期：yyyy-mm-dd 转为 yyyymmdd；虚拟柜员可填写默认日期（当前未实现兜底）
      CASE
          WHEN t.A070007 IS NULL THEN NULL
          ELSE TO_CHAR(t.A070007, 'YYYYMMDD')
      END AS SGRQ,
      # 11. 柜员状态：01=在岗；02=离岗；'00-***'替换为'其他-***'
      CASE
          WHEN t.A070008 = '01' THEN '在岗'
          WHEN t.A070008 = '02' THEN '离岗'
          WHEN t.A070008 LIKE '00-%' THEN CONCAT('其他-', SUBSTR(t.A070008, 4))
          ELSE NULLIF(TRIM(t.A070008), '')
      END AS GYZT,
      # 12. 备注：直接取自一表通柜员表的备注字段
      NULLIF(TRIM(t.A070010), '') AS BBZ,
      # 13. 采集日期：yyyy-mm-dd 转为 yyyymmdd
      TO_CHAR(t.A070011, 'YYYYMMDD') AS CJRQ

  FROM (
      # 柜员主源：过滤在岗或失效日期>=当月月初的柜员记录
      SELECT
          t.A070001,
          t.A070002,
          t.A070003,
          t.A070004,
          t.A070005,
          t.A070006,
          t.A070007,
          t.A070008,
          t.A070009,
          t.A070010,
          t.A070011,
          t.A070012
      FROM T_1_7 t
      WHERE t.A070011 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
        AND (
              t.A070008 = '01'
           OR t.A070009 >= P_MONTH_BEGIN
        )
  ) t
  LEFT JOIN (
      # 机构信息派生表：去重取最新机构记录
      SELECT
          org.A010001,
          org.A010003,
          org.A010005
      FROM T_1_1 org
      WHERE org.A010020 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
        AND NOT EXISTS (
            SELECT 1
            FROM T_1_1 org_rank
            WHERE org_rank.A010020 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
              AND org_rank.A010001 = org.A010001
              AND (
                  org_rank.A010020 > org.A010020
                  OR (
                      org_rank.A010020 = org.A010020
                      AND org_rank.A010002 < org.A010002
                  )
              )
        )
  ) o
    ON o.A010001 = t.A070001;

  COMMIT;

END;
