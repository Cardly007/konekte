# Konekte - Backlog Détaillé Sprint 0 & Sprint 1

## 🎯 Sprint 0 : Setup Infrastructure (2 semaines)

### Week 1 : Infrastructure & Database

#### TASK-001 : Setup PostgreSQL Database
**Priorité** : P0 (Critical)  
**Points** : 5

**Description**
Migrer de SQLite vers PostgreSQL et créer le nouveau schéma.

**Acceptance Criteria**
- [ ] PostgreSQL 15+ installé et configuré (local + production)
- [ ] Toutes les tables créées selon spec (users, profiles, photos, interactions, matches, messages, reports, etc.)
- [ ] Indexes créés sur colonnes critiques
- [ ] PostGIS extension activée pour géolocalisation
- [ ] Migration data existante : users, interactions, matches
- [ ] Script de seed data pour dev (50 fake users)
- [ ] Backup automatique configuré (daily)

**Technical Notes**
```sql
-- Voir schéma complet dans doc "Spécifications Techniques"
-- Priorités tables Phase 1:
1. users
2. profiles
3. photos
4. interactions
5. matches
6. messages
7. user_limits
```

---

#### TASK-002 : Setup Redis Cache
**Priorité** : P0  
**Points** : 3

**Acceptance Criteria**
- [ ] Redis installé (local + production)
- [ ] Connection pool configurée dans FastAPI
- [ ] Test connection OK
- [ ] Config TTL par défaut : 1h pour profiles, 10min pour feeds

**Code Example**
```python
import redis.asyncio as redis

redis_client = redis.from_url(
    "redis://localhost:6379",
    encoding="utf-8",
    decode_responses=True
)
```

---

#### TASK-003 : Setup Cloudinary Account
**Priorité** : P0  
**Points** : 2

**Acceptance Criteria**
- [ ] Compte Cloudinary Business créé
- [ ] API keys récupérées (cloud_name, api_key, api_secret)
- [ ] Folders créés : user_photos, user_videos
- [ ] Upload preset configuré avec transformations :
  - Resize: 1000x1000, crop: fill, gravity: face
  - Quality: auto:best
  - Format: auto (webp sur mobile)
- [ ] AI moderation activée (AWS Rekognition)

---

#### TASK-004 : Setup Firebase Auth
**Priorité** : P0  
**Points** : 3

**Acceptance Criteria**
- [ ] Projet Firebase créé
- [ ] Providers activés : Email, Google, Apple, Facebook
- [ ] google-services.json (Android) téléchargé
- [ ] GoogleService-Info.plist (iOS) téléchargé
- [ ] Flutter config : firebase_core, firebase_auth packages
- [ ] Test login Google OK

---

#### TASK-005 : Setup Stripe Account
**Priorité** : P1  
**Points** : 3

**Acceptance Criteria**
- [ ] Compte Stripe créé (mode test)
- [ ] Products créés :
  - Konekte Plus (9.99€/mois)
  - Konekte Gold (19.99€/mois)
  - Konekte Platinum (29.99€/mois)
- [ ] Prices IDs récupérés
- [ ] Webhook endpoint configuré : /api/v1/webhooks/stripe
- [ ] Test payment OK

---

### Week 2 : Backend Refactor

#### TASK-006 : Backend Architecture Refactor
**Priorité** : P0  
**Points** : 8

**Description**
Refactoriser le backend actuel avec une architecture propre.

**Acceptance Criteria**
- [ ] Structure clean :
  ```
  backend/
  ├── app/
  │   ├── api/
  │   │   ├── v1/
  │   │   │   ├── auth.py
  │   │   │   ├── profiles.py
  │   │   │   ├── discovery.py
  │   │   │   ├── matches.py
  │   │   │   ├── messages.py
  │   │   │   └── subscriptions.py
  │   ├── core/
  │   │   ├── config.py
  │   │   ├── security.py
  │   │   └── database.py
  │   ├── models/
  │   │   ├── user.py
  │   │   ├── profile.py
  │   │   └── ...
  │   ├── services/
  │   │   ├── auth_service.py
  │   │   ├── discovery_service.py
  │   │   └── ...
  │   └── main.py
  ```
- [ ] SQLAlchemy 2.0 models pour toutes tables
- [ ] Pydantic schemas pour validation
- [ ] Separation of concerns : routes → services → repositories
- [ ] Dependency injection pour DB session

---

#### TASK-007 : JWT Authentication
**Priorité** : P0  
**Points** : 5

**Acceptance Criteria**
- [ ] Génération JWT tokens (access + refresh)
- [ ] Access token TTL : 1h
- [ ] Refresh token TTL : 30 jours
- [ ] Middleware auth pour routes protégées
- [ ] Endpoint POST /api/v1/auth/refresh-token
- [ ] Token stocké dans Redis (blacklist si logout)

**Code Example**
```python
from jose import jwt
from datetime import datetime, timedelta

def create_access_token(user_id: str):
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + timedelta(hours=1),
        "type": "access"
    }
    return jwt.encode(payload, SECRET_KEY, algorithm="HS256")
```

---

#### TASK-008 : Rate Limiting
**Priorité** : P1  
**Points** : 3

**Acceptance Criteria**
- [ ] Limiter installé (fastapi-limiter + Redis)
- [ ] Limits configurés :
  - /api/v1/discovery/swipe : 100/minute
  - /api/v1/messages : 30/minute
  - /api/v1/auth/* : 10/minute
- [ ] Response 429 si limite atteinte
- [ ] Header X-RateLimit-Remaining dans responses

---

#### TASK-009 : Logging & Monitoring
**Priorité** : P1  
**Points** : 3

**Acceptance Criteria**
- [ ] structlog configuré
- [ ] Logs JSON format
- [ ] Log level: INFO (prod), DEBUG (dev)
- [ ] Logs inclus : user_id, endpoint, duration, status_code
- [ ] Sentry configuré pour error tracking (account créé)

---

#### TASK-010 : CI/CD Pipeline
**Priorité** : P1  
**Points** : 5

**Acceptance Criteria**
- [ ] GitHub Actions workflow créé
- [ ] Steps :
  - Install dependencies
  - Run linter (black, pylint)
  - Run tests (pytest, coverage > 70%)
  - Build Docker image
  - Push to registry (si main branch)
  - Deploy to staging (auto)
  - Deploy to prod (manual approval)
- [ ] Secrets configurés (DB, Redis, Cloudinary, etc.)

---

## 🚀 Sprint 1 : MVP Enhanced (2 semaines)

### Week 1 : Auth & Onboarding

#### TASK-101 : OAuth Google/Apple/Facebook
**Priorité** : P0  
**Points** : 8

**Description**
Implémenter login social avec Firebase Auth.

**Acceptance Criteria**
- [ ] Flutter : Boutons "Continuer avec Google/Apple/Facebook"
- [ ] Login flow :
  1. User clique bouton
  2. Firebase Auth popup
  3. Récupérer idToken
  4. Envoyer à backend POST /api/v1/auth/login
  5. Backend vérifie token avec Firebase Admin SDK
  6. Backend créer/update user + JWT custom
  7. Flutter stock JWT dans secure storage
- [ ] Auto-créer profil minimal si nouveau user
- [ ] Gestion erreurs (réseau, token invalide, etc.)

**Code Example Backend**
```python
from firebase_admin import auth as firebase_auth

async def verify_firebase_token(id_token: str):
    try:
        decoded = firebase_auth.verify_id_token(id_token)
        return decoded  # {'uid', 'email', 'name', ...}
    except Exception as e:
        raise HTTPException(401, "Invalid token")
```

---

#### TASK-102 : Onboarding Flow UI
**Priorité** : P0  
**Points** : 8

**Description**
Créer les 5 écrans d'onboarding.

**Acceptance Criteria**
- [ ] Écran 1 : Infos de base (prénom, date naissance, genre)
- [ ] Écran 2 : Localisation (géoloc auto + rayon de recherche slider)
- [ ] Écran 3 : Upload photos (min 3, max 9, drag & drop order)
- [ ] Écran 4 : Bio + Prompts (2 prompts obligatoires parmi 20)
- [ ] Écran 5 : Préférences (show_gender, age_min/max)
- [ ] Progress bar en haut (1/5, 2/5, ...)
- [ ] Bouton "Suivant" activé si form valide
- [ ] Bouton "Précédent" pour revenir
- [ ] Sauvegarde auto à chaque étape (draft dans DB)
- [ ] À la fin → Redirect vers SwipePage

---

#### TASK-103 : SMS Verification
**Priorité** : P1  
**Points** : 5

**Description**
Vérifier numéro de téléphone avec Twilio.

**Acceptance Criteria**
- [ ] Twilio account créé, Verify service configuré
- [ ] Flutter : Écran "Entrez votre numéro"
- [ ] Envoi OTP (6 chiffres) via Twilio
- [ ] Flutter : Écran "Entrez le code reçu"
- [ ] Backend vérifie OTP avec Twilio
- [ ] Si OK : phone_verified = true
- [ ] Gestion erreurs (code expiré, mauvais code, rate limit)

---

#### TASK-104 : Photo Upload to Cloudinary
**Priorité** : P0  
**Points** : 5

**Acceptance Criteria**
- [ ] Flutter : image_picker package
- [ ] User select photo → Compress (< 5MB)
- [ ] Upload to backend POST /api/v1/photos
- [ ] Backend upload to Cloudinary
- [ ] Backend save photo in DB (cloudinary_public_id, url, order)
- [ ] Flutter affiche photo uploadée avec loader
- [ ] Delete photo possible (DELETE /api/v1/photos/:id)
- [ ] Reorder photos possible (drag & drop)

---

#### TASK-105 : Profile Enrichment
**Priorité** : P1  
**Points** : 5

**Description**
Ajouter sections optionnelles profil (lifestyle, interests, prompts).

**Acceptance Criteria**
- [ ] Backend : Seed 50 prompts en DB (catégories : fun, sérieux, débat)
- [ ] Backend : Seed 100 interests en DB (catégories : sport, musique, voyage, etc.)
- [ ] Flutter : Page "Modifier profil" avec sections :
  - Photos
  - Bio
  - Prompts (select 3 parmi liste)
  - Interests (select max 20 parmi liste)
  - Lifestyle (dropdowns)
- [ ] PUT /api/v1/profiles/:id pour sauvegarder
- [ ] Calculer profile_completeness (0-100%)

---

### Week 2 : Discovery & Matching

#### TASK-106 : Discovery Feed Algorithm v1
**Priorité** : P0  
**Points** : 8

**Description**
Algorithme simple de recommandation pour le feed de swipe.

**Acceptance Criteria**
- [ ] GET /api/v1/discovery/feed?limit=10
- [ ] Query PostgreSQL :
  ```sql
  SELECT profiles WHERE
    - gender IN (user.show_gender)
    - age BETWEEN user.age_min AND user.age_max
    - ST_Distance(location, user.location) <= user.distance_max
    - id NOT IN (already swiped by user)
    - id NOT IN (existing matches)
    - status = 'active'
  ORDER BY
    - last_active_at DESC (priorité users actifs)
    - RANDOM() (diversité)
  LIMIT 10
  ```
- [ ] Return JSON avec 10 profils
- [ ] Cache feed dans Redis (TTL 10 min)
- [ ] Invalidate cache si user swipe

---

#### TASK-107 : Swipe UI & Animations
**Priorité** : P0  
**Points** : 8

**Description**
UI du feed avec swipe gestures fluides.

**Acceptance Criteria**
- [ ] Flutter : swipe_cards package
- [ ] Stack de cartes (voir 3-4 cartes superposées)
- [ ] Gestures :
  - Swipe gauche → Dislike (animation fade red)
  - Swipe droite → Like (animation heart pink)
  - Swipe haut → SuperLike (animation star blue)
  - Tap → Vue détaillée profil
- [ ] Boutons flottants en bas : ❌ ⭐ ❤️
- [ ] Décompte likes remaining (texte en haut)
- [ ] Si 0 likes remaining → Paywall popup
- [ ] Lottie animation si match

---

#### TASK-108 : Swipe Action API
**Priorité** : P0  
**Points** : 5

**Description**
Backend pour enregistrer swipes et détecter matches.

**Acceptance Criteria**
- [ ] POST /api/v1/discovery/swipe
- [ ] Request body : {target_user_id, action}
- [ ] Vérifier user_limits.likes_today < 100 (si free)
- [ ] Enregistrer interaction(user_id, target_user_id, action)
- [ ] Décrémenter likes_today
- [ ] Check si match :
  - Query interaction(target_user_id, user_id, 'like')
  - Si existe → Créer match + Notifications push
- [ ] Return JSON : {match: bool, match_id?, likes_remaining}

---

#### TASK-109 : Match Animation & List
**Priorité** : P0  
**Points** : 5

**Acceptance Criteria**
- [ ] Flutter : Lottie "It's a Match!" animation full-screen
- [ ] Animation : 2-3s avec confettis
- [ ] Afficher photos des 2 users
- [ ] Texte "C'est un match avec Alice ! 💕"
- [ ] Boutons : "Envoyer un message" / "Continuer à swiper"
- [ ] GET /api/v1/matches → Liste de matches
- [ ] Vue en grille avec photos
- [ ] Badge "Nouveau" si < 24h
- [ ] Tap → Ouvre chat

---

#### TASK-110 : Likes Received (Blurred for Free)
**Priorité** : P1  
**Points** : 5

**Description**
Section "Personnes qui vous ont liké" avec photos floutées pour freemium.

**Acceptance Criteria**
- [ ] GET /api/v1/matches/received-likes
- [ ] Si user free :
  - Return count + photos floutées (blur CSS)
  - Paywall : "Passez à Plus pour voir qui !"
- [ ] Si user premium :
  - Return count + liste complète (nom, photo, âge)
  - Tap → Like back direct (match instantané)

---

#### TASK-111 : Chat Realtime with WebSocket
**Priorité** : P0  
**Points** : 8

**Description**
Chat temps réel entre matches.

**Acceptance Criteria**
- [ ] Backend : WebSocket endpoint /ws/chat/{user_id}
- [ ] Connection WebSocket au login Flutter
- [ ] POST /api/v1/messages → Envoyer message
- [ ] Backend broadcast message via WebSocket
- [ ] Flutter : Afficher message instantanément (sender + receiver)
- [ ] Typing indicator (send event via WS)
- [ ] Read receipts (update is_read on scroll)
- [ ] Stockage messages en DB
- [ ] Pagination : 50 messages/page

**Code Example Backend**
```python
from fastapi import WebSocket

active_connections: dict[str, WebSocket] = {}

@app.websocket("/ws/chat/{user_id}")
async def websocket_endpoint(websocket: WebSocket, user_id: str):
    await websocket.accept()
    active_connections[user_id] = websocket
    
    try:
        while True:
            data = await websocket.receive_json()
            # Broadcast to receiver
            receiver_id = data["receiver_id"]
            if receiver_id in active_connections:
                await active_connections[receiver_id].send_json(data)
    except:
        del active_connections[user_id]
```

---

#### TASK-112 : Push Notifications Setup
**Priorité** : P1  
**Points** : 5

**Acceptance Criteria**
- [ ] Firebase Cloud Messaging (FCM) configuré
- [ ] Flutter : Store device_token dans DB au login
- [ ] Backend : fonction send_push_notification(user_id, title, body, data)
- [ ] Trigger notifications :
  - Nouveau match
  - Nouveau message
  - Nouveau like reçu (si premium)
- [ ] Flutter : Gérer tap sur notif → Ouvre app à la bonne page
- [ ] Gestion permissions (demander à l'utilisateur)

---

#### TASK-113 : Daily Picks
**Priorité** : P1  
**Points** : 3

**Description**
10 profils "Top Picks" quotidiens basés sur compatibilité.

**Acceptance Criteria**
- [ ] GET /api/v1/discovery/daily-picks
- [ ] Algorithme simple :
  - Filtrer par préférences de base (genre, âge, distance)
  - Score compatibilité = interests communs + prompts similaires
  - Trier par score DESC
  - Return top 10
- [ ] Cache 24h (reset à minuit)
- [ ] Flutter : Section "Coups de cœur du jour" dans app

---

## 📝 Definition of Done (DoD)

Chaque tâche doit respecter :

✅ **Code**
- [ ] Code écrit et fonctionnel
- [ ] Respect des conventions (PEP8 Python, Dart style guide)
- [ ] Pas de hardcoded values (use env vars)

✅ **Tests**
- [ ] Tests unitaires écrits (coverage > 70%)
- [ ] Tests manuels sur dev OK

✅ **Documentation**
- [ ] Docstrings pour fonctions complexes
- [ ] README.md mis à jour si nécessaire

✅ **Review**
- [ ] Code review par peer
- [ ] Pas de commentaires bloquants

✅ **Deploy**
- [ ] Mergé sur main
- [ ] CI/CD passé (green)
- [ ] Déployé sur staging

---

## 🎯 Success Metrics Sprint 1

À la fin du Sprint 1, on doit pouvoir :

✅ **User Journey Complet**
1. S'inscrire avec Google
2. Compléter onboarding (5 étapes)
3. Uploader 3 photos
4. Swiper 10 profils
5. Recevoir un match
6. Envoyer un message
7. Recevoir une réponse

✅ **Métriques**
- [ ] Time to first swipe : < 3 min
- [ ] Swipes/user/session : > 20
- [ ] Taux de match : > 1% (test avec 50 fake users)
- [ ] Latence API : < 200ms p95

---

## 🚨 Bloquants à Résoudre Avant Sprint 1

### BLOCKER-001 : Environment Variables
**Résoudre avant Sprint 0**

Créer fichier `.env` avec :
```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/konekte

# Redis
REDIS_URL=redis://localhost:6379

# Cloudinary
CLOUDINARY_CLOUD_NAME=konekte
CLOUDINARY_API_KEY=xxx
CLOUDINARY_API_SECRET=xxx

# Firebase
FIREBASE_PROJECT_ID=konekte-xxx
FIREBASE_PRIVATE_KEY=xxx

# Stripe
STRIPE_SECRET_KEY=sk_test_xxx
STRIPE_WEBHOOK_SECRET=whsec_xxx

# Twilio
TWILIO_ACCOUNT_SID=xxx
TWILIO_AUTH_TOKEN=xxx
TWILIO_VERIFY_SERVICE_SID=xxx

# JWT
JWT_SECRET_KEY=supersecretkey
JWT_ALGORITHM=HS256

# Sentry
SENTRY_DSN=https://xxx@sentry.io/xxx
```

### BLOCKER-002 : Fake Data for Dev
**Résoudre pendant Sprint 0**

Créer script `seed_data.py` :
- 50 fake users (Faker library)
- 200 fake photos (Unsplash API ou Lorem Picsum)
- 100 fake interactions
- 20 fake matches

---

## 📞 Communication & Tools

**Daily Standup** : 9h30 (15 min)
- Qu'est-ce que j'ai fait hier ?
- Qu'est-ce que je fais aujourd'hui ?
- Ai-je des bloquants ?

**Sprint Review** : Vendredi fin de sprint (1h)
- Demo des features terminées
- Feedback team

**Sprint Retro** : Vendredi fin de sprint (30 min)
- What went well?
- What could be improved?
- Actions next sprint

**Tools**
- Jira/Linear pour tracking tasks
- Slack pour communication
- Figma pour designs (si besoin)
- GitHub pour code
- Notion pour docs

---

**Prêt à coder ! Let's build Konekte 🚀💕**