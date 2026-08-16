# Render Workflows (Best use of Render)

Blueprints cannot create Workflow services yet. Create one in the Dashboard.

1. [Render Dashboard](https://dashboard.render.com) → **New → Workflow**
2. Link `kewinzaq1/operator`
3. **Root Directory:** `workflows`
4. **Build command:** `pip install -r requirements.txt`
5. **Start command:** `python main.py`
6. Env vars on the workflow: `OPERATOR_APP_URL` (your Rails URL) is optional; Rails passes `app_url` + token when it starts the task
7. After deploy, copy the task slug (`something/run_daily_business`) into `RENDER_TASK_SLUG`

`Run my business` then calls `POST https://api.render.com/v1/task-runs`. The workflow calls back to Rails `POST /internal/runs`. Local/demo still runs `OperatorJob` when those env vars are missing.
