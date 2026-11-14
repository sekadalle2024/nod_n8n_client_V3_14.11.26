# Quick Start - Nod N8N

**Démarrage rapide en 3 commandes** ⚡

---

## 🚀 Démarrer le Système

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\demarrer-tout-projet.bat
```

**Temps**: ~2 minutes  
**Résultat**: Containers + Serveur démarrés

**URL de l'application**:

```
http://localhost:4310/#access=KXkl8AoKlM3iFaXdP9e9RjCAiyHIyAbbYdchI2DkaRU
```

---

## 💾 Sauvegarder sur GitHub

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\commit-et-push.bat
```

**Temps**: ~2 minutes  
**Résultat**: Code sauvegardé sur GitHub

---

## 🧪 Tester le Système

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\verifier-etat.bat
```

**Temps**: ~5 secondes  
**Résultat**: État de tous les services

---

## 📚 Documentation Complète

### Guides Principaux

| Guide             | Chemin                                                            | Usage                       |
| ----------------- | ----------------------------------------------------------------- | --------------------------- |
| **Démarrage**     | `Doc demarrer container & serveur/00-README-DEMARRAGE.md`         | Premier démarrage           |
| **Git/GitHub**    | `Doc demarrer container & serveur/03-GUIDE-GIT-GITHUB.md`         | Workflow Git                |
| **Tests**         | `Doc demarrer container & serveur/01-TEST-SYSTEME-PERSISTANCE.md` | Tester les fonctionnalités  |
| **Récapitulatif** | `RECAPITULATIF-FINAL-SESSION.md`                                  | Résumé de ce qui a été fait |

### Scripts Disponibles

**Démarrage**:

- `demarrer-tout-projet.bat` - Tout démarrer (recommandé)
- `demarrer-tout.bat` - Containers uniquement
- `demarrer-serveur.bat` - Serveur uniquement
- `verifier-etat.bat` - Vérifier l'état
- `arreter-tout.bat` - Tout arrêter

**Git/GitHub**:

- `commit-et-push.bat` - Sauvegarder (recommandé)
- `commit-changes.bat` - Commit uniquement
- `push-to-github.bat` - Push uniquement
- `push-no-verify.bat` - Push sans vérification
- `install-github-cli.bat` - Installer gh CLI

---

## 🎯 Workflow Quotidien

**Matin** (démarrer):

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\demarrer-tout-projet.bat
```

**Soir** (sauvegarder):

```powershell
cd "h:\nod_n8n\Doc demarrer container & serveur"
.\commit-et-push.bat
.\arreter-tout.bat
```

**Temps total quotidien**: ~5 minutes

---

## ⚡ Commandes Git Rapides

```powershell
cd h:\nod_n8n

# Voir l'état
git status

# Voir l'historique
git log -5 --oneline

# Voir les différences
git diff

# Annuler modifications (DANGER)
git reset --hard HEAD
```

---

## 🆘 Aide Rapide

**Serveur ne démarre pas**:

```powershell
docker ps | findstr postgres
# Si absent: .\demarrer-tout.bat
```

**Port 4310 occupé**:

```powershell
netstat -ano | findstr "4310"
taskkill /PID <PID> /F
```

**Push Git bloqué**:

```powershell
.\push-no-verify.bat  # Bypass hook
```

---

## ✅ Checklist

- [ ] Docker Desktop lancé (icône verte)
- [ ] Containers démarrés (4 containers UP)
- [ ] Serveur Node.js running (port 4310)
- [ ] Application accessible dans le navigateur
- [ ] Modifications sauvegardées sur GitHub

---

## 🔗 Liens Utiles

- **Application**: http://localhost:4310/#access=KXkl8AoKlM3iFaXdP9e9RjCAiyHIyAbbYdchI2DkaRU
- **API**: http://localhost:4310/api/audit/schemas
- **GitHub V1**: https://github.com/sekadalle2024/https-github.com-sekadalle2024-nod_n8n_client_V1_13.11.26
- **GitHub V0**: https://github.com/sekadalle2024/nod_n8n_client_V0_13.11.26

---

**Pour plus de détails, consultez**:

- `Doc demarrer container & serveur/INDEX-DOCUMENTATION.md`
- `RECAPITULATIF-FINAL-SESSION.md`

**Version**: 1.0  
**Date**: 14 novembre 2026
