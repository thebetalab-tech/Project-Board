# Stored Procedures Guide: Project Board

- 1. sp_RegisterUser (The Onboarding Process)
 
    What it does: This is your main sign-up engine. It takes the user's details from your registration form and creates their account in the database.

    How it handles logic: It dynamically sorts users based on their role (Student, Faculty, or Admin). If a student is registering, it saves their Enrollment Number; if it's a faculty member, it leaves that blank. It also sets the IsLeader toggle to 0 by default.

- 2. sp_CreateGroup (The Team Foundation)

    What it does: This handles the exact moment a student decides to become a group leader and start a project team.

    How it handles logic: It registers the new group's name and locks in their chosen technology stack. Behind the scenes, it immediately does a second step: it takes the student who clicked "Create" and permanently inserts them into the group's roster as an 'Accepted' member, effectively upgrading them to a Leader.

- 3. sp_InviteStudent (The Invitation Sender)

    What it does: This is triggered when the group leader searches for a teammate and clicks "Invite."

    How it handles logic: It creates a bridge between the Group and the invited Student, explicitly marking their relationship as Pending. This is the crucial step that hides that student from the leader's search results so they can't be spammed with multiple invites.

- 4. sp_RespondToInvite (The RSVP System)

    What it does: This runs when an invited student looks at their dashboard and clicks either "Accept" or "Reject."

    How it handles logic: Instead of creating new data, it simply finds the existing Pending invitation and updates the text to whatever the student chose. If they choose Accepted, they are officially on the team.

- 5. sp_SubmitProject (The Proposal Engine)

    What it does: This takes the final project idea from the group leader and sends it to the assigned mentor for review.

    How it handles logic: It records the project type (IDP/UDP) and the detailed functionality. Crucially, it takes the raw project name and saves a NormalizedTitle (a stripped-down, lowercase version) specifically so your Jaro-Winkler algorithm can quickly scan it for duplicates later.

- 6. sp_MentorRejectsGroup (The Anti-Spam Rejection)

    What it does: This handles the negative path when a faculty mentor decides they do not want to guide a specific group.

    How it handles logic: It does two things simultaneously. First, it completely resets the group, kicking them back to the Forming stage and wiping the mentor's name from their record. Second, it logs a permanent record in a hidden tracking table so that the group can never attempt to select that specific mentor again.

- 7. sp_GetFullGroupDetails (The Data Packager)

    What it does: This is your main reporting tool, perfect for the Admin dashboard or for generating your PDF reports.

    How it handles logic: Instead of making your web server do the heavy lifting, this procedure joins five different tables together and squashes all the individual group members into a single, neat, comma-separated list. It delivers one perfect row of data per group.