# Changelog - Gold Tracker Feature

## Version: Gold Tracker v1.0 (October 14, 2025)

### 🎉 New Features

#### Gold Tracker Module
- **Cross-Character Gold Tracking**: Automatically tracks gold amounts for all characters on the same realm
- **Persistent Storage**: Data is saved in `AdiBagsGoldTrackerDB` and persists across sessions
- **Real-time Updates**: Gold is updated automatically when it changes (PLAYER_MONEY event)
- **Smart Loading**: Waits 1 second after entering world to ensure gold is properly loaded

#### Enhanced Money Frame Tooltip
- **Interactive Tooltip**: Hover over the money frame to see all characters' gold
- **Comprehensive Display**: Shows each character's gold sorted alphabetically
- **Total Calculation**: Displays the total gold across all characters on the realm
- **Large Hit Area**: Tooltip activates when hovering over numbers, icons, or the entire money frame
- **Visual Format**: Uses WoW's native gold, silver, and copper icons

#### Localization
- **Spanish Support**: Full Spanish (esES/esMX) localization
- **Bilingual Documentation**: README in both English and Spanish

### 🐛 Bug Fixes

- **Prevented Data Corruption**: Fixed issue where gold could be overwritten with 0 during character switching
- **Validation Layer**: Added protection to skip updates when GetMoney() returns invalid 0 values
- **Delayed Initialization**: PLAYER_ENTERING_WORLD event now waits for gold data to load

### 📝 Technical Details

#### Files Added
- `modules/GoldTracker.lua` - New module for gold tracking (163 lines)
- `GOLD_TRACKER_README.md` - Comprehensive documentation (96 lines)

#### Files Modified
- `AdiBags.toc` - Added GoldTracker module and SavedVariables
- `modules/MoneyFrame.lua` - Enhanced with tooltip functionality (+98 lines)
- `Localization.lua` - Added new localization strings (+10 lines)

#### Database Structure
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

### 📊 Statistics

- **7 Commits** in feature branch
- **5 Files Changed**
- **368 Lines Added**, 2 Lines Removed
- **Net Change**: +366 lines

### 🔧 Dependencies

- AceEvent-3.0 (for event handling)
- AceTimer-3.0 (for delayed execution)
- C_Timer API (preferred, with AceTimer fallback)

### 🎯 Usage

1. Login with any character
2. Gold is automatically tracked
3. Open bags with AdiBags
4. Hover mouse over the gold display (numbers or icons)
5. See tooltip with all characters' gold and total

### 🚀 Performance

- **Minimal Overhead**: Only tracks on PLAYER_MONEY events
- **Efficient Storage**: Uses compact table structure
- **Smart Updates**: Skips unnecessary updates when data hasn't changed
- **No Lag**: All operations are instant with no noticeable performance impact

### 📅 Commit History

1. `b507b58` - feat: Add gold tracker across characters with tooltip display
2. `7f5e279` - docs: Add documentation for gold tracker feature
3. `a0ce1cb` - fix: Improve GoldTracker initialization and add debugging
4. `d345f8e` - fix: Prevent overwriting gold with 0 on character switch
5. `cc9e645` - docs: Update README with overwrite protection info
6. `24e4fac` - feat: Expand tooltip hover area to all money frame elements
7. `0ef5d88` - chore: Remove debug messages and clean up code for production

### 🌟 Credits

- **Feature Request**: zavahcodes
- **Development**: GitHub Copilot
- **Testing**: zavahcodes
- **Original AdiBags**: Adirelle

---

**Tested on**: Ascension WoW - Bronzebeard - Warcraft Reborn
**WoW Version**: 3.3.5 (WoTLK)
**Status**: ✅ Production Ready
