# Item Count Feature for AdiBags

## Overview

The Item Count feature tracks items across all your characters on a realm and displays the counts in item tooltips, similar to Bagnon_Tooltips but integrated natively with AdiBags.

## Features

### ✅ Implemented

- **Cross-Character Tracking**: Automatically tracks items for all characters on your realm
- **Tooltip Display**: Shows item counts when hovering over items
- **Location Breakdown**: Displays counts by location:
  - Bags (0-4)
  - Bank (including bank bags 5-11)
  - Equipped items
  - Guild Bank (if Guild Bank module is enabled)
- **Configurable Display**: Choose what to show:
  - Current character
  - Alt characters
  - Specific locations (bags/bank/equipped/guild bank)
- **Auto-Update**: Scans automatically on:
  - Login
  - Bag updates
  - Bank opening
  - Equipment changes
  - Guild Bank updates
- **Smart Formatting**:
  - Shows total count with location breakdown
  - Groups multiple locations intelligently
  - Highlights current character

## How It Works

### Data Storage

The feature uses AdiBags' existing `AdiBagsDB` SavedVariable structure:

```lua
AdiBagsDB.namespaces.ItemCount.global.characters = {
    ["RealmName.CharacterName"] = {
        lastUpdate = timestamp,
        money = copper,
        items = {
            [itemID] = {
                bags = count,
                bank = count,
                equipped = count,
                guildBank = count
            }
        }
    }
}
```

### Scanning Process

1. **Initial Scan**: On login, scans bags and equipment
2. **Bank Scan**: When bank is opened, scans all bank slots and bags
3. **Guild Bank Scan**: When guild bank is accessed (if module enabled)
4. **Incremental Updates**: Updates specific bags/slots when items change

### Tooltip Integration

- Hooks `GameTooltip:OnTooltipSetItem` for main tooltips
- Hooks `ItemRefTooltip:OnTooltipSetItem` for chat link tooltips
- Adds a section showing:
  ```
  Item Count:
  CharacterName (Current): 15 (10 Bags, 5 Bank)
  AltCharacter: 8 Bags
  Total: 23
  ```

## Configuration

Access settings in AdiBags options under **Plugins** → **Item Count**

### Options

| Option | Description | Default |
|--------|-------------|---------|
| **Enable Item Count Tracking** | Master toggle for the feature | ON |
| **Show Current Character** | Display counts for active character | ON |
| **Show Other Characters** | Display counts for alt characters | ON |
| **Bags** | Include bags in count display | ON |
| **Bank** | Include bank in count display | ON |
| **Equipped** | Include equipped items in count display | ON |
| **Guild Bank** | Include guild bank in count display | ON |

## Usage Examples

### Example 1: Single Location
When you have an item only in bags:
```
Item Count:
MyCharacter (Current): 15 Bags
```

### Example 2: Multiple Locations
When you have an item in multiple places:
```
Item Count:
MyCharacter (Current): 23 (15 Bags, 8 Bank)
```

### Example 3: Multiple Characters
When item is spread across alts:
```
Item Count:
MainChar (Current): 15 (10 Bags, 5 Bank)
BankAlt: 50 Bank
GuildBankAlt: 20 Guild Bank
Total: 85
```

### Example 4: Equipped Items
When item is equipped:
```
Item Count:
WarriorAlt: Equipped
```

## Technical Details

### Modules

#### ItemCount.lua
**Purpose**: Data collection and storage

**Key Functions**:
- `ScanCurrentCharacter()` - Full character scan
- `ScanBags()` - Scan bags 0-4
- `ScanBank()` - Scan bank and bank bags
- `ScanEquipment()` - Scan equipped items (slots 1-19)
- `ScanGuildBank()` - Scan guild bank tabs 101-108
- `GetItemCount(itemLink, characterName)` - Get counts for specific character
- `GetTotalItemCount(itemLink)` - Get total across all characters
- `GetCharacterList()` - Get all tracked characters

#### ItemCountTooltip.lua
**Purpose**: Tooltip display integration

**Key Functions**:
- Hooks tooltip events
- Formats count display
- Manages tooltip lines
- Color coding for readability

### Event Handling

| Event | Action |
|-------|--------|
| `PLAYER_MONEY` | Update money |
| `BAG_UPDATE` | Scan specific bag |
| `BANKFRAME_OPENED` | Scan entire bank |
| `PLAYERBANKSLOTS_CHANGED` | Rescan bank |
| `UNIT_INVENTORY_CHANGED` | Rescan equipment |
| `AdiBags_BagUpdated` | Scan guild bank (if applicable) |

### Performance Considerations

- **Lazy Scanning**: Only scans when needed (login, bag open, changes)
- **Throttling**: Uses `ScheduleTimer` to batch rapid updates
- **Efficient Storage**: Stores only item IDs and counts (not full item data)
- **Smart Queries**: Caches character list, only queries relevant data

## Comparison with Bagnon_Tooltips

| Feature | Bagnon_Tooltips | AdiBags ItemCount |
|---------|-----------------|-------------------|
| Cross-character tracking | ✅ | ✅ |
| Tooltip display | ✅ | ✅ |
| Bags tracking | ✅ | ✅ |
| Bank tracking | ✅ | ✅ |
| Equipped tracking | ✅ | ✅ |
| Guild Bank tracking | ⚠️ Separate addon | ✅ Built-in |
| Configuration | Limited | Full options |
| Integration | Requires Bagnon_Forever | Native to AdiBags |
| Storage | Separate DB | Uses AdiBagsDB |

## Troubleshooting

### Items not showing in tooltips

1. **Check module is enabled**:
   - Go to AdiBags options → Plugins → Item Count
   - Ensure "Enable Item Count Tracking" is ON

2. **Verify character data exists**:
   - Login to each character at least once
   - Open bags to trigger initial scan

3. **Check location filters**:
   - Make sure the relevant location toggles are ON
   - E.g., if item is in bank, "Bank" must be enabled

### Counts are outdated

1. **Force rescan**:
   - `/reload` to trigger a full scan
   - Open bank to update bank data
   - Open guild bank to update guild bank data

2. **Check last update**:
   - Data is updated on bag/bank changes
   - Alt character data updates when you log into them

### Performance issues

1. **Disable Guild Bank scanning** if you don't use it
2. **Reduce shown characters** by disabling "Show Other Characters"
3. **Clean old data**: Module stores data for all characters indefinitely

## Future Enhancements (Ideas)

- [ ] Cross-realm tracking (using connected realms)
- [ ] Item count in bag UI (not just tooltips)
- [ ] Export/import character data
- [ ] Cleanup tool for old characters
- [ ] Search by item count
- [ ] Shopping list integration
- [ ] Mail tracking
- [ ] Auction house tracking

## Credits

- Original concept from Bagnon_Tooltips by Tuller
- Integrated and enhanced for AdiBags
- Guild Bank integration by AdiBags team

## License

Same as AdiBags - MIT License
