CREATE TABLE IF NOT EXISTS core.channels (
    channel_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    channel_name VARCHAR(120) NOT NULL,
    channel_country VARCHAR(50) NOT NULL,
    channel_language VARCHAR(50) NOT NULL,
    channel_category VARCHAR(50) NOT NULL,
    stream_url VARCHAR(255) NOT NULL,
    tvg_id VARCHAR(120) NULL
);