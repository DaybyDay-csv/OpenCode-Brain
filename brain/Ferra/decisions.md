# Decisiones — Ferra

Decisiones aceptadas, una por sección, con frontmatter. Append-only.
El agente las escribe cuando el usuario confirma ("OK", "decidido", "agreed").

---

## 2026-06-16 — Migración Worker → Pages

**Contexto:** El sitio estaba en un Worker (`coming-soon-mailer`) que servía la landing + mailer en un solo bundle monolítico. Necesitábamos añadir páginas legales (privacy, terms) con URLs reales en ferra.es.

**Decisión:** Migrar todo a Cloudflare Pages:
- Static HTML en `index.html`, `privacy.html`, `terms.html`
- Mailer como Pages Function en `functions/api/subscribe.js`
- Worker `coming-soon-mailer` borrado del dashboard
- Custom domain `ferra.es` apuntado a Pages via CNAME

**Razón:** Workers y Pages no pueden coexistir sirviendo el mismo path. Pages permite tener rutas estáticas + functions en el mismo proyecto, lo cual es más limpio y estándar que un Worker monolítico.

**Resultado:** ✅ Todo funcionando, 3 páginas en 200, mailer acepta submissions, headers de seguridad aplicados.

---

## 2026-06-16 — Páginas legales bilingües EN+ES en columnas

**Decisión:** Formato side-by-side columns (NO rutas separadas por idioma).

**Razón:** 
- Es un sitio de una sola página + dos legales, no un sitio multi-idioma completo
- Un .es TLD no necesita hreflang ni SEO multi-idioma
- Las columnas lado a lado son más legibles que el selector de idioma
- Menos páginas que mantener (1 vs 2 por idioma)

**Resultado:** ✅ Privacidad y Términos en columnas EN+ES, last updated 2026-06-16, GDPR-grade con LOPDGDD española.

---

## 2026-06-16 — Footer con 4 enlaces (Home, Privacy, Terms, Contact)

**Decisión:** Incluir Contact (mailto:admin@ferra.es) además de los 3 enlaces originales.

**Razón:** GDPR/LOPDGDD requieren un punto de contacto visible. El usuario lo pidió explícitamente.

**Resultado:** ✅ Footer en las 3 páginas con los 4 enlaces, hover state blanco.
