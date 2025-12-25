-- =====================================================
-- App_db数据库结构脚本 (v2.0)
-- 数据库名称: app_db
-- 字符集: UTF8
-- 版本: v2.0.0
-- 创建日期: 2025-12-25
-- 说明: 包含3个Schema：mall(电商核心)、audit(审计日志)、gis(地理位置)
-- =====================================================

-- =====================================================
-- 删除已存在的数据库（谨慎使用）
-- =====================================================
-- DROP DATABASE IF EXISTS app_db;

-- 创建数据库
CREATE DATABASE app_db
    ENCODING 'UTF8'
    LC_COLLATE = 'en_US.UTF-8'
    LC_CTYPE = 'en_US.UTF-8'
    TEMPLATE template0;

-- 连接到app_db数据库
\c app_db

-- =====================================================
-- 创建Schema
-- =====================================================

-- 创建mall Schema（电商核心）
CREATE SCHEMA IF NOT EXISTS mall;
COMMENT ON SCHEMA mall IS '电商核心Schema：包含所有电商相关的表、视图、函数和触发器';

-- 创建audit Schema（审计日志）
CREATE SCHEMA IF NOT EXISTS audit;
COMMENT ON SCHEMA audit IS '审计日志Schema：用于记录数据库操作日志和审计信息';

-- 创建gis Schema（地理位置）
CREATE SCHEMA IF NOT EXISTS gis;
COMMENT ON SCHEMA gis IS '地理位置Schema：包含PostGIS扩展和地理位置相关表';

-- 启用PostGIS扩展
CREATE EXTENSION IF NOT EXISTS postgis SCHEMA gis;
CREATE SCHEMA IF NOT EXISTS topology;
CREATE EXTENSION IF NOT EXISTS postgis_topology SCHEMA topology;

-- =====================================================
-- 设置默认搜索路径
-- =====================================================
SET search_path TO mall, audit, gis, public;

-- =====================================================
-- =====================================================
-- MALL SCHEMA - 电商核心
-- =====================================================
-- =====================================================

-- =====================================================
-- 序列定义（mall）
-- =====================================================

-- 用户表序列
CREATE SEQUENCE mall.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.users_user_id_seq IS '用户表主键序列';

-- 地址表序列
CREATE SEQUENCE mall.addresses_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.addresses_address_id_seq IS '地址表主键序列';

-- 用户资料表序列
CREATE SEQUENCE mall.user_profiles_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.user_profiles_profile_id_seq IS '用户资料表主键序列';

-- 分类表序列
CREATE SEQUENCE mall.categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.categories_category_id_seq IS '分类表主键序列';

-- 商品表序列
CREATE SEQUENCE mall.products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.products_product_id_seq IS '商品表主键序列';

-- 商品图片表序列
CREATE SEQUENCE mall.product_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.product_images_image_id_seq IS '商品图片表主键序列';

-- 订单表序列
CREATE SEQUENCE mall.orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.orders_order_id_seq IS '订单表主键序列';

-- 订单项表序列
CREATE SEQUENCE mall.order_items_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.order_items_order_item_id_seq IS '订单项表主键序列';

-- 订单状态历史表序列
CREATE SEQUENCE mall.order_status_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.order_status_history_history_id_seq IS '订单状态历史表主键序列';

-- 支付表序列
CREATE SEQUENCE mall.payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.payments_payment_id_seq IS '支付表主键序列';

-- 评论表序列
CREATE SEQUENCE mall.reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
COMMENT ON SEQUENCE mall.reviews_review_id_seq IS '评论表主键序列';

-- =====================================================
-- 表定义（mall）
-- =====================================================

-- 用户表
CREATE TABLE mall.users (
    user_id INTEGER DEFAULT nextval('mall.users_user_id_seq'::regclass) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT users_pkey PRIMARY KEY (user_id)
);
COMMENT ON TABLE mall.users IS '用户表：存储用户基本信息';
COMMENT ON COLUMN mall.users.user_id IS '用户ID，主键';
COMMENT ON COLUMN mall.users.username IS '用户名，唯一标识';
COMMENT ON COLUMN mall.users.email IS '电子邮件地址，唯一标识';
COMMENT ON COLUMN mall.users.password_hash IS '密码哈希值，加密存储';
COMMENT ON COLUMN mall.users.first_name IS '姓';
COMMENT ON COLUMN mall.users.last_name IS '名';
COMMENT ON COLUMN mall.users.phone IS '电话号码';
COMMENT ON COLUMN mall.users.is_active IS '是否激活：true-已激活，false-未激活';
COMMENT ON COLUMN mall.users.created_at IS '创建时间';
COMMENT ON COLUMN mall.users.updated_at IS '更新时间';

-- 地址表
CREATE TABLE mall.addresses (
    address_id INTEGER DEFAULT nextval('mall.addresses_address_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    province VARCHAR(50) NOT NULL,
    city VARCHAR(50) NOT NULL,
    district VARCHAR(50) NOT NULL,
    street_address VARCHAR(200) NOT NULL,
    postal_code VARCHAR(20),
    is_default BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT addresses_pkey PRIMARY KEY (address_id),
    CONSTRAINT addresses_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES mall.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE mall.addresses IS '地址表：存储用户收货地址';
COMMENT ON COLUMN mall.addresses.address_id IS '地址ID，主键';
COMMENT ON COLUMN mall.addresses.user_id IS '用户ID，外键关联users表';
COMMENT ON COLUMN mall.addresses.recipient_name IS '收件人姓名';
COMMENT ON COLUMN mall.addresses.phone IS '收件人电话';
COMMENT ON COLUMN mall.addresses.province IS '省/直辖市';
COMMENT ON COLUMN mall.addresses.city IS '市';
COMMENT ON COLUMN mall.addresses.district IS '区/县';
COMMENT ON COLUMN mall.addresses.street_address IS '街道详细地址';
COMMENT ON COLUMN mall.addresses.postal_code IS '邮政编码';
COMMENT ON COLUMN mall.addresses.is_default IS '是否默认地址：true-默认，false-非默认';
COMMENT ON COLUMN mall.addresses.created_at IS '创建时间';

-- 用户资料表
CREATE TABLE mall.user_profiles (
    profile_id INTEGER DEFAULT nextval('mall.user_profiles_profile_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL UNIQUE,
    gender CHAR(1),
    birth_date DATE,
    avatar_url VARCHAR(500),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT user_profiles_pkey PRIMARY KEY (profile_id),
    CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES mall.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE mall.user_profiles IS '用户资料表：存储用户扩展信息';
COMMENT ON COLUMN mall.user_profiles.profile_id IS '资料ID，主键';
COMMENT ON COLUMN mall.user_profiles.user_id IS '用户ID，外键关联users表，唯一';
COMMENT ON COLUMN mall.user_profiles.gender IS '性别：男/女';
COMMENT ON COLUMN mall.user_profiles.birth_date IS '出生日期';
COMMENT ON COLUMN mall.user_profiles.avatar_url IS '头像URL';
COMMENT ON COLUMN mall.user_profiles.bio IS '个人简介';
COMMENT ON COLUMN mall.user_profiles.created_at IS '创建时间';
COMMENT ON COLUMN mall.user_profiles.updated_at IS '更新时间';

-- 分类表
CREATE TABLE mall.categories (
    category_id INTEGER DEFAULT nextval('mall.categories_category_id_seq'::regclass) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INTEGER,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT categories_pkey PRIMARY KEY (category_id),
    CONSTRAINT categories_parent_category_id_fkey FOREIGN KEY (parent_category_id)
        REFERENCES mall.categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);
COMMENT ON TABLE mall.categories IS '分类表：存储商品分类信息';
COMMENT ON COLUMN mall.categories.category_id IS '分类ID，主键';
COMMENT ON COLUMN mall.categories.name IS '分类名称';
COMMENT ON COLUMN mall.categories.description IS '分类描述';
COMMENT ON COLUMN mall.categories.parent_category_id IS '父分类ID，支持多级分类，NULL表示顶级分类';
COMMENT ON COLUMN mall.categories.sort_order IS '排序顺序，数值越小越靠前';
COMMENT ON COLUMN mall.categories.is_active IS '是否启用：true-启用，false-禁用';
COMMENT ON COLUMN mall.categories.created_at IS '创建时间';

-- 商品表
CREATE TABLE mall.products (
    product_id INTEGER DEFAULT nextval('mall.products_product_id_seq'::regclass) NOT NULL,
    category_id INTEGER NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT products_pkey PRIMARY KEY (product_id),
    CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id)
        REFERENCES mall.categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
COMMENT ON TABLE mall.products IS '商品表：存储商品信息';
COMMENT ON COLUMN mall.products.product_id IS '商品ID，主键';
COMMENT ON COLUMN mall.products.category_id IS '分类ID，外键关联categories表';
COMMENT ON COLUMN mall.products.name IS '商品名称';
COMMENT ON COLUMN mall.products.description IS '商品描述';
COMMENT ON COLUMN mall.products.price IS '商品价格';
COMMENT ON COLUMN mall.products.stock_quantity IS '库存数量';
COMMENT ON COLUMN mall.products.is_active IS '是否上架：true-上架，false-下架';
COMMENT ON COLUMN mall.products.created_at IS '创建时间';
COMMENT ON COLUMN mall.products.updated_at IS '更新时间';

-- 商品图片表
CREATE TABLE mall.product_images (
    image_id INTEGER DEFAULT nextval('mall.product_images_image_id_seq'::regclass) NOT NULL,
    product_id INTEGER NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(200),
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_primary BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT product_images_pkey PRIMARY KEY (image_id),
    CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES mall.products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE mall.product_images IS '商品图片表：存储商品图片';
COMMENT ON COLUMN mall.product_images.image_id IS '图片ID，主键';
COMMENT ON COLUMN mall.product_images.product_id IS '商品ID，外键关联products表';
COMMENT ON COLUMN mall.product_images.image_url IS '图片URL地址';
COMMENT ON COLUMN mall.product_images.alt_text IS '图片描述文本，用于搜索引擎和屏幕阅读器';
COMMENT ON COLUMN mall.product_images.sort_order IS '排序顺序，数值越小越靠前';
COMMENT ON COLUMN mall.product_images.is_primary IS '是否主图：true-主图，false-副图';
COMMENT ON COLUMN mall.product_images.created_at IS '创建时间';

-- 订单表
CREATE TABLE mall.orders (
    order_id INTEGER DEFAULT nextval('mall.orders_order_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT orders_pkey PRIMARY KEY (order_id),
    CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES mall.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT orders_address_id_fkey FOREIGN KEY (address_id)
        REFERENCES mall.addresses(address_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT orders_status_check CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded'))
);
COMMENT ON TABLE mall.orders IS '订单表：存储订单基本信息';
COMMENT ON COLUMN mall.orders.order_id IS '订单ID，主键';
COMMENT ON COLUMN mall.orders.user_id IS '用户ID，外键关联users表';
COMMENT ON COLUMN mall.orders.address_id IS '地址ID，外键关联addresses表';
COMMENT ON COLUMN mall.orders.order_number IS '订单编号，唯一标识';
COMMENT ON COLUMN mall.orders.total_amount IS '订单总金额';
COMMENT ON COLUMN mall.orders.status IS '订单状态：pending-待付款，paid-已付款，shipped-已发货，delivered-已送达，cancelled-已取消，refunded-已退款';
COMMENT ON COLUMN mall.orders.created_at IS '创建时间';
COMMENT ON COLUMN mall.orders.updated_at IS '更新时间';

-- 订单项表
CREATE TABLE mall.order_items (
    order_item_id INTEGER DEFAULT nextval('mall.order_items_order_item_id_seq'::regclass) NOT NULL,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id),
    CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES mall.orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES mall.products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);
COMMENT ON TABLE mall.order_items IS '订单项表：存储订单详情';
COMMENT ON COLUMN mall.order_items.order_item_id IS '订单项ID，主键';
COMMENT ON COLUMN mall.order_items.order_id IS '订单ID，外键关联orders表';
COMMENT ON COLUMN mall.order_items.product_id IS '商品ID，外键关联products表';
COMMENT ON COLUMN mall.order_items.quantity IS '商品数量';
COMMENT ON COLUMN mall.order_items.unit_price IS '单价（下单时的价格）';
COMMENT ON COLUMN mall.order_items.subtotal IS '小计金额（单价*数量）';
COMMENT ON COLUMN mall.order_items.created_at IS '创建时间';

-- 订单状态历史表
CREATE TABLE mall.order_status_history (
    history_id INTEGER DEFAULT nextval('mall.order_status_history_history_id_seq'::regclass) NOT NULL,
    order_id INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT order_status_history_pkey PRIMARY KEY (history_id),
    CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES mall.orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
COMMENT ON TABLE mall.order_status_history IS '订单状态历史表：存储订单状态变更记录';
COMMENT ON COLUMN mall.order_status_history.history_id IS '历史ID，主键';
COMMENT ON COLUMN mall.order_status_history.order_id IS '订单ID，外键关联orders表';
COMMENT ON COLUMN mall.order_status_history.status IS '订单状态';
COMMENT ON COLUMN mall.order_status_history.remark IS '备注说明';
COMMENT ON COLUMN mall.order_status_history.created_at IS '创建时间（状态变更时间）';

-- 支付表
CREATE TABLE mall.payments (
    payment_id INTEGER DEFAULT nextval('mall.payments_payment_id_seq'::regclass) NOT NULL,
    order_id INTEGER NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,
    transaction_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT payments_pkey PRIMARY KEY (payment_id),
    CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES mall.orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT payments_status_check CHECK (status IN ('pending', 'success', 'failed', 'refunded'))
);
COMMENT ON TABLE mall.payments IS '支付表：存储支付记录';
COMMENT ON COLUMN mall.payments.payment_id IS '支付ID，主键';
COMMENT ON COLUMN mall.payments.order_id IS '订单ID，外键关联orders表';
COMMENT ON COLUMN mall.payments.payment_method IS '支付方式：微信支付/支付宝/信用卡/借记卡/余额支付';
COMMENT ON COLUMN mall.payments.amount IS '支付金额';
COMMENT ON COLUMN mall.payments.status IS '支付状态：pending-待支付，success-支付成功，failed-支付失败，refunded-已退款';
COMMENT ON COLUMN mall.payments.transaction_id IS '交易流水号，第三方支付平台返回';
COMMENT ON COLUMN mall.payments.created_at IS '创建时间';

-- 评论表
CREATE TABLE mall.reviews (
    review_id INTEGER DEFAULT nextval('mall.reviews_review_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    rating INTEGER NOT NULL,
    title VARCHAR(200),
    content TEXT,
    is_verified BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT reviews_pkey PRIMARY KEY (review_id),
    CONSTRAINT reviews_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES mall.users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES mall.products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT reviews_rating_check CHECK (rating >= 1 AND rating <= 5)
);
COMMENT ON TABLE mall.reviews IS '评论表：存储商品评论';
COMMENT ON COLUMN mall.reviews.review_id IS '评论ID，主键';
COMMENT ON COLUMN mall.reviews.user_id IS '用户ID，外键关联users表';
COMMENT ON COLUMN mall.reviews.product_id IS '商品ID，外键关联products表';
COMMENT ON COLUMN mall.reviews.rating IS '评分：1-5分，5分最高';
COMMENT ON COLUMN mall.reviews.title IS '评论标题';
COMMENT ON COLUMN mall.reviews.content IS '评论内容';
COMMENT ON COLUMN mall.reviews.is_verified IS '是否验证购买：true-已验证购买，false-未验证';
COMMENT ON COLUMN mall.reviews.created_at IS '创建时间';
COMMENT ON COLUMN mall.reviews.updated_at IS '更新时间';

-- =====================================================
-- 索引定义（mall）
-- =====================================================

-- 用户表索引
CREATE INDEX idx_users_email ON mall.users(email);
COMMENT ON INDEX idx_users_email IS '用户邮箱索引，用于快速查找';
CREATE INDEX idx_users_username ON mall.users(username);
COMMENT ON INDEX idx_users_username IS '用户名索引，用于快速查找';
CREATE INDEX idx_users_is_active ON mall.users(is_active);
COMMENT ON INDEX idx_users_is_active IS '用户状态索引，用于筛选激活用户';
CREATE INDEX idx_users_created_at ON mall.users(created_at);
COMMENT ON INDEX idx_users_created_at IS '用户创建时间索引，用于按时间排序';

-- 地址表索引
CREATE INDEX idx_addresses_user_id ON mall.addresses(user_id);
COMMENT ON INDEX idx_addresses_user_id IS '地址用户ID索引，用于快速查询用户地址';

-- 用户资料表索引
CREATE INDEX idx_user_profiles_user_id ON mall.user_profiles(user_id);
COMMENT ON INDEX idx_user_profiles_user_id IS '用户资料用户ID索引，用于快速查询用户资料';

-- 分类表索引
CREATE INDEX idx_categories_parent_category_id ON mall.categories(parent_category_id);
COMMENT ON INDEX idx_categories_parent_category_id IS '分类父ID索引，用于查询子分类';
CREATE INDEX idx_categories_is_active ON mall.categories(is_active);
COMMENT ON INDEX idx_categories_is_active IS '分类状态索引，用于筛选启用分类';
CREATE INDEX idx_categories_sort_order ON mall.categories(sort_order);
COMMENT ON INDEX idx_categories_sort_order IS '分类排序索引，用于按排序查询';

-- 商品表索引
CREATE INDEX idx_products_category_id ON mall.products(category_id);
COMMENT ON INDEX idx_products_category_id IS '商品分类ID索引，用于查询分类商品';
CREATE INDEX idx_products_name ON mall.products(name);
COMMENT ON INDEX idx_products_name IS '商品名称索引，用于商品搜索';
CREATE INDEX idx_products_is_active ON mall.products(is_active);
COMMENT ON INDEX idx_products_is_active IS '商品状态索引，用于筛选上架商品';
CREATE INDEX idx_products_price ON mall.products(price);
COMMENT ON INDEX idx_products_price IS '商品价格索引，用于价格排序和筛选';
CREATE INDEX idx_products_created_at ON mall.products(created_at);
COMMENT ON INDEX idx_products_created_at IS '商品创建时间索引，用于按时间排序';

-- 商品图片表索引
CREATE INDEX idx_product_images_product_id ON mall.product_images(product_id);
COMMENT ON INDEX idx_product_images_product_id IS '商品图片商品ID索引，用于查询商品图片';

-- 订单表索引
CREATE INDEX idx_orders_user_id ON mall.orders(user_id);
COMMENT ON INDEX idx_orders_user_id IS '订单用户ID索引，用于查询用户订单';
CREATE INDEX idx_orders_address_id ON mall.orders(address_id);
COMMENT ON INDEX idx_orders_address_id IS '订单地址ID索引，用于查询地址订单';
CREATE INDEX idx_orders_status ON mall.orders(status);
COMMENT ON INDEX idx_orders_status IS '订单状态索引，用于筛选订单状态';
CREATE INDEX idx_orders_created_at ON mall.orders(created_at);
COMMENT ON INDEX idx_orders_created_at IS '订单创建时间索引，用于按时间排序';
CREATE INDEX idx_orders_order_number ON mall.orders(order_number);
COMMENT ON INDEX idx_orders_order_number IS '订单编号索引，用于快速查找订单';

-- 订单项表索引
CREATE INDEX idx_order_items_order_id ON mall.order_items(order_id);
COMMENT ON INDEX idx_order_items_order_id IS '订单项订单ID索引，用于查询订单详情';
CREATE INDEX idx_order_items_product_id ON mall.order_items(product_id);
COMMENT ON INDEX idx_order_items_product_id IS '订单项商品ID索引，用于查询商品销售记录';

-- 订单状态历史表索引
CREATE INDEX idx_order_status_history_order_id ON mall.order_status_history(order_id);
COMMENT ON INDEX idx_order_status_history_order_id IS '订单历史订单ID索引，用于查询订单状态历史';
CREATE INDEX idx_order_status_history_created_at ON mall.order_status_history(created_at);
COMMENT ON INDEX idx_order_status_history_created_at IS '订单历史创建时间索引，用于按时间排序';

-- 支付表索引
CREATE INDEX idx_payments_order_id ON mall.payments(order_id);
COMMENT ON INDEX idx_payments_order_id IS '支付订单ID索引，用于查询订单支付';
CREATE INDEX idx_payments_status ON mall.payments(status);
COMMENT ON INDEX idx_payments_status IS '支付状态索引，用于筛选支付状态';
CREATE INDEX idx_payments_created_at ON mall.payments(created_at);
COMMENT ON INDEX idx_payments_created_at IS '支付创建时间索引，用于按时间排序';
CREATE INDEX idx_payments_transaction_id ON mall.payments(transaction_id);
COMMENT ON INDEX idx_payments_transaction_id IS '支付流水号索引，用于快速查找支付';

-- 评论表索引
CREATE INDEX idx_reviews_product_id ON mall.reviews(product_id);
COMMENT ON INDEX idx_reviews_product_id IS '评论商品ID索引，用于查询商品评论';
CREATE INDEX idx_reviews_user_id ON mall.reviews(user_id);
COMMENT ON INDEX idx_reviews_user_id IS '评论用户ID索引，用于查询用户评论';
CREATE INDEX idx_reviews_rating ON mall.reviews(rating);
COMMENT ON INDEX idx_reviews_rating IS '评论评分索引，用于按评分排序';
CREATE INDEX idx_reviews_created_at ON mall.reviews(created_at);
COMMENT ON INDEX idx_reviews_created_at IS '评论创建时间索引，用于按时间排序';

-- =====================================================
-- 触发器定义（mall）
-- =====================================================

-- 自动更新updated_at字段的触发器函数
CREATE OR REPLACE FUNCTION mall.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION mall.update_updated_at_column() IS '自动更新updated_at字段触发器函数';

-- 为users表添加触发器
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON mall.users
    FOR EACH ROW
    EXECUTE FUNCTION mall.update_updated_at_column();
COMMENT ON TRIGGER update_users_updated_at ON mall.users IS '用户表更新时间自动更新触发器';

-- 为user_profiles表添加触发器
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON mall.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION mall.update_updated_at_column();
COMMENT ON TRIGGER update_user_profiles_updated_at ON mall.user_profiles IS '用户资料表更新时间自动更新触发器';

-- 为products表添加触发器
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON mall.products
    FOR EACH ROW
    EXECUTE FUNCTION mall.update_updated_at_column();
COMMENT ON TRIGGER update_products_updated_at ON mall.products IS '商品表更新时间自动更新触发器';

-- 为orders表添加触发器
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON mall.orders
    FOR EACH ROW
    EXECUTE FUNCTION mall.update_updated_at_column();
COMMENT ON TRIGGER update_orders_updated_at ON mall.orders IS '订单表更新时间自动更新触发器';

-- 为reviews表添加触发器
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON mall.reviews
    FOR EACH ROW
    EXECUTE FUNCTION mall.update_updated_at_column();
COMMENT ON TRIGGER update_reviews_updated_at ON mall.reviews IS '评论表更新时间自动更新触发器';

-- =====================================================
-- 视图定义（mall）
-- =====================================================

-- 订单汇总视图
CREATE OR REPLACE VIEW mall.order_summary AS
SELECT
    o.order_id,
    o.order_number,
    o.user_id,
    u.username,
    u.email,
    o.status,
    o.total_amount,
    o.created_at,
    COUNT(oi.order_item_id) AS item_count
FROM mall.orders o
INNER JOIN mall.users u ON o.user_id = u.user_id
LEFT JOIN mall.order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, o.user_id, u.username, u.email, o.status, o.total_amount, o.created_at;
COMMENT ON VIEW mall.order_summary IS '订单汇总视图：包含订单基本信息和用户信息，统计订单项数量';

-- 商品汇总视图
CREATE OR REPLACE VIEW mall.product_summary AS
SELECT
    p.product_id,
    p.name,
    p.price,
    p.stock_quantity,
    c.name AS category_name,
    COUNT(pi.image_id) AS image_count,
    AVG(r.rating) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM mall.products p
INNER JOIN mall.categories c ON p.category_id = c.category_id
LEFT JOIN mall.product_images pi ON p.product_id = pi.product_id
LEFT JOIN mall.reviews r ON p.product_id = r.product_id
WHERE p.is_active = true
GROUP BY p.product_id, p.name, p.price, p.stock_quantity, c.name;
COMMENT ON VIEW mall.product_summary IS '商品汇总视图：包含商品基本信息、分类信息、图片数量、平均评分和评论数量';

-- =====================================================
-- =====================================================
-- AUDIT SCHEMA - 审计日志
-- =====================================================
-- =====================================================

-- =====================================================
-- 表定义（audit）
-- =====================================================

-- 审计日志表
CREATE TABLE audit.audit_logs (
    log_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    operation VARCHAR(20) NOT NULL,
    operation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    user_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    user_agent TEXT
);
COMMENT ON TABLE audit.audit_logs IS '审计日志表：记录数据库表的增删改操作';
COMMENT ON COLUMN audit.audit_logs.log_id IS '日志ID，主键';
COMMENT ON COLUMN audit.audit_logs.table_name IS '表名';
COMMENT ON COLUMN audit.audit_logs.operation IS '操作类型：INSERT/UPDATE/DELETE';
COMMENT ON COLUMN audit.audit_logs.operation_time IS '操作时间';
COMMENT ON COLUMN audit.audit_logs.user_id IS '操作用户ID';
COMMENT ON COLUMN audit.audit_logs.old_values IS '修改前的值（JSON格式）';
COMMENT ON COLUMN audit.audit_logs.new_values IS '修改后的值（JSON格式）';
COMMENT ON COLUMN audit.audit_logs.ip_address IS '操作IP地址';
COMMENT ON COLUMN audit.audit_logs.user_agent IS '用户代理信息';

-- 用户登录日志表
CREATE TABLE audit.login_logs (
    log_id BIGSERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    logout_time TIMESTAMP,
    ip_address VARCHAR(50),
    user_agent TEXT,
    login_status VARCHAR(20) NOT NULL
);
COMMENT ON TABLE audit.login_logs IS '用户登录日志表：记录用户登录和登出信息';
COMMENT ON COLUMN audit.login_logs.log_id IS '日志ID，主键';
COMMENT ON COLUMN audit.login_logs.user_id IS '用户ID';
COMMENT ON COLUMN audit.login_logs.login_time IS '登录时间';
COMMENT ON COLUMN audit.login_logs.logout_time IS '登出时间';
COMMENT ON COLUMN audit.login_logs.ip_address IS '登录IP地址';
COMMENT ON COLUMN audit.login_logs.user_agent IS '用户代理信息';
COMMENT ON COLUMN audit.login_logs.login_status IS '登录状态：success/failed/locked';

-- 数据变更历史表
CREATE TABLE audit.data_change_history (
    change_id BIGSERIAL PRIMARY KEY,
    schema_name VARCHAR(50) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT NOT NULL,
    change_type VARCHAR(20) NOT NULL,
    changed_by VARCHAR(100),
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    field_name VARCHAR(100),
    old_value TEXT,
    new_value TEXT
);
COMMENT ON TABLE audit.data_change_history IS '数据变更历史表：记录数据字段级别的变更历史';
COMMENT ON COLUMN audit.data_change_history.change_id IS '变更ID，主键';
COMMENT ON COLUMN audit.data_change_history.schema_name IS 'Schema名称';
COMMENT ON COLUMN audit.data_change_history.table_name IS '表名';
COMMENT ON COLUMN audit.data_change_history.record_id IS '记录ID';
COMMENT ON COLUMN audit.data_change_history.change_type IS '变更类型：INSERT/UPDATE/DELETE';
COMMENT ON COLUMN audit.data_change_history.changed_by IS '变更人';
COMMENT ON COLUMN audit.data_change_history.change_time IS '变更时间';
COMMENT ON COLUMN audit.data_change_history.field_name IS '字段名称';
COMMENT ON COLUMN audit.data_change_history.old_value IS '旧值';
COMMENT ON COLUMN audit.data_change_history.new_value IS '新值';

-- =====================================================
-- 索引定义（audit）
-- =====================================================

CREATE INDEX idx_audit_logs_table_name ON audit.audit_logs(table_name);
COMMENT ON INDEX idx_audit_logs_table_name IS '审计日志表名索引，用于按表查询审计日志';

CREATE INDEX idx_audit_logs_operation_time ON audit.audit_logs(operation_time);
COMMENT ON INDEX idx_audit_logs_operation_time IS '审计日志操作时间索引，用于按时间查询';

CREATE INDEX idx_audit_logs_user_id ON audit.audit_logs(user_id);
COMMENT ON INDEX idx_audit_logs_user_id IS '审计日志用户ID索引，用于按用户查询';

CREATE INDEX idx_login_logs_user_id ON audit.login_logs(user_id);
COMMENT ON INDEX idx_login_logs_user_id IS '登录日志用户ID索引，用于查询用户登录记录';

CREATE INDEX idx_login_logs_login_time ON audit.login_logs(login_time);
COMMENT ON INDEX idx_login_logs_login_time IS '登录日志登录时间索引，用于按时间查询';

CREATE INDEX idx_data_change_history_table_name ON audit.data_change_history(table_name);
COMMENT ON INDEX idx_data_change_history_table_name IS '数据变更历史表名索引，用于按表查询变更';

CREATE INDEX idx_data_change_history_record_id ON audit.data_change_history(record_id);
COMMENT ON INDEX idx_data_change_history_record_id IS '数据变更历史记录ID索引，用于查询特定记录的变更';

CREATE INDEX idx_data_change_history_change_time ON audit.data_change_history(change_time);
COMMENT ON INDEX idx_data_change_history_change_time IS '数据变更历史变更时间索引，用于按时间查询';

-- =====================================================
-- =====================================================
-- GIS SCHEMA - 地理位置
-- =====================================================
-- =====================================================

-- =====================================================
-- 表定义（gis）
-- =====================================================

-- 门店位置表
CREATE TABLE gis.store_locations (
    location_id SERIAL PRIMARY KEY,
    store_name VARCHAR(200) NOT NULL,
    address VARCHAR(500) NOT NULL,
    province VARCHAR(50),
    city VARCHAR(50),
    district VARCHAR(50),
    geometry GEOMETRY(POINT, 4326),
    phone VARCHAR(20),
    email VARCHAR(100),
    business_hours VARCHAR(200),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
COMMENT ON TABLE gis.store_locations IS '门店位置表：存储门店地理坐标信息';
COMMENT ON COLUMN gis.store_locations.location_id IS '位置ID，主键';
COMMENT ON COLUMN gis.store_locations.store_name IS '门店名称';
COMMENT ON COLUMN gis.store_locations.address IS '门店地址';
COMMENT ON COLUMN gis.store_locations.province IS '省份';
COMMENT ON COLUMN gis.store_locations.city IS '城市';
COMMENT ON COLUMN gis.store_locations.district IS '区县';
COMMENT ON COLUMN gis.store_locations.geometry IS '地理坐标（PostGIS点类型）';
COMMENT ON COLUMN gis.store_locations.phone IS '联系电话';
COMMENT ON COLUMN gis.store_locations.email IS '邮箱';
COMMENT ON COLUMN gis.store_locations.business_hours IS '营业时间';
COMMENT ON COLUMN gis.store_locations.is_active IS '是否营业：true-营业，false-停业';
COMMENT ON COLUMN gis.store_locations.created_at IS '创建时间';
COMMENT ON COLUMN gis.store_locations.updated_at IS '更新时间';

-- 配送区域表
CREATE TABLE gis.delivery_zones (
    zone_id SERIAL PRIMARY KEY,
    zone_name VARCHAR(200) NOT NULL,
    zone_type VARCHAR(50) NOT NULL,
    base_fee DECIMAL(10,2) NOT NULL,
    fee_per_km DECIMAL(10,2) NOT NULL,
    geometry GEOMETRY(POLYGON, 4326),
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
COMMENT ON TABLE gis.delivery_zones IS '配送区域表：存储配送区域的地理范围和费用信息';
COMMENT ON COLUMN gis.delivery_zones.zone_id IS '区域ID，主键';
COMMENT ON COLUMN gis.delivery_zones.zone_name IS '区域名称';
COMMENT ON COLUMN gis.delivery_zones.zone_type IS '区域类型：standard/express/overtime';
COMMENT ON COLUMN gis.delivery_zones.base_fee IS '基础配送费';
COMMENT ON COLUMN gis.delivery_zones.fee_per_km IS '每公里配送费';
COMMENT ON COLUMN gis.delivery_zones.geometry IS '区域边界（PostGIS多边形类型）';
COMMENT ON COLUMN gis.delivery_zones.is_active IS '是否启用：true-启用，false-禁用';
COMMENT ON COLUMN gis.delivery_zones.created_at IS '创建时间';

-- 物流轨迹表
CREATE TABLE gis.logistics_tracks (
    track_id BIGSERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    driver_id INTEGER,
    vehicle_number VARCHAR(50),
    status VARCHAR(50) NOT NULL,
    geometry GEOMETRY(LINESTRING, 4326),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    distance_km DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
COMMENT ON TABLE gis.logistics_tracks IS '物流轨迹表：记录配送路线和轨迹信息';
COMMENT ON COLUMN gis.logistics_tracks.track_id IS '轨迹ID，主键';
COMMENT ON COLUMN gis.logistics_tracks.order_id IS '订单ID';
COMMENT ON COLUMN gis.logistics_tracks.driver_id IS '配送员ID';
COMMENT ON COLUMN gis.logistics_tracks.vehicle_number IS '车辆号码';
COMMENT ON COLUMN gis.logistics_tracks.status IS '配送状态：pending/in_progress/completed/cancelled';
COMMENT ON COLUMN gis.logistics_tracks.geometry IS '轨迹路线（PostGIS线类型）';
COMMENT ON COLUMN gis.logistics_tracks.start_time IS '开始时间';
COMMENT ON COLUMN gis.logistics_tracks.end_time IS '结束时间';
COMMENT ON COLUMN gis.logistics_tracks.distance_km IS '配送距离（公里）';
COMMENT ON COLUMN gis.logistics_tracks.created_at IS '创建时间';

-- 热点区域表
CREATE TABLE gis.hotspot_areas (
    hotspot_id SERIAL PRIMARY KEY,
    area_name VARCHAR(200) NOT NULL,
    area_type VARCHAR(50) NOT NULL,
    geometry GEOMETRY(POLYGON, 4326),
    user_count INTEGER DEFAULT 0,
    order_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
COMMENT ON TABLE gis.hotspot_areas IS '热点区域表：存储用户密集区和订单密集区';
COMMENT ON COLUMN gis.hotspot_areas.hotspot_id IS '热点ID，主键';
COMMENT ON COLUMN gis.hotspot_areas.area_name IS '区域名称';
COMMENT ON COLUMN gis.hotspot_areas.area_type IS '区域类型：residential/commercial/mixed';
COMMENT ON COLUMN gis.hotspot_areas.geometry IS '区域边界（PostGIS多边形类型）';
COMMENT ON COLUMN gis.hotspot_areas.user_count IS '用户数量';
COMMENT ON COLUMN gis.hotspot_areas.order_count IS '订单数量';
COMMENT ON COLUMN gis.hotspot_areas.created_at IS '创建时间';
COMMENT ON COLUMN gis.hotspot_areas.updated_at IS '更新时间';

-- =====================================================
-- 索引定义（gis）
-- =====================================================

-- PostGIS空间索引
CREATE INDEX idx_store_locations_geometry ON gis.store_locations USING GIST(geometry);
COMMENT ON INDEX idx_store_locations_geometry IS '门店位置空间索引，用于空间查询';

CREATE INDEX idx_delivery_zones_geometry ON gis.delivery_zones USING GIST(geometry);
COMMENT ON INDEX idx_delivery_zones_geometry IS '配送区域空间索引，用于空间查询';

CREATE INDEX idx_logistics_tracks_geometry ON gis.logistics_tracks USING GIST(geometry);
COMMENT ON INDEX idx_logistics_tracks_geometry IS '物流轨迹空间索引，用于空间查询';

CREATE INDEX idx_hotspot_areas_geometry ON gis.hotspot_areas USING GIST(geometry);
COMMENT ON INDEX idx_hotspot_areas_geometry IS '热点区域空间索引，用于空间查询';

-- 普通索引
CREATE INDEX idx_store_locations_is_active ON gis.store_locations(is_active);
COMMENT ON INDEX idx_store_locations_is_active IS '门店状态索引，用于筛选营业门店';

CREATE INDEX idx_logistics_tracks_order_id ON gis.logistics_tracks(order_id);
COMMENT ON INDEX idx_logistics_tracks_order_id IS '物流轨迹订单ID索引，用于查询订单轨迹';

CREATE INDEX idx_logistics_tracks_start_time ON gis.logistics_tracks(start_time);
COMMENT ON INDEX idx_logistics_tracks_start_time IS '物流轨迹开始时间索引，用于按时间查询';

-- =====================================================
-- =====================================================
-- MALL SCHEMA - 函数和存储过程
-- =====================================================
-- =====================================================

-- =====================================================
-- 函数定义（mall）
-- =====================================================

-- 获取用户总消费金额函数
CREATE OR REPLACE FUNCTION mall.get_user_total_spent(user_id_param INTEGER)
RETURNS DECIMAL(10,2) AS $$
DECLARE
    total_spent DECIMAL(10,2);
BEGIN
    SELECT COALESCE(SUM(total_amount), 0) INTO total_spent
    FROM mall.orders
    WHERE user_id = user_id_param
      AND status IN ('paid', 'shipped', 'delivered');
    
    RETURN total_spent;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION mall.get_user_total_spent(INTEGER) IS '获取用户总消费金额函数：返回用户已完成的订单总金额';

-- 获取商品平均评分函数
CREATE OR REPLACE FUNCTION mall.get_product_avg_rating(product_id_param INTEGER)
RETURNS DECIMAL(3,2) AS $$
DECLARE
    avg_rating DECIMAL(3,2);
BEGIN
    SELECT COALESCE(AVG(rating), 0) INTO avg_rating
    FROM mall.reviews
    WHERE product_id = product_id_param;
    
    RETURN avg_rating;
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION mall.get_product_avg_rating(INTEGER) IS '获取商品平均评分函数：返回指定商品的平均评分';

-- =====================================================
-- 存储过程定义（mall）
-- =====================================================

-- 清理过期订单存储过程
CREATE OR REPLACE PROCEDURE mall.clean_expired_orders(IN days_old INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 标记超过指定天数且状态为pending的订单为cancelled
    UPDATE mall.orders
    SET status = 'cancelled',
        updated_at = CURRENT_TIMESTAMP
    WHERE status = 'pending'
      AND created_at < CURRENT_TIMESTAMP - INTERVAL '1 day' * days_old;
    
    RAISE NOTICE '已清理 % 天前的过期订单', days_old;
END;
$$;
COMMENT ON PROCEDURE mall.clean_expired_orders(INTEGER) IS '清理过期订单存储过程：将超过指定天数的待支付订单标记为已取消';

-- 批量更新商品库存存储过程
CREATE OR REPLACE PROCEDURE mall.batch_update_stock(IN product_ids_param INTEGER[], IN quantities_param INTEGER[])
LANGUAGE plpgsql
AS $$
DECLARE
    i INTEGER;
BEGIN
    -- 检查数组长度是否匹配
    IF array_length(product_ids_param, 1) != array_length(quantities_param, 1) THEN
        RAISE EXCEPTION '商品ID数组和数量数组长度不匹配';
    END IF;
    
    -- 循环更新每个商品的库存
    FOR i IN 1..array_length(product_ids_param, 1) LOOP
        UPDATE mall.products
        SET stock_quantity = stock_quantity - quantities_param[i],
            updated_at = CURRENT_TIMESTAMP
        WHERE product_id = product_ids_param[i]
          AND stock_quantity >= quantities_param[i];
    END LOOP;
    
    RAISE NOTICE '已批量更新 % 个商品的库存', array_length(product_ids_param, 1);
END;
$$;
COMMENT ON PROCEDURE mall.batch_update_stock(INTEGER[], INTEGER[]) IS '批量更新商品库存存储过程：根据商品ID和数量数组批量扣减库存';

-- 生成月度销售报表存储过程
CREATE OR REPLACE PROCEDURE mall.generate_monthly_sales_report(IN year_param INTEGER, IN month_param INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    -- 删除旧报表（如果存在）
    DROP TABLE IF EXISTS audit.monthly_sales_report_temp;
    
    -- 创建临时报表表
    CREATE TABLE audit.monthly_sales_report_temp AS
    SELECT
        EXTRACT(MONTH FROM o.created_at) AS sales_month,
        EXTRACT(YEAR FROM o.created_at) AS sales_year,
        COUNT(o.order_id) AS total_orders,
        SUM(o.total_amount) AS total_sales,
        AVG(o.total_amount) AS avg_order_value,
        COUNT(DISTINCT o.user_id) AS unique_customers
    FROM mall.orders o
    WHERE o.status IN ('paid', 'shipped', 'delivered')
      AND EXTRACT(YEAR FROM o.created_at) = year_param
      AND EXTRACT(MONTH FROM o.created_at) = month_param
    GROUP BY EXTRACT(YEAR FROM o.created_at), EXTRACT(MONTH FROM o.created_at);
    
    RAISE NOTICE '已生成 % 年 % 月的销售报表', year_param, month_param;
END;
$$;
COMMENT ON PROCEDURE mall.generate_monthly_sales_report(INTEGER, INTEGER) IS '生成月度销售报表存储过程：创建指定年月的销售统计报表';

-- 批量导入用户存储过程（测试用）
CREATE OR REPLACE PROCEDURE mall.bulk_import_users(IN user_count INTEGER)
LANGUAGE plpgsql
AS $$
DECLARE
    i INTEGER;
    first_name_list TEXT[] := ARRAY['郑', '贺', '王', '刘', '陈'];
    last_name_list TEXT[] := ARRAY['龙', '芳', '娜', '秀英', '敏'];
BEGIN
    FOR i IN 1..user_count LOOP
        INSERT INTO mall.users (username, email, password_hash, first_name, last_name, phone, is_active)
        VALUES (
            'import_user' || i,
            'import_user' || i || '@test.com',
            'hashed_' || MD5('password' || i),
            first_name_list[(i % 5) + 1],
            last_name_list[(i % 5) + 1],
            '138' || LPAD(i::TEXT, 8, '0'),
            true
        );
    END LOOP;
    
    RAISE NOTICE '已批量导入 % 个用户', user_count;
END;
$$;
COMMENT ON PROCEDURE mall.bulk_import_users(INTEGER) IS '批量导入用户存储过程：生成指定数量的测试用户数据';

-- =====================================================
-- =====================================================
-- GIS SCHEMA - 函数
-- =====================================================
-- =====================================================

-- =====================================================
-- 函数定义（gis）
-- =====================================================

-- 计算两点之间距离（GIS函数）
CREATE OR REPLACE FUNCTION gis.calculate_distance(lat1 FLOAT, lon1 FLOAT, lat2 FLOAT, lon2 FLOAT)
RETURNS FLOAT AS $$
BEGIN
    RETURN ST_Distance(
        ST_MakePoint(lon1, lat1)::geography,
        ST_MakePoint(lon2, lat2)::geography
    ) / 1000; -- 返回公里数
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION gis.calculate_distance(FLOAT, FLOAT, FLOAT, FLOAT) IS '计算两点距离函数：返回两个经纬度坐标之间的距离（公里）';

-- 判断点是否在区域内（GIS函数）
CREATE OR REPLACE FUNCTION gis.is_point_in_zone(point_lat FLOAT, point_lon FLOAT, zone_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    point_geom GEOMETRY;
    zone_geom GEOMETRY;
BEGIN
    point_geom := ST_SetSRID(ST_MakePoint(point_lon, point_lat), 4326);
    zone_geom := (SELECT geometry FROM gis.delivery_zones WHERE delivery_zones.zone_id = gis.is_point_in_zone.zone_id);
    
    IF zone_geom IS NULL THEN
        RETURN false;
    END IF;
    
    RETURN ST_Contains(zone_geom, point_geom);
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION gis.is_point_in_zone(FLOAT, FLOAT, INTEGER) IS '判断点是否在区域内函数：检查坐标点是否在指定配送区域内';

-- =====================================================
-- =====================================================
-- PUBLIC SCHEMA - 通用函数
-- =====================================================
-- =====================================================

-- =====================================================
-- 函数定义（public）
-- =====================================================

-- 生成唯一ID函数
CREATE OR REPLACE FUNCTION public.generate_uuid()
RETURNS UUID AS $$
BEGIN
    RETURN gen_random_uuid();
END;
$$ LANGUAGE plpgsql;
COMMENT ON FUNCTION public.generate_uuid() IS '生成UUID函数：返回唯一的UUID值';

-- =====================================================
-- =====================================================
-- 数据库结构创建完成
-- =====================================================

-- 显示统计信息
SELECT
    'Schema创建完成' AS 状态,
    COUNT(*) AS 表数量
FROM information_schema.tables
WHERE table_schema IN ('mall', 'audit', 'gis')
  AND table_type = 'BASE TABLE'
UNION ALL
SELECT
    'Schema创建完成' AS 状态,
    COUNT(*) AS 视图数量
FROM information_schema.views
WHERE table_schema = 'mall'
UNION ALL
SELECT
    'Mall Schema创建完成' AS 状态,
    COUNT(*) AS 函数数量
FROM information_schema.routines
WHERE routine_schema = 'mall'
  AND routine_type = 'FUNCTION'
UNION ALL
SELECT
    'GIS Schema创建完成' AS 状态,
    COUNT(*) AS 函数数量
FROM information_schema.routines
WHERE routine_schema = 'gis'
  AND routine_type = 'FUNCTION'
UNION ALL
SELECT
    'Public Schema创建完成' AS 状态,
    COUNT(*) AS 函数数量
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_type = 'FUNCTION'
UNION ALL
SELECT
    'Mall Schema创建完成' AS 状态,
    COUNT(*) AS 存储过程数量
FROM information_schema.routines
WHERE routine_schema = 'mall'
  AND routine_type = 'PROCEDURE';

-- =====================================================
-- 使用说明
-- =====================================================
-- 1. Mall Schema - 电商核心
--    - 包含所有电商相关的表（用户、商品、订单等）
--    - 提供视图、触发器、函数和存储过程
--    - 使用方式：SELECT * FROM mall.users;
--
-- 2. Audit Schema - 审计日志
--    - 用于记录数据库操作日志和审计信息
--    - 可用于数据追踪和安全审计
--    - 使用方式：SELECT * FROM audit.audit_logs ORDER BY operation_time DESC;
--
-- 3. GIS Schema - 地理位置
--    - 包含PostGIS扩展和地理位置相关表
--    - 提供GIS相关函数
--    - 支持空间查询和地理计算
--    - 使用方式：SELECT store_name, ST_AsText(geometry) FROM gis.store_locations;
--
-- 4. Public Schema - 通用函数
--    - 包含通用函数（如UUID生成）
--    - 使用方式：SELECT public.generate_uuid();
--
-- 5. Mall Schema 函数调用示例
--    SELECT mall.get_user_total_spent(1);
--    SELECT mall.get_product_avg_rating(10);
--
-- 6. Mall Schema 存储过程调用示例
--    CALL mall.clean_expired_orders(30);
--    CALL mall.batch_update_stock(ARRAY[1,2,3], ARRAY[10,5,8]);
--    CALL mall.generate_monthly_sales_report(2024, 12);
--    CALL mall.bulk_import_users(100);
--
-- 7. GIS Schema 函数调用示例
--    SELECT gis.calculate_distance(39.9, 116.4, 31.2, 121.5);
--    SELECT gis.is_point_in_zone(39.9, 116.4, 1);
--
-- 8. Public Schema 函数调用示例
--    SELECT public.generate_uuid();
-- =====================================================
