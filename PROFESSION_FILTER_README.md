# Filtro de Trade Goods por Profesión

## Descripción

Este nuevo filtro permite separar automáticamente los objetos de la categoría "Trade Goods" (Mercancías comerciales) en secciones específicas según la profesión a la que pertenecen.

## Características

### Profesiones Soportadas

El filtro detecta y organiza materiales de las siguientes profesiones:

- **Herrería** (Blacksmithing)
- **Sastrería** (Tailoring)
- **Peletería** (Leatherworking)
- **Alquimia** (Alchemy)
- **Ingeniería** (Engineering)
- **Encantamiento** (Enchanting)
- **Joyería** (Jewelcrafting)
- **Inscripción** (Inscription)
- **Cocina** (Cooking)
- **Primeros auxilios** (First Aid)

### Soporte Multi-idioma

El filtro funciona en múltiples idiomas:
- Español
- Inglés
- Alemán
- Francés

## Cómo Funciona

1. El filtro escanea el tooltip de cada objeto de tipo "Trade Goods"
2. Busca palabras clave relacionadas con profesiones
3. Agrupa automáticamente los objetos en secciones por profesión
4. Los objetos sin profesión detectada se agrupan en "Other Trade Goods"

## Configuración

### Acceso a Opciones

1. Abre la interfaz de AdiBags: `/adibags config`
2. Ve a la pestaña "Filters" (Filtros)
3. Busca "Trade Goods by Profession"

### Opciones Disponibles

#### Enable (Activar)
- **Descripción**: Activa o desactiva el filtro de profesiones
- **Por defecto**: Activado

#### Scan Tooltips (Escanear Tooltips)
- **Descripción**: Permite escanear los tooltips de los objetos para detectar la profesión
- **Nota**: Desactiva esto si experimentas problemas de rendimiento
- **Por defecto**: Activado

#### Group Other Trade Goods (Agrupar Otros Objetos Comerciales)
- **Descripción**: Agrupa los Trade Goods sin profesión detectada en una sección "Other Trade Goods"
- **Por defecto**: Activado

## Prioridad del Filtro

El filtro tiene una prioridad de **85**, lo que significa que:
- Se ejecuta ANTES del filtro general "Item Category" (prioridad 10)
- Se ejecuta DESPUÉS del filtro "ItemSets" (prioridad 90) y "Quest Items" (prioridad 75)

Esto permite que los materiales de profesión se organicen correctamente sin interferir con otros filtros importantes.

## Compatibilidad

- **Versión de WoW**: 3.3.5 (WotLK)
- **Versión de AdiBags**: 3.3.8+
- **Servidor**: Ascension y otros servidores WotLK 3.3.5

## Rendimiento

El filtro usa un sistema de caché para minimizar el impacto en el rendimiento:
- Los resultados se almacenan en caché por item ID
- El caché se limpia cuando el filtro se activa/desactiva
- Si experimentas lag, puedes desactivar "Scan Tooltips" en las opciones

## Notas Técnicas

### Archivo Principal
`modules/ProfessionTradeGoods.lua`

### Dependencias
- AceEvent-3.0 (para manejo de eventos)
- Sistema de tooltips de WoW

### Cómo se Detectan las Profesiones

El filtro busca palabras clave en los tooltips de los objetos. Por ejemplo:
- En español: "Herrería", "Sastrería", "Peletería"
- En inglés: "Blacksmithing", "Tailoring", "Leatherworking"

## Solución de Problemas

### Los objetos no se agrupan correctamente
- Verifica que "Scan Tooltips" esté activado
- Asegúrate de que el filtro esté habilitado
- Comprueba que el filtro "Item Category" no esté interfiriendo (debería tener menor prioridad)

### Problemas de rendimiento
- Desactiva "Scan Tooltips" si experimentas lag
- El caché debería resolver la mayoría de los problemas de rendimiento

### Los objetos aparecen en "Other Trade Goods"
- Algunos objetos pueden no tener información de profesión en su tooltip
- Esto es normal para objetos genéricos que pueden usarse en múltiples profesiones

## Desarrollo

### Añadir Soporte para Nuevos Idiomas

Para añadir soporte para un nuevo idioma, edita el array `PROFESSION_PATTERNS` en el archivo:
```lua
["Palabra en nuevo idioma"] = "NOMBRE_PROFESION_EN_MAYUSCULAS"
```

### Modificar Prioridad

Para cambiar la prioridad del filtro, modifica el segundo parámetro en:
```lua
local filter = addon:RegisterFilter("ProfessionTradeGoods", 85, "AceEvent-3.0")
```

## Créditos

- **Desarrollador**: zavahcodes
- **Basado en**: AdiBags por Adirelle
- **Versión WotLK**: Backported por Sattva#7238

## Licencia

MIT License - Ver archivo LICENSE en el repositorio principal
