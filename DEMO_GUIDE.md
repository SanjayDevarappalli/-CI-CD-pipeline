# TaskAPI - Quick Commands

## Run Locally

```bash
pip install -r requirements.txt
python wsgi.py
```
Open: http://localhost:5000

## Docker

```bash
# Build
docker build -t taskapi .

# Run locally built
docker run -p 5000:5000 taskapi

# Pull from Docker Hub
docker pull devarapallisanjay/taskapi:latest
docker run -p 5000:5000 devarapallisanjay/taskapi:latest
```

## Git + CI/CD

```bash
git add .
git commit -m "message"
git push
```

Pipeline runs automatically on GitHub Actions after push.

## Test API

```bash
curl http://localhost:5000/health
curl http://localhost:5000/api/tasks
```

## Links

- GitHub Repo: https://github.com/SanjayDevarappalli/-CI-CD-pipeline/actions
- Docker Hub: https://hub.docker.com/u/devarapallisanjay/taskapi
- API: http://localhost:5000
- Web UI: http://localhost:5000 (same URL)
