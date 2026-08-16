from render_sdk import Workflows
import json
import os
import urllib.error
import urllib.request

app = Workflows()


@app.task(name="run_daily_business")
def run_daily_business(app_url: str, token: str) -> dict:
    """Kick the Rails operator. Taking this task out means production has no runner."""
    url = app_url.rstrip("/") + "/internal/runs"
    payload = json.dumps({"trigger": "render_workflow"}).encode()
    request = urllib.request.Request(
        url,
        data=payload,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "X-Operator-Token": token,
        },
    )
    try:
        with urllib.request.urlopen(request, timeout=60) as response:
            body = response.read().decode()
            return json.loads(body) if body else {"ok": True, "status": response.status}
    except urllib.error.HTTPError as error:
        return {"ok": False, "status": error.code, "error": error.read().decode()[:500]}


if __name__ == "__main__":
    app.start()
