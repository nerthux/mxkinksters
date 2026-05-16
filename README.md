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

## Deploy a Cloudflare (Workers — Static Assets)

El sitio se publica en Cloudflare Workers usando Static Assets. La build
se ejecuta con `build.sh`, que pinea Hugo, Go, Node y Dart Sass para que
el output sea reproducible entre tu máquina y el runner de Cloudflare.

### Archivos involucrados

- `wrangler.toml` — config del Worker. Apunta `[assets]` a `./public` y
  declara `command = "./build.sh"` para CI.
- `build.sh` — instala las dependencias pineadas, inicializa el
  submodule de Blowfish y corre `hugo build --gc --minify`.
- `static/_headers` — headers de seguridad y caché para los assets.
- `config/_default/hugo.toml` — `baseURL` apunta a `mxkinksters.pages.dev`
  por default; actualízalo cuando conectes el dominio definitivo.

### Primer deploy

```bash
# Requiere wrangler instalado (npm i -g wrangler) y `wrangler login`.
./build.sh           # genera ./public
wrangler deploy      # sube los assets al Worker llamado `mxkinksters`
```

El Worker queda disponible en `https://mxkinksters.<account>.workers.dev`.
Para dominio custom: añádelo desde el dashboard (Workers & Pages →
mxkinksters → Settings → Domains & Routes) y luego actualiza `baseURL`
en `config/_default/hugo.toml` y vuelve a desplegar.

### Builds automáticas desde Git

Si conectas el repo en el dashboard de Cloudflare (Workers & Pages →
Create → Connect to Git), Cloudflare detectará `wrangler.toml` y usará
`./build.sh` como build command. No requiere configuración adicional —
los submodules se clonan dentro del script.

### Preview local

```bash
./build.sh
wrangler dev         # sirve ./public en http://localhost:8787
```

