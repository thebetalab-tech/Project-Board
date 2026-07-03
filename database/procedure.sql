-- ==========================================
-- 2. STORED PROCEDURES
-- ==========================================

-- 1. Register a New User (Student, Faculty, or Admin)
GO
CREATE PROCEDURE sp_RegisterUser
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @PasswordHash NVARCHAR(256),
    @EnrollmentNo NVARCHAR(20) = NULL,
    @Role NVARCHAR(10),
    @IsLeader BIT = 0
AS
BEGIN
    INSERT INTO Users (FullName, Email, PasswordHash, EnrollmentNo, Role, IsLeader)
    VALUES (@FullName, @Email, @PasswordHash, @EnrollmentNo, @Role, @IsLeader);
END
GO

-- 2. Create a Group (Leader Action)
CREATE PROCEDURE sp_CreateGroup
    @GroupName NVARCHAR(100),
    @LeaderId INT,
    @TechId INT
AS
BEGIN
    -- Insert the new group
    INSERT INTO Groups (GroupName, LeaderId, TechId, Status)
    VALUES (@GroupName, @LeaderId, @TechId, 'Forming');

    -- Automatically add the Leader to the GroupMembers table as 'Accepted'
    DECLARE @NewGroupId INT = SCOPE_IDENTITY();
    INSERT INTO GroupMembers (GroupId, UserId, JoinStatus)
    VALUES (@NewGroupId, @LeaderId, 'Accepted');
END
GO

-- 3. Send an Invitation to a Student
CREATE PROCEDURE sp_InviteStudent
    @GroupId INT,
    @UserId INT
AS
BEGIN
    INSERT INTO GroupMembers (GroupId, UserId, JoinStatus)
    VALUES (@GroupId, @UserId, 'Pending');
END
GO

-- 4. Student Responds to Invitation (Accept or Reject)
CREATE PROCEDURE sp_RespondToInvite
    @GroupId INT,
    @UserId INT,
    @Response NVARCHAR(15) -- Must pass 'Accepted' or 'Rejected' from frontend
AS
BEGIN
    UPDATE GroupMembers
    SET JoinStatus = @Response
    WHERE GroupId = @GroupId AND UserId = @UserId;
END
GO

-- 5. Submit a Project Proposal
CREATE PROCEDURE sp_SubmitProject
    @GroupId INT,
    @ProjectType CHAR(3),
    @ProjectTitle NVARCHAR(150),
    @NormalizedTitle NVARCHAR(150),
    @Functionality NVARCHAR(1000)
AS
BEGIN
    INSERT INTO Projects (GroupId, ProjectType, ProjectTitle, NormalizedTitle, Functionality, Status)
    VALUES (@GroupId, @ProjectType, @ProjectTitle, @NormalizedTitle, @Functionality, 'Pending');
END
GO

-- 6. Mentor Rejects a Group (The logic we discussed earlier)
CREATE PROCEDURE sp_MentorRejectsGroup
    @GroupId INT,
    @FacultyId INT
AS
BEGIN
    -- 1. Log the rejection so they don't show up again
    INSERT INTO GroupMentorRejections (GroupId, FacultyId)
    VALUES (@GroupId, @FacultyId);

    -- 2. Reset the group so the leader has to pick someone else
    UPDATE Groups
    SET Status = 'Forming', MentorId = NULL
    WHERE GroupId = @GroupId;
END
GO

-- 7. Fetch Full Group Details (The string aggregation query)
CREATE PROCEDURE sp_GetFullGroupDetails
AS
BEGIN
    SELECT 
        g.GroupName,
        Leader.FullName AS LeaderName,
        ISNULL(Mentor.FullName, 'Not Assigned') AS MentorName,
        STRING_AGG(Member.FullName, ', ') AS AllMembers
    FROM 
        Groups g
    INNER JOIN 
        Users Leader ON g.LeaderId = Leader.UserId
    LEFT JOIN 
        Users Mentor ON g.MentorId = Mentor.UserId
    LEFT JOIN 
        GroupMembers gm ON g.GroupId = gm.GroupId AND gm.JoinStatus = 'Accepted'
    LEFT JOIN 
        Users Member ON gm.UserId = Member.UserId
    GROUP BY 
        g.GroupName, Leader.FullName, Mentor.FullName;
END
GO