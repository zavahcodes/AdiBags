# Filtro de Trade Goods por Profesión

## Descripción

Este nuevo filtro permite separar automáticamente los objetos de la categoría "Trade Goods" (Mercancías comerciales) en secciones específicas según la profesión a la que pertenecen.

Compatible con servidores que no tienen Joyería ni Inscripción (pre-WotLK o custom).

## Características

### Profesiones Soportadas

El filtro detecta y organiza materiales de las siguientes profesiones:

- **Herrería** (Blacksmithing)
- **Sastrería** (Tailoring)
- **Peletería** (Leatherworking)
- **Alquimia** (Alchemy)
- **Ingeniería** (Engineering)
- **Encantamiento** (Enchanting)
- **Cocina** (Cooking)
- **Primeros auxilios** (First Aid)

**Nota:** Joyería e Inscripción no están incluidas ya que no están disponibles en este servidor.

### Soporte Multi-idioma

El filtro funciona en múltiples idiomas:
- Español
- Inglés
- Alemán
- Francés

## Cómo Funciona

1. El filtro usa una base de datos de Item IDs por profesión
2. Cada objeto de tipo "Trade Goods" se verifica contra la base de datos
3. Agrupa automáticamente los objetos en secciones por profesión
4. Los objetos sin profesión detectada se agrupan en "Other Trade Goods"

### Base de Datos de Items

El filtro contiene listas completas de Item IDs para WoW 3.3.5, incluyendo:
- Todos los materiales básicos (barras, minerales, telas, cueros, hierbas)
- Materiales procesados (hilos, tintes, tintas, pigmentos)
- Elementos especiales (explosivos, piezas de ingeniería, fragmentos de encantamiento)
- Materiales de cocina y primeros auxilios

## Configuración

### Acceso a Opciones

1. Abre la interfaz de AdiBags: `/adibags config`
2. Ve a la pestaña "Filters" (Filtros)
3. Busca "Trade Goods by Profession"

### Opciones Disponibles

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

El filtro es extremadamente eficiente ya que usa una base de datos estática de Item IDs:

- No requiere escaneo de tooltips
- Búsqueda instantánea por Item ID
- Sin impacto en el rendimiento del juego

## Notas Técnicas

### Archivo Principal

`modules/ProfessionTradeGoods.lua`

### Dependencias

- AceEvent-3.0 (para manejo de eventos)
- Base de datos de Item IDs de WoW 3.3.5

### Cómo se Detectan las Profesiones

El filtro usa una base de datos interna con cientos de Item IDs organizados por profesión. Cada objeto se verifica contra esta base de datos para determinar a qué profesión pertenece.

## Solución de Problemas

### Los objetos no se agrupan correctamente

- Asegúrate de que el filtro esté habilitado en la configuración
- Verifica que el objeto sea realmente de tipo "Trade Goods"
- Comprueba que el filtro "Item Category" no esté interfiriendo (debería tener menor prioridad)

### Los objetos aparecen en "Other Trade Goods"

- Algunos objetos pueden no estar en la base de datos todavía
- Objetos genéricos que se usan en múltiples profesiones pueden no tener profesión asignada
- Si encuentras un objeto que debería estar clasificado, puedes añadirlo al código

## Desarrollo

### Añadir Nuevos Item IDs

Para añadir nuevos items a una profesión, edita el array `PROFESSION_ITEMS` en el archivo:

```lua
BLACKSMITHING = {
    -- Añade el nuevo Item ID aquí
    12345, -- Descripción del item
}
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
