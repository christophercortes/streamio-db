CREATE TABLE IF NOT EXISTS auth.users (
    user_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_name VARCHAR(200) NOT NULL,
    user_email CITEXT NOT NULL UNIQUE,
    user_phone VARCHAR(30),
    user_address VARCHAR(200),
    password_hash VARCHAR(255) NOT NULL,
    last_login TIMESTAMPTZ,
    created_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);