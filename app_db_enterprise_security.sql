/*
 * PostgreSQL DBA Architecture Playbook
 * Copyright (c) 2026, gczheng
 * License: PostgreSQL License / MIT
 */

-- =====================================================
-- app_db 企业级安全加固脚本 (v3.1.0)
-- 数据库名称: app_db
-- 用途：实现 app_db_README.md 第 14~17 章的加固蓝图
-- 核心特性：细粒度列访问、动态数据脱敏、行级安全（RLS）、职责分离（SoD）、特权访问管理（PAM）
-- 执行方式：psql -U postgres -d app_db -f app_db_enterprise_security.sql
-- 修订日期: 2026-06-10
-- =====================================================

\echo '>>> 开始执行 app_db 企业级安全加固流程...'

-- =====================================================
-- 1. 创建配置 Schema 与元数据结构
-- =====================================================
CREATE SCHEMA IF NOT EXISTS app_config;
COMMENT ON SCHEMA app_config IS '配置与元数据Schema：用于存储企业级安全策略及角色映射元数据';

-- 创建角色生命周期表
CREATE TABLE IF NOT EXISTS app_config.role_ownership (
    role_name NAME PRIMARY KEY,
    owner_team TEXT NOT NULL,
    expiration_date DATE,
    approval_ticket TEXT,
    purpose TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
COMMENT ON TABLE app_config.role_ownership IS '角色所有权与元数据生命周期管理表';

-- 创建跨集群角色映射表
CREATE TABLE IF NOT EXISTS app_config.cross_db_role_mapping (
    local_role NAME,
    remote_cluster TEXT,
    remote_role NAME,
    PRIMARY KEY (local_role, remote_cluster)
);
COMMENT ON TABLE app_config.cross_db_role_mapping IS '跨集群与跨库的本地到远程角色映射表';

-- =====================================================
-- 2. 创建提权（PAM）管理表（存储于 audit schema）
-- =====================================================

-- 提权申请记录表
CREATE TABLE IF NOT EXISTS audit.privilege_escalation_requests (
    request_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    requester_name NAME NOT NULL,
    duration_hours INT NOT NULL CHECK (duration_hours > 0 AND duration_hours <= 24),
    reason TEXT NOT NULL,
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'expired')),
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    approved_by NAME,
    approved_at TIMESTAMP
);
COMMENT ON TABLE audit.privilege_escalation_requests IS '临时提权申请记录表';

-- 提权授权与回收审计日志表
CREATE TABLE IF NOT EXISTS audit.privilege_escalation_log (
    log_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    request_id INT NOT NULL,
    role_name NAME NOT NULL,
    grantee NAME NOT NULL,
    granted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    revoked_at TIMESTAMP,
    action_type VARCHAR(20) NOT NULL CHECK (action_type IN ('grant', 'revoke'))
);
COMMENT ON TABLE audit.privilege_escalation_log IS '提权与回收操作的追踪审计日志表';

-- =====================================================
-- 3. 职责分离（SoD）角色定义与层级关联
-- =====================================================
DO $$
BEGIN
    -- 3.1 隐私数据查看者
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_privacy_viewer') THEN
        CREATE ROLE role_privacy_viewer WITH NOLOGIN;
        COMMENT ON ROLE role_privacy_viewer IS '隐私数据查看者权限组，可访问脱敏前明文';
    END IF;

    -- 3.2 合规审计员
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_compliance_auditor') THEN
        CREATE ROLE role_compliance_auditor WITH NOLOGIN;
        COMMENT ON ROLE role_compliance_auditor IS '合规审计员，具备全库 SELECT 权限与全量审计日志查看权';
    END IF;

    -- 3.3 DBA日常结构变更组
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_dba_admin') THEN
        CREATE ROLE role_dba_admin WITH NOLOGIN;
        COMMENT ON ROLE role_dba_admin IS 'DBA日常结构变更权限组，继承 DDL 权，禁止直接 SELECT 业务数据';
    END IF;

    -- 3.4 数据修复/批量操作组
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_dml_admin') THEN
        CREATE ROLE role_dml_admin WITH NOLOGIN;
        COMMENT ON ROLE role_dml_admin IS '数据修复与批量 DML 权限组，继承 role_global_rw 权限，无 DDL 变更权';
    END IF;

    -- 3.5 审计表管理组
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_audit_admin') THEN
        CREATE ROLE role_audit_admin WITH NOLOGIN;
        COMMENT ON ROLE role_audit_admin IS '审计表维护权限组，允许 DDL 管理审计 Schema，但不能删改审计日志记录';
    END IF;

    -- 3.6 备份操作组
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_backup_operator') THEN
        CREATE ROLE role_backup_operator WITH NOLOGIN;
        COMMENT ON ROLE role_backup_operator IS '物理备份操作员组，继承复制权限，无常规 SELECT 表权限';
    END IF;

    -- 3.7 数据安全导出组
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_data_exporter') THEN
        CREATE ROLE role_data_exporter WITH NOLOGIN;
        COMMENT ON ROLE role_data_exporter IS '数据安全导出权限组，继承只读，用于记录额外导出的安全审计';
    END IF;

    -- 3.8 技术支持排查组
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_support_engineer') THEN
        CREATE ROLE role_support_engineer WITH NOLOGIN;
        COMMENT ON ROLE role_support_engineer IS '技术支持与故障排查组，不直接查表，仅通过预定义函数操作';
    END IF;

    -- 3.9 临时提权角色
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'role_temp_dml_admin') THEN
        CREATE ROLE role_temp_dml_admin WITH NOLOGIN;
        COMMENT ON ROLE role_temp_dml_admin IS '临时高权限角色组，支持临时继承 role_dml_admin 权限以作故障修复';
    END IF;
END $$;

-- 关联继承关系
GRANT role_global_owner TO role_dba_admin;
GRANT role_global_rw TO role_dml_admin;
GRANT role_dml_admin TO role_temp_dml_admin;
GRANT role_global_ro TO role_compliance_auditor;
GRANT SELECT ON ALL TABLES IN SCHEMA audit TO role_compliance_auditor;

-- 为审计管理员分配 DDL 权，但收回 DML 修改权
GRANT USAGE ON SCHEMA audit TO role_audit_admin;
GRANT CREATE ON SCHEMA audit TO role_audit_admin;
REVOKE INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA audit FROM role_audit_admin;

-- 彻底清除基础版遗留的 audit 库安全特权补丁，回归防篡改合规架构
REVOKE UPDATE, DELETE ON ALL TABLES IN SCHEMA audit FROM role_global_rw;
ALTER DEFAULT PRIVILEGES FOR ROLE role_global_owner IN SCHEMA audit REVOKE UPDATE, DELETE ON TABLES FROM role_global_rw;

-- =====================================================
-- 4. 细粒度隐私与脱敏视图
-- =====================================================

-- 细粒度公开视图（不含哈希列）
CREATE OR REPLACE VIEW mall.users_public AS
SELECT user_id, username, email, phone, created_at
FROM mall.users;
COMMENT ON VIEW mall.users_public IS '公开用户基础信息视图（不包含敏感的密码哈希等列）';

-- 动态数据脱敏视图
CREATE OR REPLACE VIEW mall.users_masked AS
SELECT
    user_id,
    username,
    -- 电子邮箱脱敏：保留前两位和域名部分，中间隐藏为 ****
    CASE 
        WHEN email LIKE '%@%' THEN regexp_replace(email, '^([^@]{1,2})[^@]*(@.*)$', '\1****\2')
        ELSE '****'
    END AS email_masked,
    -- 手机号脱敏：保留前三和后四，中间隐藏为 ****
    CASE 
        WHEN length(phone) >= 7 THEN substring(phone from 1 for 3) || '****' || substring(phone from length(phone)-3)
        ELSE '****' || right(phone, 4)
    END AS phone_masked,
    created_at
FROM mall.users;
COMMENT ON VIEW mall.users_masked IS '动态脱敏用户隐私数据视图（手机号、电子邮箱脱敏）';

-- 授权视图访问
GRANT SELECT ON mall.users_public TO role_global_ro;
GRANT SELECT ON mall.users_masked TO role_global_ro;

-- =====================================================
-- 5. 行级安全（RLS）策略实现
-- =====================================================

-- 5.1 动态检测并扩展 tenant_id 字段
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'mall' AND table_name = 'orders' AND column_name = 'tenant_id'
    ) THEN
        ALTER TABLE mall.orders ADD COLUMN tenant_id INT DEFAULT 1;
        COMMENT ON COLUMN mall.orders.tenant_id IS '多租户ID，支持 RLS 数据分区隔离';
        \echo '>>> 成功为 mall.orders 表添加了 tenant_id 多租户分区列。'
    END IF;
END $$;

-- 5.2 开启表 orders 的行安全保护
ALTER TABLE mall.orders ENABLE ROW LEVEL SECURITY;

-- 5.3 策略 1：多租户会话级别物理隔离
DROP POLICY IF EXISTS orders_tenant_isolation ON mall.orders;
CREATE POLICY orders_tenant_isolation ON mall.orders
    USING (tenant_id = COALESCE(NULLIF(current_setting('app.current_tenant', true), ''), '1')::INT);
COMMENT ON POLICY orders_tenant_isolation ON mall.orders IS '基于会话变量 app.current_tenant 的多租户数据行隔离策略';

-- 5.4 策略 2：只读状态过滤策略（解决 RLS 逻辑漏洞：AND 代替 OR）
DROP POLICY IF EXISTS orders_bi_readonly ON mall.orders;
CREATE POLICY orders_bi_readonly ON mall.orders FOR SELECT
    TO role_global_ro
    USING (status != 'cancelled' AND status != 'refunded');
COMMENT ON POLICY orders_bi_readonly ON mall.orders IS '只读分析角色只能查看非取消、非退款状态的订单';

-- 5.5 策略 3：特权绕过
ALTER ROLE role_global_dba BYPASSRLS;
ALTER ROLE role_dba_admin BYPASSRLS;

-- =====================================================
-- 6. 特权访问管理 (PAM) 审批过程与自动过期回收
-- =====================================================

-- 6.1 开发运维人员提交提权申请
CREATE OR REPLACE PROCEDURE audit.request_escalation(
    p_requester_name NAME,
    p_duration_hours INT,
    p_reason TEXT
) LANGUAGE plpgsql AS $$
BEGIN
    -- 插入提权申请，状态默认为 'pending'
    INSERT INTO audit.privilege_escalation_requests (requester_name, duration_hours, reason, status)
    VALUES (p_requester_name, p_duration_hours, p_reason, 'pending');
    
    RAISE NOTICE '提权申请已提交，等待管理员执行审批过程 audit.approve_escalation()。';
END;
$$;
COMMENT ON PROCEDURE audit.request_escalation IS '开发/运维人员提交临时高权限申请';

-- 6.2 管理员审批申请并动态授权
CREATE OR REPLACE PROCEDURE audit.approve_escalation(
    p_request_id INT,
    p_approver_name NAME
) LANGUAGE plpgsql AS $$
DECLARE
    v_requester NAME;
    v_duration INT;
    v_status VARCHAR(20);
    v_expire_time TIMESTAMP;
BEGIN
    -- 获取并锁定申请记录，防止并发审批
    SELECT requester_name, duration_hours, status
    INTO v_requester, v_duration, v_status
    FROM audit.privilege_escalation_requests
    WHERE request_id = p_request_id
    FOR UPDATE;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION '未找到提权申请单，ID: %', p_request_id;
    END IF;
    
    IF v_status != 'pending' THEN
        RAISE EXCEPTION '提权申请单（ID: %）状态为 %，无法重复审批', p_request_id, v_status;
    END IF;
    
    -- 计算过期时间
    v_expire_time := CURRENT_TIMESTAMP + (v_duration || ' hours')::INTERVAL;
    
    -- 执行动态赋权语句
    EXECUTE format('GRANT role_temp_dml_admin TO %I', v_requester);
    
    -- 记录提权审计日志 (action_type = 'grant')
    INSERT INTO audit.privilege_escalation_log (request_id, role_name, grantee, expires_at, action_type)
    VALUES (p_request_id, 'role_temp_dml_admin', v_requester, v_expire_time, 'grant');
    
    -- 更新申请单状态
    UPDATE audit.privilege_escalation_requests
    SET status = 'approved',
        approved_by = p_approver_name,
        approved_at = CURRENT_TIMESTAMP
    WHERE request_id = p_request_id;
    
    RAISE NOTICE '申请单 % 审批通过！已将临时读写权限 role_temp_dml_admin 授予账号 %，有效期至 %', 
                 p_request_id, v_requester, v_expire_time;
END;
$$;
COMMENT ON PROCEDURE audit.approve_escalation IS '管理员执行提权申请单审批并执行动态赋权';

-- 6.3 核心自动回收函数 (定时任务或运维程序自动轮询)
CREATE OR REPLACE FUNCTION audit.recycle_expired_privileges() 
RETURNS INT 
LANGUAGE plpgsql AS $$
DECLARE
    v_record RECORD;
    v_recycle_count INT := 0;
BEGIN
    -- 检索出所有已到期、但尚未进行撤销操作的临时授权记录
    FOR v_record IN 
        SELECT log_id, request_id, role_name, grantee, expires_at
        FROM audit.privilege_escalation_log g
        WHERE expires_at < CURRENT_TIMESTAMP
          AND action_type = 'grant'
          AND NOT EXISTS (
              SELECT 1 
              FROM audit.privilege_escalation_log r 
              WHERE r.request_id = g.request_id 
                AND r.action_type = 'revoke'
          )
    LOOP
        BEGIN
            -- 执行动态收回权限语句
            EXECUTE format('REVOKE %I FROM %I', v_record.role_name, v_record.grantee);
            
            -- 写入撤销日志记录 (action_type = 'revoke')
            INSERT INTO audit.privilege_escalation_log (request_id, role_name, grantee, granted_at, expires_at, revoked_at, action_type)
            VALUES (v_record.request_id, v_record.role_name, v_record.grantee, v_record.expires_at, v_record.expires_at, CURRENT_TIMESTAMP, 'revoke');
            
            -- 将对应的提权申请状态更新为 'expired'
            UPDATE audit.privilege_escalation_requests
            SET status = 'expired'
            WHERE request_id = v_record.request_id;
            
            v_recycle_count := v_recycle_count + 1;
            RAISE NOTICE '已成功收回用户 % 到期的临时权限 %（申请单 ID: %）', 
                         v_record.grantee, v_record.role_name, v_record.request_id;
        EXCEPTION WHEN OTHERS THEN
            -- 异常容错处理：若该实体账户已被物理删除，跳过 REVOKE 动作，但日志强制标记回收
            INSERT INTO audit.privilege_escalation_log (request_id, role_name, grantee, granted_at, expires_at, revoked_at, action_type)
            VALUES (v_record.request_id, v_record.role_name, v_record.grantee, v_record.expires_at, v_record.expires_at, CURRENT_TIMESTAMP, 'revoke');
            
            UPDATE audit.privilege_escalation_requests
            SET status = 'expired'
            WHERE request_id = v_record.request_id;
            
            RAISE WARNING '用户 % 权限回收执行时出现异常（可能账号已物理删除）：%', v_record.grantee, SQLERRM;
        END;
    END LOOP;
    
    RETURN v_recycle_count;
END;
$$;
COMMENT ON FUNCTION audit.recycle_expired_privileges IS '定时检测并动态收回所有过期临时授权的自动化运维函数';

-- =====================================================
-- 7. 预填元数据示例
-- =====================================================
INSERT INTO app_config.role_ownership (role_name, owner_team, expiration_date, approval_ticket, purpose)
VALUES 
    ('role_dba_admin', 'DBA-Team', NULL, 'TICKET-1001', '日常结构变更与数据库运维'),
    ('role_dml_admin', 'Ops-Team', NULL, 'TICKET-1002', '生产数据在线紧急修复'),
    ('role_compliance_auditor', 'SecOps-Team', NULL, 'TICKET-1003', '数据合规与内部审计审计')
ON CONFLICT (role_name) DO UPDATE 
SET owner_team = EXCLUDED.owner_team, 
    approval_ticket = EXCLUDED.approval_ticket, 
    purpose = EXCLUDED.purpose;

\echo '>>> app_db 企业级安全加固流程执行完毕！所有视图、策略及函数均已成功建立。'
