# Security Setup Guide - API Keys & Secrets

## Overview
This document explains how to securely manage API keys and sensitive credentials in this project without exposing them in the codebase.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     SECURE SETUP                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LOCAL DEVELOPMENT              PRODUCTION (GitHub Actions)    │
│  ─────────────────              ───────────────────────────    │
│                                                                 │
│  .env file (gitignored)    →    GitHub Secrets                 │
│       ↓                              ↓                         │
│  EnvConfig.dart reads      →    Workflow creates files         │
│       ↓                              ↓                         │
│  App uses credentials      →    App uses credentials           │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Files That Are NEVER Committed

| File | Purpose | Location |
|------|---------|----------|
| `.env` | All API keys & secrets | Root folder |
| `firebase_service_account.json` | FCM push notifications | `assets/` |
| `upload-keystore.jks` | App signing | `android/app/` |
| `key.properties` | Keystore passwords | `android/` |

These are all in `.gitignore` ✅

---

## GitHub Secrets Required

Go to: **GitHub Repo → Settings → Secrets and variables → Actions**

| Secret Name | Description |
|-------------|-------------|
| `ENV_FILE` | Complete .env file content |
| `FIREBASE_FCM_SERVICE_ACCOUNT_JSON` | Firebase service account JSON for push notifications |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Google Play Console service account for deployments |
| `UPLOAD_KEYSTORE_BASE64` | Base64 encoded keystore file |
| `KEY_PROPERTIES` | Keystore passwords |

---

## How to Set Up GitHub Secrets

### 1. ENV_FILE Secret
Copy your entire `.env` file content (WITHOUT Firebase private key issues):

```bash
# Copy .env content to clipboard (Windows PowerShell)
Get-Content .env | Set-Clipboard
```

### 2. FIREBASE_FCM_SERVICE_ACCOUNT_JSON Secret

Get this from Firebase Console:
1. Go to **Firebase Console** → **Project Settings** → **Service Accounts**
2. Click **"Generate New Private Key"**
3. Download the JSON file
4. Copy the **entire JSON content** and paste as secret value

Example format:
```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "...",
  ...
}
```

### 3. UPLOAD_KEYSTORE_BASE64 Secret

```bash
# Windows PowerShell - Convert keystore to Base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/upload-keystore.jks")) | Set-Clipboard
```

---

## How It Works

### Local Development
1. Developer copies `.env.example` to `.env`
2. Fills in actual values
3. App reads from `.env` via `EnvConfig.dart`

### Production Build (GitHub Actions)
1. Workflow runs on push to branch
2. Creates `.env` from `ENV_FILE` secret
3. Creates `assets/firebase_service_account.json` from `FIREBASE_FCM_SERVICE_ACCOUNT_JSON` secret
4. App reads from JSON file (priority) or `.env` (fallback)

---

## Security Best Practices

1. **NEVER** commit `.env` or any credential files
2. **NEVER** share secrets in chat/email - use secure channels
3. **Rotate** keys immediately if accidentally exposed
4. **Use** different Firebase projects for dev/staging/production
5. **Limit** service account permissions to minimum required

---

## If Keys Are Exposed

1. **Firebase Service Account**: 
   - Go to Firebase Console → Project Settings → Service Accounts
   - Delete compromised key
   - Generate new key
   - Update GitHub secrets

2. **Keystore**: 
   - You CANNOT change keystore for existing Play Store apps
   - Use Play App Signing to manage keys securely

---

## Verification Checklist

- [ ] `.env` is in `.gitignore`
- [ ] `firebase_service_account.json` is in `.gitignore`
- [ ] All secrets added to GitHub
- [ ] Local development works with `.env`
- [ ] GitHub Actions build succeeds
- [ ] Notifications work in production app

