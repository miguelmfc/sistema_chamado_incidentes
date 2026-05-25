import pika
import logging

RABBITMQ_URL = 'amqp://guest:guest@localhost:5672/'

QUEUES = {
    'incident_created': 'incident.created',
    'incident_updated': 'incident.status_updated',
}

def get_connection():
    params = pika.URLParameters(RABBITMQ_URL)
    return pika.BlockingConnection(params)

def get_channel(connection):
    channel = connection.channel()
    for queue in QUEUES.values():
        channel.queue_declare(queue=queue, durable=True)
    return channel

def publish(queue_name, message: str):
    try:
        connection = get_connection()
        channel = get_channel(connection)
        channel.basic_publish(
            exchange='',
            routing_key=queue_name,
            body=message.encode(),
            properties=pika.BasicProperties(delivery_mode=2)
        )
        connection.close()
        logging.info(f'[MOM] Evento publicado em "{queue_name}": {message}')
    except Exception as e:
        logging.error(f'[MOM] Falha ao publicar evento: {e}')