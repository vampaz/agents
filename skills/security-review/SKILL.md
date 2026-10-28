---
name: security-review
description: Ensure code follows security best practices and identify potential vulnerabilities.
---

This skill ensures all code follows security best practices and identifies potential vulnerabilities.

For browser security guidance adapted from Google's Modern Web Guidance, read [references/browser-security.md](references/browser-security.md) when reviewing DOM injection, CSP, Trusted Types, cookies, cross-origin messaging, or passkeys. Apply the relevant section within the task's scope; the reference does not require a full security rollout for every frontend change.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

## Security Checklist

### 1. Secrets Management

#### NEVER Do This

```typescript
const apiKey = 'sk-proj-xxxxx'
const dbPassword = 'password123'
```

#### ALWAYS Do This

```typescript
const apiKey = process.env.OPENAI_API_KEY
const dbUrl = process.env.DATABASE_URL

if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

#### Verification Steps

- No hardcoded API keys, tokens, or passwords
- All secrets in environment variables
- .env.local in .gitignore
- No secrets in git history
- Production secrets in hosting platform (Vercel, Railway)

### 2. Input Validation

#### Always Validate User Input

```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
  age: z.number().int().min(0).max(150)
})

export async function createUser(input: unknown) {
  try {
    const validated = CreateUserSchema.parse(input)
    return await db.users.create(validated)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.errors }
    }
    throw error
  }
}
```

#### File Upload Validation

```typescript
function validateFileUpload(file: File) {
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    throw new Error('File too large (max 5MB)')
  }

  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type')
  }

  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif']
  const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0]
  if (!extension || !allowedExtensions.includes(extension)) {
    throw new Error('Invalid file extension')
  }

  return true
}
```

#### Verification Steps

- All user inputs validated with schemas
- File uploads restricted (size, type, extension)
- No direct use of user input in queries
- Whitelist validation (not blacklist)
- Error messages do not leak sensitive info

### 3. SQL Injection Prevention

#### NEVER Concatenate SQL

```typescript
const query = `SELECT * FROM users WHERE email = '${userEmail}'`
await db.query(query)
```

#### ALWAYS Use Parameterized Queries

```typescript
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('email', userEmail)

await db.query(
  'SELECT * FROM users WHERE email = $1',
  [userEmail]
)
```

#### Verification Steps

- All database queries use parameterized queries
- No string concatenation in SQL
- ORM or query builder used correctly
- Supabase queries properly sanitized

### 4. Authentication and Authorization

#### JWT Token Handling

```typescript
res.setHeader(
  'Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`
)
```

#### Authorization Checks

```typescript
export async function deleteUser(userId: string, requesterId: string) {
  const requester = await db.users.findUnique({
    where: { id: requesterId }
  })

  if (requester.role !== 'admin') {
    return NextResponse.json(
      { error: 'Unauthorized' },
      { status: 403 }
    )
  }

  await db.users.delete({ where: { id: userId } })
}
```

#### Row Level Security (Supabase)

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

#### Verification Steps

- Tokens stored in httpOnly cookies (not localStorage)
- Authorization checks before sensitive operations
- Row Level Security enabled in Supabase
- Role-based access control implemented
- Session management secure

### 5. XSS Prevention

#### Sanitize HTML

```typescript
import DOMPurify from 'isomorphic-dompurify'

function renderUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: []
  })
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

#### Content Security Policy

Inspect the application's existing headers, inline scripts, and third-party integrations before defining a policy. Prefer script nonces or hashes over broad `'unsafe-inline'` and `'unsafe-eval'` exceptions. For existing applications, follow the report-only migration and verification steps in [references/browser-security.md](references/browser-security.md#csp-and-trusted-types) before tightening enforcement.

#### Verification Steps

- User-provided HTML sanitized
- CSP headers configured
- No unvalidated dynamic content rendering
- React built-in XSS protection used

### 6. CSRF Protection

#### CSRF Tokens

```typescript
import { csrf } from '@/lib/csrf'

export async function POST(request: Request) {
  const token = request.headers.get('X-CSRF-Token')

  if (!csrf.verify(token)) {
    return NextResponse.json(
      { error: 'Invalid CSRF token' },
      { status: 403 }
    )
  }
}
```

#### SameSite Cookies

```typescript
res.setHeader(
  'Set-Cookie',
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`
)
```

#### Verification Steps

- CSRF tokens on state-changing operations
- SameSite matches the authentication and embedding flows; use Strict only where cross-site entry does not need the cookie
- The application's chosen CSRF defense is verified; SameSite and CORS alone do not replace it

### 7. Rate Limiting

#### API Rate Limiting

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  message: 'Too many requests'
})

app.use('/api/', limiter)
```

#### Expensive Operations

```typescript
const searchLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  message: 'Too many search requests'
})

app.use('/api/search', searchLimiter)
```

#### Verification Steps

- Rate limiting on all API endpoints
- Stricter limits on expensive operations
- IP-based rate limiting
- User-based rate limiting (authenticated)

### 8. Sensitive Data Exposure

#### Logging

```typescript
console.log('User login:', { email, password })
console.log('Payment:', { cardNumber, cvv })

console.log('User login:', { email, userId })
console.log('Payment:', { last4: card.last4, userId })
```

#### Error Messages

```typescript
catch (error) {
  return NextResponse.json(
    { error: error.message, stack: error.stack },
    { status: 500 }
  )
}

catch (error) {
  console.error('Internal error:', error)
  return NextResponse.json(
    { error: 'An error occurred. Please try again.' },
    { status: 500 }
  )
}
```

#### Verification Steps

- No passwords, tokens, or secrets in logs
- Error messages generic for users
- Detailed errors only in server logs
- No stack traces exposed to users

### 9. Blockchain Security (Solana)

#### Wallet Verification

```typescript
import { verify } from '@solana/web3.js'

async function verifyWalletOwnership(
  publicKey: string,
  signature: string,
  message: string
) {
  try {
    const isValid = verify(
      Buffer.from(message),
      Buffer.from(signature, 'base64'),
      Buffer.from(publicKey, 'base64')
    )
    return isValid
  } catch (error) {
    return false
  }
}
```

#### Transaction Verification

```typescript
async function verifyTransaction(transaction: Transaction) {
  if (transaction.to !== expectedRecipient) {
    throw new Error('Invalid recipient')
  }

  if (transaction.amount > maxAmount) {
    throw new Error('Amount exceeds limit')
  }

  const balance = await getBalance(transaction.from)
  if (balance < transaction.amount) {
    throw new Error('Insufficient balance')
  }

  return true
}
```

#### Verification Steps

- Wallet signatures verified
- Transaction details validated
- Balance checks before transactions
- No blind transaction signing

### 10. Dependency Security

#### Regular Updates

```bash
npm audit
npm audit fix
npm update
npm outdated
```

#### Lock Files

```bash
git add package-lock.json

npm ci
```

#### Verification Steps

- Dependencies up to date
- No known vulnerabilities (npm audit clean)
- Lock files committed
- Dependabot enabled on GitHub
- Regular security updates

## Security Testing

### Automated Security Tests

```typescript
test('requires authentication', async () => {
  const response = await fetch('/api/protected')
  expect(response.status).toBe(401)
})

test('requires admin role', async () => {
  const response = await fetch('/api/admin', {
    headers: { Authorization: `Bearer ${userToken}` }
  })
  expect(response.status).toBe(403)
})

test('rejects invalid input', async () => {
  const response = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify({ email: 'not-an-email' })
  })
  expect(response.status).toBe(400)
})

test('enforces rate limits', async () => {
  const requests = Array(101).fill(null).map(() =>
    fetch('/api/endpoint')
  )

  const responses = await Promise.all(requests)
  const tooManyRequests = responses.filter(r => r.status === 429)

  expect(tooManyRequests.length).toBeGreaterThan(0)
})
```

## Pre-Deployment Security Checklist

Before any production deployment:

- Secrets: No hardcoded secrets, all in env vars
- Input Validation: All user inputs validated
- SQL Injection: All queries parameterized
- XSS: User content sanitized
- CSRF: Protection enabled
- Authentication: Proper token handling
- Authorization: Role checks in place
- Rate Limiting: Enabled on all endpoints
- HTTPS: Enforced in production
- Security Headers: CSP, X-Frame-Options configured
- Error Handling: No sensitive data in errors
- Logging: No sensitive data logged
- Dependencies: Up to date, no vulnerabilities
- Row Level Security: Enabled in Supabase
- CORS: Properly configured
- File Uploads: Validated (size, type)
- Wallet Signatures: Verified (if blockchain)

## Resources

- OWASP Top 10: https://owasp.org/www-project-top-ten/
- Next.js Security: https://nextjs.org/docs/security
- Supabase Security: https://supabase.com/docs/guides/auth
- Web Security Academy: https://portswigger.net/web-security

Remember: Security is not optional. One vulnerability can compromise the entire platform. When in doubt, err on the side of caution.

