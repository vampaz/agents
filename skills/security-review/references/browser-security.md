# Browser Security

Selected guidance adapted from GoogleChrome's Modern Web Guidance, reviewed on 2026-10-28 at commit `4f2b13e25c5815b3f080ca0d983e828d96561a0f`. This local adaptation scopes browser hardening to the requested work and the application's existing architecture. It omits the upstream installer and automatic rollout requirements. The upstream material is licensed under [Apache-2.0](../LICENSE.google-modern-web-guidance).

## DOM injection

- Render plain text with framework escaping or `textContent`. Parsing markup, including through `DOMParser`, does not by itself sanitize it for later insertion.
- Where rich HTML is required, use the application's maintained sanitizer at the rendering boundary. Native sanitizing APIs may be an option when the target browsers support them; methods named `Unsafe` do not provide that guarantee.
- Trusted Types constrains dangerous sinks but does not invent a sanitization policy. A policy that returns its input unchanged defeats the intended protection.
- Keep sanitization on unsupported browsers too. A compatibility wrapper cannot reproduce native Trusted Types enforcement, and must not become an unsanitized fallback.

## CSP and Trusted Types

1. Locate existing headers in the server, CDN, and framework. Inventory inline scripts, dynamic loaders, HTML sinks, embeds, and authentication/payment popups before proposing stricter policies.
2. For a new or stricter policy on an existing application, start with `Content-Security-Policy-Report-Only` while retaining current enforcement. Collect violations through an approved endpoint or inspect them in the browser. Report-only detects breakage; it does not block an attack.
3. Migrate allowed scripts to framework-supported per-response nonces or hashes, and update sink writes to real sanitizing Trusted Types policies. A nonce must be unpredictable and generated for each response; it must match the script markup. Review response caching so a nonce-bearing page is not reused across responses.
4. Test the affected routes and integrations before enforcement. Restrict Trusted Types policy names to those actually needed. Do not add pass-through policies or broad `'unsafe-inline'`/`'unsafe-eval'` exceptions merely to silence violations.

Use headers for policies such as `frame-ancestors`; it is not supported in a CSP meta tag. Choose allowed embedders from product requirements. COOP/COEP can affect OAuth popups, payments, and embedded resources, so do not apply a blanket isolation configuration without testing those flows.

## Cookies and cross-origin boundaries

- For first-party session cookies, use `Secure` and `HttpOnly` and choose `SameSite` for the actual login and navigation flows. Strict can interfere with cross-site entry; Lax is often suitable for ordinary first-party navigation. Cross-site cookies require separate analysis.
- Use the `__Host-` prefix when a cookie is intentionally host-only: it requires `Secure`, `Path=/`, and no `Domain` attribute. Do not rename shared-domain cookies without checking their consumers.
- CORS controls which responses another origin can read. It is neither authorization nor a complete CSRF defense. Validate allowed origins exactly and avoid wildcard origins with credentialed requests.
- For `postMessage`, specify the intended target origin, validate the sender's origin, and check `event.source` when the sender should be a particular window. Validate the message shape before dispatching operations; substring origin comparisons are unsafe.
- Keep passwords, tokens, and user content out of policy reports and logs. Review reporting payloads before enabling additional telemetry.

## Passkeys

Apply this section when implementing or reviewing passkeys; it does not require adding them to an existing login flow.

- Verify secure-context and relying-party ID requirements for the application's domains. A successful browser call alone is not authenticated application access.
- Reuse the existing vetted server-side WebAuthn implementation for challenges and verification. Check challenge binding, expected origin/RP ID, signature verification, and the required user-verification policy; keep account authorization on the server.
- Feature-detect optional convenience APIs, such as conditional mediation, without breaking the existing sign-in path.
- Authenticator provider labels derived from AAGUID are display hints for ordinary consumer passkeys, not proof that a credential came from a trusted provider.
- Preserve the framework and authentication library already in use. New browser examples do not justify a dependency swap or handwritten cryptographic verification.

## Verification

Exercise permitted and rejected DOM input, policy violations, login/logout, redirects, relevant popup and iframe flows, and message rejection. Verify behavior on the supported browser set, including browsers without newer enforcement APIs. A clean report-only run covers the exercised paths; it does not prove every route is ready for enforcement.

## Sources

- [Web security](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/security/security.md)
- [Trusted Types](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/security/trusted-types.md)
- [Passkeys](https://github.com/GoogleChrome/modern-web-guidance/blob/4f2b13e25c5815b3f080ca0d983e828d96561a0f/skills/modern-web-guidance/guides/security/passkeys.md)
