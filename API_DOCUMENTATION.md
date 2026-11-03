# API_DOCUMENTATION.md - Documentación de APIs Odoo 19 REST Controllers

Toda la comunicación de red con Odoo 19 se realiza exclusivamente mediante controladores HTTP JSON REST. No se utiliza el protocolo XMLRPC directamente. A continuación se detallan los endpoints mínimos requeridos y simulados por el sistema.

---

## 1. Módulo de Autenticación

### POST /api/auth/login
* **Descripción:** Iniciar sesión y obtener tokens JWT de acceso.
* **Autenticación requerida:** No.
* **Headers:**
  `Content-Type: application/json`
* **Body JSON:**
  ```json
  {
    "username": "juan.perez@example.com",
    "password": "mi_contraseña_secreta"
  }
  ```
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "token": "mock-jwt-access-token-secret-12345",
    "refresh_token": "mock-jwt-refresh-token-secret-67890",
    "user": {
      "id": 42,
      "name": "Juan Pérez",
      "email": "juan.perez@example.com",
      "phone": "+54 9 11 5555-1234",
      "address": "Av. de Mayo 800, CABA, Argentina"
    }
  }
  ```
* **Respuesta de Error (400 Bad Request):**
  ```json
  {
    "success": false,
    "message": "Usuario/Email y contraseña son requeridos"
  }
  ```

---

### POST /api/auth/refresh
* **Descripción:** Refrescar el token de acceso JWT expirado.
* **Autenticación requerida:** Sí (Header de Autorización con Refresh Token).
* **Body JSON:**
  ```json
  {
    "refresh_token": "mock-jwt-refresh-token-secret-67890"
  }
  ```
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "token": "new-mock-jwt-access-token-secret-12345",
    "refresh_token": "new-mock-jwt-refresh-token-secret-67890"
  }
  ```
* **Respuesta de Error (401 Unauthorized):**
  ```json
  {
    "success": false,
    "message": "Sesión expirada. Por favor inicie sesión de nuevo."
  }
  ```

---

### GET /api/auth/profile
* **Descripción:** Obtiene los datos del perfil del cliente autenticado.
* **Autenticación requerida:** Sí (`Bearer <token>`).
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "user": {
      "id": 42,
      "name": "Juan Pérez",
      "email": "juan.perez@example.com",
      "phone": "+54 9 11 5555-1234",
      "address": "Av. de Mayo 800, CABA, Argentina"
    }
  }
  ```

---

## 2. Módulo de Productos

### GET /api/products
* **Descripción:** Obtiene el listado paginado y filtrado de productos del catálogo de Odoo.
* **Autenticación requerida:** No.
* **Query Parameters:**
  * `limit`: Cantidad de ítems a recuperar (default `10`).
  * `offset`: Desplazamiento de ítems para paginación (default `0`).
  * `category_id`: Filtrar por categoría.
  * `search`: Filtrar por coincidencia de texto (nombre, SKU o marca).
  * `sort_by`: Criterio de orden (`name`, `price_asc`, `price_desc`).
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "products": [
      {
        "id": 101,
        "name": "iPhone 15 Pro Max",
        "sku": "IPH15PM-256",
        "internal_code": "OD-PROD-001",
        "category_id": 11,
        "brand": "Apple",
        "short_description": "Pantalla Super Retina XDR de 6.7 pulgadas.",
        "description_html": "<h3>Rendimiento...</h3>",
        "price_normal": 1399.00,
        "price_offer": 1299.00,
        "discount": 7.1,
        "stock": 25,
        "availability": "En Stock",
        "weight": 0.221,
        "attributes": {"Color": "Titanio Negro"},
        "image_url": "https://images.unsplash.com/photo-1695048133142-1a20484d2569",
        "gallery": [],
        "videos": [],
        "documents": [],
        "is_featured": true,
        "is_new": false,
        "is_offer": true,
        "related_product_ids": [102]
      }
    ],
    "total_count": 10,
    "offset": 0,
    "limit": 10
  }
  ```

---

### GET /api/products/{id}
* **Descripción:** Recupera la ficha técnica y galería detallada de un producto específico.
* **Autenticación requerida:** No.
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "product": { ... }
  }
  ```
* **Respuesta de Error (404 Not Found):**
  ```json
  {
    "success": false,
    "message": "Producto no encontrado"
  }
  ```

---

## 3. Módulo de Categorías

### GET /api/categories/tree
* **Descripción:** Retorna el árbol jerárquico completo de categorías y subcategorías de Odoo.
* **Autenticación requerida:** No.
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "categories": [
      {
        "id": 1,
        "name": "Tecnología",
        "parent_id": null,
        "image_url": "https://...",
        "products_count": 4,
        "subcategories": [
          {
            "id": 11,
            "name": "Smartphones",
            "parent_id": 1,
            "image_url": "https://...",
            "products_count": 2
          }
        ]
      }
    ]
  }
  ```

---

## 4. Módulo del Carrito de Compras

### GET /api/cart
* **Descripción:** Obtiene los artículos agregados al carrito del usuario en el servidor.
* **Autenticación requerida:** Sí (`Bearer <token>`).
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "cart": [
      {
        "product_id": 101,
        "quantity": 2,
        "product": { ... }
      }
    ]
  }
  ```

---

### POST /api/cart/add
* **Descripción:** Agrega un producto al carrito de Odoo.
* **Autenticación requerida:** Sí (`Bearer <token>`).
* **Body JSON:**
  ```json
  {
    "product_id": 101,
    "quantity": 1
  }
  ```
* **Respuesta Exitosa (200 OK):**
  ```json
  {
    "success": true,
    "cart": [ ... ]
  }
  ```

---

## 5. Módulo de Pedidos (Checkout)

### POST /api/orders/create
* **Descripción:** Finaliza la compra de los artículos contenidos en el carrito del cliente de Odoo, generando un presupuesto o pedido de venta.
* **Autenticación requerida:** Sí (`Bearer <token>`).
* **Respuesta Exitosa (201 Created):**
  ```json
  {
    "success": true,
    "order": {
      "id": 1002,
      "name": "SO-1002",
      "date": "2026-07-19T23:40:00Z",
      "state": "draft",
      "total": 1299.00,
      "items": [ ... ],
      "invoice_url": "https://pdf-invoice-mock.s3.amazonaws.com/invoice-1002.pdf"
    }
  }
  ```
* **Respuesta de Error (400 Bad Request):**
  ```json
  {
    "success": false,
    "message": "El carrito está vacío"
  }
  ```
