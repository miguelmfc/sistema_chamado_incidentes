# Documentação dos Eventos — Sprint 2

## Tabela de eventos

| Campo | incident.created | incident.status_updated |
|---|---|---|
| **Nome do evento** | incident.created | incident.status_updated |
| **Produtor** | IncidentService.create_incident() | IncidentService.update_incident_status() |
| **Consumidor** | incident_consumer.handle_incident_created() | incident_consumer.handle_incident_updated() |
| **Fila** | incident.created | incident.status_updated |
| **Quando ocorre** | Ao criar um novo incidente via POST /api/incidents | Ao atualizar o status via PATCH /api/incidents/:id/status |

## Payload: incident.created

```json
{
  "event": "incident.created",
  "timestamp": "2026-05-25T14:30:00.000000",
  "data": {
    "id": 1,
    "title": "Acesso suspeito detectado",
    "severity": "high",
    "reporter_name": "Miguel Martins",
    "status": "open",
    "created_at": "2026-05-25 14:30:00"
  }
}
```

## Payload: incident.status_updated

```json
{
  "event": "incident.status_updated",
  "timestamp": "2026-05-25T15:00:00.000000",
  "data": {
    "id": 1,
    "title": "Acesso suspeito detectado",
    "status": "in_progress",
    "analyst_name": "Miguel Martins 2",
    "updated_at": "2026-05-25 15:00:00"
  }
}
```

## Fluxo assíncrono
