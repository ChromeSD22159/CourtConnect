INSERT INTO
    auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) (
        SELECT
            '00000000-0000-0000-0000-000000000000',  -- Or remove instance_id if not needed
            uuid_generate_v4 (),
            'authenticated',
            'authenticated',
            'test@user.de',  -- Unique emails
            crypt ('frederik', gen_salt ('bf')),  -- Secure password hashing
            current_timestamp,
            current_timestamp,
            current_timestamp,
            '{"provider":"email","providers":["email"]}',
            '{}',
            current_timestamp,
            current_timestamp,
            '',
            '',
            '',
            ''
        FROM
            generate_series(1, 1)
    );
-- Create UserProfiles for ALL the newly created users (the key change!)
INSERT INTO public."UserProfile" ("userId", "firstName", "lastName", "birthday", "lastOnline")
SELECT id, 'Frederik', 'Kohler', '22.11.1986', NOW() 
FROM auth.users
WHERE email = 'test@user.de';

-- Create email identities for the new users
INSERT INTO
    auth.identities (
        id,
        provider_id,
        user_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    ) (
        SELECT
            uuid_generate_v4 (),
            uuid_generate_v4 (),
            id,
            format('{"sub":"%s","email":"%s"}', id::text, email)::jsonb,
            'email',
            current_timestamp,
            current_timestamp,
            current_timestamp
        FROM
            auth.users
        WHERE raw_user_meta_data = '{}' -- Filter to avoid already assigned identities if needed.
    );


    INSERT INTO
    auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) (
        SELECT
            '00000000-0000-0000-0000-000000000000',  -- Or remove instance_id if not needed
            uuid_generate_v4 (),
            'authenticated',
            'authenticated',
           'user' || (ROW_NUMBER() OVER ()) || '@example.com',
            crypt ('frederik', gen_salt ('bf')),  -- Secure password hashing
            current_timestamp,
            current_timestamp,
            current_timestamp,
            '{"provider":"email","providers":["email"]}',
            '{}',
            current_timestamp,
            current_timestamp,
            '',
            '',
            '',
            ''
        FROM
            generate_series(1, 20)
    );


-- Create UserProfiles for ALL the newly created users (the key change!)
WITH first_names AS (
    SELECT name
    FROM (VALUES 
        ('Max'), ('Anna'), ('Paul'), ('Lisa'), ('Tom'), 
        ('Sarah'), ('Felix'), ('Julia'), ('Tim'), ('Laura')
    ) AS names(name)
),
last_names AS (
    SELECT name
    FROM (VALUES 
        ('Müller'), ('Schmidt'), ('Schneider'), ('Fischer'), ('Weber'), 
        ('Wagner'), ('Becker'), ('Hoffmann'), ('Schäfer'), ('Koch')
    ) AS names(name)
)
INSERT INTO public."UserProfile" ("userId", "firstName", "lastName", "birthday", "lastOnline")
SELECT 
    id, 
    (SELECT name FROM first_names ORDER BY random() LIMIT 1),  -- Random first name for EACH row
    (SELECT name FROM last_names ORDER BY random() LIMIT 1),   -- Random last name for EACH row
    to_char(
        DATE '1950-01-01' + (random() * (DATE '2020-12-31' - DATE '1950-01-01'))::int,
        'DD.MM.YYYY' -- Formatierung als String im Format "dd.mm.yyyy"
    ),
    NOW() 
FROM auth.users
WHERE raw_user_meta_data = '{}' AND NOT email = 'test@user.de'; 