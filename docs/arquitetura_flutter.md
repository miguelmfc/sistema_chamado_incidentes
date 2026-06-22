# Arquitetura do App Flutter — Cliente

## Camadas

### Models (lib/models/)
Representação dos objetos de domínio em Dart.
- `incident.dart` — classe Incident com fromJson()

### Services (lib/services/)
Comunicação com o backend REST.
- `incident_service.dart` — chamadas HTTP (GET, POST)

### Screens (lib/screens/)
Telas do aplicativo.
- `incident_list_screen.dart` — listagem com filtros e polling
- `incident_detail_screen.dart` — detalhes de um incidente
- `create_incident_screen.dart` — formulário de criação

## Atualização assíncrona
Implementada via polling com Timer.periodic de 10 segundos
na IncidentListScreen. Não requer ação do usuário.

## Fluxo de navegação
Lista → (toque no item) → Detalhes
Lista → (botão novo chamado) → Criação → retorna para Lista
