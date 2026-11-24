# Tutor PLC con Claude Code

El tutor es una *skill* de Claude Code. No usa ninguna API de pago: funciona con Claude Code y tu suscripción
de Claude (consume del cupo de uso de tu plan, como cualquier otra conversación).

Tiene tres modos:

| Comando | Qué hace |
|---|---|
| `/tutor-plc pista` | Te da pistas, de menor a mayor ayuda, sin escribirte la solución |
| `/tutor-plc explicar` | Lee tu programa, te explica qué hace y por qué falla, y te dice qué cambiar |
| `/tutor-plc hacer` | Escribe el programa completo con comentarios y te lo explica paso a paso |

## Cómo funciona

La app web y Claude Code comparten una **carpeta de tu ordenador**:

1. La app guarda el proyecto en esa carpeta (`project.json`, `scene.json`, `plc/*.st`, `tests/` y `AGENTS.md`,
   una guía con los nombres reales de tus tags que la app regenera en cada guardado).
2. Claude Code lee y escribe esos ficheros.
3. La app vigila la carpeta y carga los cambios sola (sincronización en los dos sentidos, solo en Chrome y Edge).

Claude Code tiene que ejecutarse **en tu ordenador** (sesión local de la app de Claude o la CLI), porque una sesión
en la nube no puede ver tus carpetas locales.

## Puesta en marcha (una vez)

1. **Instala la skill.** En una sesión local de Claude Code, pide:

   > Descarga https://raw.githubusercontent.com/atienzacrespomarcos-oss/FACTORY_io/main/tutor/tutor-plc/SKILL.md
   > y guárdalo en `~/.claude/skills/tutor-plc/SKILL.md`

   En Windows, `~` es tu carpeta de usuario (`C:\Users\<tú>`). También puedes copiar a mano la carpeta
   `tutor/tutor-plc` de este repositorio a `~/.claude/skills/`.

2. **Vincula tu proyecto a una carpeta.** En <https://atienzacrespomarcos-oss.github.io/FACTORY_io/app/> (Chrome o Edge),
   usa **Save Project to Folder…** para guardar el proyecto en una carpeta nueva (por ejemplo
   `Documentos/FabricaPLC/mi-linea`), o **Link Project Folder…** para abrir una que ya tengas.
   El navegador te pedirá permiso de edición sobre esa carpeta.

## Uso diario

1. Abre la app y tu proyecto vinculado.
2. Abre Claude Code en local **sobre la carpeta del proyecto**.
3. Escribe `/tutor-plc pista`, `/tutor-plc explicar` o `/tutor-plc hacer` y describe qué quieres conseguir.
4. Comprueba en la app: pestaña **Problems**, botón **Play** y **Simulation > Run Project Tests**. Cuéntale al tutor
   el resultado.
