-- =====================================================
-- App_db数据库结构脚本
-- 数据库名称: app_db
-- 字符集: UTF8
-- 版本: v1.0.0
-- 创建日期: 2025-12-25
-- =====================================================

-- 删除已存在的数据库（谨慎使用）
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
-- 序列定义
-- =====================================================

-- 用户表序列
CREATE SEQUENCE users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 地址表序列
CREATE SEQUENCE addresses_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 用户资料表序列
CREATE SEQUENCE user_profiles_profile_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 分类表序列
CREATE SEQUENCE categories_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 商品表序列
CREATE SEQUENCE products_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 商品图片表序列
CREATE SEQUENCE product_images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 订单表序列
CREATE SEQUENCE orders_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 订单项表序列
CREATE SEQUENCE order_items_order_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 订单状态历史表序列
CREATE SEQUENCE order_status_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 支付表序列
CREATE SEQUENCE payments_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- 评论表序列
CREATE SEQUENCE reviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- =====================================================
-- 表定义
-- =====================================================

-- 用户表
CREATE TABLE users (
    user_id INTEGER DEFAULT nextval('users_user_id_seq'::regclass) NOT NULL,
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

-- 地址表
CREATE TABLE addresses (
    address_id INTEGER DEFAULT nextval('addresses_address_id_seq'::regclass) NOT NULL,
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
        REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 用户资料表
CREATE TABLE user_profiles (
    profile_id INTEGER DEFAULT nextval('user_profiles_profile_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL UNIQUE,
    gender CHAR(1),
    birth_date DATE,
    avatar_url VARCHAR(500),
    bio TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT user_profiles_pkey PRIMARY KEY (profile_id),
    CONSTRAINT user_profiles_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 分类表
CREATE TABLE categories (
    category_id INTEGER DEFAULT nextval('categories_category_id_seq'::regclass) NOT NULL,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    parent_category_id INTEGER,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT true NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT categories_pkey PRIMARY KEY (category_id),
    CONSTRAINT categories_parent_category_id_fkey FOREIGN KEY (parent_category_id)
        REFERENCES categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- 商品表
CREATE TABLE products (
    product_id INTEGER DEFAULT nextval('products_product_id_seq'::regclass) NOT NULL,
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
        REFERENCES categories(category_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 商品图片表
CREATE TABLE product_images (
    image_id INTEGER DEFAULT nextval('product_images_image_id_seq'::regclass) NOT NULL,
    product_id INTEGER NOT NULL,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(200),
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_primary BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT product_images_pkey PRIMARY KEY (image_id),
    CONSTRAINT product_images_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 订单表
CREATE TABLE orders (
    order_id INTEGER DEFAULT nextval('orders_order_id_seq'::regclass) NOT NULL,
    user_id INTEGER NOT NULL,
    address_id INTEGER NOT NULL,
    order_number VARCHAR(50) NOT NULL UNIQUE,
    total_amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT orders_pkey PRIMARY KEY (order_id),
    CONSTRAINT orders_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT orders_address_id_fkey FOREIGN KEY (address_id)
        REFERENCES addresses(address_id)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT orders_status_check CHECK (status IN ('pending', 'paid', 'shipped', 'delivered', 'cancelled', 'refunded'))
);

-- 订单项表
CREATE TABLE order_items (
    order_item_id INTEGER DEFAULT nextval('order_items_order_item_id_seq'::regclass) NOT NULL,
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT order_items_pkey PRIMARY KEY (order_item_id),
    CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT order_items_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 订单状态历史表
CREATE TABLE order_status_history (
    history_id INTEGER DEFAULT nextval('order_status_history_history_id_seq'::regclass) NOT NULL,
    order_id INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    remark TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT order_status_history_pkey PRIMARY KEY (history_id),
    CONSTRAINT order_status_history_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- 支付表
CREATE TABLE payments (
    payment_id INTEGER DEFAULT nextval('payments_payment_id_seq'::regclass) NOT NULL,
    order_id INTEGER NOT NULL,
    payment_method VARCHAR(50) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending' NOT NULL,
    transaction_id VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT payments_pkey PRIMARY KEY (payment_id),
    CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT payments_status_check CHECK (status IN ('pending', 'success', 'failed', 'refunded'))
);

-- 评论表
CREATE TABLE reviews (
    review_id INTEGER DEFAULT nextval('reviews_review_id_seq'::regclass) NOT NULL,
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
        REFERENCES users(user_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT reviews_product_id_fkey FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT reviews_rating_check CHECK (rating >= 1 AND rating <= 5)
);

-- =====================================================
-- 索引定义
-- =====================================================

-- 用户表索引
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_created_at ON users(created_at);

-- 地址表索引
CREATE INDEX idx_addresses_user_id ON addresses(user_id);

-- 用户资料表索引
CREATE INDEX idx_user_profiles_user_id ON user_profiles(user_id);

-- 分类表索引
CREATE INDEX idx_categories_parent_category_id ON categories(parent_category_id);
CREATE INDEX idx_categories_is_active ON categories(is_active);
CREATE INDEX idx_categories_sort_order ON categories(sort_order);

-- 商品表索引
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_is_active ON products(is_active);
CREATE INDEX idx_products_price ON products(price);
CREATE INDEX idx_products_created_at ON products(created_at);

-- 商品图片表索引
CREATE INDEX idx_product_images_product_id ON product_images(product_id);

-- 订单表索引
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_address_id ON orders(address_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_orders_created_at ON orders(created_at);
CREATE INDEX idx_orders_order_number ON orders(order_number);

-- 订单项表索引
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- 订单状态历史表索引
CREATE INDEX idx_order_status_history_order_id ON order_status_history(order_id);
CREATE INDEX idx_order_status_history_created_at ON order_status_history(created_at);

-- 支付表索引
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_created_at ON payments(created_at);
CREATE INDEX idx_payments_transaction_id ON payments(transaction_id);

-- 评论表索引
CREATE INDEX idx_reviews_product_id ON reviews(product_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_reviews_created_at ON reviews(created_at);

-- =====================================================
-- 触发器定义
-- =====================================================

-- 自动更新updated_at字段的触发器函数
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 为users表添加触发器
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 为user_profiles表添加触发器
CREATE TRIGGER update_user_profiles_updated_at
    BEFORE UPDATE ON user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 为products表添加触发器
CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 为orders表添加触发器
CREATE TRIGGER update_orders_updated_at
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 为reviews表添加触发器
CREATE TRIGGER update_reviews_updated_at
    BEFORE UPDATE ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- 视图定义
-- =====================================================

-- 订单汇总视图
CREATE OR REPLACE VIEW order_summary AS
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
FROM orders o
INNER JOIN users u ON o.user_id = u.user_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.order_id, o.order_number, o.user_id, u.username, u.email, o.status, o.total_amount, o.created_at;

-- 商品汇总视图
CREATE OR REPLACE VIEW product_summary AS
SELECT
    p.product_id,
    p.name,
    p.price,
    p.stock_quantity,
    c.name AS category_name,
    COUNT(pi.image_id) AS image_count,
    AVG(r.rating) AS average_rating,
    COUNT(r.review_id) AS review_count
FROM products p
INNER JOIN categories c ON p.category_id = c.category_id
LEFT JOIN product_images pi ON p.product_id = pi.product_id
LEFT JOIN reviews r ON p.product_id = r.product_id
WHERE p.is_active = true
GROUP BY p.product_id, p.name, p.price, p.stock_quantity, c.name;

-- =====================================================
-- 注释
-- =====================================================

-- 表注释
COMMENT ON TABLE users IS '用户表：存储用户基本信息';
COMMENT ON TABLE addresses IS '地址表：存储用户收货地址';
COMMENT ON TABLE user_profiles IS '用户资料表：存储用户扩展信息';
COMMENT ON TABLE categories IS '分类表：存储商品分类信息';
COMMENT ON TABLE products IS '商品表：存储商品信息';
COMMENT ON TABLE product_images IS '商品图片表：存储商品图片';
COMMENT ON TABLE orders IS '订单表：存储订单基本信息';
COMMENT ON TABLE order_items IS '订单项表：存储订单详情';
COMMENT ON TABLE order_status_history IS '订单状态历史表：存储订单状态变更记录';
COMMENT ON TABLE payments IS '支付表：存储支付记录';
COMMENT ON TABLE reviews IS '评论表：存储商品评论';

-- 列注释
COMMENT ON COLUMN users.username IS '用户名';
COMMENT ON COLUMN users.email IS '电子邮件';
COMMENT ON COLUMN users.password_hash IS '密码哈希值';
COMMENT ON COLUMN users.is_active IS '是否激活';

COMMENT ON COLUMN categories.parent_category_id IS '父分类ID，支持多级分类';

COMMENT ON COLUMN products.stock_quantity IS '库存数量';

COMMENT ON COLUMN orders.order_number IS '订单编号，唯一';
COMMENT ON COLUMN orders.status IS '订单状态：pending/paid/shipped/delivered/cancelled/refunded';

COMMENT ON COLUMN reviews.rating IS '评分：1-5分';
COMMENT ON COLUMN reviews.is_verified IS '是否验证购买';

-- =====================================================
-- 数据库结构创建完成
-- =====================================================
