# PostgreSQL-High-Availability-Lab
Infraestructura de alta disponibilidad con Patroni, etcd y HAProxy.

🚀 Features
Failover automático (Patroni)
Cluster etcd con quorum (3 nodos)
Balanceo con HAProxy
VIP con Keepalived
Simulación de fallos real
🧪 Tests realizados
Caída del nodo primario
Promoción automática de réplica
Persistencia de conexión vía VIP
Inserciones tras failover
Caída de nodo etcd (quorum)
📊 Arquitectura

(imagen aquí)
