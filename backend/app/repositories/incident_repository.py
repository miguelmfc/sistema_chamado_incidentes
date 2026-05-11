from database import get_connection
from app.models.incident import Incident

class IncidentRepository:

    def _row_to_incident(self, row):
        return Incident(
            id=row['id'],
            title=row['title'],
            description=row['description'],
            severity=row['severity'],
            status=row['status'],
            reporter_name=row['reporter_name'],
            analyst_name=row['analyst_name'],
            created_at=row['created_at'],
            updated_at=row['updated_at']
        )

    def find_all(self):
        conn = get_connection()
        rows = conn.execute('SELECT * FROM incidents ORDER BY created_at DESC').fetchall()
        conn.close()
        return [self._row_to_incident(r) for r in rows]

    def find_by_id(self, incident_id):
        conn = get_connection()
        row = conn.execute('SELECT * FROM incidents WHERE id = ?', (incident_id,)).fetchone()
        conn.close()
        return self._row_to_incident(row) if row else None

    def create(self, title, description, severity, reporter_name):
        conn = get_connection()
        cursor = conn.execute(
            '''INSERT INTO incidents (title, description, severity, reporter_name)
               VALUES (?, ?, ?, ?)''',
            (title, description, severity, reporter_name)
        )
        conn.commit()
        incident_id = cursor.lastrowid
        conn.close()
        return self.find_by_id(incident_id)

    def update_status(self, incident_id, status, analyst_name=None):
        conn = get_connection()
        conn.execute(
            '''UPDATE incidents
               SET status = ?,
                   analyst_name = COALESCE(?, analyst_name),
                   updated_at = datetime('now')
               WHERE id = ?''',
            (status, analyst_name, incident_id)
        )
        conn.commit()
        conn.close()
        return self.find_by_id(incident_id)

    def delete(self, incident_id):
        conn = get_connection()
        affected = conn.execute('DELETE FROM incidents WHERE id = ?', (incident_id,)).rowcount
        conn.commit()
        conn.close()
        return affected > 0