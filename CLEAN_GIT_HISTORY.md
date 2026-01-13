# 🚨 Remove Sensitive Files from Git History

## ⚠️ CRITICAL WARNING

**Yeh operation git history ko rewrite karega!**
- Sabhi commits change ho jayenge
- Team members ko repository re-clone karni padegi
- Force push required hai

**Pehle team ko inform karo aur backup lo!**

---

## 🎯 Sensitive Files to Remove from History

1. `.env` files
2. `*.jks` (keystore files)
3. `*.keystore` files
4. `android/key.properties`
5. `*service-account*.json`
6. `asaan-rishta-chat-*.json`

---

## 🛠️ Method 1: Using BFG Repo-Cleaner (RECOMMENDED - Fast & Safe)

### Step 1: Install BFG
```bash
# Download from: https://rtyley.github.io/bfg-repo-cleaner/
# Or using Chocolatey (Windows):
choco install bfg-repo-cleaner

# Or download JAR directly
# https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar
```

### Step 2: Backup Your Repository
```bash
# Create a backup
cd ..
cp -r assaan_rishta assaan_rishta_backup
cd assaan_rishta
```

### Step 3: Create a Fresh Clone (Mirror)
```bash
cd ..
git clone --mirror https://github.com/YOUR_USERNAME/assaan_rishta.git assaan_rishta-mirror
cd assaan_rishta-mirror
```

### Step 4: Remove Sensitive Files Using BFG
```bash
# Remove specific files by name
bfg --delete-files ".env"
bfg --delete-files "*.jks"
bfg --delete-files "*.keystore"
bfg --delete-files "key.properties"
bfg --delete-files "*service-account*.json"
bfg --delete-files "asaan-rishta-chat-*.json"

# Or remove all files matching patterns in one command
bfg --delete-files "{.env,*.jks,*.keystore,key.properties,*service-account*.json,asaan-rishta-chat-*.json}"
```

### Step 5: Clean Up and Garbage Collect
```bash
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Step 6: Force Push to GitHub
```bash
git push --force
```

### Step 7: Clean Up Your Local Repository
```bash
cd ../assaan_rishta
git fetch origin
git reset --hard origin/main
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

---

## 🛠️ Method 2: Using git filter-branch (Built-in but Slower)

### Step 1: Backup
```bash
# Create backup branch
git branch backup-before-cleanup
```

### Step 2: Remove Files from History
```powershell
# PowerShell commands
git filter-branch --force --index-filter `
  "git rm --cached --ignore-unmatch .env *.jks *.keystore android/key.properties *service-account*.json asaan-rishta-chat-*.json" `
  --prune-empty --tag-name-filter cat -- --all
```

### Step 3: Clean Up References
```bash
git for-each-ref --format="delete %(refname)" refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Step 4: Force Push
```bash
git push origin --force --all
git push origin --force --tags
```

---

## 🛠️ Method 3: Using git-filter-repo (Modern & Fast)

### Step 1: Install git-filter-repo
```bash
# Windows (using pip)
pip install git-filter-repo

# Or download from: https://github.com/newren/git-filter-repo
```

### Step 2: Create paths-to-remove.txt
```bash
# Create file with paths to remove
echo .env > paths-to-remove.txt
echo *.jks >> paths-to-remove.txt
echo *.keystore >> paths-to-remove.txt
echo android/key.properties >> paths-to-remove.txt
echo *service-account*.json >> paths-to-remove.txt
echo asaan-rishta-chat-*.json >> paths-to-remove.txt
```

### Step 3: Run git-filter-repo
```bash
git filter-repo --invert-paths --paths-from-file paths-to-remove.txt --force
```

### Step 4: Re-add Remote and Force Push
```bash
git remote add origin https://github.com/YOUR_USERNAME/assaan_rishta.git
git push origin --force --all
git push origin --force --tags
```

---

## ✅ Verification Steps

### 1. Check if Files are Removed from History
```bash
# Search for sensitive files in history
git log --all --full-history --pretty=format:"%H" -- ".env"
git log --all --full-history --pretty=format:"%H" -- "*.jks"
git log --all --full-history --pretty=format:"%H" -- "asaan-rishta-chat-*.json"

# Should return nothing if successfully removed
```

### 2. Check Repository Size
```bash
# Before and after size comparison
git count-objects -vH
```

### 3. Verify on GitHub
- Go to GitHub repository
- Check commit history
- Search for sensitive files in old commits
- Should not find any

---

## 👥 Team Coordination

### After Force Push, Team Members Must:

```bash
# 1. Backup their local changes
git stash

# 2. Fetch the cleaned history
git fetch origin

# 3. Reset to the new history
git reset --hard origin/main

# 4. Clean up local repository
git reflog expire --expire=now --all
git gc --prune=now --aggressive

# 5. Restore their changes (if any)
git stash pop
```

---

## 🔐 Post-Cleanup Security Checklist

- [ ] Verify sensitive files removed from all commits
- [ ] Update `.gitignore` (already done ✅)
- [ ] Rotate all exposed credentials:
  - [ ] Firebase Service Account key
  - [ ] Keystore passwords
  - [ ] API keys in `.env`
  - [ ] Database credentials
- [ ] Update GitHub Secrets with new credentials
- [ ] Test GitHub Actions workflow
- [ ] Inform team about history rewrite
- [ ] Monitor for any unauthorized access

---

## 📝 Quick Command Reference

### BFG (Fastest - Recommended)
```bash
cd ..
git clone --mirror https://github.com/YOUR_USERNAME/assaan_rishta.git assaan_rishta-mirror
cd assaan_rishta-mirror
bfg --delete-files "{.env,*.jks,*.keystore,key.properties,*service-account*.json,asaan-rishta-chat-*.json}"
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force
```

### git-filter-repo (Modern)
```bash
git filter-repo --invert-paths --path .env --path '*.jks' --path '*.keystore' --path 'android/key.properties' --path '*service-account*.json' --path 'asaan-rishta-chat-*.json' --force
git remote add origin https://github.com/YOUR_USERNAME/assaan_rishta.git
git push origin --force --all
```

---

## ⚠️ Important Notes

1. **Backup First**: Always create a backup before cleaning history
2. **Team Communication**: Inform all team members before force pushing
3. **Rotate Credentials**: Change all exposed passwords/keys immediately
4. **One-time Operation**: Only do this once, then maintain proper `.gitignore`
5. **GitHub Actions**: May need to re-run after history cleanup

---

## 🆘 If Something Goes Wrong

### Restore from Backup
```bash
cd ..
rm -rf assaan_rishta
cp -r assaan_rishta_backup assaan_rishta
cd assaan_rishta
```

### Or Restore from Backup Branch
```bash
git reset --hard backup-before-cleanup
git push origin --force
```

---

## ✅ Success Indicators

After cleanup, you should see:
- ✅ No sensitive files in `git log --all`
- ✅ Reduced repository size
- ✅ Clean commit history on GitHub
- ✅ All team members on new history
- ✅ GitHub Actions still working

**Your repository will be completely clean!** 🎉
