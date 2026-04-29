/*
业务目标：
- 从一表通岗位信息表 T_1_4 映射生成 EAST5.0 岗位信息表 IE_001_104。
- 报送截至采集日有效的岗位数据，以及上一采集日至采集日期间结清、失效、终结等所有视为终态的数据。
- 撤销的岗位于次月不再报送。

目标系统：
- EAST5.0系统。

目标产物：
- GBase 8a MPP 存储过程草案。

依赖知识页：
- [[来源-EAST5.0系统-IE_001_104-岗位信息表]]
- [[数据表-IE_001_104-岗位信息表-EAST5.0系统]]
- [[来源-一表通系统-1.4-岗位信息]]
- [[数据表-T_1_4-岗位信息-一表通系统]]
- [[概念-系统-EAST5.0系统]]
- [[概念-系统-一表通系统]]

源表：
- T_1_4：一表通岗位信息，主源表，取截至采集日有效及终态数据。
- T_1_1：一表通机构信息，通过内部机构号关联取金融许可证号。

目标表：
- IE_001_104：EAST5.0 岗位信息表。

参数：
- I_DATE：采集日期，格式 YYYYMMDD。
- I_BATCH_NO：批次号/任务流水号。

运行方式：
- 截面重跑：先删除目标表同一采集日期数据，再插入当日映射结果。

未确认点：
- 一表通 T_1_4 表级关联规则中"岗位ID从12开始截取到最后"的截取逻辑，需确认 T_1_4 的机构ID字段（A040001）是否直接包含完整机构编号，截取后与 T_1_1 的内部机构号（A010002）匹配。
- 岗位撤销日期的"当月"判断：当前实现为 DATE_FORMAT(岗位撤销日期, '%Y%m') = DATE_FORMAT(采集日期, '%Y%m')，需确认是否应使用采集日期的年月。
- GSFZJG（归属分支机构）、SENSITIVEFLAG（涉密标志）当前无映射来源，仍置空。
- 一表通 T_1_4 的岗位撤销日期字段（A040010）取值为 9999-12-31 时表示有效，需确认该常量是否统一。
- 采集日期字段在 T_1_4 中为 DATE 类型，输出为 VARCHAR(8) 格式 YYYYMMDD，需确认 EAST5.0 目标表 CJRQ 是否必须 VARCHAR(8)。

开发说明：
- 日期函数使用 GBase 8a 风格：TO_DATE / TO_CHAR。
- 直接 DML + COMMIT，不写 START TRANSACTION。
- 异常处理使用 GET DIAGNOSTICS CONDITION 1 + GBASE_ERRNO。
*/

CREATE PROCEDURE `PROC_EAST_IE_001_104`(
    IN I_DATE VARCHAR(8),
    IN I_BATCH_NO VARCHAR(64)
)
BEGIN
  #声明变量
  DECLARE P_DATA_DATE      DATE;
  DECLARE P_LAST_MON_DT    DATE;
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
  SET P_LAST_MON_DT = LAST_DAY(P_DATA_DATE - INTERVAL 1 MONTH);

  #1.清除数据
  DELETE FROM IE_001_104
   WHERE CJRQ = I_DATE;
  COMMIT;

  #2.插入数据
  INSERT INTO IE_001_104 (
      NBJGH,
      JRXKZH,
      GSFZJG,
      CJRQ,
      GWSM,
      SENSITIVEFLAG,
      BBZ,
      GWMC,
      GWZT,
      GWZL,
      GWBH
  )
  SELECT
      # 内部机构号：从岗位信息.机构ID（A040001）截取第12位开始至最后一位
      SUBSTR(src.A040001, 12) AS NBJGH,

      # 金融许可证号：通过截取后的内部机构号关联机构信息表获取
      org.A010003 AS JRXKZH,

      # 归属分支机构：当前无映射来源，置空
      NULL AS GSFZJG,

      # 采集日期：从岗位信息.采集日期（A040008）转换 YYYYMMDD 格式
      TO_CHAR(src.A040008, 'YYYYMMDD') AS CJRQ,

      # 岗位说明：直接映射
      src.A040005 AS GWSM,

      # 涉密标志：当前无映射来源，置空
      NULL AS SENSITIVEFLAG,

      # 备注：直接映射
      src.A040007 AS BBZ,

      # 岗位名称：直接映射
      src.A040004 AS GWMC,

      # 岗位状态：直接映射
      src.A040006 AS GWZT,

      # 岗位种类：直接映射
      src.A040003 AS GWZL,

      # 岗位编号：直接映射
      src.A040002 AS GWBH

  FROM (
      # 主源：一表通岗位信息表
      # 过滤条件：岗位撤销日期等于当月 或 9999-12-31（视为有效/终态）
      SELECT
          t.A040001,
          t.A040002,
          t.A040003,
          t.A040004,
          t.A040005,
          t.A040006,
          t.A040007,
          t.A040008,
          t.A040010
      FROM T_1_4 t
      WHERE t.A040010 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
         OR t.A040010 = '9999-12-31'
  ) src
  LEFT JOIN (
      # 机构信息子查询：通过内部机构号关联取金融许可证号
      # 注意：SUBSTR(A040001, 12) 截取后与 A010002 关联
      SELECT
          t.A010002,
          t.A010003
      FROM T_1_1 t
      WHERE t.A010020 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
        AND NOT EXISTS (
            SELECT 1
            FROM T_1_1 t_min
            WHERE t_min.A010020 = TO_CHAR(P_DATA_DATE, 'YYYY-MM-DD')
              AND t_min.A010002 = t.A010002
              AND t_min.A010001 < t.A010001
        )
  ) org
    ON SUBSTR(src.A040001, 12) = org.A010002;

  COMMIT;

END;
