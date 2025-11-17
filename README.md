`markdown
# utsSTDT

Repository ini berisi jawaban UTS dan contoh implementasi PostgreSQL streaming replication dengan Docker Compose.

## Isi:
1. Penjelasan teorema CAP dan BASE (dengan contoh)
2. Keterkaitan GraphQL dengan komunikasi antar-proses (diagram dan penjelasan)
3. Implementasi praktis: Docker Compose untuk primary + replica PostgreSQL, langkah-langkah, dan verifikasi

## Cara pakai (singkat)
1. Pastikan Docker & Git terpasang
2. Buka terminal di folder ini
3. Jalankan: `docker compose up --build`
4. Verifikasi seperti dijelaskan di bagian 3

(Langkah rinci ada di bagian bawah README ini)

---
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

flowchart LR
  Client -->|GraphQL Query| GraphQLServer[GraphQL Server / Gateway]
  GraphQLServer -->|HTTP/gRPC| UserService[User Service]
  GraphQLServer -->|HTTP/gRPC| OrderService[Order Service]
  GraphQLServer -->|AMQP / Kafka| InventoryService[Inventory Service]
  InventoryService -->|Event| WarehouseService[Warehouse Service]
  GraphQLServer -->|Response| Client
`
                 |                    |                   |
                 +--------------------+-------------------+
                                      |
                       (4. Data aggregated by GraphQL)
