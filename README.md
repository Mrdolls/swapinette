# push_swap Performance Tester

Ce script Bash permet de **tester automatiquement** les performances d'un exécutable `push_swap` avec une barre de progression.

---

## 🛠️ Utilisation

``bash
./test_push_swap.sh <executable> <nb_tests> <taille_liste> <max_operations>
``

Exemple :
``bash
./test_push_swap.sh push_swap 100 100 700
``

Effectue 100 tests avec des listes de 100 entiers aléatoires uniques (entre 0 et 99).

Vérifie que push_swap ne dépasse jamais 700 instructions.

Affiche une barre de progression en temps réel.

S’arrête immédiatement en cas d’échec.

| Argument           | Description                                   |
| ------------------ | --------------------------------------------- |
| `<executable>`     | Nom de votre exécutable `push_swap`           |
| `<nb_tests>`       | Nombre de tests à exécuter                    |
| `<taille_liste>`   | Taille de la liste aléatoire pour chaque test |
| `<max_operations>` | Nombre maximum d'instructions autorisées      |

✅ Exemple de sortie

Progression : [##########################################......................] 50%
...

OK - Toutes les operations respectent la limite (700)

🔴 En cas d’erreur :

KO ➜ 752 operations (limite 700)

Le script s'arrête dès qu'une opération dépasse la limite fixée.

KO ➜ 722 instructions (limite 700)

Sinon, à la fin :

OK - Toutes les itérations respectent la limite (700)
