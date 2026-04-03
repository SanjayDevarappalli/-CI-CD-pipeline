from flask import Flask, render_template
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()


def create_app(config=None):
    app = Flask(__name__)

    # Default config
    app.config["SQLALCHEMY_DATABASE_URI"] = (
        "sqlite:///tasks.db"  # overridden by env var in production
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["TESTING"] = False

    import os
    if os.environ.get("DATABASE_URL"):
        app.config["SQLALCHEMY_DATABASE_URI"] = os.environ["DATABASE_URL"]

    if config:
        app.config.update(config)

    db.init_app(app)
    migrate.init_app(app, db)

    from app.routes import tasks_bp
    app.register_blueprint(tasks_bp)

    @app.route("/health")
    def health():
        return {"status": "ok"}, 200

    @app.route("/")
    def index():
        return render_template("index.html")

    return app
