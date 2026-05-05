# EAST5.0 GBase 存储过程草案质量审计（2026-05-04）

> 结论：上一轮自动生成的多数存储过程不能作为可执行草案评审，必须逐表按业务需求重写 JOIN、WHERE 和 CASE。

- 审计过程数：62
- 仍含 `ON 1 = 1` 的过程：43
- 仍缺表级过滤的过程：43
- 已先行修复 JOIN/WHERE 的样例：`PROC_EAST_IE_003_301_JJKXXB_草案.sql`、`PROC_EAST_IE_003_302_CZXXB_草案.sql`、`PROC_EAST_IE_003_303_SDSHXXB_草案.sql`

| 目标表 | 代码 | 文件 | 状态 | JOIN TODO | WHERE TODO | 字段/转换待确认 | NULL赋值 | 主要问题 |
| --- | --- | --- | --- | ---: | ---: | ---: | ---: | --- |
| `IE_001_101` | `JGXXB` | `PROC_EAST_IE_001_101_JGXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值 |
| `IE_001_102` | `YSB` | `PROC_EAST_IE_001_102_YSB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值 |
| `IE_001_103` | `GYB` | `PROC_EAST_IE_001_103_GYB_草案.sql` | 需人工复核 | 0 | 0 | 0 | 0 | 未发现自动扫描项 |
| `IE_001_104` | `GXAXB` | `PROC_EAST_IE_001_104_GXAXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值 |
| `IE_001_105` | `JGGXB` | `PROC_EAST_IE_001_105_JGGXB_草案.sql` | 需人工复核 | 0 | 0 | 0 | 0 | 未发现自动扫描项 |
| `IE_001_106` | `GDHLFBXXB` | `PROC_EAST_IE_001_106_GDHLFBXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 1 | 1 个 NULL 赋值 |
| `IE_002_201` | `GRJCBXXB` | `PROC_EAST_IE_002_201_GRJCBXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值 |
| `IE_002_202` | `GRRKXB` | `PROC_EAST_IE_002_202_GRRKXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 3 | 3 个 NULL 赋值 |
| `IE_002_203` | `DGKHXXB` | `PROC_EAST_IE_002_203_DGKHXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 53 | 53 个 NULL 赋值 |
| `IE_002_204` | `DGKHCWXXB` | `PROC_EAST_IE_002_204_DGKHCWXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值 |
| `IE_002_205` | `JTKHB` | `PROC_EAST_IE_002_205_JTKHB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值 |
| `IE_002_206` | `GLGXB` | `PROC_EAST_IE_002_206_GLGXB_草案.sql` | 需人工复核 | 0 | 0 | 0 | 0 | 未发现自动扫描项 |
| `IE_003_301` | `JJKXXB` | `PROC_EAST_IE_003_301_JJKXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 3 | 3 | 3 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_003_302` | `CZXXB` | `PROC_EAST_IE_003_302_CZXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 3 | 3 | 3 个业务需求未给来源字段保留 NULL；机构ID/内部机构号口径待现场确认 |
| `IE_003_303` | `SDSHXXB` | `PROC_EAST_IE_003_303_SDSHXXB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 3 | 3 | 3 个业务需求未给来源字段保留 NULL；公共代码关联口径待现场确认 |
| `IE_004_401` | `ZZKJQKMB` | `PROC_EAST_IE_004_401_ZZKJQKMB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 2 | 2 | 2 个业务需求未给来源字段保留 NULL；统计当月过滤按采集日期等于跑批日实现，需现场确认 |
| `IE_004_402` | `NBKMDZB` | `PROC_EAST_IE_004_402_NBKMDZB_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 3 | 2 | 2 个业务需求未给来源字段保留 NULL；归属业务子类公共参数来源待确认 |
| `IE_004_403` | `GRCKFHZ` | `PROC_EAST_IE_004_403_GRCKFHZ_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 3 | 3 | 3 个业务需求未给来源字段保留 NULL；销户状态码值需现场确认 |
| `IE_004_404_INC` | `GRCKFHZMX` | `PROC_EAST_IE_004_404_INC_GRCKFHZMX_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 4 | 4 | 4 个业务需求未给来源字段保留 NULL；查询交易排除码值和增量边界待确认 |
| `IE_004_405` | `DGCKFHZ` | `PROC_EAST_IE_004_405_DGCKFHZ_草案.sql` | 不合格 | 5 | 1 | 6 | 3 | 5 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_004_406_INC` | `DGCKFHZMX` | `PROC_EAST_IE_004_406_INC_DGCKFHZMX_草案.sql` | 不合格 | 1 | 1 | 12 | 7 | 1 个 JOIN 未实现；过滤条件未实现；12 个字段/转换待确认；7 个 NULL 赋值 |
| | | | | | | | | | **2026-05-05 重新校准**：33 个业务需求字段全部映射正确，4 个"待确认"源字段已通过 JOIN 表确认可追溯；3 个 NULL 赋值（SENSITIVEFLAG、GSFZJG、DFKHLB）为 DDL 存在但业务需求未给来源的字段，符合处置原则。审计计数（12/7）存在高估。
| `IE_004_407` | `NBFHZ` | `PROC_EAST_IE_004_407_NBFHZ_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 2 | 2 个 NULL 赋值（GSFZJG、SENSITIVEFLAG），符合审计处置原则；其余字段/转换已补齐 |
| `IE_004_408_INC` | `NBFHZMX` | `PROC_EAST_IE_004_408_INC_NBFHZMX_草案.sql` | 已消除JOIN/WHERE阻塞，仍需复核 | 0 | 0 | 0 | 3 | 3 个 NULL 赋值（GSFZJG、SENSITIVEFLAG、DFKHLB），符合审计处置原则；其余字段/转换已补齐 |
| | | | | | | | | **2026-05-05 重新校准**：依据《023_内部分户账明细记录.md》逐项校准 32 个字段映射；3 个 LEFT JOIN 已实现（IE_004_407 + IE_004_402×2）；5 个码值 CASE 已补齐（JYLX 15 分支/JYQD 8 分支+通配/JYJDBZ 4 分支/CBMBZ 2 分支/XZBZ 3 分支）；3 个 NULL 赋值（GSFZJG、SENSITIVEFLAG、DFKHLB）为 DDL 存在但业务需求未给来源的字段，符合处置原则；WHERE 过滤 `G100028 = V_DATA_DATE`；柜员号 `'自动'`→NULL 处理。
| `IE_004_409` | `GRXDFHZ` | `PROC_EAST_IE_004_409_GRXDFHZ_草案.sql` | 不合格 | 5 | 1 | 5 | 3 | 5 个 JOIN 未实现；过滤条件未实现；5 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_004_410_INC` | `GRXDFHZMX` | `PROC_EAST_IE_004_410_INC_GRXDFHZMX_草案.sql` | 不合格 | 2 | 1 | 13 | 7 | 2 个 JOIN 未实现；过滤条件未实现；13 个字段/转换待确认；7 个 NULL 赋值 |
| `IE_004_411` | `DGXDFHZ` | `PROC_EAST_IE_004_411_DGXDFHZ_草案.sql` | 不合格 | 5 | 1 | 5 | 3 | 5 个 JOIN 未实现；过滤条件未实现；5 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_004_412_INC` | `DGXDFHZMX` | `PROC_EAST_IE_004_412_INC_DGXDFHZMX_草案.sql` | 不合格 | 2 | 1 | 10 | 4 | 2 个 JOIN 未实现；过滤条件未实现；10 个字段/转换待确认；4 个 NULL 赋值 |
| `IE_005_501` | `XDHTB` | `PROC_EAST_IE_005_501_XDHTB_草案.sql` | 不合格 | 2 | 1 | 6 | 4 | 2 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；4 个 NULL 赋值 |
| `IE_005_502` | `HLWDKHTFJB` | `PROC_EAST_IE_005_502_HLWDKHTFJB_草案.sql` | 不合格 | 3 | 1 | 3 | 2 | 3 个 JOIN 未实现；过滤条件未实现；3 个字段/转换待确认；2 个 NULL 赋值 |
| `IE_005_503` | `GRXDYWJJB` | `PROC_EAST_IE_005_503_GRXDYWJJB_草案.sql` | 不合格 | 9 | 1 | 19 | 10 | 9 个 JOIN 未实现；过滤条件未实现；19 个字段/转换待确认；10 个 NULL 赋值 |
| `IE_005_504` | `DGXDYWJJB` | `PROC_EAST_IE_005_504_DGXDYWJJB_草案.sql` | 不合格 | 10 | 1 | 15 | 8 | 10 个 JOIN 未实现；过滤条件未实现；15 个字段/转换待确认；8 个 NULL 赋值 |
| `IE_005_505_INC` | `STZFXXB` | `PROC_EAST_IE_005_505_INC_STZFXXB_草案.sql` | 不合格 | 3 | 1 | 3 | 3 | 3 个 JOIN 未实现；过滤条件未实现；3 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_005_506` | `XMDKXXB` | `PROC_EAST_IE_005_506_XMDKXXB_草案.sql` | 不合格 | 3 | 1 | 9 | 9 | 3 个 JOIN 未实现；过滤条件未实现；9 个字段/转换待确认；9 个 NULL 赋值 |
| `IE_005_507` | `YTDKXXB` | `PROC_EAST_IE_005_507_YTDKXXB_草案.sql` | 不合格 | 1 | 1 | 15 | 14 | 1 个 JOIN 未实现；过滤条件未实现；15 个字段/转换待确认；14 个 NULL 赋值 |
| `IE_005_508` | `PJTXB` | `PROC_EAST_IE_005_508_PJTXB_草案.sql` | 不合格 | 2 | 1 | 4 | 2 | 2 个 JOIN 未实现；过滤条件未实现；4 个字段/转换待确认；2 个 NULL 赋值 |
| `IE_005_509` | `PJZTXB` | `PROC_EAST_IE_005_509_PJZTXB_草案.sql` | 不合格 | 2 | 1 | 6 | 3 | 2 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_005_510` | `MYRZYWB` | `PROC_EAST_IE_005_510_MYRZYWB_草案.sql` | 不合格 | 1 | 1 | 7 | 6 | 1 个 JOIN 未实现；过滤条件未实现；7 个字段/转换待确认；6 个 NULL 赋值 |
| `IE_005_511` | `RZZLYWB` | `PROC_EAST_IE_005_511_RZZLYWB_草案.sql` | 不合格 | 3 | 1 | 8 | 7 | 3 个 JOIN 未实现；过滤条件未实现；8 个字段/转换待确认；7 个 NULL 赋值 |
| `IE_005_512` | `DKDJB` | `PROC_EAST_IE_005_512_DKDJB_草案.sql` | 不合格 | 2 | 1 | 6 | 4 | 2 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；4 个 NULL 赋值 |
| `IE_005_513` | `HLWDKHZXYB` | `PROC_EAST_IE_005_513_HLWDKHZXYB_草案.sql` | 不合格 | 2 | 1 | 6 | 2 | 2 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；2 个 NULL 赋值 |
| `IE_006_601` | `BNWYWDBHTB` | `PROC_EAST_IE_006_601_BNWYWDBHTB_草案.sql` | 不合格 | 2 | 1 | 7 | 3 | 2 个 JOIN 未实现；过滤条件未实现；7 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_006_602` | `BNWYWDBR` | `PROC_EAST_IE_006_602_BNWYWDBR_草案.sql` | 不合格 | 3 | 1 | 5 | 4 | 3 个 JOIN 未实现；过滤条件未实现；5 个字段/转换待确认；4 个 NULL 赋值 |
| `IE_006_603` | `BNWYWDZYW` | `PROC_EAST_IE_006_603_BNWYWDZYW_草案.sql` | 不合格 | 3 | 1 | 7 | 5 | 3 个 JOIN 未实现；过滤条件未实现；7 个字段/转换待确认；5 个 NULL 赋值 |
| `IE_007_701` | `SXXXB` | `PROC_EAST_IE_007_701_SXXXB_草案.sql` | 不合格 | 2 | 1 | 9 | 6 | 2 个 JOIN 未实现；过滤条件未实现；9 个字段/转换待确认；6 个 NULL 赋值 |
| `IE_007_702` | `ZCHXB` | `PROC_EAST_IE_007_702_ZCHXB_草案.sql` | 不合格 | 1 | 1 | 23 | 23 | 1 个 JOIN 未实现；过滤条件未实现；23 个字段/转换待确认；23 个 NULL 赋值 |
| `IE_007_703` | `XDZCZRB` | `PROC_EAST_IE_007_703_XDZCZRB_草案.sql` | 不合格 | 3 | 1 | 4 | 4 | 3 个 JOIN 未实现；过滤条件未实现；4 个字段/转换待确认；4 个 NULL 赋值 |
| `IE_007_704` | `ZCZRGXB` | `PROC_EAST_IE_007_704_ZCZRGXB_草案.sql` | 不合格 | 2 | 1 | 6 | 5 | 2 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；5 个 NULL 赋值 |
| `IE_007_705_INC` | `DKWJXTBDB` | `PROC_EAST_IE_007_705_INC_DKWJXTBDB_草案.sql` | 不合格 | 1 | 1 | 18 | 18 | 1 个 JOIN 未实现；过滤条件未实现；18 个字段/转换待确认；18 个 NULL 赋值 |
| `IE_008_801` | `XYKXXB` | `PROC_EAST_IE_008_801_XYKXXB_草案.sql` | 不合格 | 4 | 1 | 7 | 7 | 4 个 JOIN 未实现；过滤条件未实现；7 个字段/转换待确认；7 个 NULL 赋值 |
| `IE_008_802_INC` | `XYKJYMXB` | `PROC_EAST_IE_008_802_INC_XYKJYMXB_草案.sql` | 不合格 | 3 | 1 | 9 | 9 | 3 个 JOIN 未实现；过滤条件未实现；9 个字段/转换待确认；9 个 NULL 赋值 |
| `IE_008_803` | `XYKSXQKB` | `PROC_EAST_IE_008_803_XYKSXQKB_草案.sql` | 不合格 | 3 | 1 | 14 | 12 | 3 个 JOIN 未实现；过滤条件未实现；14 个字段/转换待确认；12 个 NULL 赋值 |
| `IE_008_804_INC` | `XYKFQYWB` | `PROC_EAST_IE_008_804_INC_XYKFQYWB_草案.sql` | 不合格 | 3 | 1 | 8 | 8 | 3 个 JOIN 未实现；过滤条件未实现；8 个字段/转换待确认；8 个 NULL 赋值 |
| `IE_009_901` | `PJCPXXB` | `PROC_EAST_IE_009_901_PJCPXXB_草案.sql` | 不合格 | 2 | 1 | 8 | 4 | 2 个 JOIN 未实现；过滤条件未实现；8 个字段/转换待确认；4 个 NULL 赋值 |
| `IE_009_902` | `BHYXYZB` | `PROC_EAST_IE_009_902_BHYXYZB_草案.sql` | 不合格 | 3 | 1 | 35 | 35 | 3 个 JOIN 未实现；过滤条件未实现；35 个字段/转换待确认；35 个 NULL 赋值 |
| `IE_009_903_INC` | `JYBJXXB` | `PROC_EAST_IE_009_903_INC_JYBJXXB_草案.sql` | 不合格 | 5 | 1 | 6 | 5 | 5 个 JOIN 未实现；过滤条件未实现；6 个字段/转换待确认；5 个 NULL 赋值 |
| `IE_009_904` | `WTDKXXB` | `PROC_EAST_IE_009_904_WTDKXXB_草案.sql` | 不合格 | 6 | 1 | 9 | 6 | 6 个 JOIN 未实现；过滤条件未实现；9 个字段/转换待确认；6 个 NULL 赋值 |
| `IE_009_905_INC` | `DLDXJYXXB` | `PROC_EAST_IE_009_905_INC_DLDXJYXXB_草案.sql` | 不合格 | 3 | 1 | 12 | 8 | 3 个 JOIN 未实现；过滤条件未实现；12 个字段/转换待确认；8 个 NULL 赋值 |
| `IE_010_1001_INC` | `HLXXB` | `PROC_EAST_IE_010_1001_INC_HLXXB_草案.sql` | 不合格 | 2 | 1 | 3 | 3 | 2 个 JOIN 未实现；过滤条件未实现；3 个字段/转换待确认；3 个 NULL 赋值 |
| `IE_010_1002` | `JRGJXXB` | `PROC_EAST_IE_010_1002_JRGJXXB_草案.sql` | 不合格 | 3 | 1 | 8 | 8 | 3 个 JOIN 未实现；过滤条件未实现；8 个字段/转换待确认；8 个 NULL 赋值 |
| `IE_010_1003_INC` | `ZYZJJYXXB` | `PROC_EAST_IE_010_1003_INC_ZYZJJYXXB_草案.sql` | 不合格 | 1 | 1 | 35 | 35 | 1 个 JOIN 未实现；过滤条件未实现；35 个字段/转换待确认；35 个 NULL 赋值 |
| `IE_010_1004` | `ZYZJYWYEB` | `PROC_EAST_IE_010_1004_ZYZJYWYEB_草案.sql` | 不合格 | 1 | 1 | 27 | 27 | 1 个 JOIN 未实现；过滤条件未实现；27 个字段/转换待确认；27 个 NULL 赋值 |
| `IE_010_1005_INC` | `JQJYSPJYXXB` | `PROC_EAST_IE_010_1005_INC_JQJYSPJYXXB_草案.sql` | 不合格 | 2 | 1 | 10 | 3 | 2 个 JOIN 未实现；过滤条件未实现；10 个字段/转换待确认；3 个 NULL 赋值 |

## 处置原则

- 含 `ON 1 = 1` 的过程一律不得投产，也不应作为可运行草案。
- 含 `WHERE 1 = 1 /* TODO */` 的过程视为表级过滤未实现。
- “转换规则需人工补齐 CASE 分支”的字段必须改成明确 CASE 后，才算字段口径落地。
- `NULL AS` 只允许用于业务需求和 DDL 均确认无来源且允许空的字段；否则应列为阻塞缺口。

## 本次先行修复

- `PROC_EAST_IE_003_301_JJKXXB_草案.sql` 已按用户指出的表级规则修复 JOIN 与 WHERE，并补客户主数据、卡产品、机构信息关联。
- `PROC_EAST_IE_003_302_CZXXB_草案.sql` 已按 `014_存折信息表.md` 重写介质协议、机构信息、个人/对公客户信息关联和介质有效/注销过滤。
- `PROC_EAST_IE_003_303_SDSHXXB_草案.sql` 已按 `015_收单商户信息表.md` 重写机构信息、公共代码行政区划关联和商户/终端有效期过滤。
- `PROC_EAST_IE_004_401_ZZKJQKMB_草案.sql` 已按 `016_总账会计全科目表.md` 重写机构信息、科目信息关联和币种/采集日期过滤。
- `PROC_EAST_IE_004_402_NBKMDZB_草案.sql` 已按 `017_内部科目对照表.md` 重写机构信息、科目信息自关联和采集日期过滤。
- `PROC_EAST_IE_004_403_GRCKFHZ_草案.sql` 已按 `018_个人存款分户账.md` 重写存款协议、分户账信息、存款状态、机构信息、科目信息关联和个人分户账/销户过滤。
- `PROC_EAST_IE_004_404_INC_GRCKFHZMX_草案.sql` 已按 `019_个人存款分户账明细记录.md` 重写客户存款账户交易与 EAST 个人存款分户账、机构信息、内部科目、个人基础信息关联和采集日期过滤。
