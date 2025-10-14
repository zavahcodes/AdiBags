# Gold Tracker Feature - AdiBags

## Descripción / Description

**Español:**
Esta característica permite rastrear el oro de todos tus personajes en un reino específico. Al pasar el cursor sobre el marco de dinero en AdiBags, se mostrará un tooltip con:
- El oro de cada personaje en el reino actual
- El total de oro acumulado entre todos los personajes

**English:**
This feature allows you to track gold across all your characters on a specific realm. When hovering over the money frame in AdiBags, a tooltip will display:
- Gold amount for each character on the current realm
- Total gold accumulated across all characters

## Instalación / Installation

Los cambios ya están integrados en la rama `feature/gold-tracker-tooltip`. Para usar esta característica:

1. Asegúrate de que estás en la rama correcta:
   ```bash
   git checkout feature/gold-tracker-tooltip
   ```

2. El addon se cargará automáticamente cuando inicies WoW

## Uso / Usage

**Español:**
1. Simplemente inicia sesión con cualquiera de tus personajes
2. El oro se rastreará automáticamente
3. Abre tus bolsas (AdiBags)
4. Pasa el cursor sobre el marco de oro en la esquina inferior derecha
5. Verás un tooltip mostrando el oro de todos tus personajes

**English:**
1. Simply login with any of your characters
2. Gold will be tracked automatically
3. Open your bags (AdiBags)
4. Hover over the gold frame in the bottom right corner
5. You'll see a tooltip showing gold for all your characters

## Archivos Modificados / Modified Files

- `modules/GoldTracker.lua` - Nuevo módulo para rastrear oro / New module to track gold
- `modules/MoneyFrame.lua` - Modificado para mostrar tooltip / Modified to show tooltip
- `Localization.lua` - Strings de localización en español / Spanish localization strings
- `AdiBags.toc` - Actualizado con el nuevo módulo / Updated with new module

## Base de Datos / Database

El oro se guarda en la variable global `AdiBagsGoldTrackerDB` con la siguiente estructura:

```lua
AdiBagsGoldTrackerDB = {
    ["RealmName"] = {
        ["CharacterName"] = {
            gold = 123456,        -- Amount in copper
            lastUpdate = 1234567  -- Unix timestamp
        }
    }
}
```

## Características Técnicas / Technical Features

- **Persistencia por reino**: Los datos se guardan por reino, no se mezclan entre diferentes reinos
- **Actualización automática**: El oro se actualiza automáticamente cuando cambia
- **Formato visual**: Usa los iconos de WoW para oro, plata y cobre
- **Ordenamiento**: Los personajes se muestran ordenados alfabéticamente

---

**Realm persistence**: Data is saved per realm, doesn't mix between different realms
**Automatic updates**: Gold is automatically updated when it changes
**Visual format**: Uses WoW's gold, silver, and copper icons
**Sorting**: Characters are displayed in alphabetical order

## Próximos Pasos / Next Steps

Para integrar esta característica en la rama principal:
```bash
git checkout main
git merge feature/gold-tracker-tooltip
```

To integrate this feature into the main branch:
```bash
git checkout main
git merge feature/gold-tracker-tooltip
```
