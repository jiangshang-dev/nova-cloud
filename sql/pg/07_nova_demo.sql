-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/07_nova_demo.sql
-- PostgreSQL 14+
-- 约定：
-- 1. 表名小写；必备 id / gmt_create / gmt_modified
-- 2. id 为 BIGINT，应用侧雪花 ID（不用 SERIAL）
-- 3. 原 TINYINT UNSIGNED → SMALLINT；BIGINT/INTEGER UNSIGNED → BIGINT/INTEGER
-- 4. DATETIME → TIMESTAMP；无 ON UPDATE（由应用更新 gmt_modified）
-- 5. 禁止外键；注释使用 COMMENT ON
-- =========================================================

-- 请先连接到 nova_cloud

-- =========================================================
-- nova-demo：分表示例（ShardingSphere 逻辑表 demo_order）
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================

DROP TABLE IF EXISTS demo_order_0 CASCADE;
CREATE TABLE demo_order_0 (
  id            BIGINT NOT NULL,
  user_id       BIGINT NOT NULL,
  order_no      VARCHAR(64)     NOT NULL,
  amount        DECIMAL(18, 2)  NOT NULL DEFAULT 0.00,
  status        SMALLINT NOT NULL DEFAULT 0,
  gmt_create    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_demo_order_0 PRIMARY KEY (id),
  CONSTRAINT uk_demo_order0_order_no UNIQUE (order_no)
);
COMMENT ON TABLE demo_order_0 IS '演示订单分表0';
COMMENT ON COLUMN demo_order_0.id IS '主键';
COMMENT ON COLUMN demo_order_0.user_id IS '用户ID（分片键）';
COMMENT ON COLUMN demo_order_0.order_no IS '订单号';
COMMENT ON COLUMN demo_order_0.amount IS '金额';
COMMENT ON COLUMN demo_order_0.status IS '状态：0待支付 1已支付 2已取消';
COMMENT ON COLUMN demo_order_0.gmt_create IS '创建时间';
COMMENT ON COLUMN demo_order_0.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_demo_order0_user_id ON demo_order_0 (user_id);

DROP TABLE IF EXISTS demo_order_1 CASCADE;
CREATE TABLE demo_order_1 (
  id            BIGINT NOT NULL,
  user_id       BIGINT NOT NULL,
  order_no      VARCHAR(64)     NOT NULL,
  amount        DECIMAL(18, 2)  NOT NULL DEFAULT 0.00,
  status        SMALLINT NOT NULL DEFAULT 0,
  gmt_create    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_demo_order_1 PRIMARY KEY (id),
  CONSTRAINT uk_demo_order1_order_no UNIQUE (order_no)
);
COMMENT ON TABLE demo_order_1 IS '演示订单分表1';
COMMENT ON COLUMN demo_order_1.id IS '主键';
COMMENT ON COLUMN demo_order_1.user_id IS '用户ID（分片键）';
COMMENT ON COLUMN demo_order_1.order_no IS '订单号';
COMMENT ON COLUMN demo_order_1.amount IS '金额';
COMMENT ON COLUMN demo_order_1.status IS '状态：0待支付 1已支付 2已取消';
COMMENT ON COLUMN demo_order_1.gmt_create IS '创建时间';
COMMENT ON COLUMN demo_order_1.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_demo_order1_user_id ON demo_order_1 (user_id);
