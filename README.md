# push_swap Tester

Petit script bash pour tester automatiquement le projet [`push_swap`](https://github.com/) (projet de tri par instructions, école 42).

Il permet de :
- Générer des listes de nombres aléatoires uniques.
- Exécuter `push_swap` sur ces listes.
- Vérifier que le nombre d'instructions ne dépasse pas une limite donnée.
- Afficher une barre de progression claire.
- Arrêter immédiatement en cas d'erreur (limite dépassée).

---

## ✅ Utilisation

### 1. Rendre le script exécutable :
``bash
chmod +x test_push_swap.sh
``

2. Lancer le test :
```bash
test_push_swap.sh <nb_tests> <size_of_list> <max_instructions>
Exemple :

./test_push_swap.sh 100 100 700

    Teste 100 listes aléatoires de 100 entiers.

    Vérifie que push_swap utilise ≤ 700 instructions à chaque fois.

🧪 Fonctionnement

Le script fait ceci :

1. Génère une liste aléatoire avec shuf.
2. Lance ./push_swap sur cette liste.
3. Compte le nombre de lignes (instructions) générées.
4. Compare avec la limite autorisée.
5. Affiche une barre de progression.

En cas de dépassement de la limite :

KO ➜ 722 instructions (limite 700)

Sinon, à la fin :

OK - Toutes les itérations respectent la limite (700)
