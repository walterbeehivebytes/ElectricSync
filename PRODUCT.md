# ElectricSync — Product Spec

## Vision
Role-first job site coordination for electricians. Every screen is scoped to exactly what that role needs, coordinated by AI that understands electrical job site context. Not a generic PM tool — built for the trade.

## Core Problems
- **Communication gaps** — crews and management have no structured channel; critical info falls through via text/phone
- **Task visibility** — no one knows what's done, blocked, or who owns what at any moment
- **Blueprint coordination** — field workers and PMs looking at different versions; markups get lost

## Differentiator
AI-powered coordination. Claude understands the job site context and helps each role make decisions faster — generating work orders from plain language and recommending optimal crew assignments.

---

## Role Skills

### Project Manager
- Upload blueprints and define task pins
- Generate work orders from plain-language descriptions (AI)
- View portfolio health: budget vs. actual, project status, risk flags
- Define task breakdown structure (WBS) per project
- Escalate blocked issues

### Site Manager
- Dispatch crew to tasks (AI recommends optimal assignments)
- Approve/reject work orders from PM
- Create field work orders
- Track materials and flag supply issues
- View all Team Leads and crew status

### Team Lead
- Assign tasks to Team Members within their crew
- Redline blueprints with field notes
- Sign off on completed work (QC)
- Escalate blockers to Site Manager

### Team Member
- View and accept assigned tasks
- Clock in/out on a task
- Upload work photos for QC
- Request help from Team Lead
- View blueprint for their active task

---

## AI Capabilities

### Work Order Generator (PM)
PM types a plain-language description:
> "Run conduit from panel B to floors 3-5, pull #12 wire for 40 circuits, install junction boxes at each floor"

Claude returns a structured work order:
- Task title + description
- Estimated hours per task
- Materials list
- Priority level
- Assigned role level (which role should execute)

PM reviews and publishes to the project.

### Dispatch Assistant (Site Manager)
When Site Manager opens crew dispatch, Claude analyzes:
- Task requirements and priority
- Crew skills and certifications
- Current workload per Team Lead/Member

Returns ranked crew recommendations with reasoning. Site Manager accepts, reassigns, or overrides.

---

## Milestone 1: Full Day-in-the-Life Demo

**The flow:**
1. **PM** → opens AI work order generator → describes a job → reviews generated tasks → publishes
2. **Site Manager** → sees pending tasks → AI recommends crew → dispatches
3. **Team Lead** → sees crew assignments → assigns Team Members → adds redline to blueprint
4. **Team Member** → sees assigned task → starts → uploads photo → marks complete
5. **All dashboards** update to reflect completed status

**Acceptance Criteria:**

| # | Criteria |
|---|----------|
| 1 | All 4 roles log in with real JWT auth |
| 2 | PM generates a work order via AI (Claude response) |
| 3 | Site Manager sees AI crew recommendations |
| 4 | Task status changes visible across roles |
| 5 | Blueprint pins link to tasks |
| 6 | Each role sees only their relevant UI |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter (web + mobile) |
| Backend | Python / FastAPI |
| AI | Anthropic Claude (claude-sonnet-4-6) |
| Auth | JWT (python-jose + passlib) |
| Database | In-memory mock → PostgreSQL (future) |
| Hosting | GitHub Pages (frontend) |

---

## Backend API Surface

### Auth
- `POST /api/auth/login` — returns JWT token
- `POST /api/auth/signup`

### Projects
- `GET /api/projects/` — list (filtered by role)
- `POST /api/projects/` — create (PM only)
- `PATCH /api/projects/{id}` — update status

### Tasks
- `GET /api/tasks/` — list (filtered by user/role)
- `POST /api/tasks/` — create
- `PATCH /api/tasks/{id}` — update status, assign, complete
- `POST /api/tasks/{id}/photos` — upload work photo

### Blueprints
- `GET /api/blueprints/` — list by project
- `POST /api/blueprints/` — upload (PM/SM)
- `POST /api/blueprints/{id}/pins` — add task pin
- `PATCH /api/blueprints/{id}/pins/{pin_id}` — redline

### AI
- `POST /api/ai/generate-work-order` — PM work order generation
- `POST /api/ai/dispatch-recommend` — SM crew dispatch recommendation
