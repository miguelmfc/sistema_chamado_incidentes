# SecCall — Sistema de Gestão de Incidentes de Segurança

## Componentes
- `backend/` — API REST em Flask (Python)
- `client_app/` — App Flutter do cliente (usuário que reporta)
- `analyst_app/` — App Flutter do analista (prestador de serviços)

## Como executar

### Pré-requisitos
- Python 3.11+
- Flutter 3.10+
- Docker Desktop

### 1. RabbitMQ
```bash
docker start rabbitmq
```

### 2. Backend
```bash
cd backend
pip install -r requirements.txt
python run.py
```

### 3. Consumidor
```bash
cd backend
python app/consumers/incident_consumer.py
```

### 4. App Cliente
```bash
cd client_app
flutter run -d edge --web-port 3000
```

### 5. App Analista
```bash
cd analyst_app
flutter run -d edge --web-port 3001
```

## Arquitetura
Flask REST + SQLite + RabbitMQ (MOM) + Flutter Web (2 apps)