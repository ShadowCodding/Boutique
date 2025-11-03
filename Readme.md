# 📘 Guide d’ajout d’images d’armes (zUI)

## 🖼️ 1. Format des images
- Toutes les images doivent être au **format `.png`**
- Deux choix possibles :
    1. **Utiliser un lien Internet (URL)**
    2. **Utiliser un fichier local (dans ton dossier du script)**

---

## 📂 2. Si tu utilises un **fichier local**
- Mets ton image dans ce dossier : 
```
    zUI/web/build/assets
```
- Exemple de nom de fichier :  
```
weapon_assaultrifle.png
```
- Dans la configuration de ton arme :
```lua
{ 
    weaponName = 'WEAPON_ASSAULTRIFLE',
    weaponLabel = "AK-47",
    credit = 5000,
    button,
    image = "assets/assaultrifle.png"
},
```
## 🌐 3. Si tu veux utiliser un lien Internet pour chaque arme

- Mets ton lien complet dans la ligne image = "..."

- Exemple :
```lua
{ 
    weaponName = 'WEAPON_ASSAULTRIFLE',
    weaponLabel = "AK-47",
    credit = 5000,
    button,
    image = "https://docs.fivem.net/weapons/assaultrifle.png"
},
```
- Et dans l’affichage de l’arme :
```lua
zUI.ShowInfoBox(
    key,
    item.weaponLabel,
    "default",
    {
        { type = "text",  title = "Prix",       value = ("~r~%s credits"):format(item.credit) },
        { type = "text",  title = "Catégorie",  value = key },
        { type = "image", title = "",           value = item.image }
    }
)
```
## 🌍 4. Si tu veux utiliser un lien automatique pour toutes les armes

Pas besoin d’ajouter une image à chaque fois :
le script va chercher l’image sur le site de FiveM selon le nom de l’arme.

Exemple :
```lua
zUI.ShowInfoBox(
    key,
    item.weaponLabel,
    "default",
    {
        { type = "text",  title = "Prix",       value = ("~r~%s credits"):format(item.credit) },
        { type = "text",  title = "Catégorie",  value = key },
        { type = "image", title = "",           value = ("https://docs.fivem.net/weapons/%s.png"):format(item.weaponName) }
    }
)
```
## 👉 Résultat :
### Le script affichera automatiquement une image depuis
- https://docs.fivem.net/weapons/

| Méthode             | Où mettre l’image      | Exemple                                                                          |
| ------------------- | ---------------------- | -------------------------------------------------------------------------------- |
| Fichier local       | zUI/web/build/assets/  | "assets/assaultrifle.png"                                                        |
| Lien Internet perso | Ton propre lien        | "[https://ton-site.com/images/ak47.png](https://ton-site.com/images/ak47.png)"   |
| Lien automatique    | Aucun fichier à mettre | "[https://docs.fivem.net/weapons/%s.png](https://docs.fivem.net/weapons/%s.png)" |
