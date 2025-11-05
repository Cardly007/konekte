# Konekte - Spécifications Techniques Détaillées

## 📋 Table des Matières
1. [Schéma Base de Données](#database)
2. [Architecture API](#api)
3. [Workflows Techniques](#workflows)
4. [Intégrations Tierces](#integrations)
5. [Sécurité & Performance](#security)

---

## 🗄️ Schéma Base de Données PostgreSQL {#database}

### Tables Principales

#### **users**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    phone_verified BOOLEAN DEFAULT FALSE,
    
    -- Auth
    auth_provider VARCHAR(50) NOT NULL, -- 'email', 'google', 'apple', 'facebook'
    auth_provider_id VARCHAR(255),
    password_hash VARCHAR(255), -- Si auth email
    
    -- Status
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'banned', 'suspended', 'deleted'
    ban_reason TEXT,
    ban_until TIMESTAMP,
    
    -- Premium
    subscription_tier VARCHAR(20) DEFAULT 'free', -- 'free', 'plus', 'gold', 'platinum'
    subscription_status VARCHAR(20), -- 'active', 'cancelled', 'past_due'
    subscription_expires_at TIMESTAMP,
    stripe_customer_id VARCHAR(255),
    
    -- Metadata
    last_active_at TIMESTAMP,
    device_token VARCHAR(255), -- FCM token pour push
    locale VARCHAR(10) DEFAULT 'fr-FR',
    timezone VARCHAR(50) DEFAULT 'Europe/Paris',
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    deleted_at TIMESTAMP -- Soft delete
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_last_active ON users(last_active_at);
```

#### **profiles**
```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    
    -- Basic Info
    first_name VARCHAR(100) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(20) NOT NULL, -- 'man', 'woman', 'non_binary'
    
    -- Location (géolocalisée)
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_city VARCHAR(100),
    location_country VARCHAR(100) DEFAULT 'France',
    
    -- Bio & Prompts
    bio TEXT,
    
    -- Lifestyle (optionnel)
    height INT, -- en cm
    education VARCHAR(50), -- 'high_school', 'bachelors', 'masters', 'phd'
    occupation VARCHAR(100),
    company VARCHAR(100),
    relationship_goal VARCHAR(50), -- 'serious', 'casual', 'friendship', 'unsure'
    has_children VARCHAR(20), -- 'yes', 'no', 'want'
    wants_children VARCHAR(20), -- 'yes', 'no', 'maybe'
    smoking VARCHAR(20), -- 'yes', 'no', 'socially'
    drinking VARCHAR(20), -- 'yes', 'no', 'socially'
    exercise VARCHAR(20), -- 'active', 'sometimes', 'never'
    
    -- Socials
    instagram_handle VARCHAR(100),
    spotify_id VARCHAR(100),
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verified_at TIMESTAMP,
    
    -- Préférences de découverte
    show_gender VARCHAR(20), -- 'men', 'women', 'everyone'
    age_min INT DEFAULT 18,
    age_max INT DEFAULT 80,
    distance_max INT DEFAULT 50, -- en km
    
    -- Stats
    profile_views INT DEFAULT 0,
    profile_completeness INT DEFAULT 0, -- 0-100%
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_profiles_user_id ON profiles(user_id);
CREATE INDEX idx_profiles_location ON profiles USING GIST(
    ST_MakePoint(location_lng, location_lat)
); -- PostGIS pour requêtes géographiques
```

#### **photos**
```sql
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    cloudinary_public_id VARCHAR(255) NOT NULL,
    cloudinary_url TEXT NOT NULL,
    cloudinary_secure_url TEXT NOT NULL,
    
    display_order INT NOT NULL, -- Ordre d'affichage (0-8)
    
    -- Moderation
    is_approved BOOLEAN DEFAULT NULL, -- null = pending, true/false après review
    moderation_status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    moderation_reason TEXT,
    moderator_id UUID REFERENCES users(id),
    moderated_at TIMESTAMP,
    
    -- AI Analysis (Cloudinary)
    has_face BOOLEAN,
    is_inappropriate BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_photos_user_id ON photos(user_id);
CREATE INDEX idx_photos_moderation_status ON photos(moderation_status);
```

#### **prompts**
```sql
CREATE TABLE prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(50) NOT NULL, -- 'fun', 'serious', 'debate', 'lifestyle'
    question TEXT NOT NULL, -- "Mon dernier repas serait...", "Je ne pourrais pas vivre sans..."
    locale VARCHAR(10) DEFAULT 'fr-FR',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_prompts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    prompt_id UUID REFERENCES prompts(id),
    answer TEXT NOT NULL,
    display_order INT, -- 1, 2, 3 (3 prompts max par user)
    created_at TIMESTAMP DEFAULT NOW(),
    
    UNIQUE(user_id, prompt_id)
);
```

#### **interests**
```sql
CREATE TABLE interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(50) NOT NULL, -- 'sport', 'music', 'travel', 'food', etc.
    name VARCHAR(100) NOT NULL, -- 'Football', 'Rock', 'Asia'
    emoji VARCHAR(10), -- 🏐, 🎸, 🌏
    locale VARCHAR(10) DEFAULT 'fr-FR',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_interests (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    interest_id UUID REFERENCES interests(id),
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY(user_id, interest_id)
);
```

#### **interactions**
```sql
CREATE TABLE interactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Qui a swipé
    target_user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Sur qui
    
    action VARCHAR(20) NOT NULL, -- 'like', 'dislike', 'superlike'
    
    -- Context
    session_id UUID, -- Pour tracking comportement
    distance_km DECIMAL(10, 2), -- Distance au moment du swipe
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_interactions_user_id ON interactions(user_id);
CREATE INDEX idx_interactions_target_user_id ON interactions(target_user_id);
CREATE INDEX idx_interactions_created_at ON interactions(created_at);
CREATE UNIQUE INDEX idx_unique_interaction ON interactions(user_id, target_user_id); -- 1 seule interaction par paire
```

#### **matches**
```sql
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID REFERENCES users(id) ON DELETE CASCADE,
    user2_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Status
    status VARCHAR(20) DEFAULT 'active', -- 'active', 'unmatched_by_user1', 'unmatched_by_user2', 'blocked'
    unmatched_by UUID REFERENCES users(id),
    unmatched_at TIMESTAMP,
    
    -- Stats
    messages_count INT DEFAULT 0,
    last_message_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW(),
    
    CHECK (user1_id < user2_id), -- Garantit ordre (évite doublons)
    UNIQUE(user1_id, user2_id)
);

CREATE INDEX idx_matches_user1_id ON matches(user1_id);
CREATE INDEX idx_matches_user2_id ON matches(user2_id);
CREATE INDEX idx_matches_created_at ON matches(created_at);
```

#### **messages**
```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    -- Content
    content_type VARCHAR(20) DEFAULT 'text', -- 'text', 'image', 'gif', 'voice'
    text_content TEXT, -- Si type text
    media_url TEXT, -- Si type image/gif/voice (Cloudinary)
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    is_deleted BOOLEAN DEFAULT FALSE, -- Soft delete
    
    -- Moderation
    is_flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_messages_match_id ON messages(match_id);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

#### **reports**
```sql
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID REFERENCES users(id) ON DELETE SET NULL, -- Qui report
    reported_user_id UUID REFERENCES users(id) ON DELETE CASCADE, -- Qui est reporté
    
    report_type VARCHAR(50) NOT NULL, -- 'fake_profile', 'harassment', 'inappropriate_content', 'spam', 'underage'
    reason TEXT,
    
    -- Context
    reported_message_id UUID REFERENCES messages(id), -- Si report sur message
    reported_photo_id UUID REFERENCES photos(id), -- Si report sur photo
    
    -- Moderation
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'reviewed', 'action_taken', 'dismissed'
    moderator_id UUID REFERENCES users(id),
    moderator_notes TEXT,
    action_taken VARCHAR(50), -- 'warning', 'ban_1d', 'ban_7d', 'ban_permanent', 'none'
    reviewed_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_reported_user_id ON reports(reported_user_id);
```

#### **subscriptions**
```sql
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    stripe_subscription_id VARCHAR(255) UNIQUE,
    
    tier VARCHAR(20) NOT NULL, -- 'plus', 'gold', 'platinum'
    status VARCHAR(20) NOT NULL, -- 'active', 'cancelled', 'past_due', 'trialing'
    
    current_period_start TIMESTAMP NOT NULL,
    current_period_end TIMESTAMP NOT NULL,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    
    -- Pricing
    price_amount DECIMAL(10, 2),
    price_currency VARCHAR(3) DEFAULT 'EUR',
    billing_interval VARCHAR(20), -- 'month', 'year'
    
    trial_end TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user_id ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_stripe_id ON subscriptions(stripe_subscription_id);
```

#### **purchases**
```sql
CREATE TABLE purchases (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    product_type VARCHAR(50) NOT NULL, -- 'superlikes_5', 'boost_1', 'boost_10'
    quantity INT NOT NULL,
    
    price_amount DECIMAL(10, 2) NOT NULL,
    price_currency VARCHAR(3) DEFAULT 'EUR',
    
    stripe_payment_intent_id VARCHAR(255),
    
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'succeeded', 'failed'
    
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### **user_limits**
```sql
CREATE TABLE user_limits (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    
    -- Daily limits
    likes_today INT DEFAULT 0,
    superlikes_today INT DEFAULT 0,
    boosts_available INT DEFAULT 0, -- Stock de boosts achetés/offerts
    rewinds_available INT DEFAULT 0,
    
    -- Reset
    last_reset_date DATE DEFAULT CURRENT_DATE,
    
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### **boosts**
```sql
CREATE TABLE boosts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    started_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL, -- started_at + 30 min
    
    -- Stats
    profile_views INT DEFAULT 0,
    likes_received INT DEFAULT 0,
    
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### **notifications**
```sql
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    
    type VARCHAR(50) NOT NULL, -- 'new_match', 'new_message', 'new_like', 'boost_discount', etc.
    title VARCHAR(255),
    body TEXT,
    
    -- Data (JSON pour contexte)
    data JSONB,
    
    -- Status
    is_read BOOLEAN DEFAULT FALSE,
    is_sent_push BOOLEAN DEFAULT FALSE,
    sent_push_at TIMESTAMP,
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);
```

#### **events** (à venir Phase 3)
```sql
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    title VARCHAR(255) NOT NULL,
    description TEXT,
    event_type VARCHAR(50), -- 'speed_dating', 'afterwork', 'workshop'
    
    -- Location
    location_name VARCHAR(255),
    location_address TEXT,
    location_lat DECIMAL(10, 8),
    location_lng DECIMAL(11, 8),
    location_city VARCHAR(100),
    
    -- Timing
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,
    
    -- Capacity
    max_participants INT,
    current_participants INT DEFAULT 0,
    
    -- Pricing
    is_premium_only BOOLEAN DEFAULT FALSE,
    price_amount DECIMAL(10, 2) DEFAULT 0,
    
    status VARCHAR(20) DEFAULT 'draft', -- 'draft', 'published', 'cancelled', 'completed'
    
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE event_participants (
    event_id UUID REFERENCES events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(20) DEFAULT 'registered', -- 'registered', 'cancelled', 'attended'
    registered_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY(event_id, user_id)
);
```

---

## 🔌 Architecture API {#api}

### Structure des Routes

```
/api/v1/
├── auth/
│   ├── POST /register
│   ├── POST /login
│   ├── POST /logout
│   ├── POST /refresh-token
│   ├── POST /verify-phone
│   ├── POST /resend-verification
│   └── GET /me
│
├── profiles/
│   ├── GET /profiles/:id
│   ├── PUT /profiles/:id
│   ├── POST /profiles/verify (selfie verification)
│   └── GET /profiles/stats
│
├── photos/
│   ├── GET /photos (user's photos)
│   ├── POST /photos (upload)
│   ├── PUT /photos/:id/order
│   └── DELETE /photos/:id
│
├── discovery/
│   ├── GET /discovery/feed (get profiles to swipe)
│   ├── POST /discovery/swipe (like/dislike/superlike)
│   ├── GET /discovery/daily-picks
│   └── POST /discovery/rewind
│
├── matches/
│   ├── GET /matches (list)
│   ├── GET /matches/:id
│   ├── DELETE /matches/:id (unmatch)
│   └── GET /matches/received-likes
│
├── messages/
│   ├── GET /messages/:match_id (list messages)
│   ├── POST /messages (send)
│   ├── PUT /messages/:id/read
│   └── DELETE /messages/:id
│
├── subscriptions/
│   ├── GET /subscriptions/plans
│   ├── POST /subscriptions/create
│   ├── PUT /subscriptions/cancel
│   ├── POST /purchases (achats one-time)
│   └── POST /webhooks/stripe
│
├── boosts/
│   ├── POST /boosts/activate
│   └── GET /boosts/stats
│
├── reports/
│   ├── POST /reports (create)
│   └── POST /reports/:id/appeal
│
└── admin/
    ├── GET /admin/dashboard
    ├── GET /admin/users
    ├── GET /admin/users/:id
    ├── PUT /admin/users/:id/ban
    ├── GET /admin/reports
    ├── PUT /admin/reports/:id/review
    ├── GET /admin/analytics
    └── ...
```

### Exemples d'Endpoints Critiques

#### **POST /api/v1/auth/register**
```json
// Request
{
  "email": "john@example.com",
  "password": "SecurePass123!",
  "first_name": "John",
  "date_of_birth": "1995-03-15",
  "gender": "man",
  "show_gender": "women"
}

// Response 201
{
  "user_id": "uuid",
  "email": "john@example.com",
  "token": "jwt_token",
  "refresh_token": "refresh_token"
}
```

#### **GET /api/v1/discovery/feed**
```json
// Request Query Params
?limit=10&last_seen_id=uuid

// Response 200
{
  "profiles": [
    {
      "user_id": "uuid",
      "first_name": "Alice",
      "age": 28,
      "distance_km": 5.2,
      "photos": [
        {
          "id": "uuid",
          "url": "https://cloudinary.com/...",
          "order": 0
        }
      ],
      "bio": "Amoureuse de voyages et de bon vin 🍷",
      "prompts": [
        {
          "question": "Mon dernier repas serait...",
          "answer": "Des sushis avec vue sur mer"
        }
      ],
      "interests": ["Voyage", "Cuisine", "Yoga"],
      "verified": true
    }
  ],
  "has_more": true
}
```

#### **POST /api/v1/discovery/swipe**
```json
// Request
{
  "target_user_id": "uuid",
  "action": "like", // 'like', 'dislike', 'superlike'
  "session_id": "uuid"
}

// Response 200 (no match)
{
  "match": false,
  "likes_remaining": 95,
  "superlikes_remaining": 4
}

// Response 200 (match!)
{
  "match": true,
  "match_id": "uuid",
  "matched_user": {
    "user_id": "uuid",
    "first_name": "Alice",
    "photo_url": "..."
  },
  "likes_remaining": 95
}
```

#### **GET /api/v1/matches/received-likes**
```json
// Response 200 (Freemium)
{
  "count": 15,
  "profiles": [] // Empty, need premium
}

// Response 200 (Premium)
{
  "count": 15,
  "profiles": [
    {
      "user_id": "uuid",
      "first_name": "Sophie",
      "age": 26,
      "photo_url": "...",
      "liked_at": "2025-11-05T10:30:00Z"
    }
  ]
}
```

#### **POST /api/v1/messages**
```json
// Request
{
  "match_id": "uuid",
  "content_type": "text",
  "text_content": "Salut ! Comment tu vas ? 😊"
}

// Response 201
{
  "message_id": "uuid",
  "match_id": "uuid",
  "sender_id": "uuid",
  "content_type": "text",
  "text_content": "Salut ! Comment tu vas ? 😊",
  "created_at": "2025-11-05T10:30:00Z"
}
```

---

## ⚙️ Workflows Techniques {#workflows}

### Workflow Matching

```
User A like User B
├─> Enregistrer interaction(user_a, user_b, 'like')
├─> Check si interaction(user_b, user_a, 'like') existe
│   ├─> OUI → Match!
│   │   ├─> Créer match(user_a, user_b)
│   │   ├─> Envoyer notification push aux 2 users
│   │   ├─> Retourner match=true à l'API
│   │   └─> Incrémenter compteur stats_matches
│   └─> NON → Pas de match
│       ├─> Si action = 'superlike', notifier User B
│       ├─> Retourner match=false à l'API
│       └─> Décrémenter likes_remaining de User A
```

### Workflow Discovery Feed

```
GET /discovery/feed
├─> Récupérer préférences user (show_gender, age_min/max, distance_max)
├─> Query PostgreSQL:
│   SELECT profiles WHERE
│     - gender IN (user.show_gender)
│     - age BETWEEN user.age_min AND user.age_max
│     - distance <= user.distance_max (PostGIS)
│     - NOT IN (déjà swipés par user)
│     - NOT IN (matches existants)
│     - status = 'active'
│   ORDER BY
│     - last_active_at DESC (priorité aux actifs récents)
│     - RANDOM() (diversité)
│   LIMIT 10
├─> Pour chaque profil:
│   ├─> Fetch photos (3 premières)
│   ├─> Fetch prompts (3)
│   ├─> Fetch interests (top 5)
│   └─> Calculer distance exacte
└─> Retourner JSON
```

### Workflow Boost

```
POST /boosts/activate
├─> Vérifier boosts_available > 0
├─> Créer boost(user_id, starts_at=NOW, ends_at=NOW+30min)
├─> Décrémenter boosts_available
├─> Pendant 30 min:
│   ├─> Modifier ORDER BY discovery feed:
│   │   └─> Profils boostés en premier
│   ├─> Tracker profile_views pour le boost
│   └─> Tracker likes_received pour le boost
├─> Après 30 min:
│   ├─> Notification "Votre boost est terminé ! Vous avez reçu X likes"
│   └─> Désactiver priorité dans feed
```

### Workflow Premium Conversion

```
POST /subscriptions/create
├─> Vérifier user n'est pas déjà premium
├─> Créer checkout Stripe
│   ├─> Plan: plus/gold/platinum
│   ├─> Billing: monthly/yearly
│   └─> Success URL, Cancel URL
├─> Retourner checkout_url à Flutter
├─> User paye sur Stripe
├─> Stripe envoie webhook /webhooks/stripe
│   ├─> Event: 'checkout.session.completed'
│   ├─> Récupérer subscription_id
│   ├─> Créer subscription(user_id, stripe_subscription_id, tier, status='active')
│   ├─> Update user.subscription_tier
│   ├─> Envoyer email "Bienvenue Premium!"
│   └─> Notification push "Vous êtes maintenant Premium 🎉"
```

---

## 🔗 Intégrations Tierces {#integrations}

### Firebase Auth

**Setup**
- Créer projet Firebase
- Activer providers: Google, Apple, Facebook, Email
- Télécharger google-services.json (Android) et GoogleService-Info.plist (iOS)
- Config Flutter: `firebase_auth` package

**Login Flow**
```dart
// Flutter
final credential = await FirebaseAuth.instance.signInWithGoogle();
final idToken = await credential.user?.getIdToken();

// Envoyer idToken au backend
POST /api/v1/auth/login
{
  "provider": "google",
  "id_token": "firebase_id_token"
}

// Backend vérifie idToken avec Firebase Admin SDK
// Si valide, créer/update user, générer JWT custom
```

### Cloudinary

**Upload Photos**
```python
# Backend
import cloudinary
import cloudinary.uploader

cloudinary.config(
    cloud_name="konekte",
    api_key="...",
    api_secret="..."
)

# Upload avec transformations
result = cloudinary.uploader.upload(
    file,
    folder="user_photos",
    transformation=[
        {"width": 1000, "height": 1000, "crop": "fill", "gravity": "face"},
        {"quality": "auto:best"},
        {"fetch_format": "auto"}
    ],
    moderation="aws_rek:explicit:0.8"  # AI moderation
)

# Récupérer URL
photo_url = result['secure_url']
public_id = result['public_id']
```

**Transformations dynamiques**
```
https://res.cloudinary.com/konekte/image/upload/
  w_500,h_500,c_fill,g_face,q_auto,f_auto/
  user_photos/photo_id.jpg
```

### Stripe

**Create Subscription**
```python
import stripe

stripe.api_key = "sk_..."

# Créer customer
customer = stripe.Customer.create(
    email=user.email,
    metadata={"user_id": user.id}
)

# Créer checkout session
session = stripe.checkout.Session.create(
    customer=customer.id,
    payment_method_types=['card'],
    line_items=[{
        'price': 'price_plus_monthly', # ID du plan dans Stripe
        'quantity': 1,
    }],
    mode='subscription',
    success_url='konekte://subscription-success',
    cancel_url='konekte://subscription-cancel',
)

# Retourner session.url à Flutter
```

**Webhooks**
```python
@app.post("/api/v1/webhooks/stripe")
async def stripe_webhook(request: Request):
    payload = await request.body()
    sig_header = request.headers.get('stripe-signature')
    
    event = stripe.Webhook.construct_event(
        payload, sig_header, webhook_secret
    )
    
    if event.type == 'checkout.session.completed':
        session = event.data.object
        # Activer subscription
        
    elif event.type == 'customer.subscription.updated':
        subscription = event.data.object
        # Update subscription
        
    elif event.type == 'customer.subscription.deleted':
        subscription = event.data.object
        # Cancel subscription
```

### Twilio (SMS)

**Send OTP**
```python
from twilio.rest import Client

client = Client(account_sid, auth_token)

verification = client.verify \
    .v2 \
    .services('VERIFY_SERVICE_SID') \
    .verifications \
    .create(to=phone_number, channel='sms')
```

**Verify OTP**
```python
verification_check = client.verify \
    .v2 \
    .services('VERIFY_SERVICE_SID') \
    .verification_checks \
    .create(to=phone_number, code=otp_code)

if verification_check.status == 'approved':
    # Phone verified
```

### Firebase Cloud Messaging (Push)

**Send Notification**
```python
from firebase_admin import messaging

message = messaging.Message(
    notification=messaging.Notification(
        title="Nouveau match ! 💕",
        body="Alice vous a liké !"
    ),
    data={
        "type": "new_match",
        "match_id": match_id,
        "user_id": user_id
    },
    token=device_token,
    android=messaging.AndroidConfig(
        priority='high',
    ),
    apns=messaging.APNSConfig(
        payload=messaging.APNSPayload(
            aps=messaging.Aps(
                sound='default',
                badge=1
            )
        )
    )
)

response = messaging.send(message)
```

---

## 🔒 Sécurité & Performance {#security}

### Rate Limiting

**Par Endpoint**
```python
from fastapi_limiter import FastAPILimiter
from fastapi_limiter.depends import RateLimiter

@app.post("/api/v1/discovery/swipe")
@limiter.limit("100/minute")  # Max 100 swipes/minute
async def swipe():
    ...

@app.post("/api/v1/messages")
@limiter.limit("30/minute")  # Max 30 messages/minute
async def send_message():
    ...
```

**Redis Config**
```python
import redis.asyncio as redis

redis_client = redis.from_url("redis://localhost", encoding="utf-8")
await FastAPILimiter.init(redis_client)
```

### Caching Strategy

**Cache Profiles**
```python
# Cache profil dans Redis (TTL 1h)
profile_key = f"profile:{user_id}"
cached = await redis_client.get(profile_key)

if cached:
    return json.loads(cached)
else:
    profile = await db.get_profile(user_id)
    await redis_client.setex(
        profile_key,
        3600,  # 1h
        json.dumps(profile)
    )
    return profile
```

**Cache Discovery Feed**
```python
# Cache feed par user (TTL 10 min)
feed_key = f"feed:{user_id}"
cached_feed = await redis_client.get(feed_key)

if cached_feed:
    return json.loads(cached_feed)
else:
    feed = await generate_feed(user_id)
    await redis_client.setex(feed_key, 600, json.dumps(feed))
    return feed
```

### Database Optimization

**Indexes Critiques**
```sql
-- Index pour discovery feed (géo + actifs récents)
CREATE INDEX idx_profiles_discovery ON profiles(
    location_lat, location_lng, last_active_at
) WHERE status = 'active';

-- Index pour matches lookup
CREATE INDEX idx_matches_users ON matches(user1_id, user2_id);

-- Index pour messages récents par match
CREATE INDEX idx_messages_match_recent ON messages(
    match_id, created_at DESC
);

-- Index pour notifications non lues
CREATE INDEX idx_notifications_unread ON notifications(user_id, is_read)
WHERE is_read = FALSE;
```

**Partitioning** (si > 10M users)
```sql
-- Partitionner interactions par mois
CREATE TABLE interactions (
    ...
) PARTITION BY RANGE (created_at);

CREATE TABLE interactions_2025_01 PARTITION OF interactions
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');
```

### Security Headers

```python
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://konekte.app"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

app.add_middleware(
    TrustedHostMiddleware,
    allowed_hosts=["konekte.app", "api.konekte.app"]
)

# Security headers
@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    response.headers["X-Content-Type-Options"] = "nosniff"
    response.headers["X-Frame-Options"] = "DENY"
    response.headers["X-XSS-Protection"] = "1; mode=block"
    response.headers["Strict-Transport-Security"] = "max-age=31536000"
    return response
```

### Input Validation

```python
from pydantic import BaseModel, Field, validator

class ProfileUpdate(BaseModel):
    bio: str = Field(None, max_length=500)
    age_min: int = Field(ge=18, le=80)
    age_max: int = Field(ge=18, le=80)
    distance_max: int = Field(ge=1, le=100)
    
    @validator('age_max')
    def age_max_greater_than_min(cls, v, values):
        if 'age_min' in values and v < values['age_min']:
            raise ValueError('age_max must be >= age_min')
        return v
```

---

## 📊 Monitoring & Logs

### Structured Logging

```python
import structlog

logger = structlog.get_logger()

# Log avec contexte
logger.info(
    "user_swiped",
    user_id=user_id,
    target_user_id=target_user_id,
    action=action,
    distance_km=distance,
    duration_ms=duration
)
```

### Metrics Tracking

```python
from prometheus_client import Counter, Histogram

# Compteurs
swipes_total = Counter('swipes_total', 'Total swipes', ['action'])
matches_total = Counter('matches_total', 'Total matches')
messages_total = Counter('messages_total', 'Total messages')

# Histogrammes (latences)
api_latency = Histogram('api_request_duration_seconds', 'API latency')

@api_latency.time()
async def some_endpoint():
    ...
    swipes_total.labels(action='like').inc()
```

---

**Document complet et prêt pour l'implémentation ! 🚀**