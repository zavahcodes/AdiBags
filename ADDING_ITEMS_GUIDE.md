# Guía para Añadir Items al Filtro de Profesiones

Esta guía te ayudará a añadir nuevos Item IDs al filtro de Trade Goods por Profesión.

## Cómo Encontrar el Item ID

### Método 1: Usando Comandos en el Juego

1. Coloca el cursor sobre el item en tu bolsa o inventario
2. Escribe en el chat: `/dump GetMouseFocus():GetItem()`
3. El juego mostrará el item link, que incluye el Item ID

Ejemplo de output:
```
"|cffffffff|Hitem:2589:::::::::|h[Lino]|h|r"
```
El número `2589` es el Item ID.

### Método 2: Usando Addons

- **ItemID**: Addon que muestra el ID directamente en el tooltip
- **Idtip**: Similar, muestra información adicional

### Método 3: Bases de Datos Online

Para WoW 3.3.5:
- WoWHead (versión WotLK)
- Database de tu servidor privado
- WoW-DB

## Cómo Añadir Items al Código

### 1. Abre el archivo del módulo

```
modules/ProfessionTradeGoods.lua
```

### 2. Encuentra la sección `PROFESSION_ITEMS`

Busca la profesión correspondiente. Por ejemplo, para Herrería:

```lua
-- Item ID database by profession for WoW 3.3.5
local PROFESSION_ITEMS = {
    -- BLACKSMITHING (Herrería)
    BLACKSMITHING = {
        -- Bars (Barras)
        2840, 2841, 2842, -- etc...
```

### 3. Añade el nuevo Item ID

Añade el número al final de la lista correspondiente:

```lua
BLACKSMITHING = {
    -- Bars (Barras)
    2840, 2841, 2842, 3575, 3576, 3577, 3859, 3860,
    12345, -- Tu nuevo item aquí
```

### 4. Añade un comentario (opcional pero recomendado)

```lua
BLACKSMITHING = {
    -- Bars (Barras)
    2840, 2841, 2842, 3575, 3576, 3577, 3859, 3860,
    12345, -- Barra de Mithril Oscuro (ejemplo)
```

## Estructura por Profesión

### BLACKSMITHING (Herrería)
- Barras (Bars)
- Minerales (Ore)
- Piedras (Stone)
- Flux y otros materiales

### TAILORING (Sastrería)
- Telas (Cloth)
- Hilos (Thread)
- Tintes (Dye)
- Seda de araña, etc.

### LEATHERWORKING (Peletería)
- Cueros (Leather)
- Escamas (Scales)
- Pieles (Hide)
- Hilo, Sal

### ALCHEMY (Alquimia)
- Hierbas (Herbs)
- Lotos (Lotus)
- Viales (Vials)
- Elementos

### ENGINEERING (Ingeniería)
- Explosivos (Explosives)
- Piezas (Parts)
- Elementos

### ENCHANTING (Encantamiento)
- Polvo (Dust)
- Esencias (Essence)
- Fragmentos (Shard)
- Cristales (Crystal)
- Varitas (Rods)

### JEWELCRAFTING (Joyería)
- Gemas en bruto (Raw Gems)
- Minerales para prospectar

### INSCRIPTION (Inscripción)
- Hierbas (para moler)
- Tintas (Inks)
- Pigmentos (Pigments)
- Pergaminos (Parchment)

### COOKING (Cocina)
- Carnes (Meat)
- Pescado (Fish)
- Especias (Spices)

### FIRST_AID (Primeros Auxilios)
- Telas para vendajes
- Materiales para anti-veneno

## Ejemplo Completo

Supongamos que quieres añadir "Barra de Titanio" (Item ID: 41163) a Herrería:

### Antes:
```lua
BLACKSMITHING = {
    -- Bars (Barras)
    2840, 2841, 2842, 3575, 3576, 3577, 3859, 3860, 6037, 11371,
```

### Después:
```lua
BLACKSMITHING = {
    -- Bars (Barras)
    2840, 2841, 2842, 3575, 3576, 3577, 3859, 3860, 6037, 11371, 41163,
```

O con comentario:
```lua
BLACKSMITHING = {
    -- Bars (Barras)
    2840, 2841, 2842, 3575, 3576, 3577, 3859, 3860, 6037, 11371,
    41163, -- Barra de Titanio
```

## Items que Pertenecen a Múltiples Profesiones

Algunos items pueden ser usados por varias profesiones (por ejemplo, hierbas para Alquimia e Inscripción). El filtro asignará el item a la PRIMERA profesión en la que aparezca.

Si quieres que un item aparezca en una profesión específica:
1. Añádelo SOLO a esa profesión, O
2. Si ya existe en otra, la primera en el código tendrá prioridad

## Probar tus Cambios

1. Guarda el archivo `ProfessionTradeGoods.lua`
2. Recarga la interfaz en el juego: `/reload`
3. Abre tus bolsas y verifica que el item aparezca en la sección correcta
4. Si no funciona, verifica:
   - El Item ID es correcto
   - Añadiste una coma después del número anterior
   - El item es de tipo "Trade Goods"
   - El filtro está habilitado en la configuración

## Compartir tus Cambios

Si has añadido items útiles, considera compartir tus cambios:

1. Haz commit de los cambios:
   ```bash
   git add modules/ProfessionTradeGoods.lua
   git commit -m "feat: add new item IDs for [profession]"
   ```

2. Crea un Pull Request en GitHub

## Items Comunes de WoW 3.3.5

Aquí hay algunos Item IDs comunes que podrías necesitar:

### Barras (Blacksmithing)
- 2840: Barra de cobre
- 2841: Barra de bronce
- 2842: Barra de plata
- 3575: Barra de hierro
- 3576: Barra de estaño
- 3577: Barra de oro
- 3859: Barra de acero
- 3860: Barra de mithril
- 6037: Barra de truesilver
- 12359: Barra de torio
- 12360: Barra de arcanita
- 17771: Barra de elementium
- 23445: Barra de fel iron
- 23446: Barra de adamantita
- 23447: Barra de eternium
- 36913: Barra de saronita
- 36916: Barra de cobalto
- 41163: Barra de titanio

### Telas (Tailoring)
- 2589: Lino
- 2592: Lana
- 4305: Seda
- 4306: Tela de mago
- 14047: Tela rúnica
- 14048: Tela de red
- 21840: Telaúreo
- 21841: Tela vil
- 33470: Tela de escarcha
- 41510: Tela de telaraña

### Cueros (Leatherworking)
- 2318: Cuero ligero
- 2319: Cuero medio
- 4234: Cuero pesado
- 4304: Cuero grueso
- 8170: Cuero resistente
- 15407: Cuero resistente
- 17012: Escamas de dragón negro

### Hierbas (Alchemy/Inscription)
- 765: Alga plateada
- 785: Hierba magenta
- 2447: Alamoiroqués
- 2449: Terránea
- 2450: Brionia
- 2452: Equinácea
- 2453: Cardosanto
- 3355: Aliento de vida
- 3356: Reina de las nieves
- 3357: Aligustre
- 3358: Khadgar's Whisker
- 3369: Tumba grave
- 3818: Fadeleaf
- 3819: Dragonthorn
- 3820: Stranglekelp
- 3821: Goldthorn
- 8831: Malemort
- 8836: Arthas' Tears
- 8838: Sungrass
- 8839: Blindweed
- 8845: Ghostmushroom
- 8846: Gromsblood
- 13463: Dreamfoil
- 13464: Golden Sansam
- 13465: Mountain Silversage
- 13466: Plaguebloom
- 13467: Icecap
- 13468: Black Lotus
- 22785: Fel Lotus
- 22786: Dreaming Glory
- 22787: Felweed
- 22788: Flamecap
- 22789: Terocone
- 22790: Ancient Lichen
- 22791: Netherbloom
- 22792: Nightmare Vine
- 22793: Mana Thistle
- 36901: Goldclover
- 36903: Adder's Tongue
- 36904: Tiger Lily
- 36905: Lichbloom
- 36906: Icethorn
- 36907: Talandra's Rose
- 37921: Frozen Herb (for Frost Lotus)
- 39970: Fire Leaf

## Problemas Comunes

### El item no aparece clasificado
- Verifica que el item sea de tipo "Trade Goods" en el juego
- Algunos items parecen materiales pero tienen otra clasificación

### Error de sintaxis después de añadir
- Asegúrate de poner coma después de cada número
- NO pongas coma después del último número antes del cierre `}`
- Verifica que no hayas borrado accidentalmente una coma existente

### El item aparece en la profesión incorrecta
- Busca si el Item ID está duplicado en otra profesión
- El sistema asignará el item a la primera profesión donde aparezca

## Recursos Adicionales

- [WoWHead WotLK Database](https://wotlk.evowow.com/)
- [WoW 3.3.5 Item Database](https://wowgaming.altervista.org/aowow/)
- Documentación de la API de WoW 3.3.5

## Soporte

Si tienes problemas añadiendo items:
1. Verifica tu sintaxis Lua
2. Usa `/reload` en el juego para recargar
3. Revisa el archivo `WoWError.txt` en tu carpeta de WoW
4. Crea un issue en GitHub con detalles del problema
