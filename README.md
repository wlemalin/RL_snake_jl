
# Snake Q-Learning en Julia

Ce projet implémente une version autonome du jeu Snake, contrôlée par un agent qui utilise le Q-learning pour apprendre et maximiser son score. Le projet est codé en Julia et structuré en plusieurs modules pour une meilleure organisation et lisibilité du code.

## Table des Matières

1. [Aperçu](#aperçu)
2. [Prérequis](#prérequis)
3. [Installation](#installation)
4. [Structure du Projet](#structure-du-projet)
5. [Utilisation](#utilisation)

---

### Aperçu

Dans le jeu Snake, l’objectif est de guider le serpent pour qu’il mange des pommes tout en évitant de heurter son propre corps ou les murs du plateau. Ce projet utilise le Q-learning pour entraîner le serpent à jouer de manière autonome, en optimisant sa stratégie au fil des épisodes de jeu. L’agent reçoit des récompenses pour chaque pomme consommée et des pénalités pour chaque collision.

### Prérequis

- Julia 1.x
- Packages Julia nécessaires :
  - `Random`
  - `Serialization`
  - `Printf`

### Installation

1. Clonez le dépôt du projet sur votre machine.
2. Installez les dépendances nécessaires en utilisant le gestionnaire de paquets Julia.

```julia
import Pkg
Pkg.add("Random")
Pkg.add("Serialization")
Pkg.add("Printf")
```

### Structure du Projet

Le projet est structuré de la manière suivante, avec une description des fichiers et dossiers :

```
├── HyperParameters.jl      # Définit les hyperparamètres utilisés pour l'algorithme de Q-learning.
├── InitGame.jl             # Initialise le jeu, en configurant le plateau et les positions de départ.
├── main.jl                 # Point d'entrée du programme, lance l'entraînement et initialise le jeu.
├── PlayGame.jl             # Contient la logique de jeu, y compris les règles de déplacement et de consommation de pommes.
├── Qtable.jl               # Gère la Q-table pour enregistrer et améliorer les décisions de l’agent.
├── qtables                 # Dossier contenant les Q-tables sauvegardées pendant l’entraînement.
│   ├── 0f03_0f1_0f825_1f0_0f0-1f00f0_1f0_0f0_0f0.jls
│   └── 0f03_0f825_1f0_0f0-1f00f0_0f0_0f0_0f0.jls
├── README.md               # Documentation du projet avec une description et des instructions d’utilisation.
├── Symmetry.jl             # Module permettant d’appliquer des transformations de symétrie pour réduire la taille de la Q-table.
├── test.jl                 # Script pour tester les fonctionnalités du projet.
├── TrainDat.jl             # Module pour gérer les données d'entraînement du modèle.
├── TrainSnake.jl           # Script pour l’entraînement du serpent sur plusieurs épisodes.
└── visualisation           # Dossier pour les données et scripts de visualisation.
    ├── data
    │   └── 0f03_0f1_0f825_1f0_0f0-1f0_0f0_1f0_0f0_0f0.csv  # Données de suivi pour visualiser les performances.
    └── Plots.ipynb         # Notebook Jupyter pour visualiser les résultats et analyses.

```

Chaque fichier et dossier a un rôle spécifique pour organiser et faciliter le développement, l'entraînement et l'analyse du modèle de Q-learning.

### Utilisation

Pour lancer l’entraînement du serpent sur un nombre défini d'épisodes, exécutez la commande suivante :

```julia
julia main.jl train 1000000
```

Cela entraînera l'agent sur 1 million d'épisodes, ajustant la Q-table pour améliorer sa stratégie de jeu.

Pour visualiser une partie jouée par le serpent en utilisant la Q-table entraînée, exécutez la commande suivante :

```julia
julia main.jl play
```

Cela permet d’observer le comportement du serpent dans le jeu, basé sur les décisions apprises.
