# Project Board - Master Context (brain.md)

## 1. Project Overview & Architecture
* **Project Board** is a college project management system designed for group formation, mentorship assignment, and most importantly, project duplicate detection using Jaro-Winkler/Jaccard similarity. The system catches duplicate ideas before the mentor does, preventing multiple groups from building the same project (e.g., "Hospital Management System") in the same technology stack.
* **Tech Stack**: ASP.NET Web Forms, C# Code-Behind, ADO.NET, SQL Server. The Frontend UI is built using HTML, CSS (Vanilla or Tailwind CDN), and JavaScript without external build tools.
* **User Roles**:
  - **Student**: Registers, forms groups, selects a technology stack, chooses a faculty mentor, and submits project proposals.
  - **Faculty**: Mentors groups, approves or rejects group requests, reviews project proposals (with an integrated similarity check), manages approved projects, and generates reports.
  - **Admin**: System administrator who manages users (deactivates/activates students), creates faculty accounts, manages technology stacks, and assigns technologies to faculty.

## 2. Master AI Directives & Design System
### Master System Prompt
Every HTML page generated must adhere to the following master system prompt:
```
You are an expert frontend web developer and UI/UX designer. You will build HTML pages for a project called "Project Board" — a college project management system. Each page you build is a standalone HTML file with all CSS and JavaScript embedded inside <style> and <script> tags. No external build tools. You may use Google Fonts and a CDN CSS framework (Tailwind CDN or plain CSS).
CRITICAL RULES — follow all of these without exception:
1. SINGLE FILE: Every output is one complete, self-contained .html file. All CSS inside <style>, all JS inside <script>. No imports except Google Fonts and optionally one CDN.
2. DESIGN SYSTEM: Always use exactly these CSS variables. Never invent new colors.
   --ink: #001219
   --teal: #005f73
   --cyan: #0a9396
   --aqua: #94d2bd
   --custard: #e9d8a6
   --orange: #ee9b00
   --rust: #ca6702
   --sienna: #bb3e03
   --clay: #ae2012
   --brick: #9b2226
   Page background: var(--custard)  |  Primary CTA: var(--orange)
3. FONTS: Google Fonts: 'DM Serif Display' (headings) + 'DM Sans' (body). Always include both.
4. FULLY FUNCTIONAL UI: All buttons, dropdowns, modals, tabs, and form validations must work in vanilla JS. No page should feel static.
5. REALISTIC SAMPLE DATA: Populate every table, list, and card with realistic-looking dummy data. A page with empty tables is useless. Make it look like a real running app.
6. RESPONSIVE: Works on desktop (1280px) and mobile (375px). Use CSS Grid / Flexbox.
7. NAV BAR: Every page includes a top nav bar with bg: var(--teal) (or var(--brick) for admin). Nav shows:
   - Left: "Project Board" logo text in DM Serif Display, white
   - Middle: role-appropriate navigation links
   - Right: notification bell (with badge count) + user avatar/name dropdown
8. NO AI SLOP: Do not produce a generic Bootstrap-looking page. Every page must feel like a real, operational software dashboard.
9. STATUS BADGES: Use colored pill badges throughout.
   Approved → bg #94d2bd, text #001219
   Pending  → bg #ee9b00, text #001219
   Rejected → bg #ae2012, text white
   Active   → bg #0a9396, text white
   Forming  → bg #ca6702, text white
10. PAGE STRUCTURE: Every page follows this layout:
    [Nav bar] → [Page header with breadcrumb + page title] → [Main content] → [Footer with team info]
    Footer text: "Project Board · Tirth Joshi · Rudra Rangpariya · Sujal Domadiya · 5th Sem Diploma CE"
PROJECT CONTEXT: Project Board is a college platform where student groups register, select a technology stack, choose a faculty mentor, and submit project ideas. Faculty approve/reject groups and project proposals. Duplicate project detection (fuzzy name matching + keyword tags) prevents two groups from building the same project in the same technology.
```

### Color Palette (Hex Codes)
* `--ink`: `#001219` (headlines, body text, icons on light bg)
* `--teal`: `#005f73` (nav bg for Student/Faculty, section headings)
* `--cyan`: `#0a9396` (links, active states, info badges)
* `--aqua`: `#94d2bd` (success state, available-idea green, approved badge)
* `--custard`: `#e9d8a6` (PAGE BACKGROUND — used everywhere as the canvas)
* `--orange`: `#ee9b00` (PRIMARY CTA button, notification badges, pending badge)
* `--rust`: `#ca6702` (card borders, secondary accents, forming badge)
* `--sienna`: `#bb3e03` (warning/taken state, duplicate match warning)
* `--clay`: `#ae2012` (error/rejected badges, danger buttons)
* `--brick`: `#9b2226` (Admin navigation bar, critical alerts)

### Typography Rules
* **Headings**: `DM Serif Display` from Google Fonts.
* **Body / UI Text**: `DM Sans` from Google Fonts.

## 3. Global Concepts & Session State
* **Session Management Rules**:
  Every protected page checks session variables in `Page_Load` before rendering content. If invalid, it redirects to `Login.aspx`.
  - `Session["UserId"]` (int): Passed to all DAL methods.
  - `Session["Role"]` (string): Gates access to role-specific folders (`/Student/`, `/Faculty/`, `/Admin/`).
  - `Session["FullName"]` (string): Displayed in the navigation bar.
  - `Session["GroupId"]` (int?): Shortcut to avoid repeated DB lookups for group state.
  The **Standard Page_Load Guard Pattern** checks `Session["UserId"]`, verifies the correct `Session["Role"]`, and ensures the group state is correct for the specific page being accessed. Folder-level `web.config` files also enforce location-based authorization based on Roles.

* **Duplicate Detection Core Mechanic**:
  A critical system feature using pure C# string operations (`SimilarityHelper.cs`). Before a student submits a project or a faculty member approves one, the system:
  1. Normalizes the project title (lowercases, strips stop words like "system", "app", "management").
  2. Uses Jaccard Similarity (or Jaro-Winkler) to compare the input against all existing pending/approved projects in the same technology.
  3. Checks for overlap with associated domain keywords for the technology.
  If a match is found (>50% similarity or keyword match), the student sees a warning panel but can still proceed explicitly by checking a "Submit anyway" checkbox. The faculty is forced to review the similarity alert panel before the "Approve" button is fully disclosed.

## 4. Page-by-Page Master Index

### login.html
* **Purpose**: Single entry point for all three roles. Validates credentials and redirects to the correct role dashboard.
* **UI/Design Prompt**: Two-column layout. Left: Teal bg with features list. Right: White card form with email, password (show/hide), remember me, "Sign In" orange button. Includes demo credentials below the form and JS logic to redirect based on email prefix (student/faculty/admin).
* **Backend Responsibilities**: `Page_Load` redirects if already logged in. `btnLogin_Click` validates via `UserDAL.Login`, sets session variables (`UserId`, `Role`, `FullName`), creates FormsAuthentication cookie, and redirects based on Role.

### register.html
* **Purpose**: Student-only self-registration. Faculty cannot register here.
* **UI/Design Prompt**: Two-column layout. Left: Teal bg with 3-step progress indicator (Step 1 active). Right: Form with Full Name, Enrollment No. (11 digits), Email, Dept dropdown, Password, Confirm Password. Features a live password strength meter and inline validation errors.
* **Backend Responsibilities**: `btnRegister_Click` validates fields, hashes password (SHA-256), and calls `UserDAL.Register`. If email is a duplicate, shows error. On success, sets session and auto-logs in to the Student dashboard.

### student-dashboard.html
* **Purpose**: The main student hub showing group status, progress through the flow, and quick actions based on their current state.
* **UI/Design Prompt**: Progress stepper at the top highlighting current phase. Two columns below: Left (2/3) shows "Your Group" details (status, tech, mentor, members list). Right (1/3) shows recent notifications and quick links. Bottom features 4 stat cards.
* **Backend Responsibilities**: `Page_Load` calls `GroupDAL.GetGroupByUser`. Displays `pnlNoGroup`, `pnlInGroup`, or pending invites based on status. Handles accepting/rejecting invites via `btnAcceptInvite_Click` / `btnRejectInvite_Click`.

### create-group.html
* **Purpose**: Form to create a new group. The creator automatically becomes the Group Leader. Blocked if the student is already in a group.
* **UI/Design Prompt**: Centered single card form. Input for Group Name with live character counter (0/50). Live mini-card preview of the group structure. "Create Group & Become Leader" orange button. Shows a 3-step "What happens next?" guide below.
* **Backend Responsibilities**: Checks if student already has a group. `btnCreate_Click` validates name and calls `GroupDAL.CreateGroup`, auto-inserting the leader. Redirects to `InviteMembers.aspx`.

### invite-members.html
* **Purpose**: Group leader searches for ungrouped students and sends join invitations (max 4 invitations, 5 total members).
* **UI/Design Prompt**: Two-column layout. Left: Search bar and results grid with "Invite" buttons (change to disabled "Invited" on click). Right: Sticky card showing "Current Team" members with remove buttons (except leader) and progress bar (X/5).
* **Backend Responsibilities**: Leader-only access. `btnSearch_Click` uses `UserDAL.SearchUngroupedStudents`. RowCommand "Invite" calls `GroupDAL.InviteStudent` and `NotificationDAL.Insert`.

### select-technology.html
* **Purpose**: Leader selects the technology stack for the group. Locked once a mentor is selected.
* **UI/Design Prompt**: 2x3 grid of tech cards (PHP, .NET, Python, etc.) with icons, descriptions, and active group counts. Hover effects scale cards. Selection highlights card in orange and shows an info panel below with a "Continue to Select Mentor" button.
* **Backend Responsibilities**: Checks if group has members and hasn't locked tech yet. Binds dropdown/grid via `GroupDAL.GetAllTechnologies`. `btnSave_Click` calls `GroupDAL.SetTechnology`.

### select-mentor.html
* **Purpose**: Leader selects a faculty mentor from those handling the group's chosen technology. Sends an approval request.
* **UI/Design Prompt**: 3 Mentor cards side-by-side with avatars, tags, active group stats, bios, star ratings, and availability status dots. "Select as Mentor" button opens a confirmation modal.
* **Backend Responsibilities**: Binds `gvFaculty` using `GroupDAL.GetFacultyByTech`. `btnSelect` calls `GroupDAL.SetMentor`, updating Status to 'Pending' and inserting a notification for the faculty.

### submit-project.html
* **Purpose**: Leader submits a project idea. Includes critical server-side duplicate check before showing final submit button.
* **UI/Design Prompt**: Form card with Project Type dropdown, Title, and Functionality textarea. "Check If Title Is Available" button triggers a spinner, then reveals either a Green Success Panel (proceed to submit) or an Orange Warning Panel (similar projects detected with a mandatory "Submit anyway" checkbox). Sidebar shows recent approved project names.
* **Backend Responsibilities**: `btnCheck_Click` uses `SimilarityHelper` and `ProjectDAL.GetProjectsByTech` to find duplicates/keyword overlaps. Only enables `btnSubmit` if no warning or if the explicit confirmation checkbox is ticked.

### project-status.html
* **Purpose**: Read-only page showing the current status of the group's project proposal.
* **UI/Design Prompt**: Features a demo toggle to switch states. Pending: pulsing orange clock hero card. Approved: green checkmark trophy card, approval remark, and download letter button. Rejected: red clay hero card with mentor remark and "Submit New Proposal" button.
* **Backend Responsibilities**: `ProjectDAL.GetLatestByGroup` fetches the latest submission. Binds labels and selectively displays `pnlRejected` or approval components based on the project's status.

### notifications.html
* **Purpose**: In-app notification inbox. Marks notifications as read when opened.
* **UI/Design Prompt**: Vertical list of notification cards. Each has a colored type icon (invite/cyan, approval/aqua, rejection/clay, system/rust), message, timestamp, and unread dot. Filter bar for "All | Invites | Approvals | System".
* **Backend Responsibilities**: `Page_Load` fetches via `NotificationDAL.GetAllForUser` and marks all read via `NotificationDAL.MarkAllRead`.

### faculty-dashboard.html
* **Purpose**: Faculty landing page showing pending work counts and quick-access panels.
* **UI/Design Prompt**: Teal nav with "Faculty Portal". 4 Stat cards at the top (Pending Groups, Pending Projects, Active Groups, Approved Projects). Main area split 60/40: Left shows mini-tables for pending group requests and project reviews. Right shows a PHP tech distribution bar chart and quick action buttons.
* **Backend Responsibilities**: Fetches counts using `GroupDAL` and `ProjectDAL` methods. Binds top 5 rows for pending groups and project proposals.

### group-requests.html
* **Purpose**: Full list of groups awaiting faculty approval, plus active and dropped groups.
* **UI/Design Prompt**: Tabs for Pending, Active, Dropped. Pending tab uses expanded card rows detailing group members and "Approve/Reject" buttons. Active tab uses a standard table with "Drop" buttons.
* **Backend Responsibilities**: `btnApprove_Click` calls `GroupDAL.ApproveGroup` (Status='Active'). `btnReject_Click` sets Status to 'Forming'. `btnDrop_Click` drops active groups. Sends appropriate notifications to students.

### project-requests.html
* **Purpose**: Faculty reviews project proposals. The most critical page featuring a mandatory duplicate detection review panel.
* **UI/Design Prompt**: Sidebar with proposal list (30%). Main panel (70%) shows project details and a prominent Orange Duplicate Detection Panel listing similar projects. An "I have reviewed..." disclosure button must be clicked to reveal the Reject/Approve decision section and keyword tagging input.
* **Backend Responsibilities**: Auto-runs `SimilarityHelper` on `Page_Load` or row selection against `ProjectDAL.GetApprovedByTech`. `btnApprove_Click` saves remarks and domain keywords. `btnReject` requires a remark.

### approved-projects.html
* **Purpose**: Browse all approved projects in the faculty's technology and manage keyword tags.
* **UI/Design Prompt**: Full-width table of approved projects. Keywords are shown as colored pill chips. An "Edit" button opens a modal to add/remove keyword tags. Stats sidebar shows keyword distribution.
* **Backend Responsibilities**: `ProjectDAL.GetApprovedByFaculty` binds the grid. Edit modal uses `ProjectDAL.DeleteKeywords` and `ProjectDAL.AddKeyword` to update tagging.

### generate-report.html
* **Purpose**: Generate and download a PDF report of groups and projects.
* **UI/Design Prompt**: Two-column layout. Left: Configuration card with checkboxes for what to include and an orange "Generate PDF" button. Right: Styled visual preview card mimicking the final PDF layout.
* **Backend Responsibilities**: Uses `iTextSharp` (NuGet). `btnGenerate_Click` fetches all relevant data, constructs the PDF (title, stats, tables), sets response headers, and streams the file to the browser.

### admin-dashboard.html
* **Purpose**: Admin's system-wide overview with stats across all roles and technologies.
* **UI/Design Prompt**: Admin uses `--brick` (#9b2226) for the nav bar. 2x4 grid of stat cards. Three-column layout below: Recent Groups, Recent Projects, and Quick Admin Action icon buttons. Bottom section features a CSS bar chart of technology distribution.
* **Backend Responsibilities**: Uses aggregate counting methods from `UserDAL`, `GroupDAL`, and `ProjectDAL` to bind stats and recent grids.

### manage-users.html
* **Purpose**: Browse all students, search, filter, view group membership, and deactivate accounts.
* **UI/Design Prompt**: Brick nav bar. Search/filter row. Full-width table of students with avatars, enrollment numbers, current group, status, and [View] / [Deactivate] action buttons. Pagination included.
* **Backend Responsibilities**: Binds `UserDAL.GetAllStudents`. RowCommands handle toggling the `IsActive` flag via `UserDAL.SetActiveStatus`.

### manage-faculty.html
* **Purpose**: Admin creates and manages faculty accounts (no self-registration).
* **UI/Design Prompt**: "Add New Faculty" orange button reveals an inline form to create a faculty account and assign a technology. Table below lists existing faculty with edit and deactivate buttons.
* **Backend Responsibilities**: `btnAddFaculty_Click` hashes the initial password and calls `UserDAL.Register` with Role='Faculty', then `GroupDAL.AssignTechnology`. Supports editing faculty details via GridView updates.

### manage-technology.html
* **Purpose**: Add, rename, and activate/deactivate technology stacks.
* **UI/Design Prompt**: Inline row to add a new technology. Below is a 2-column card grid showing technologies with an icon, usage stats, and Rename/Deactivate buttons.
* **Backend Responsibilities**: Uses `GroupDAL` methods to Add, Rename, or Toggle `IsActive` state of technologies. Deactivation preserves existing records but hides the tech from new students.

### assign-technology.html
* **Purpose**: Visual mapping matrix of which faculty handles which technologies.
* **UI/Design Prompt**: Hero element is a matrix grid table (Faculty as rows, Tech as columns). Checked cells highlight in cyan. Includes an orange "Save All Assignments" button and a live text-based summary list below the matrix.
* **Backend Responsibilities**: Typically loads `ddlFaculty` and uses a CheckBoxList for tech, but visually represented as a matrix. Saving clears existing assignments for the faculty and inserts new ones via `GroupDAL.AssignTechnology`.

## 5. Development Build Order
1. **Database Setup** (Tables, Stored Procedures)
2. **`DBHelper.cs`**
3. **DAL Classes** (`UserDAL`, `GroupDAL`, `ProjectDAL`, `NotificationDAL`)
4. **`Login.aspx` / `Register.aspx`**
5. **Student Pages** (In sequential flow order)
6. **Faculty Pages**
7. **Admin Pages**
