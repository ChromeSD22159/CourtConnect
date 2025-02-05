-- Löschen aller Tabellen (in umgekehrter Reihenfolge der Erstellung, um Abhängigkeiten zu berücksichtigen) 
DROP TABLE IF EXISTS public."UserProfile";
DROP TABLE IF EXISTS public."UserOnline";
DROP TABLE IF EXISTS public."UserAccount";
DROP TABLE IF EXISTS public."UpdateHistory";
DROP TABLE IF EXISTS public."Termine";
DROP TABLE IF EXISTS public."TeamMember";
DROP TABLE IF EXISTS public."TeamAdmin";
DROP TABLE IF EXISTS public."Team";
DROP TABLE IF EXISTS public."Statistic";
DROP TABLE IF EXISTS public."Request";
DROP TABLE IF EXISTS public."Interest";
DROP TABLE IF EXISTS public."Document";
DROP TABLE IF EXISTS public."DeletionRequest";
DROP TABLE IF EXISTS public."Chat";
DROP TABLE IF EXISTS public."Attendance"; 
DROP TABLE IF EXISTS public."Absence";

-- Erstellen der Tabellen (wie in deinem ursprünglichen Code)
create table
  public."Attendance" (
    id uuid not null default gen_random_uuid (),
    "userAccountId" uuid not null,
    "terminId" uuid not null,
    "startTime" timestamp without time zone not null,
    "endTime" timestamp without time zone not null,
    "attendanceStatus" text not null default 'Pending'::text,
    "createdAt" timestamp without time zone not null default now(),
    "updatedAt" timestamp without time zone not null default now(),
    "deletedAt" timestamp without time zone null,
    constraint attendance_pkey primary key (id),
    constraint unique_id unique (id)
  ) tablespace pg_default;

 CREATE OR REPLACE FUNCTION "LogAttendanceInsertUpdate"()
 RETURNS TRIGGER AS $$
 DECLARE
    user_id UUID;
BEGIN
   -- Get the userId from the UserAccount table based on the trainerId
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."userAccountId";

    IF user_id IS NULL THEN
        RAISE NOTICE 'userAccountId % not found in UserAccount', NEW."userAccountId"; 
    END IF;

  INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
    VALUES ('Attendance', NOW(), NOW(), user_id)
    ON CONFLICT ("tableString", "userId")
    DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

    RETURN NULL; 
END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "AttendanceInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Attendance"
 FOR EACH ROW
 EXECUTE FUNCTION "LogAttendanceInsertUpdate"();









create table
  public."Chat" (
    id uuid not null default gen_random_uuid (),
    "senderId" uuid not null,
    "recipientId" uuid not null,
    message text not null,
    "readedAt" timestamp with time zone null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint chat_pkey primary key (id)
  ) tablespace pg_default;

 CREATE OR REPLACE FUNCTION "LogChatInsertUpdate"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Chat', NOW(), NEW."senderId") 
      ON CONFLICT ("tableString", "userId") 
      DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogChatInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Chat"
 FOR EACH ROW
 EXECUTE FUNCTION "LogChatInsertUpdate"();









create table
  public."DeletionRequest" (
    id uuid not null default gen_random_uuid (),
    "userId" uuid not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint deletionrequest_pkey primary key (id),
    constraint DeletionRequest_userId_key unique ("userId")
  ) tablespace pg_default;









create table
  public."Document" (
    id uuid not null default gen_random_uuid (),
    "teamId" uuid not null,
    name text not null,
    info text not null,
    url text not null,
    "roleString" text not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint document_pkey primary key (id)
  ) tablespace pg_default;








create table
  public."Interest" (
    id uuid not null default gen_random_uuid (),
    "memberId" uuid not null,
    "terminId" uuid not null,
    "willParticipate" boolean not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint interest_pkey primary key (id)
  ) tablespace pg_default;


 CREATE OR REPLACE FUNCTION "LogInterestInsertUpdate"()
 RETURNS TRIGGER AS $$
DECLARE
    userId UUID;
BEGIN
    SELECT "userId" INTO userId
    FROM public."UserAccount" WHERE "id" IN (SELECT userAccountId FROM public."Member" WHERE id = NEW."memberId");

  IF user_id IS NULL THEN
        RAISE NOTICE 'memberId % nicht in Member oder TeamMember gefunden', NEW."memberId"; 
    END IF;

     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('Interest', NOW(), userId)
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogInterestInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Interest"
 FOR EACH ROW
 EXECUTE FUNCTION "LogInterestInsertUpdate"();









create table
  public."Request" (
    id uuid not null default gen_random_uuid (),
    "accountId" uuid not null,
    "teamId" uuid not null, 
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint requests_pkey primary key (id)
  ) tablespace pg_default;

 CREATE OR REPLACE FUNCTION "LogRequestInsertUpdateTrigger"()
 RETURNS TRIGGER AS $$  
 DECLARE
    user_id UUID;
BEGIN 
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."accountId";

    IF user_id IS NULL THEN
        RAISE NOTICE 'accountId % not found in UserAccount', NEW."accountId"; 
    END IF;

  INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
    VALUES ('Request', NOW(), NOW(), user_id)
    ON CONFLICT ("tableString", "userId")
    DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

    RETURN NULL; 
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogRequestInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Request"
 FOR EACH ROW
 EXECUTE FUNCTION "LogRequestInsertUpdateTrigger"();









create table
  public."Statistic" (
    id uuid not null default gen_random_uuid (),
    "userAccountId" uuid not null,
    "fouls" integer not null default 0,
    "twoPointAttempts" integer not null default 0,
    "threePointAttempts" integer not null default 0,
    "terminType" text not null default ''::text,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint statistic_pkey primary key (id)
  ) tablespace pg_default;

 CREATE OR REPLACE FUNCTION "LogStatisticInsertUpdate"()
 RETURNS TRIGGER AS $$
  DECLARE
      user_id UUID;
  BEGIN 
      SELECT "userId" INTO user_id
      FROM public."UserAccount"
      WHERE id = NEW."userAccountId";

      IF user_id IS NULL THEN
          RAISE NOTICE 'userAccountId % not found in UserAccount', NEW."userAccountId"; 
      END IF;

    INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
      VALUES ('Statistic', NOW(), NOW(), user_id)
      ON CONFLICT ("tableString", "userId")
      DO UPDATE SET 
          "timestamp" = NOW(), 
          "updatedAt" = NOW(); 

      RETURN NULL; 
  END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogStatisticInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Statistic"
 FOR EACH ROW
 EXECUTE FUNCTION "LogStatisticInsertUpdate"();









create table
  public."Team" (
    id uuid not null default gen_random_uuid (),
    "teamName" text not null,
    "createdByUserAccountId" uuid not null default gen_random_uuid (),
    headcoach text not null,
    "joinCode" text not null,
    email text not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint team_pkey primary key (id),
    constraint team_joincode_key unique ("joinCode")
  ) tablespace pg_default;

 CREATE OR REPLACE FUNCTION "LogTeamInsertUpdate"()
 RETURNS TRIGGER AS $$
DECLARE
    user_id UUID;
BEGIN 
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."createdByUserAccountId";

    IF user_id IS NULL THEN
        RAISE NOTICE 'createdByUserAccountId % not found in UserAccount', NEW."createdByUserAccountId"; 
    END IF;

  INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
    VALUES ('Team', NOW(), NOW(), user_id)
    ON CONFLICT ("tableString", "userId")
    DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

    RETURN NULL; 
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogTeamInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Team"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamInsertUpdate"();









create table
  public."TeamAdmin" (
    id uuid not null default gen_random_uuid (),
    "teamId" uuid not null,
    "userAccountId" uuid not null,
    role text not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint teamadmin_pkey primary key (id)
  ) tablespace pg_default;

CREATE OR REPLACE FUNCTION "LogTeamAdminInsertUpdate"()
 RETURNS TRIGGER AS $$
DECLARE
    user_id UUID;
BEGIN 
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."userAccountId";

    IF user_id IS NULL THEN
        RAISE NOTICE 'userAccountId % not found in UserAccount', NEW."userAccountId"; 
    END IF;

  INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
    VALUES ('TeamAdmin', NOW(), NOW(), user_id)
    ON CONFLICT ("tableString", "userId")
    DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

    RETURN NULL; 
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogTeamAdminInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "TeamAdmin"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamAdminInsertUpdate"(); 








-- DROP TRIGGER IF EXISTS "LogUserAccountCrudTrigger" ON public."UserAccount";
create table
  public."TeamMember" (
    id uuid not null default gen_random_uuid (),
    "userAccountId" uuid not null,
    "teamId" uuid not null,
    role text not null,
     "shirtNumber" smallint null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint teammember_pkey primary key (id)
  ) tablespace pg_default;

CREATE OR REPLACE FUNCTION "LogTeamMemberInsertUpdate"()
 RETURNS TRIGGER AS $$
DECLARE
    user_id UUID;
BEGIN 
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."userAccountId"; 

     IF user_id IS NULL THEN
        RAISE NOTICE 'userAccountId % not found in UserAccount', NEW."userAccountId"; 
        RAISE EXCEPTION 'userAccountId % not found in UserAccount', NEW."userAccountId"; 
    END IF;

    IF user_id IS NOT NULL THEN -- Add this check
        INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
        VALUES ('TeamMember', NOW(), NOW(), user_id)
        ON CONFLICT ("tableString", "userId") DO UPDATE SET 
            "timestamp" = NOW(),
            "updatedAt" = NOW();
    END IF;

    RETURN NULL; 
 END;
 $$ LANGUAGE plpgsql;

 CREATE TRIGGER "LogTeamMemberInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "TeamMember"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamMemberInsertUpdate"(); 







create table
  public."Termin" (
    id uuid not null default gen_random_uuid (),
    "teamId" uuid not null,
    "typeString" text not null,
    "startTime" timestamp without time zone not null,
    "endTime" timestamp without time zone not null,
     "terminType" text not null default ''::text, 
    title text not null,
    place text not null,
    infomation text not null,
    "durationMinutes" smallint not null default '0'::smallint,
    "createdByUserAccountId" uuid not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint termine_pkey primary key (id)
  ) tablespace pg_default;


 CREATE OR REPLACE FUNCTION "LogTermineInsertUpdate"()
 RETURNS TRIGGER AS $$
DECLARE
    user_id UUID;
BEGIN
   -- Get the userId from the UserAccount table based on the trainerId
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."createdByUserAccountId";

    SELECT id INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."createdByUserAccountId";

      IF user_id IS NULL THEN
        RAISE NOTICE 'userId % not found in UserAccount', NEW."createdByUserAccountId"; 
        RAISE EXCEPTION 'userId % not found in UserAccount', NEW."createdByUserAccountId"; 
      END IF;

    IF user_id IS NOT NULL THEN -- Add this check
        INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
        VALUES ('Termin', NOW(), NOW(), user_id)
        ON CONFLICT ("tableString", "userId") DO UPDATE SET 
            "timestamp" = NOW(),
            "updatedAt" = NOW();
    END IF; 

    RETURN NULL; 
END;
 $$ LANGUAGE plpgsql;

create trigger "LogTermineInsertUpdateTrigger"
after insert 
or update on "Termin" for each row
execute function "LogTermineInsertUpdate" ();
 


CREATE OR REPLACE FUNCTION InsertAttendanceOnTerminInsert()
RETURNS TRIGGER AS $$
DECLARE
    team_member RECORD;
BEGIN
    -- Iteriere über alle User, die die gleiche teamId haben
    FOR team_member IN 
        SELECT "id" FROM public."UserAccount" WHERE "teamId" = NEW."teamId"
    LOOP
        -- Füge für jeden User einen Eintrag in die Attendance-Tabelle hinzu
        INSERT INTO public."Attendance" 
        ("userAccountId", "terminId", "startTime", "endTime", "createdAt", "updatedAt", "deletedAt", "attendanceStatus")
        VALUES 
        (team_member."id", NEW."id", NEW."startTime", NEW."endTime", NOW(), NOW(), NULL, 'Pending');
        ON CONFLICT ("userAccountId", "terminId") DO UPDATE
        SET 
            "startTime" = EXCLUDED."startTime",
            "endTime" = EXCLUDED."endTime",
            "updatedAt" = NOW()
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER triggerInsertAttendanceOnTerminInsert
AFTER INSERT ON public."Termin"
FOR EACH ROW 
EXECUTE FUNCTION InsertAttendanceOnTerminInsert();





create table
  public."UpdateHistory" (
    id uuid not null default gen_random_uuid (),
    "tableString" text not null,
    "userId" uuid not null,
    timestamp timestamp with time zone not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint updatehistory_pkey primary key (id),
    constraint unique_table_user unique ("tableString", "userId")
  ) tablespace pg_default;







-- DROP TRIGGER IF EXISTS "LogUserAccountCrudTrigger" ON public."UserAccount";
create table
  public."UserAccount" (
    id uuid not null default gen_random_uuid (),
    "userId" uuid not null,
    "teamId" uuid null,
    position text not null,
    role text not null,
    "displayName" text not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint useraccount_pkey primary key (id)
  ) tablespace pg_default;

 CREATE OR REPLACE FUNCTION "LogUserAccountInsertUpdate"()
 RETURNS TRIGGER AS $$
 BEGIN
     INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
     VALUES ('UserAccount', NOW(), NEW."userId")
     ON CONFLICT ("tableString", "userId")
     DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

     RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;

 -- 2. Trigger erstellen
 CREATE TRIGGER "LogUserAccountInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "UserAccount"
 FOR EACH ROW
 EXECUTE FUNCTION "LogUserAccountInsertUpdate"();







create table
  public."UserOnline" (
    id uuid not null default gen_random_uuid (),
    "userId" uuid not null,
    "firstName" text not null,
    "lastName" text not null,
    "deviceToken" text not null,
    timestamp timestamp with time zone not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint useronline_pkey primary key (id),
    constraint UserOnline_userId_key unique ("userId"),
    constraint UserOnline_deviceToken_key unique ("deviceToken"),
    constraint unique_user_device unique ("userId", "deviceToken")
  ) tablespace pg_default;






-- DROP TRIGGER IF EXISTS "LogUserProfileCrudTrigger" ON public."UserProfile";
create table
  public."UserProfile" (
    id uuid not null default gen_random_uuid (),
    "userId" uuid not null,
    "firstName" text not null,
    "lastName" text not null,
    birthday text not null,
    "fcmToken" text null,
    "lastOnline" timestamp with time zone not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    "onBoardingAt" timestamp with time zone null,
    constraint userprofile_pkey primary key (id),
    constraint UserProfile_userId_key unique ("userId")
  ) tablespace pg_default;

CREATE OR REPLACE FUNCTION "LogUserProfileInsertUpdate"()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "userId")
    VALUES ('UserProfile', NOW(), COALESCE(NEW."userId", OLD."userId"))
    ON CONFLICT ("tableString", "userId")
      DO UPDATE SET 
        "timestamp" = NOW(), 
        "updatedAt" = NOW(); 

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

create trigger "LogUserProfileInsertUpdateTrigger"
after insert 
or update on "UserProfile" for each row
execute function "LogUserProfileInsertUpdate"();
 




create table
  public."Absence" (
   id uuid not null default gen_random_uuid (),
    "userAccountId" uuid not null,
    "teamId" uuid not null,
    date text not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone null,
    constraint absence_pkey primary key (id)
  ) tablespace pg_default;

CREATE OR REPLACE FUNCTION "LogAbsenceInsertUpdate"()
 RETURNS TRIGGER AS $$
DECLARE
    user_id UUID;
BEGIN 
    SELECT "userId" INTO user_id
    FROM public."UserAccount"
    WHERE id = NEW."userAccountId"; 

     IF user_id IS NULL THEN
        RAISE NOTICE 'userAccountId % not found in Absence', NEW."userAccountId"; 
        RAISE EXCEPTION 'userAccountId % not found in Absence', NEW."userAccountId"; 
    END IF;

    IF user_id IS NOT NULL THEN -- Add this check
        INSERT INTO public."UpdateHistory" ("tableString", "timestamp", "updatedAt", "userId")
        VALUES ('Absence', NOW(), NOW(), user_id)
        ON CONFLICT ("tableString", "userId") DO UPDATE SET 
            "timestamp" = NOW(),
            "updatedAt" = NOW();
    END IF;

    RETURN NULL; 
 END;
 $$ LANGUAGE plpgsql;

 CREATE TRIGGER "LogAbsenceInsertUpdateTrigger"
 AFTER INSERT OR UPDATE ON "Absence"
 FOR EACH ROW
 EXECUTE FUNCTION "LogTeamMemberInsertUpdate"(); 






 -- BUCKETS
insert into storage.buckets (id, name, public)
values ('TeamFiles', 'TeamFiles', true);

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
 
-- Richtlinie für ALL (CRUD)
CREATE POLICY "Authenticated users can CRUD files from TeamFiles" ON storage.objects FOR ALL TO authenticated USING (bucket_id = 'TeamFiles');