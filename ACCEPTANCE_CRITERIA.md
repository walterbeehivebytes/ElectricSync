# ElectricSync — Acceptance Criteria

> **Legend:**
> - `[EXISTS]` — Already built, no changes needed
> - `[UPDATE]` — Feature exists but needs modification
> - `[NEW]` — Does not exist yet, must be built
> - `[MOCK→REAL]` — Exists as mock, needs real backend wiring

---

## AC-1: Authentication & Authorization

### AC-1.1 — Login with real JWT [MOCK→REAL]
**Feature:** Replace mock auth with real backend login
**Given** a user is on the login screen
**When** they enter a valid email and password and tap Login
**Then** the app calls `POST /api/auth/login`, receives a JWT token, stores it securely, and navigates to their role-based home screen

**Definition of Done:**
- Backend `POST /api/auth/login` returns `{ token, user }` with role info
- Flutter AuthService sends real HTTP request (not mock delay)
- JWT stored in secure storage (not just memory)
- Wrong credentials show error from server response

**Files to touch:**
- `backend/api/auth.py` [NEW]
- `backend/services/auth_service.py` [NEW]
- `frontend/lib/services/auth_service.dart` [UPDATE: mock → real]
- `frontend/lib/services/api_service.dart` [NEW]

---

### AC-1.2 — Role-gated routes [UPDATE]
**Feature:** Each route is only accessible to the correct role(s)
**Given** a Team Member is authenticated
**When** they attempt to access any PM-only screen (e.g., work order generator, blueprint upload)
**Then** the route is not reachable — it is not surfaced in their UI and direct navigation returns to their home

**Definition of Done:**
- No role can see nav items outside their skill matrix
- Backend endpoints check role from JWT claims and return 403 if unauthorized
- Frontend role guards on all screens

**Files to touch:**
- `backend/main.py` [UPDATE: add auth middleware]
- All `backend/api/*.py` [UPDATE: add role checks]
- `frontend/lib/screens/home_screen.dart` [EXISTS — already role-routed]

---

### AC-1.3 — Sign up with role selection [EXISTS]
**Feature:** New user can register and pick their role
**Given** a user is on the signup screen
**When** they complete the form with name, email, password, and role
**Then** their account is created and they are logged in as that role

**Definition of Done (currently mock — needs real backend):**
- `POST /api/auth/signup` creates user, returns JWT
- Duplicate email returns validation error

**Files to touch:**
- `backend/api/auth.py` [NEW]
- `frontend/lib/screens/auth/signup_screen.dart` [UPDATE: wire to real API]

---

## AC-2: Project Manager Skills

### AC-2.1 — Portfolio Dashboard shows real projects [MOCK→REAL]
**Feature:** PM home screen displays live project data
**Given** a PM is logged in
**When** their dashboard loads
**Then** they see all active projects fetched from `GET /api/projects/`, with real status, progress %, phase, and risk flag

**Definition of Done:**
- Portfolio health stats (Active/On Track/At Risk/Behind) computed from real data
- Budget vs. actual bars use real budget/spent fields from backend
- Project cards link to real project IDs

**Files to touch:**
- `backend/models/project.py` [UPDATE: add phase, budget_spent, risk_flag]
- `backend/api/projects.py` [UPDATE: add PM-scoped filter]
- `frontend/lib/screens/home/project_manager_home.dart` [UPDATE: replace hardcoded cards]
- `frontend/lib/services/project_service.dart` [NEW]

---

### AC-2.2 — Blueprint upload and pin creation [UPDATE]
**Feature:** PM can upload a blueprint image and add task pins
**Given** a PM is in the Blueprint List screen
**When** they tap "Add Blueprint" and provide name + image
**Then** the blueprint is saved and they can open it to place task pins on specific locations

**Definition of Done:**
- Blueprint list shows real blueprints from `GET /api/blueprints/project/{id}`
- Add blueprint dialog saves to `POST /api/blueprints/`
- Pin creation saves to `POST /api/blueprints/{id}/pins`
- Pins persist across sessions

**Files to touch:**
- `backend/api/blueprints.py` [NEW]
- `backend/models/blueprint.py` [NEW]
- `frontend/lib/screens/blueprints/blueprint_list.dart` [UPDATE: wire to real API]
- `frontend/lib/screens/blueprints/blueprint_viewer.dart` [UPDATE: persist pins via API]
- `frontend/lib/services/blueprint_service.dart` [NEW]

---

### AC-2.3 — AI Work Order Generator [NEW]
**Feature:** PM types a plain-language job description; AI returns structured tasks
**Given** a PM is on the Work Order Creator screen
**When** they type a description like "Run conduit from panel B to floors 3-5, pull #12 wire for 40 circuits" and tap Generate
**Then** the AI responds with a structured work order breakdown

**AI Output format:**
```json
{
  "work_order_title": "Panel B Conduit Run — Floors 3-5",
  "tasks": [
    {
      "title": "Run conduit from Panel B to Floor 3",
      "estimated_hours": 4,
      "priority": "high",
      "assigned_role": "team_lead",
      "materials": ["1/2\" EMT conduit x 200ft", "conduit straps x 40"],
      "safety_notes": "Lock out Panel B before starting"
    }
  ]
}
```

**Then** PM reviews, edits if needed, and taps Publish → tasks are created in backend

**Definition of Done:**
- Backend `POST /api/ai/generate-work-order` calls Claude with electrical trade context
- Response streams or returns structured JSON
- Flutter UI renders task cards from AI response
- Publish button calls `POST /api/tasks/` for each task

**Files to touch:**
- `backend/services/ai_service.py` [NEW]
- `backend/api/ai.py` [NEW]
- `frontend/lib/screens/tasks/work_order_creator.dart` [UPDATE: add AI generation UI]
- `frontend/lib/services/ai_service.dart` [NEW]

---

## AC-3: Site Manager Skills

### AC-3.1 — Site Operations Dashboard shows real data [MOCK→REAL]
**Feature:** SM home screen shows live crew and task status
**Given** a Site Manager is logged in
**When** their dashboard loads
**Then** they see today's task counts (total/completed/blocked), pending approvals, and Team Leads with their crew counts — all from real backend data

**Files to touch:**
- `backend/api/projects.py` [UPDATE: SM-scoped endpoints]
- `frontend/lib/screens/home/site_manager_home.dart` [UPDATE: replace hardcoded cards]

---

### AC-3.2 — Crew Dispatch [UPDATE]
**Feature:** SM dispatches crew to tasks
**Given** a Site Manager opens Crew Dispatch
**When** they select a task and assign a Team Lead or Team Member
**Then** the assignment is saved via `PATCH /api/tasks/{id}` and the assignee's dashboard updates

**Definition of Done:**
- Task list fetched from real backend
- Assignment persisted
- Assigned user sees task on their dashboard immediately

**Files to touch:**
- `backend/api/tasks.py` [UPDATE: add PATCH /tasks/{id}/assign]
- `frontend/lib/screens/tasks/crew_dispatch.dart` [UPDATE: wire to real API]

---

### AC-3.3 — AI Dispatch Recommendation [NEW]
**Feature:** AI recommends which crew member should handle which task
**Given** a Site Manager is on the Crew Dispatch screen
**When** they tap "Get AI Recommendation" on an unassigned task
**Then** Claude analyzes the task requirements, crew skills, and current workload and returns a ranked list of recommended assignees with reasoning

**AI Output format:**
```json
{
  "task_id": "task_003",
  "recommendations": [
    {
      "user_id": "user_002",
      "name": "Carmen Ortiz",
      "role": "team_lead",
      "confidence": "high",
      "reason": "Carmen's crew is currently at 60% capacity and this task requires conduit routing experience she has demonstrated on proj_001."
    }
  ]
}
```

**Definition of Done:**
- Backend `POST /api/ai/dispatch-recommend` sends task + crew context to Claude
- Response shown inline in dispatch UI with Accept/Override buttons
- Accepting triggers the same assignment flow as AC-3.2

**Files to touch:**
- `backend/services/ai_service.py` [NEW — shared with AC-2.3]
- `backend/api/ai.py` [NEW — shared endpoint file]
- `frontend/lib/screens/tasks/crew_dispatch.dart` [UPDATE: add AI recommendation card]

---

## AC-4: Team Lead Skills

### AC-4.1 — Crew Status Dashboard shows real data [MOCK→REAL]
**Feature:** TL home screen shows their crew's real task status
**Given** a Team Lead is logged in
**When** their dashboard loads
**Then** they see their crew members, each person's current task, and status (in-progress / blocked / idle) — from real backend

**Files to touch:**
- `backend/api/tasks.py` [UPDATE: GET /tasks/team-lead/{id}]
- `frontend/lib/screens/home/team_lead_home.dart` [UPDATE: replace hardcoded crew cards]

---

### AC-4.2 — Task Assignment to Team Members [UPDATE]
**Feature:** TL assigns a task to a specific Team Member
**Given** a Team Lead is viewing an unassigned task in their queue
**When** they tap Assign and select a Team Member from their crew
**Then** the task is updated via `PATCH /api/tasks/{id}` and the Team Member sees it on their dashboard

**Files to touch:**
- `backend/api/tasks.py` [UPDATE]
- `frontend/lib/screens/home/team_lead_home.dart` [UPDATE]

---

### AC-4.3 — Blueprint Redline [UPDATE]
**Feature:** TL can add redline notes on a blueprint pin
**Given** a Team Lead is viewing a blueprint
**When** they long-press an existing pin
**Then** they can add a redline note (text annotation) and the pin status changes to `redlined`

**Definition of Done:**
- Redline note saved via `PATCH /api/blueprints/{id}/pins/{pin_id}`
- Note visible to PM and SM when they view the same blueprint

**Files to touch:**
- `frontend/lib/screens/blueprints/blueprint_viewer.dart` [UPDATE: wire redline to API]
- `backend/api/blueprints.py` [NEW]

---

### AC-4.4 — QC Sign-off [EXISTS — needs wiring]
**Feature:** TL reviews and approves completed work
**Given** a Team Member has marked a task complete and uploaded a photo
**When** the Team Lead opens QC Sign-off
**Then** they see the completed task, work photo, and can Approve or Request Revision

**Definition of Done:**
- QC queue fetched from `GET /api/tasks/?status=completed&team_lead={id}`
- Approve calls `PATCH /api/tasks/{id}` with status → `verified`
- Revision request sends notification (or updates help_requested field)

**Files to touch:**
- `backend/api/tasks.py` [UPDATE]
- `frontend/lib/screens/tasks/qc_signoff.dart` [UPDATE: wire to real API]

---

## AC-5: Team Member Skills

### AC-5.1 — My Workspace shows real assigned tasks [MOCK→REAL]
**Feature:** TM home screen shows their real current task
**Given** a Team Member is logged in
**When** their dashboard loads
**Then** they see their currently assigned task (from backend), "Up Next" queue, and today's completed tasks

**Files to touch:**
- `backend/api/tasks.py` [UPDATE: GET /tasks/assigned-to/{user_id}]
- `frontend/lib/screens/home/team_member_home.dart` [UPDATE: replace hardcoded task card]

---

### AC-5.2 — Start / Complete a Task [NEW]
**Feature:** TM taps Start and Complete on their task
**Given** a Team Member is viewing their assigned task
**When** they tap "Start Task"
**Then** the task status changes to `in_progress` and a clock-in timestamp is recorded

**When** they tap "Mark Complete"
**Then** the task status changes to `completed`, clock-out is recorded, and TL sees it in QC queue

**Definition of Done:**
- `PATCH /api/tasks/{id}` updates status + started_at / completed_at timestamps
- TL dashboard QC count increments
- TM dashboard moves task to "Completed Today"

**Files to touch:**
- `backend/api/tasks.py` [UPDATE]
- `backend/models/task.py` [UPDATE: add started_at, completed_at]
- `frontend/lib/screens/tasks/task_detail_view.dart` [UPDATE: wire Start/Complete to API]

---

### AC-5.3 — Upload Work Photo [NEW]
**Feature:** TM uploads a photo as proof of completed work
**Given** a Team Member has completed a task
**When** they tap "Add Photo" and select/take a photo
**Then** the photo is uploaded and attached to the task for TL QC review

**Definition of Done:**
- `POST /api/tasks/{id}/photos` accepts image upload
- Photo URL stored on task record
- TL QC view displays the photo

**Files to touch:**
- `backend/api/tasks.py` [UPDATE: add photo upload endpoint]
- `frontend/lib/screens/tasks/task_detail_view.dart` [UPDATE: add photo picker]

---

### AC-5.4 — Request Help from Team Lead [EXISTS — needs wiring]
**Feature:** TM can flag a task as blocked and request help
**Given** a Team Member is stuck on a task
**When** they tap "Request Help" and describe the issue
**Then** the task is flagged as `help_requested` and the Team Lead sees it in their blocked items list

**Definition of Done:**
- `PATCH /api/tasks/{id}` sets help_requested + help_message
- TL dashboard "Blocked" count increments
- TL sees the message when they open the task

**Files to touch:**
- `backend/api/tasks.py` [UPDATE]
- `frontend/lib/screens/tasks/task_detail_view.dart` [EXISTS — already has help UI, needs API wiring]
- `frontend/lib/screens/home/team_lead_home.dart` [UPDATE: show blocked tasks from real data]

---

## AC-6: Cross-Role Data Flow (Milestone 1 Demo)

### AC-6.1 — Full Day-in-the-Life Flow [NEW — integration test]
**The sequence that must work end-to-end:**

```
1. PM logs in
   → Creates a project via AI work order generator
   → Publishes 3 tasks

2. Site Manager logs in
   → Sees the 3 new tasks in pending queue
   → Requests AI dispatch recommendation
   → Accepts recommendation → assigns Task 1 to Team Lead

3. Team Lead logs in
   → Sees Task 1 assigned to their crew
   → Assigns Task 1 to a specific Team Member

4. Team Member logs in
   → Sees Task 1 in "My Workspace"
   → Taps Start → taps Complete → uploads photo

5. Team Lead logs in
   → Sees Task 1 in QC queue
   → Approves it

6. Site Manager logs in
   → Sees Task 1 as verified in project progress

7. PM logs in
   → Portfolio shows updated task count and % progress
```

**Definition of Done:** All 7 steps work in sequence without a page reload between users.

---

## AC-7: Backend — Role System Update [UPDATE]

### AC-7.1 — Backend roles match frontend
**Given** the backend currently uses ELECTRICIAN / JOURNEYMAN / FOREMAN
**When** this AC is complete
**Then** all backend models, mock data, and API responses use: PROJECT_MANAGER / SITE_MANAGER / TEAM_LEAD / TEAM_MEMBER

**Files to touch:**
- `backend/models/user.py` [UPDATE]
- `backend/mock_data/users_mock.py` [UPDATE: 4 new mock users matching frontend]
- `backend/mock_data/tasks_mock.py` [UPDATE: assigned_to uses new users]

---

---

## AC-8: Competitive Differentiators — Electrical Trade Specific

> **Competitive context:** ServiceTitan, Jobber, JobNimbus, FieldEdge, and HousecallPro all fail to address permit tracking, NEC compliance, LOTO safety, and panel schedules. These are ElectricSync's key moats.

### AC-8.1 — Permit & Inspection Tracking [NEW]
**Feature:** Full permit lifecycle management per project
**Given** a Site Manager is on a project
**When** they open the Permits tab
**Then** they can create a permit record and move it through stages: `Draft → Submitted → Inspection Scheduled → Passed | Failed | Correction Required`

**Permit record contains:**
- Permit type (electrical, low-voltage, solar, etc.)
- Jurisdiction and inspector name
- Submitted date, inspection date
- Pass/fail result with notes
- Attached documents (permit PDF, inspection report)

**When** an inspection is scheduled
**Then** TL on site gets a notification and can update the result from their mobile device

**When** a permit fails
**Then** PM and SM get an alert and a correction task is auto-created and assigned

**Definition of Done:**
- Permit CRUD at `POST/PATCH /api/permits/`
- PM sees permit status on portfolio dashboard per project
- Failed permit triggers auto-task creation
- No competitor has automated permit failure → task creation flow

**Files to touch:**
- `backend/models/permit.py` [NEW]
- `backend/api/permits.py` [NEW]
- `frontend/lib/screens/permits/permit_tracker.dart` [NEW]
- `frontend/lib/screens/home/site_manager_home.dart` [UPDATE: add permit summary]

---

### AC-8.2 — Safety & LOTO Compliance [NEW]
**Feature:** Team Member must complete a safety checklist before starting any task
**Given** a Team Member taps "Start Task"
**When** the task type requires electrical work on live or potentially live systems
**Then** a mandatory LOTO (Lockout/Tagout) checklist appears before the clock-in timestamp is recorded

**LOTO Checklist (must all be checked):**
- [ ] Identified all energy sources
- [ ] Applied lockout devices to all isolation points
- [ ] Verified zero energy state with a meter
- [ ] Informed crew members of lockout
- [ ] PPE confirmed (gloves, safety glasses, arc flash suit if required)

**When** all items are checked and signed
**Then** task clock-in is recorded with a `loto_confirmed: true` flag and timestamp

**When** a task has `requires_loto: true` and TM skips checklist
**Then** Start Task button is disabled until checklist is complete

**Definition of Done:**
- Task model has `requires_loto` field (set by PM/SM at work order creation or AI-detected)
- LOTO completion stored per task per user
- TL and SM can audit LOTO completions
- Differentiates from all competitors — none enforce LOTO digitally

**Files to touch:**
- `backend/models/task.py` [UPDATE: add requires_loto, loto_completed_at, loto_completed_by]
- `backend/api/tasks.py` [UPDATE]
- `frontend/lib/screens/tasks/task_detail_view.dart` [UPDATE: add LOTO checklist modal]
- `frontend/lib/screens/tasks/loto_checklist.dart` [NEW]

---

### AC-8.3 — NEC Code Compliance Checks (AI) [NEW]
**Feature:** AI flags potential NEC 2023 code violations in work order descriptions
**Given** a PM is generating a work order with AI
**When** the description contains configurations that may violate NEC code
**Then** the AI response includes a `compliance_flags` array with specific warnings

**Example AI compliance flag:**
```json
{
  "compliance_flags": [
    {
      "severity": "warning",
      "nec_article": "NEC 210.52",
      "issue": "Description mentions outlets more than 12 feet apart in a kitchen. NEC 210.52(B) requires outlets every 4 feet on kitchen counter tops.",
      "recommendation": "Add additional outlet circuits to meet spacing requirements."
    }
  ]
}
```

**When** a compliance flag exists
**Then** PM sees a yellow warning card in the work order review screen with the NEC article, issue, and recommendation — they can acknowledge and proceed or modify the task

**Definition of Done:**
- AI system prompt includes NEC 2023 context for the work order generation endpoint
- `compliance_flags` array returned alongside task breakdown
- UI renders warning cards that can be dismissed
- No competitor has AI-powered NEC compliance checking

**Files to touch:**
- `backend/services/ai_service.py` [UPDATE: add NEC context to system prompt]
- `frontend/lib/screens/tasks/work_order_creator.dart` [UPDATE: render compliance flags]

---

### AC-8.4 — Panel Schedules [NEW]
**Feature:** Circuit-by-circuit documentation linked to a project's electrical panels
**Given** a PM creates a project with a panel
**When** they open the Panel Schedules tab
**Then** they can define a panel (name, amperage, voltage, location) and add circuits (number, description, amperage, breaker type, load)

**Panel schedule circuit states:**
- `planned` — defined by PM, not yet installed
- `rough_in` — TM marks rough-in complete
- `wired` — TM marks wiring complete
- `tested` — TL marks tested and passing
- `inspected` — SM marks inspector-approved

**When** a TM completes wiring for circuit #14
**Then** they update circuit 14 status from their mobile device and TL sees real-time panel completion %

**When** a PM views the panel schedule
**Then** they see a visual grid of all circuits color-coded by status, with completion % per panel

**Definition of Done:**
- Panel and circuit CRUD at `POST/PATCH /api/panels/`
- Visual grid rendered in Flutter (color-coded)
- Status changes sync in real-time across roles
- No competitor provides real-time panel schedule tracking

**Files to touch:**
- `backend/models/panel.py` [NEW]
- `backend/api/panels.py` [NEW]
- `frontend/lib/screens/panels/panel_schedule.dart` [NEW]
- `frontend/lib/screens/home/project_manager_home.dart` [UPDATE: add panel schedule link]

---

## AC-9: Material & Inventory Tracking [NEW]

### AC-9.1 — Per-Project Materials List
**Feature:** Track materials ordered, received, on-site, and consumed per project
**Given** a work order is published with a materials list (AI-generated or manual)
**When** a Site Manager opens the Materials tab
**Then** they see each material item with quantity needed, quantity ordered, quantity on-site, and quantity used

**Material status flow:**
`needed → ordered → received → on_site → consumed`

**When** a TM uses a material on a task
**Then** they can tap "Use Materials" and decrement the on-site quantity — this is logged with timestamp and task ID

**When** on-site quantity drops below a threshold
**Then** SM gets an alert: "Panel covers running low — 2 remaining for 5 remaining tasks"

**Definition of Done:**
- Materials CRUD at `POST/PATCH /api/materials/`
- AI work order generator populates initial materials list
- TM can log material consumption from task detail view
- SM gets low-stock alerts
- Differentiates from Jobber (no material tracking) and JobNimbus (basic only)

**Files to touch:**
- `backend/models/material.py` [NEW]
- `backend/api/materials.py` [NEW]
- `frontend/lib/screens/materials/material_tracker.dart` [NEW]
- `frontend/lib/screens/tasks/task_detail_view.dart` [UPDATE: add material usage logging]

---

## AC-10: Offline Mode [NEW]

### AC-10.1 — Task Viewing and Updates Offline
**Feature:** Team Member can work without signal (basements, metal buildings)
**Given** a Team Member has loaded their assigned tasks while online
**When** they lose network connectivity
**Then** the app continues to function — they can view task details, start/complete tasks, fill LOTO checklist, and queue photo uploads

**When** connectivity is restored
**Then** all offline actions sync automatically to the backend with the original timestamps

**Offline queue behavior:**
- Tasks updated offline are stored in local storage with a `pending_sync` flag
- Sync status indicator shown in app header (offline/syncing/synced)
- Conflicts (e.g., task was reassigned while offline) are shown as a resolution prompt

**Definition of Done:**
- Flutter app uses local storage (sqlite or hive) to cache assigned tasks
- Offline actions queued and sent on reconnect
- No competitor reliably handles this for electrical field workers
- ServiceTitan does this for HVAC but it's complex and slow; ElectricSync must be lightweight

**Files to touch:**
- `frontend/lib/services/offline_sync_service.dart` [NEW]
- `frontend/lib/services/local_storage_service.dart` [NEW]
- `frontend/lib/screens/tasks/task_detail_view.dart` [UPDATE: offline-aware actions]
- `frontend/pubspec.yaml` [UPDATE: add hive or sqflite dependency]

---

## AC-11: Edge Cases & Reliability

### AC-11.1 — Conflict Resolution: Double Assignment [NEW]
**Feature:** Prevent two TLs from assigning the same TM to conflicting tasks
**Given** TM Mike is currently assigned to Task A (in_progress)
**When** a second TL attempts to assign Mike to Task B at the same time
**Then** the assignment is blocked with a message: "Mike Rodriguez is currently assigned to [Task A — Panel B Rough-in]. Reassign Task A first or choose another team member."

**Definition of Done:**
- Backend `PATCH /api/tasks/{id}/assign` checks for active assignments before accepting
- Returns 409 Conflict with descriptive message
- Flutter shows conflict dialog with option to view the blocking task

**Files to touch:**
- `backend/api/tasks.py` [UPDATE: assignment conflict check]
- `frontend/lib/screens/tasks/crew_dispatch.dart` [UPDATE: handle 409 response]

---

### AC-11.2 — AI Failure Graceful Degradation [NEW]
**Feature:** App remains functional when AI endpoints fail or time out
**Given** the AI service is unavailable (timeout, error, rate limit)
**When** PM taps "Generate Work Order" or SM taps "Get AI Recommendation"
**Then** the app shows: "AI assistant is currently unavailable. You can create this manually." — and presents the manual form

**Definition of Done:**
- All AI calls have a 15-second timeout
- On error: friendly message shown, manual fallback surfaced immediately
- No loading spinners that spin forever
- Manual work order creation and manual dispatch remain fully functional without AI

**Files to touch:**
- `frontend/lib/services/ai_service.dart` [NEW: add timeout + error handling]
- `frontend/lib/screens/tasks/work_order_creator.dart` [UPDATE: manual fallback]
- `frontend/lib/screens/tasks/crew_dispatch.dart` [UPDATE: manual fallback]
- `backend/services/ai_service.py` [UPDATE: add try/except with fallback response]

---

### AC-11.3 — Role Change Mid-Project [NEW]
**Feature:** Admin promotes a Team Member to Team Lead
**Given** a user with role Team Member has completed tasks and has work history
**When** an admin changes their role to Team Lead
**Then** on the user's next login they see the Team Lead UI, their task history is preserved, and previously assigned tasks remain in their profile

**Definition of Done:**
- `PATCH /api/users/{id}/role` endpoint (admin only)
- JWT re-issued with new role on next login
- Task history not deleted on role change
- New role home screen renders immediately after next login

**Files to touch:**
- `backend/api/users.py` [UPDATE: add role change endpoint with admin guard]
- `frontend/lib/screens/profile/profile_screen.dart` [UPDATE: show current role, notify of change]

---

## AC-12: Notifications & Alerts [NEW]

### AC-12.1 — In-App Notification Center
**Feature:** All roles receive contextual notifications for relevant events
**Notification triggers by role:**

| Event | PM | SM | TL | TM |
|-------|----|----|----|----|
| Task assigned to you | — | — | ✓ | ✓ |
| Task completed in your project | ✓ | ✓ | ✓ | — |
| Task blocked / help requested | ✓ | ✓ | ✓ | — |
| QC approved | — | — | — | ✓ |
| QC revision requested | — | — | — | ✓ |
| Blueprint pin added | — | ✓ | ✓ | — |
| Permit status changed | ✓ | ✓ | — | — |
| Permit failed → auto-task created | ✓ | ✓ | — | — |
| Material low stock alert | — | ✓ | — | — |
| Daily site summary ready | ✓ | ✓ | — | — |

**Definition of Done:**
- In-app notification bell (already exists in home_screen.dart) wired to real events
- Notifications stored in backend at `GET /api/notifications/`
- Unread count shown on bell icon badge
- Tap notification → navigate to relevant screen

**Files to touch:**
- `backend/models/notification.py` [NEW]
- `backend/api/notifications.py` [NEW]
- `frontend/lib/screens/home_screen.dart` [UPDATE: wire notification bell]
- `frontend/lib/screens/notifications/notification_center.dart` [NEW]

---

## AC-13: Job Costing by Phase [NEW]

### AC-13.1 — Phase-Level Budget vs. Actual Tracking
**Feature:** PM tracks labor hours and material cost per project phase
**Given** a project has phases (Rough-in, Trim-out, Inspection, etc.)
**When** tasks are completed within a phase
**Then** the phase card shows: estimated hours, actual hours logged, variance %, estimated material cost, actual material cost

**When** actual cost exceeds estimate by >10%
**Then** PM sees a risk flag on that phase and receives a notification

**Definition of Done:**
- Project model has `phases` array with estimated hours + budget per phase
- Task clock-in/out timestamps feed actual hours per phase
- Material usage logs feed actual material cost per phase
- PM portfolio dashboard shows phase-level cost variance
- Differentiates from Jobber (basic reporting) and JobNimbus (no phase-level costing)

**Files to touch:**
- `backend/models/project.py` [UPDATE: add phases with budget fields]
- `backend/api/projects.py` [UPDATE: compute phase actuals]
- `frontend/lib/screens/home/project_manager_home.dart` [UPDATE: phase cost cards]

---

## AC-14: AI Daily Site Summary [NEW]

### AC-14.1 — AI-Generated End-of-Day Report
**Feature:** Claude generates a daily summary of site activity for PM and SM
**Given** it is end of work day (or PM/SM taps "Generate Daily Summary")
**When** the summary is generated
**Then** Claude receives: tasks completed today, hours logged, materials used, blocked tasks, permit updates, and generates a concise narrative report

**Example output:**
> "Day 12 — Office Rewiring Project. 4 of 6 tasks completed today (67%). Team Lead Carmen's crew finished floors 2-3 rough-in ahead of schedule (+2 hours buffer). Floor 4 conduit run is blocked — Mike requested help (short on 1/2\" EMT, 200ft needed). Permit inspection scheduled tomorrow at 10am. Recommend dispatching additional materials from warehouse tonight."

**Definition of Done:**
- `POST /api/ai/daily-summary` endpoint generates report from day's data
- PM and SM can tap "Daily Summary" from their home dashboard
- Summary is stored and viewable in notification center
- Differentiates from all competitors — none generate AI narrative site reports

**Files to touch:**
- `backend/api/ai.py` [UPDATE: add daily-summary endpoint]
- `backend/services/ai_service.py` [UPDATE: add summary generation]
- `frontend/lib/screens/home/project_manager_home.dart` [UPDATE: add summary button]
- `frontend/lib/screens/home/site_manager_home.dart` [UPDATE: add summary button]

---

## AC-15: Quick Onboarding [NEW]

### AC-15.1 — First Task Visible Within 5 Minutes of Sign-Up
**Feature:** New user can be productive in under 5 minutes (vs. ServiceTitan's 12-16 weeks)
**Given** a new Team Member receives an invite link
**When** they open the app, create their account, and complete their profile
**Then** they see their first assigned task on their home screen

**Onboarding flow:**
1. Open invite link → pre-filled email
2. Set name + password (30 seconds)
3. Role is pre-set by the SM who invited them
4. One-screen tutorial overlay showing their 3 key actions (Start Task, View Blueprint, Request Help)
5. First assigned task visible immediately

**Definition of Done:**
- Invite link generation: `POST /api/users/invite` (SM/TL can invite)
- Invite pre-fills email and role in signup
- Tutorial overlay shown on first login only (dismissed on tap)
- Time-to-first-task measurable and under 5 minutes

**Files to touch:**
- `backend/api/users.py` [UPDATE: add invite endpoint]
- `frontend/lib/screens/auth/signup_screen.dart` [UPDATE: handle invite links]
- `frontend/lib/screens/onboarding/onboarding_overlay.dart` [NEW]

---

## Competitive Positioning Summary

| Feature | ElectricSync | ServiceTitan | Jobber | JobNimbus | FieldEdge |
|---------|-------------|-------------|--------|-----------|-----------|
| Role-first UI | ✓ | Partial | ✗ | ✗ | Partial |
| AI work order gen | ✓ | ✗ | ✗ | ✗ | ✗ |
| AI dispatch recommend | ✓ | ✗ | ✗ | ✗ | ✗ |
| AI daily summary | ✓ | ✗ | ✗ | ✗ | ✗ |
| NEC compliance checks | ✓ | ✗ | ✗ | ✗ | ✗ |
| LOTO digital checklist | ✓ | ✗ | ✗ | ✗ | ✗ |
| Panel schedules (real-time) | ✓ | ✗ | ✗ | ✗ | Partial |
| Permit lifecycle tracking | ✓ | Partial | ✗ | ✗ | ✗ |
| Offline mode (field) | ✓ | ✓ | ✗ | ✗ | Partial |
| Material tracking | ✓ | ✓ | ✗ | ✗ | ✓ |
| Job costing by phase | ✓ | ✓ | Partial | ✗ | Partial |
| Blueprint w/ task pins | ✓ | ✗ | ✗ | ✗ | ✗ |
| Onboarding < 5 min | ✓ | ✗ (12-16 wks) | ✓ | ✓ | ✗ |
| Transparent pricing | ✓ | ✗ | ✓ | Partial | ✗ |

---

## Build Order (Recommended Sequence)

```
Phase 1 — Backend Foundation
  AC-7.1  Update backend role system
  AC-1.1  JWT auth (login + signup)
  AC-1.2  Role-gated routes

Phase 2 — Real Data (replace mocks)
  AC-2.1  PM portfolio from real projects
  AC-3.1  SM operations from real data
  AC-4.1  TL crew status from real data
  AC-5.1  TM workspace from real tasks

Phase 3 — Core Task Flow
  AC-5.2  TM Start/Complete task
  AC-3.2  SM crew dispatch
  AC-4.2  TL task assignment
  AC-5.4  TM request help
  AC-4.4  TL QC sign-off

Phase 4 — Blueprint System
  AC-2.2  PM blueprint upload + pins
  AC-4.3  TL blueprint redline

Phase 5 — AI Features
  AC-2.3  AI work order generator (+ NEC compliance flags: AC-8.3)
  AC-3.3  AI dispatch recommendation
  AC-14.1 AI daily site summary

Phase 6 — Safety & Compliance (Moat Features)
  AC-8.1  Permit & inspection tracking
  AC-8.2  LOTO safety checklist
  AC-8.4  Panel schedules
  AC-9.1  Material & inventory tracking
  AC-13.1 Job costing by phase

Phase 7 — Reliability & UX
  AC-10.1 Offline mode
  AC-11.1 Assignment conflict resolution
  AC-11.2 AI failure graceful degradation
  AC-11.3 Role change mid-project
  AC-12.1 Notification center
  AC-15.1 Quick onboarding (< 5 min)

Phase 8 — Integration
  AC-6.1  Full day-in-the-life demo
  AC-5.3  TM photo upload
```
