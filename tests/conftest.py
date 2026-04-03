import pytest
from app import create_app, db as _db


@pytest.fixture(scope="session")
def app():
    """Create application for testing."""
    test_config = {
        "TESTING": True,
        "SQLALCHEMY_DATABASE_URI": "sqlite:///:memory:",
        "SQLALCHEMY_TRACK_MODIFICATIONS": False,
    }
    app = create_app(config=test_config)

    with app.app_context():
        _db.create_all()
        yield app
        _db.drop_all()


@pytest.fixture(scope="function")
def client(app):
    """Test client for each test function."""
    return app.test_client()


@pytest.fixture(scope="function", autouse=True)
def clean_db(app):
    """Wipe all rows before every test (keeps schema)."""
    with app.app_context():
        yield
        _db.session.rollback()
        for table in reversed(_db.metadata.sorted_tables):
            _db.session.execute(table.delete())
        _db.session.commit()
