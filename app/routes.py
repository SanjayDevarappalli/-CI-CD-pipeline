from flask import Blueprint, request, jsonify, abort
from app.models import Task, db


def _get_task_or_404(task_id):
    task = db.session.get(Task, task_id)
    if task is None:
        abort(404)
    return task


tasks_bp = Blueprint("tasks", __name__, url_prefix="/api/tasks")


# ── GET /api/tasks  →  list all tasks (optional ?completed=true/false filter)
@tasks_bp.route("/", methods=["GET"])
def get_tasks():
    completed = request.args.get("completed")
    query = Task.query
    if completed is not None:
        query = query.filter_by(completed=completed.lower() == "true")
    tasks = query.order_by(Task.created_at.desc()).all()
    return jsonify([t.to_dict() for t in tasks]), 200


# ── GET /api/tasks/<id>  →  single task
@tasks_bp.route("/<int:task_id>", methods=["GET"])
def get_task(task_id):
    task = _get_task_or_404(task_id)
    return jsonify(task.to_dict()), 200


# ── POST /api/tasks  →  create task
@tasks_bp.route("/", methods=["POST"])
def create_task():
    data = request.get_json(silent=True)
    if not data:
        abort(400, description="Request body must be JSON.")
    title = data.get("title", "").strip()
    if not title:
        abort(400, description="'title' is required and cannot be blank.")
    task = Task(
        title=title,
        description=data.get("description", "").strip(),
    )
    db.session.add(task)
    db.session.commit()
    return jsonify(task.to_dict()), 201


# ── PUT /api/tasks/<id>  →  update task
@tasks_bp.route("/<int:task_id>", methods=["PUT"])
def update_task(task_id):
    task = _get_task_or_404(task_id)
    data = request.get_json(silent=True)
    if not data:
        abort(400, description="Request body must be JSON.")
    if "title" in data:
        title = data["title"].strip()
        if not title:
            abort(400, description="'title' cannot be blank.")
        task.title = title
    if "description" in data:
        task.description = data["description"].strip()
    if "completed" in data:
        if not isinstance(data["completed"], bool):
            abort(400, description="'completed' must be a boolean.")
        task.completed = data["completed"]
    db.session.commit()
    return jsonify(task.to_dict()), 200


# ── DELETE /api/tasks/<id>  →  delete task
@tasks_bp.route("/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    task = _get_task_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return jsonify({"message": f"Task {task_id} deleted."}), 200


# ── Error handlers
@tasks_bp.app_errorhandler(400)
def bad_request(e):
    return jsonify({"error": str(e.description)}), 400


@tasks_bp.app_errorhandler(404)
def not_found(e):
    return jsonify({"error": "Resource not found."}), 404


@tasks_bp.app_errorhandler(405)
def method_not_allowed(e):
    return jsonify({"error": "Method not allowed."}), 405
