# M-TREAT Patient Registration System

## Prerequisites

- Python 3.9+
- Node.js 14+
- PostgreSQL

## Backend Setup

1. Create virtual environment

```bash
python3 -m venv venv
source venv/bin/activate
```

2. Install dependencies

```bash
pip install -r requirements.txt
```

3. Database Configuration

- Create PostgreSQL database
- Update .env with your credentials

4. Run Migrations

```bash
python manage.py migrate
```

5. Start Server

```bash
python manage.py runserver
```

## Frontend Setup

1. Install dependencies

```bash
cd frontend
npm install
```

2. Start Development Server

```bash
npm start
```

## Project Structure

- `backend/`: Django REST framework backend
- `frontend/`: React Redux frontend
- `.env`: Environment configuration
