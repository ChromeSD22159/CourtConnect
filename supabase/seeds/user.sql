/*-- SEEED
-- Zuerst den Benutzer erstellen (mit bcrypt-Hash für das Passwort)
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
        select
            '00000000-0000-0000-0000-000000000000',
            uuid_generate_v4 (),
            'authenticated',
            'authenticated',
            'user' || (ROW_NUMBER() OVER ()) || '@example.com',
            crypt ('password123', gen_salt ('bf')),
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
    );

-- ID des gerade erstellten Benutzers abrufen 
WITH inserted_user AS (
  SELECT id
  FROM auth.users
  WHERE email = 'test@user.de'
)

-- Nun das Benutzerprofil erstellen und die ID aus dem vorherigen Schritt verwenden
INSERT INTO public."UserProfile" ("userId", "firstName", "lastName", "birthday", "lastOnline") 
SELECT (SELECT id FROM inserted_user), 'Max', 'Mustermann', '2000-01-01', NOW();
*/

/*
INSERT INTO public."Team" ("teamName", "createdByUserAccountId", "headcoach", "joinCode", "email", "createdAt", "updatedAt")
SELECT 'Brooklyn', id, 'Frederik Kohler', '123456', 'frederik@kohler.de', NOW(), NOW()
FROM auth.users WHERE email = 'test@user.de';
*/ 