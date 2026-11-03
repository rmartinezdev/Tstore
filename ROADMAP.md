# ROADMAP.md - Plan de Versiones Futuras

Este documento traza el camino de desarrollo proyectado para expandir las capacidades de la aplicación e-commerce TStore.

---

## Fase 1: Corto Plazo (Q3 2026) - Consolidación del E-commerce

* **Integración Completa de Notificaciones Push:**
  Implementar la arquitectura de Firebase Cloud Messaging (F FCM) ya preparada para enviar alertas de promociones, cambios en el estado de pedidos y carritos abandonados.
* **Módulo de Cupones y Descuentos Especiales:**
  Agregar validación de códigos de cupones durante el proceso de checkout y cálculo dinámico de subtotales.
* **Pasarela de Pagos Móviles (Paypal / Stripe):**
  Integrar SDKs de cobro directo y confirmación del estado del pago antes de enviar la orden final a Odoo.
* **Lista de Deseos Avanzada (Wishlist):**
  Permitir guardar múltiples listas de deseos temáticas con posibilidad de compartirlas mediante enlaces profundos (Deep Links).

---

## Fase 2: Mediano Plazo (Q4 2026) - Experiencia Inteligente

* **Chatbot de Asistencia con Inteligencia Artificial (Chat IA):**
  Implementar un bot de ayuda interactivo que responda preguntas técnicas del catálogo, sugiera productos alternativos basándose en el historial del cliente y consulte el estado del envío consumiendo APIs de Odoo.
* **Geolocalización & Rastreo de Envíos:**
  Integrar Google Maps SDK para que los usuarios puedan ver en tiempo real el trayecto de su paquete y registrar coordenadas GPS precisas de entrega.
* **Escáner de Código de Barras y QR:**
  Permitir a los usuarios buscar productos escaneando códigos de barra físicos, o facilitar al personal de almacén la carga de stock escaneando códigos QR.

---

## Fase 3: Largo Plazo (Q1 2027) - Capacidades Corporativas

* **Programa de Fidelización y Puntos:**
  Añadir acumulación de puntos por compras realizadas e integrarlo con el módulo de cupones de Odoo para canjearlos por descuentos o regalos.
* **Membresías VIP y Suscripciones:**
  Permitir a los usuarios pagar planes recurrentes para acceder a envíos gratis y catálogos de ofertas anticipadas.
* **Arquitectura Multi-Almacén y Multi-Empresa:**
  Habilitar la consulta de stock geolocalizada, mostrando la disponibilidad del artículo según la sucursal más cercana o el almacén seleccionado del usuario.
