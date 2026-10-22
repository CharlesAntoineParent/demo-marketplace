# Plugins Claude Code pour AL (Business Central)

| Plugin | Contenu |
| --- | --- |
| `al` | Hook qui lint chaque fichier `.al` modifié, vérification des outils au démarrage de session, serveur MCP ALCops, skills `build-and-lint`, `new-object`, `event-subscriber`, `test-codeunit`, `review`. |

## Installer

```
/plugin marketplace add CharlesAntoineParent/demo-marketplace
/plugin install al@al-tools
```

Les skills s'appellent ensuite `/al:review`, `/al:new-object`, etc.

Pour l'activer automatiquement dans un projet, ajouter au `.claude/settings.json` du dépôt:

```json
{
  "extraKnownMarketplaces": {
    "al-tools": { "source": { "source": "github", "repo": "CharlesAntoineParent/demo-marketplace" } }
  },
  "enabledPlugins": { "al@al-tools": true }
}
```

## Prérequis

```
dotnet tool install -g Microsoft.Dynamics.BusinessCentral.Development.Tools
dotnet tool install -g ALCops.Mcp
```

- `jq` et bash (Git Bash sous Windows) pour les hooks.
- Les symboles du projet dans `.alpackages/`.

Au démarrage d'une session dans un projet AL, le plugin vérifie ces outils et Claude prévient l'utilisateur s'il en manque.

À l'activation, Claude Code demande les analyseurs à exécuter (défaut `CodeCop,UICop`), d'éventuelles DLL d'analyseurs supplémentaires et un ruleset.

## Contribuer

Chaque changement passe en PR et se révise comme du code: un hook s'exécute sur le poste de chaque développeur, un serveur MCP ouvre un accès. Valider avant de pousser:

```
claude plugin validate .
claude plugin validate ./plugins/al
```
