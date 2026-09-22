CREATE EXTENSION IF NOT EXISTS citext;
CREATE SCHEMA IF NOT EXISTS auth;
CREATE SCHEMA IF NOT EXISTS core;
CREATE TABLE IF NOT EXISTS auth.users (
    users_id BIGINT GENERATE ALWAYS AS IDENTITY PRIMARY KEY,
    users_name VARCHAR(200) NOT NULL,
    users_email CITEX NOT NULL UNIQUE,
    users_phone VARCHAR(30),
    users_address VARCHAR(200),
    password_hash VARCHAR(255) NOT NULL,
    last_login TIMESTAMP,
    creation_date TIMESTAMP NOT NULL DEFAULT now(),
    updated_date TIMESTAMP NOT NULL DEFAULT now(),
);

RAISE NOTICE 'User table created';

END IF;

END;

$$;

CREATE TABLE IF NOT EXISTS core.channel (
    channel_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    channel_name VARCHAR(120) NOT NULL,
    channel_country VARCHAR(50) NOT NULL,
    channel_language VARCHAR(50) NOT NULL,
    channel_category VARCHAR(50) NOT NULL,
    streamUrl VARCHAR(255) NOT NULL,
    tvgId VARCHAR(120) NULL,
);

RAISE NOTICE 'Channel table created';

END IF;

END;

$$;

-- ===============================
-- USER: Get all
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.users_get_all () RETURNS
TABLE (
    users_id BIGINT,
    users_name VARCHAR,
    users_email CITEXT,
    users_phone VARCHAR,
    users_address VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ
) LANGUAGE sql STABLE AS $$
SELECT u.users_id,
u.users_name,
u.users_email,
u.users_phone,
u.users_address,
u.last_login,
u.created_date,
u.updated_date
FROM auth.users u
$$;

-- ===============================
-- USER: Get by id
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_get_by_id (user_id BIGINT) RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    password_hash VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ
) LANGUAGE sql STABLE AS $$
SELECT u.user_id,
u.user_name,
u.user_email,
u.user_phone,
u.user_address,
u.password_hash,
u.last_login,
u.created_date,
u.updated_date
FROM auth.user u
WHERE u.user_id = user_id
$$;

-- ===============================
-- USER: Get by email
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_get_by_id (user_email CITEXT) RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    password_hash VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ,
) LANGUAGE sql STABLE AS $$
SELECT u.user_id,
u.user_name,
u.user_email,
u.user_phone,
u.user_address,
u.password_hash,
u.last_login,
u.created_date,
u.updated_date,
FROM auth.user u
WHERE u.user_id = user_id
$$;

-- ===============================
-- USER: Create
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_create (
        user_name VARCHAR,
        user_email CITEXT,
        user_phone VARCHAR,
        user_address VARCHAR,
        password_hash VARCHAR,
) RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    password_hash VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ,
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
INSERT INTO auth.user (
user_name,
user_email,
user_phone,
user_address,
password_hash,
)
SELECT user_name,
user_email, 
user_phone, 
user_address, 
password_hash,
FROM auth.user u
RETURNING auth.user.user_id,
auth.user.user_name,
auth.user.user_email,
auth.user.user_phone,
auth.user.user_address,
auth.user.password_hash,
auth.user.created_date,
auth.user.updated_date,
EXCEPTION
WHEN unique_violetion THEN RAISE EXCEPTION 'The email % is already in use',
user_email USING ERRCODE = '23505',
HINT = 'Email must be unique';
END;

$$;

-- ===============================
-- USER: Update
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_update (
        user_name VARCHAR,
        user_email CITEXT,
        user_phone VARCHAR,
        user_address VARCHAR,
        password_hash VARCHAR,
) RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    password_hash VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ,
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
UPDATE auth.user u
SET
user_name = COALESCE(u.user_name), 
user_email = COALESCE(u.user_email),
user_phone = COALESCE(u.user_phone),
user_address = COALESCE(u.user_address),
password_hash = COALESCE(u.user_password_hash),
updated_date = now()
WHERE u user_id = user_id
RETURNING 
u user_name,
u user_email, 
u user_phone, 
u user_address, 
u password_hash,
u last_login,
u updated_date,
END;
$$;

-- ===============================
-- USER: Soft delete
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_soft_delete (
        user_id BIGINT,
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$ BEGIN
UPDATE auth.user u
SET 
updated_date = now()
WHERE u user_id = user_id
RETURN FOUND;
END;
$$;

-- ===============================
-- USER: Reactivate
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_soft_reactivate (
        user_id BIGINT,
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$ BEGIN
UPDATE auth.user u
SET 
updated_date = now()
WHERE u user_id = user_id
RETURN FOUND;
END;
$$;