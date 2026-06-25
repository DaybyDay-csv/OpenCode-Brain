# Decisiones — Globalthy

Decisiones aceptadas, una por sección, con frontmatter. Append-only.
El agente las escribe cuando el usuario confirma ("OK", "decidido", "agreed").

---

## 2026-06-24 · Enfoque de propuesta: test diagnóstico de 30 días antes que plan completo

**Status:** propuesta (pendiente confirmar envío a Gisela/Iván)
**Contexto:** tras reunión 2 del 19 junio, Gisela confirmó: caja=0, Iván reticente sin asistir por trauma con 5.000€ en Meta fallidos, trauma adicional con bots en IG (600 likes / 80% falsos), necesidad de ver "1 cliente aunque sea" ya.

**Decisión:**
- La propuesta enviada será la **v3** (test 30 días, no plan completo de 6-12 meses)
- Auditoría gratis de los 5.000€ fallidos abre la propuesta como prueba de honestidad técnica
- Mes 1: 150€ de ad spend + 0€ de fee si no hay cita
- Mes 2+: 800€/mes + 5€/cita desde la 3ª (bonus por performance)
- 1 sola vertical al principio (psicología, por datos que Gisela dio: 40€/sesión, 50% recurrencia, 6 visitas/año)
- 1 solo profesional fundador para el test

**Razones:**
- Iván firmó 5.000€ y se quedó sin nada → cualquier propuesta con fee alto o contrato largo muere
- Gisela dijo "ponnos algo que veamos un cliente" → el test de 30 días responde a eso sin quemar caja
- Gemini confirmó: "Si acepta el test rápido, el pago variable y audita vuestro error anterior gratis, dale una oportunidad"

**Trade-off aceptado:**
- Si el test falla, Globalthy pierde 150€ y se queda con todo el material producido (sin caja quemada)
- Si el test funciona, paso a fee de 800€/mes que es la sexta parte de agencia estándar

---

## 2026-06-24 · Posicionamiento de Globalthy: nunca contra SS/aseguradoras, siempre contra la situación del usuario

**Status:** confirmado (Gisela lo verbalizó explícitamente en reunión 2)
**Contexto:** Gisela fue tajante: "No queremos ponernos en contra de las aseguradoras ni de la Seguridad Social. Trabajamos con aseguradoras en nuestra práctica privada. No queremos comparaciones."

**Decisión:**
- El copy de paid nunca nombra explícitamente a SS ni aseguradoras
- La comparación es contra la **situación del usuario**:
  - "Pagas una cuota mensual sin usar"
  - "Esperas 105 días para un especialista"
  - "No tienes una red de profesionales certificados en tu problema concreto"
- Beneficio comunicado en contraposición a lo que el usuario **pierde** si no usa Globalthy
- Frase ancla: **"pagas solo cuando lo necesitas, con el especialista que necesitas, cuando lo necesitas"**

**Aplicación operativa:**
- Cada anuncio se centra en el **perfil del profesional y su solución**, nunca en el problema del paciente (compliance-friendly y autorizado por Gisela)
- Estrategia de nicho: cada profesional = 1 especialidad concreta = 1 anuncio + 1 LP

---

## 2026-06-24 · Mínimos de atribución para que un cliente "cuente como venido de nosotros"

**Status:** propuesto en v3, pendiente validar con Gisela/Iván
**Contexto:** Gisela dijo "ponnos algo que veamos algo concreto que veamos un cliente aunque sea". Sin atribución clara, no se puede saber qué clientes vienen del plan y cuáles son ruido orgánico.

**Decisión:**
- Los 5 mínimos de tracking que se necesitan desde el día 1:
  1. UTM único en cada anuncio (utm_source=meta, utm_campaign=test_psico_junio)
  2. Evento "reserva iniciada" en la web/app
  3. Evento "reserva confirmada" (solo si completa el flujo)
  4. Evento "pago recibido" (vía Stripe webhook) — métrica real
  5. Captura de email + teléfono del paciente en el flujo
- Lo que **NO cuenta** como cliente venido de nosotros: visitas, clics, registros, descargas
- Vara de medir: si un paciente completa reserva Y pago vía el canal paid, cuenta. Si no completa pago, no cuenta

**Trade-off aceptado:**
- Sesgo conservador: subestimamos resultados en lugar de sobreestimarlos
- Coherente con el principio "cero humo": si al final del mes hay 2 clientes que pagaron, no decimos "hemos traído 5 leads cualificados"

---

## 2026-06-24 · Skin in the game: honorarios solo si hay cita real

**Status:** propuesto en v3, pendiente validar con Gisela/Iván
**Contexto:** Iván dijo "Iván está muy en contra porque hemos invertido en Meta y hemos conseguido cero clientes". La estructura de fees tradicional (retainer fijo mensual) no alineaba incentivos con esta cicatriz.

**Decisión:**
- Mes 1 del test: 0€ de fee Pablo (honorarios completos condicionales a cita real)
- Si en mes 1 hay ≥3 citas: paso a mes 2 con fee de 800€/mes + 5€/cita desde la 3ª
- Si en mes 1 hay <3 citas: renegociamos o paramos sin debernos nada

**Razones:**
- Acepto este modelo porque estoy seguro de que con metodología correcta y 150€ en ads, en 30 días validamos al menos el canal
- Si no validamos, el problema es propuesta o profesional elegido, no metodología
- Demuestra a Gisela/Iván que asumo el mismo riesgo que les pido asumir

---

## 2026-06-13 · Estructura 4 fases del roadmap

**Status:** propuesta (pendiente validar en reunión 2, que se celebró el 19/06)
**Contexto:** tras 1ª reunión, Gisela confirmó interés en seguir hablando. Iván propuso masterclass para profesionales como idea semilla.

**Decisión:**
- Estructura del sistema en 4 fases: F0 (Foundation) → F1 (Activación) → F2 (Escala) → F3 (Aceleración)
- Cada fase se paga con KPIs de la anterior
- Salida limpia a 3 meses si no funciona
- Pricing total 12 meses (sin ad spend): ~150.000-175.000 €
- Ad spend aparte (Meta/Google): 50.000-120.000 € en 12 meses

**Trade-off aceptado:**
- F0 es caro (4.000€) para una startup sin presupuesto. Se mantiene porque sin tracking no hay nada
- Equipo Pablo al 98% de capacidad durante 12 meses (no puede tomar proyectos grandes adicionales sin soltar Globalthy)

**Reemplazado por:**
- Propuesta v3 (test 30 días) como punto de entrada real, no F0

---

## 2026-06-10 · Posicionamiento "Growth Partner" vs agencia tradicional

**Status:** confirmado
**Contexto:** Pablo compite contra agencias tradicionales con retainer 2.000-4.000€/mes. Necesita diferenciarse.

**Decisión:**
- Posicionarse como growth partner, no como agencia de ads
- Trato de socio, no de proveedor
- Visión a 12-24 meses, no por campaña
- Sistema, no servicios sueltos
- Cobrar por construcción, no por promesa

**Aplicación operativa:**
- Toda comunicación usa "sistema", "vía", "fase" — nunca "campaña", "servicio", "paquete"
- Pricing por fase, no por servicio
- Reporting por KPIs de negocio, no por métricas de vanidad
