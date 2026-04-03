"""Integration tests for /api/tasks endpoints."""
import json


# ── Helpers ────────────────────────────────────────────────────────────────

def create_task(client, title="Test Task", description=""):
    return client.post(
        "/api/tasks/",
        data=json.dumps({"title": title, "description": description}),
        content_type="application/json",
    )


# ── Health check ───────────────────────────────────────────────────────────

def test_health_check(client):
    res = client.get("/health")
    assert res.status_code == 200
    assert res.get_json()["status"] == "ok"


# ── GET /api/tasks/ ────────────────────────────────────────────────────────

def test_get_tasks_empty(client):
    res = client.get("/api/tasks/")
    assert res.status_code == 200
    assert res.get_json() == []


def test_get_tasks_returns_all(client):
    create_task(client, "Task A")
    create_task(client, "Task B")
    res = client.get("/api/tasks/")
    data = res.get_json()
    assert res.status_code == 200
    assert len(data) == 2


def test_get_tasks_filter_completed(client):
    create_task(client, "Incomplete")
    create_task(client, "Complete")
    # mark second task complete via PUT
    create_task(client, "Complete me")
    all_tasks = client.get("/api/tasks/").get_json()
    complete_id = all_tasks[0]["id"]
    client.put(
        f"/api/tasks/{complete_id}",
        data=json.dumps({"completed": True}),
        content_type="application/json",
    )
    res = client.get("/api/tasks/?completed=true")
    assert res.status_code == 200
    for t in res.get_json():
        assert t["completed"] is True


# ── GET /api/tasks/<id> ────────────────────────────────────────────────────

def test_get_single_task(client):
    r = create_task(client, "Single task")
    task_id = r.get_json()["id"]
    res = client.get(f"/api/tasks/{task_id}")
    assert res.status_code == 200
    assert res.get_json()["title"] == "Single task"


def test_get_nonexistent_task(client):
    res = client.get("/api/tasks/9999")
    assert res.status_code == 404


# ── POST /api/tasks/ ───────────────────────────────────────────────────────

def test_create_task_success(client):
    res = create_task(client, "New task", "Some description")
    data = res.get_json()
    assert res.status_code == 201
    assert data["title"] == "New task"
    assert data["description"] == "Some description"
    assert data["completed"] is False


def test_create_task_missing_title(client):
    res = client.post(
        "/api/tasks/",
        data=json.dumps({"description": "no title"}),
        content_type="application/json",
    )
    assert res.status_code == 400


def test_create_task_blank_title(client):
    res = client.post(
        "/api/tasks/",
        data=json.dumps({"title": "   "}),
        content_type="application/json",
    )
    assert res.status_code == 400


def test_create_task_no_body(client):
    res = client.post("/api/tasks/", content_type="application/json")
    assert res.status_code == 400


# ── PUT /api/tasks/<id> ────────────────────────────────────────────────────

def test_update_task_title(client):
    r = create_task(client, "Old title")
    task_id = r.get_json()["id"]
    res = client.put(
        f"/api/tasks/{task_id}",
        data=json.dumps({"title": "New title"}),
        content_type="application/json",
    )
    assert res.status_code == 200
    assert res.get_json()["title"] == "New title"


def test_update_task_completed(client):
    r = create_task(client, "Mark done")
    task_id = r.get_json()["id"]
    res = client.put(
        f"/api/tasks/{task_id}",
        data=json.dumps({"completed": True}),
        content_type="application/json",
    )
    assert res.status_code == 200
    assert res.get_json()["completed"] is True


def test_update_task_invalid_completed(client):
    r = create_task(client, "Bad update")
    task_id = r.get_json()["id"]
    res = client.put(
        f"/api/tasks/{task_id}",
        data=json.dumps({"completed": "yes"}),
        content_type="application/json",
    )
    assert res.status_code == 400


def test_update_nonexistent_task(client):
    res = client.put(
        "/api/tasks/9999",
        data=json.dumps({"title": "Ghost"}),
        content_type="application/json",
    )
    assert res.status_code == 404


# ── DELETE /api/tasks/<id> ─────────────────────────────────────────────────

def test_delete_task(client):
    r = create_task(client, "Delete me")
    task_id = r.get_json()["id"]
    res = client.delete(f"/api/tasks/{task_id}")
    assert res.status_code == 200
    # confirm gone
    assert client.get(f"/api/tasks/{task_id}").status_code == 404


def test_delete_nonexistent_task(client):
    res = client.delete("/api/tasks/9999")
    assert res.status_code == 404
