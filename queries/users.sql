-- ===============================
-- USER: Get all
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_get_all () RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ
) LANGUAGE sql STABLE AS $$
SELECT u.user_id,
u.user_name,
u.user_email,
u.user_phone,
u.user_address,
u.last_login,
u.created_date,
u.updated_date
FROM auth.users u
$$;

-- ===============================
-- USER: Get by id
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_get_by_id (p_user_id BIGINT) RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ
) LANGUAGE sql STABLE AS $$
SELECT u.user_id,
u.user_name,
u.user_email,
u.user_phone,
u.user_address,
u.last_login,
u.created_date,
u.updated_date
FROM auth.users AS u
WHERE u.user_id = p_user_id
$$;

-- ===============================
-- USER: Get by email
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_get_by_email (p_user_email CITEXT) 
    RETURNS TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ
) LANGUAGE sql STABLE AS $$
SELECT u.user_id,
u.user_name,
u.user_email,
u.user_phone,
u.user_address,
u.last_login,
u.created_date,
u.updated_date
FROM auth.users AS u
WHERE u.user_email = p_user_email
$$;

-- ===============================
-- USER: Create
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_create (
        p_user_name VARCHAR,
        p_user_email CITEXT,
        p_user_phone VARCHAR,
        p_user_address VARCHAR,
        p_password_hash VARCHAR
) RETURNS
TABLE (
    user_id BIGINT,
    user_name VARCHAR,
    user_email CITEXT,
    user_phone VARCHAR,
    user_address VARCHAR,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ,
    updated_date TIMESTAMPTZ
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
INSERT INTO auth.users AS u (
user_name,
user_email,
user_phone,
user_address,
password_hash
)
VALUES ( p_user_name,
p_user_email, 
p_user_phone, 
p_user_address, 
p_password_hash
)
RETURNING u.user_id,
u.user_name,
u.user_email,
u.user_phone,
u.user_address,
u.last_login,
u.created_date,
u.updated_date;
EXCEPTION
WHEN unique_violation THEN RAISE EXCEPTION 'The email % is already in use',
p_user_email USING ERRCODE = '23505',
HINT = 'Email must be unique';
END;
$$;

-- ===============================
-- USER: Update
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_update (
        p_user_id BIGINT,
        p_user_name VARCHAR DEFAULT NULL,
        p_user_email CITEXT DEFAULT NULL,
        p_user_phone VARCHAR DEFAULT NULL,
        p_user_address VARCHAR DEFAULT NULL,
        p_password_hash VARCHAR DEFAULT NULL
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
    updated_date TIMESTAMPTZ
) LANGUAGE plpgsql AS $$ BEGIN RETURN QUERY
UPDATE auth.users AS u
SET
user_name = COALESCE(p_user_name , u.user_name), 
user_email = COALESCE(p_user_email , u.user_email),
user_phone = COALESCE(p_user_phone , u.user_phone),
user_address = COALESCE(p_user_address , u.user_address),
password_hash = COALESCE(p_password_hash , u.password_hash),
updated_date = now()
WHERE u.user_id = p_user_id
RETURNING 
u.user_id,
u.user_name,
u.user_email, 
u.user_phone, 
u.user_address,
u.password_hash,
u.last_login, 
u.created_date,
u.updated_date;
END;
$$;

-- ===============================
-- USER: Soft delete
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_soft_delete (
        p_user_id BIGINT
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$ BEGIN
UPDATE auth.users
SET 
is_active = FALSE,
updated_date = now()
WHERE user_id = p_user_id;
RETURN FOUND;
END;
$$;

-- ===============================
-- USER: Reactivate
-- ===============================
CREATE OR REPLACE
    FUNCTION auth.user_soft_reactivate (
        p_user_id BIGINT
) RETURNS BOOLEAN LANGUAGE plpgsql AS $$ BEGIN
UPDATE auth.users
SET 
is_active = TRUE,
updated_date = now()
WHERE user_id = p_user_id;
RETURN FOUND;
END;
$$;