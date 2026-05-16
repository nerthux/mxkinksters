# MxKinksters — sitio Hugo

Sitio Blowfish inicializado por `bootstrap_project.py` (vía `blowfish-tools`).

## Setup

```bash
cd projects/kink-tijuana/site
hugo server   # preview en http://localhost:1313
```

Si tu Hugo no soporta la versión actual de Blowfish, pina el theme a una
versión anterior:

```bash
cd themes/blowfish
git checkout v2.94.0   # ajusta según tu Hugo
cd -
```

## Estructura

```
content/
├── _index.md           home (creado por blowfish-tools)
├── blog/               longtails que escribe generar_post.py
└── hubs/<hub>/
    ├── _index.md       pillar page del hub
    └── <spoke>/index.md (page bundles para spokes con featured.png)
data/voice/             JSONs de voz/persona/umbrella (contexto)
docs/                   markdown de contexto (UMBRELLA, VOZ, PERSONA)
themes/blowfish/        theme como submodule git
```

Actualiza Blowfish con `npx blowfish-tools update`.
