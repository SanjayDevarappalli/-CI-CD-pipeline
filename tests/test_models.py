"""Unit tests for the Task model."""
import pytest
from app import db
from app.models import Task


@pytest.fixture
def app_ctx(app):
    with app.app_context():
        yield


def test_task_creation(app):
    with app.app_context():
        task = Task(title="Buy groceries", description="Milk, eggs, bread")
        db.session.add(task)
        db.session.commit()
        assert task.id is not None


def test_task_defaults(app):
    with app.app_context():
        task = Task(title="Default task")
        db.session.add(task)
        db.session.commit()
        assert task.completed is False
        assert task.description == ""


def test_task_to_dict(app):
    with app.app_context():
        task = Task(title="Test task", description="desc")
        db.session.add(task)
        db.session.commit()
        d = task.to_dict()
        assert d["title"] == "Test task"
        assert d["description"] == "desc"
        assert d["completed"] is False
        assert "id" in d
        assert "created_at" in d
        assert "updated_at" in d


def test_task_repr(app):
    with app.app_context():
        task = Task(title="Repr test")
        db.session.add(task)
        db.session.commit()
        assert "Repr test" in repr(task)


def test_task_update_completed(app):
    with app.app_context():
        task = Task(title="Finish report")
        db.session.add(task)
        db.session.commit()
        task.completed = True
        db.session.commit()
        from app import db as _db
        fetched = _db.session.get(Task, task.id)
        assert fetched.completed is True
