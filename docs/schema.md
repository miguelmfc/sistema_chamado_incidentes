# Schema do Banco de Dados

## Tabela: incidents

| Coluna         | Tipo    | Restrições                        | Descrição                              |
|----------------|---------|-----------------------------------|----------------------------------------|
| id             | INTEGER | PRIMARY KEY, AUTOINCREMENT        | Identificador único do incidente       |
| title          | TEXT    | NOT NULL                          | Título resumido do incidente           |
| description    | TEXT    | NOT NULL                          | Descrição detalhada do incidente       |
| severity       | TEXT    | NOT NULL, DEFAULT 'medium'        | Severidade: low, medium, high, critical|
| status         | TEXT    | NOT NULL, DEFAULT 'open'          | Status: open, in_progress, resolved, closed |
| reporter_name  | TEXT    | NOT NULL                          | Nome do usuário que reportou           |
| analyst_name   | TEXT    | NULLABLE                          | Nome do analista responsável           |
| created_at     | TEXT    | DEFAULT datetime('now')           | Horário de criação                   |
| updated_at     | TEXT    | DEFAULT datetime('now')           | Horário da última atualização        |

## Valores válidos

- **severity**: `low` | `medium` | `high` | `critical`
- **status**: `open` | `in_progress` | `resolved` | `closed`