# utsSTDT

## 1) Teorema CAP dan BASE

**CAP**: Consistency, Availability, Partition tolerance. Teorema CAP menyatakan saat terjadi partition (P), sebuah sistem terdistribusi tidak bisa menjamin konsistensi (C) dan ketersediaan (A) sekaligus — harus memilih trade-off.

**BASE**: Basically Available, Soft state, Eventual consistency. Ini filosofi desain untuk sistem yang memilih Availability+Partition tolerance (A+P), menukar konsistensi keras dengan konsistensi bersifat eventual.

**Contoh terkait implementasi**: konfigurasi replikasi PostgreSQL:
- *Synchronous replication* → menjunjung konsistensi (C), dapat mengurangi availability saat replica tidak hadir (memilih C+P).
- *Asynchronous replication* → mempercepat availability (A) dan membiarkan replica mengejar sinkronisasi kemudian (BASE / eventual consistency).

---

## 2) GraphQL & komunikasi antar-proses

GraphQL bertindak sebagai *orchestrator/gateway* yang menerima satu query dari client dan melakukan beberapa panggilan antar-microservice (HTTP/gRPC/AMQP) untuk mengumpulkan data.

Diagram (mermaid):

```mermaid
flowchart LR
  Client -->|GraphQL Query| GraphQLServer[GraphQL Server / Gateway]
  GraphQLServer -->|HTTP/gRPC| UserService[User Service]
  GraphQLServer -->|HTTP/gRPC| OrderService[Order Service]
  GraphQLServer -->|AMQP / Kafka| InventoryService[Inventory Service]
  InventoryService -->|Event| WarehouseService[Warehouse Service]
  GraphQLServer -->|Response| Client
`

+----------+       (1. Single GraphQL Query)       +---------------------+
|          | -----------------------------------> |                     |
|  Client  |                                      |  GraphQL API        |
| (Web/App)|                                      |  Gateway / Server   |
|          | <----------------------------------- |                     |
+----------+      (5. Single JSON Response)      +---------------------+
                                                          |
                                      (2. Resolvers parse query & make IPC calls)
                                                          |
                 +--------------------+-------------------+--------------------+
                 | (IPC: gRPC)        | (IPC: REST)       | (IPC: REST/gRPC)   |
                 V                    V                   V
         +---------------+    +---------------+   +----------------+
         | User Service  |    | Order Service |   | Product Service|
         +---------------+    +---------------+   +----------------+
                 | (3. Data)          | (3. Data)         | (3. Data)
                 |                    |                   |
                 +--------------------+-------------------+
                                      |
                       (4. Data aggregated by GraphQL)

