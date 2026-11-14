# Guide Git & GitHub - Nod N8N

## 📋 Vue d'Ensemble

Ce guide explique comment utiliser Git et GitHub pour sauvegarder votre projet **Nod N8N**.

---

## 🎯 Repositories Configurés

### Repository Principal (V0)

- **URL**: https://github.com/sekadalle2024/nod_n8n_client_V0_13.11.26.git
- **Remote**: `origin`
- **Usage**: Repository source original

### Repository Backup (V1)

- **URL**: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26.git
- **Remote**: `backup` (configuré) et `v1backup` (alias)
- **Usage**: Sauvegarde et versions alternatives

---

## 🚀 Scripts Disponibles

### 1. commit-changes.bat

**Usage**: Commit interactif des modifications

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\commit-changes.bat
```

**Ce qui se passe**:

1. Affiche l'état actuel (`git status`)
2. Ajoute tous les fichiers modifiés (`git add .`)
3. Demande un message de commit
4. Crée le commit

---

### 2. push-to-github.bat

**Usage**: Push vers GitHub avec vérifications (hook lefthook)

```powershell
.\push-to-github.bat
```

**Ce qui se passe**:

1. Affiche l'état et les remotes
2. Affiche les derniers commits
3. Demande confirmation
4. Execute `git push -u backup main`
5. Le hook lefthook vérifie TypeScript avant le push

**⚠️ Note**: Peut bloquer si des erreurs TypeScript existent.

---

### 3. push-no-verify.bat ⚠️

**Usage**: Push sans vérifications (bypass hook)

```powershell
.\push-no-verify.bat
```

**Ce qui se passe**:

1. Commit automatique
2. Push avec `--no-verify` (bypass hook lefthook)

**⚠️ ATTENTION**: Utilisez SEULEMENT si:

- Les erreurs TypeScript sont non-critiques
- Vous êtes certain de votre code
- Le hook bloque injustement

---

### 4. commit-et-push.bat ⭐

**Usage**: TOUT-EN-UN - Commit + Push en une commande

```powershell
.\commit-et-push.bat
```

**Ce qui se passe**:

1. Ajoute tous les fichiers
2. Demande un message de commit
3. Crée le commit
4. Push vers GitHub (remote backup)

**Temps estimé**: 2-5 minutes

**C'est le script RECOMMANDÉ pour un workflow rapide!**

---

### 5. install-github-cli.bat

**Usage**: Installe GitHub CLI (gh)

```powershell
.\install-github-cli.bat
```

**Ce qui se passe**:

1. Vérifie si `gh` est déjà installé
2. Installe via winget si absent
3. Affiche les commandes disponibles

**Après installation**, vous pouvez utiliser:

```powershell
gh auth login          # S'authentifier
gh repo view           # Voir les infos du repo
gh pr create           # Créer une Pull Request
```

---

## 📝 Workflow Recommandé

### Workflow Simple (Quotidien)

```powershell
# 1. Aller dans le dossier des scripts
cd "h:\nod_n8n\Doc demarrer container & serveur"

# 2. Commit et Push en une commande
.\commit-et-push.bat

# 3. Entrer votre message de commit quand demandé
# Exemple: "Ajout nouvelle fonctionnalité X"

# 4. Confirmer le push
# Le script fait tout automatiquement
```

**Temps total**: ~2 minutes

---

### Workflow Avancé (Contrôle Total)

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"

# 1. Commit séparément
.\commit-changes.bat
# Message: "Implémentation feature X"

# 2. Vérifier l'état
cd ..
git log -3 --oneline
git status

# 3. Push quand prêt
cd "Doc demarrer container & serveur"
.\push-to-github.bat
```

---

### Workflow Urgence (Bypass Hook)

**Si le hook lefthook bloque à cause d'erreurs TypeScript**:

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"

# Push sans vérification
.\push-no-verify.bat
```

⚠️ **Utilisez avec prudence** - les erreurs TypeScript peuvent causer des problèmes.

---

## 🔧 Commandes Git Utiles

### Vérifier l'État

```powershell
cd h:\nod_n8n

# État complet
git status

# État court
git status --short

# Voir les différences
git diff
```

---

### Historique des Commits

```powershell
# 10 derniers commits
git log -10 --oneline

# Historique graphique
git log --graph --oneline --all

# Commits d'aujourd'hui
git log --since="today" --oneline
```

---

### Gestion des Remotes

```powershell
# Voir tous les remotes
git remote -v

# Ajouter un nouveau remote
git remote add <nom> <url>

# Changer l'URL d'un remote
git remote set-url <nom> <nouvelle-url>

# Supprimer un remote
git remote remove <nom>
```

---

### Branches

```powershell
# Voir toutes les branches
git branch -a

# Voir les branches avec tracking
git branch -vv

# Créer une nouvelle branche
git checkout -b nouvelle-branche

# Changer de branche
git checkout main
```

---

## 🛠️ Résolution de Problèmes

### Problème: "fatal: not a git repository"

**Cause**: Vous n'êtes pas dans le dossier du projet.

**Solution**:

```powershell
cd h:\nod_n8n
```

---

### Problème: Hook lefthook bloque le push

**Symptôme**: Push échoué avec erreurs TypeScript.

**Solution 1** - Corriger les erreurs:

```powershell
cd h:\nod_n8n
pnpm run lint
# Corriger les erreurs affichées
```

**Solution 2** - Bypass (si non-critique):

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\push-no-verify.bat
```

---

### Problème: "Everything up-to-date" mais des commits locaux existent

**Cause**: Le push a déjà été fait précédemment.

**Vérification**:

```powershell
cd h:\nod_n8n
git status
```

Si "Your branch is up to date", c'est normal. Sinon:

```powershell
git push -u backup main --force
```

⚠️ **Attention**: `--force` écrase l'historique distant.

---

### Problème: Authentification GitHub échoue

**Solution 1** - Via navigateur:

```powershell
# Le push ouvrira une fenêtre d'authentification
git push -u backup main
# Connectez-vous avec votre compte GitHub
```

**Solution 2** - Via Personal Access Token:

```powershell
# 1. Créer un token sur GitHub
# Aller sur: Settings → Developer settings → Personal access tokens → Generate new token

# 2. Configurer Git pour utiliser le token
git config --global credential.helper store

# 3. Push (Git demandera le token)
git push -u backup main
# Username: sekadalle2024
# Password: ghp_VotreTOKENici
```

**Solution 3** - Via GitHub CLI:

```powershell
# Installer GitHub CLI
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\install-github-cli.bat

# S'authentifier
gh auth login

# Push normalement
cd h:\nod_n8n
git push -u backup main
```

---

### Problème: Conflit de fusion (merge conflict)

**Symptôme**: `CONFLICT (content): Merge conflict in <fichier>`

**Solution**:

```powershell
# 1. Voir les fichiers en conflit
git status

# 2. Éditer les fichiers et résoudre les conflits
# Chercher les lignes avec <<<<<<< HEAD

# 3. Ajouter les fichiers résolus
git add <fichier>

# 4. Continuer le commit
git commit -m "Résolution des conflits"

# 5. Push
git push -u backup main
```

---

### Problème: Annuler le dernier commit (pas encore pushé)

```powershell
# Annuler le commit mais garder les modifications
git reset --soft HEAD~1

# Annuler le commit ET les modifications (⚠️ DANGER)
git reset --hard HEAD~1
```

---

### Problème: Annuler un push (déjà sur GitHub)

⚠️ **DANGER** - Cela réécrit l'historique!

```powershell
# 1. Revenir en arrière localement
git reset --hard HEAD~1

# 2. Forcer le push
git push -u backup main --force
```

---

## 📊 État Actuel de Votre Projet

### Configuration Git

```
Utilisateur: sekadalle2024
Email: sekadalle2024@gmail.com
Credential Helper: manager (Windows)
```

### Remotes Configurés

| Nom      | URL                                                                                            | Usage           |
| -------- | ---------------------------------------------------------------------------------------------- | --------------- |
| origin   | https://github.com/sekadalle2024/nod_n8n_client_V0_13.11.26.git                                | Repository V0   |
| backup   | https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26.git | Repository V1   |
| v1backup | https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26.git | Alias de backup |

### Branche Actuelle

- **Branche**: `main`
- **Tracking**: `backup/main`
- **Status**: ✓ À jour

---

## 🎓 Bonnes Pratiques

### Messages de Commit

**Format recommandé**:

```
Type: Description courte (max 50 caractères)

Description détaillée si nécessaire (max 72 caractères par ligne)
- Point 1
- Point 2
```

**Types courants**:

- `feat`: Nouvelle fonctionnalité
- `fix`: Correction de bug
- `docs`: Documentation uniquement
- `style`: Formatage, pas de changement de code
- `refactor`: Refactoring du code
- `test`: Ajout de tests
- `chore`: Maintenance, configuration

**Exemples**:

```
feat: Ajout système de persistance des tables d'audit

- Implémentation de 4 tables PostgreSQL
- 11 endpoints API REST
- Interface frontend avec clic droit sur table
```

```
fix: Correction erreurs TypeScript dans routes-audit-tables

- Ajout paramètre 'undefined' aux appels transaction
- Ajout propriété default_value à ColumnMapping
```

---

### Fréquence des Commits

**Recommandé**:

- **Après chaque fonctionnalité complète** (même petite)
- **Avant une pause longue** (fin de journée, weekend)
- **Après avoir corrigé un bug**
- **Avant de tester quelque chose de risqué**

**Éviter**:

- ❌ Commits trop gros (plusieurs fonctionnalités)
- ❌ Commits incomplets (code qui ne compile pas)
- ❌ Messages vagues ("update", "fix", "changes")

---

### Fréquence des Push

**Recommandé**:

- **Quotidien** si vous travaillez activement
- **Après plusieurs commits** (regrouper 3-5 commits)
- **Avant de changer de machine**
- **Avant une manipulation risquée** (rebase, reset)

---

## 📚 Ressources

### Documentation Officielle

- **Git**: https://git-scm.com/doc
- **GitHub**: https://docs.github.com/
- **GitHub CLI**: https://cli.github.com/manual/

### Tutoriels

- **Git Basics**: https://git-scm.com/book/en/v2/Getting-Started-Git-Basics
- **GitHub Flow**: https://guides.github.com/introduction/flow/
- **Atlassian Git Tutorial**: https://www.atlassian.com/git/tutorials

### Cheat Sheets

- **Git Cheat Sheet**: https://education.github.com/git-cheat-sheet-education.pdf
- **GitHub CLI Cheat Sheet**: https://github.com/github/gh-cli-cheatsheet

---

## ✅ Checklist Quotidienne

Avant de finir votre journée de développement:

- [ ] Vérifier les modifications: `git status`
- [ ] Commiter les changements: `.\commit-changes.bat`
- [ ] Pousser vers GitHub: `.\push-to-github.bat`
- [ ] Vérifier sur GitHub que le push a réussi
- [ ] (Optionnel) Créer une Pull Request si nécessaire

---

## 🎉 Félicitations!

Vous avez maintenant:

✅ 5 scripts Git/GitHub prêts à l'emploi  
✅ Un workflow Git efficace  
✅ Deux repositories GitHub configurés  
✅ La documentation complète  
✅ Les bonnes pratiques en place

**Prochaine étape**: Utilisez `.\commit-et-push.bat` régulièrement pour sauvegarder votre travail!

---

**Date de création**: 2026-11-14  
**Version**: 1.0  
**Auteur**: Kiro Assistant
