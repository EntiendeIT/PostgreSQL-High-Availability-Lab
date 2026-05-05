# PostgreSQL High Availability Lab

Infraestructura de alta disponibilidad con PostgreSQL, Patroni, etcd, HAProxy y Keepalived.

---

## 🎯 Objetivo

Diseñar e implementar una arquitectura capaz de mantener el servicio operativo ante fallos de nodos, eliminando puntos únicos de fallo (SPOF).

---

## 🧩 Arquitectura

- PostgreSQL + Patroni → failover automático
- etcd (cluster 3 nodos) → consenso distribuido (quorum)
- HAProxy → balanceo y redirección al nodo primario
- Keepalived → gestión de IPs virtuales (VIP)
- Servidores web Apache → balanceo Round Robin

---

## 🚀 Features

- ✔️ Failover automático de PostgreSQL
- ✔️ Promoción automática de réplica a líder
- ✔️ Acceso mediante VIP sin cambiar cliente
- ✔️ Balanceo web con HAProxy
- ✔️ Tolerancia a fallo de nodos
- ✔️ Cluster etcd con quorum (2/3)

---

## 🧪 Pruebas realizadas

- 🔹 Caída del nodo primario → failover automático
- 🔹 Inserciones tras promoción de réplica
- 🔹 Conexión mediante VIP (transparente al cliente)
- 🔹 Caída de servidor web → servicio continúa
- 🔹 Caída de balanceador → VIP migra correctamente
- 🔹 Caída de nodo etcd → quorum mantiene servicio

---

## 📊 Arquitectura del sistema

![Arquitectura HA](diagramas_red/ejemplo_diagrama.jpg)

---

## ⚙️ Configuración

Se incluye la configuración de un nodo por tipo:

- `lb` → balanceador (HAProxy + Keepalived + etcd)
- `db` → nodo PostgreSQL (Patroni)
- `wa` → servidor web

Los nodos secundarios utilizan la misma configuración modificando:

- IP
- nombre del nodo
- prioridad (Keepalived)

---

## 🧠 Key Learnings

- Implementación real de alta disponibilidad
- Gestión de failover automático con Patroni
- Importancia del quorum en etcd
- Resolución de problemas de split-brain
- Eliminación de puntos únicos de fallo (SPOF)

---

## 📂 Documentación

- [Fase de pruebas](docs/FaseProves.pdf)
- [Esquemas de red](docs/projecte7_esquemas.pdf)

---

## ⚠️ Aviso

Las configuraciones incluidas son ejemplos de laboratorio.  
Las credenciales han sido modificadas (`choose-your-pwd`).

---
