import pika
import json
import logging
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', '..', '..'))

from messaging import get_connection, get_channel, QUEUES

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [CONSUMER] %(message)s',
    datefmt='%H:%M:%S'
)

def handle_incident_created(ch, method, properties, body):
    data = json.loads(body.decode())
    incident = data['data']
    logging.info(f"NOVO INCIDENTE RECEBIDO:")
    logging.info(f"  ID       : {incident['id']}")
    logging.info(f"  Título   : {incident['title']}")
    logging.info(f"  Severidade: {incident['severity']}")
    logging.info(f"  Reportado por: {incident['reporter_name']}")
    logging.info(f"  Timestamp: {data['timestamp']}")
    ch.basic_ack(delivery_tag=method.delivery_tag)

def handle_incident_updated(ch, method, properties, body):
    data = json.loads(body.decode())
    incident = data['data']
    logging.info(f"INCIDENTE ATUALIZADO:")
    logging.info(f"  ID      : {incident['id']}")
    logging.info(f"  Título  : {incident['title']}")
    logging.info(f"  Novo status: {incident['status']}")
    logging.info(f"  Analista: {incident['analyst_name']}")
    logging.info(f"  Timestamp: {data['timestamp']}")
    ch.basic_ack(delivery_tag=method.delivery_tag)

def start_consumer():
    connection = get_connection()
    channel = get_channel(connection)

    channel.basic_consume(
        queue=QUEUES['incident_created'],
        on_message_callback=handle_incident_created
    )
    channel.basic_consume(
        queue=QUEUES['incident_updated'],
        on_message_callback=handle_incident_updated
    )

    logging.info('Consumidor iniciado. Aguardando eventos...')
    logging.info(f'Filas monitoradas: {list(QUEUES.values())}')
    channel.start_consuming()

if __name__ == '__main__':
    start_consumer()