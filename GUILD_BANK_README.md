# Personal Bank (Guild Bank) Support for AdiBags

## Overview

This feature adds Personal Bank (Guild Bank system) support to AdiBags for WoW 3.3.5 (WotLK). The implementation allows you to view Personal Bank contents through the AdiBags interface while the bank window is open. This is especially useful on servers like Ascension WoW that use the Guild Bank system as a Personal Bank for individual players.

## Features

### ✅ Implemented
- **Personal Bank Window Integration**: When you open the Personal Bank, AdiBags automatically displays it with a custom "Personal Bank" title
- **Multi-Tab Support**: Virtual bag IDs (101-108) represent Personal Bank tabs 1-8
- **Item Filtering**: All AdiBags filters work on Personal Bank items
- **Visual Stacking**: Virtual stacks work with Personal Bank items
- **Tab Switching**: Automatically updates when you switch between tabs
- **Permission Aware**: Only shows tabs you have permission to view
- **Custom Color**: Personal Bank window has a green background color to distinguish it from regular bags
- **Original Frame Hidden**: The default Guild Bank frame is automatically hidden while AdiBags is showing
- **DataStore Compatibility**: Built-in module to prevent errors from DataStore_Containers addon

### 🔄 Current Behavior
- Personal Bank items are displayed in **read-only mode** from AdiBags perspective
- Items are filtered and organized just like regular bags
- The current visible tab is displayed (changes when you switch tabs)
- Personal Bank window opens automatically when you open the bank
- Window closes automatically and properly when you close AdiBags
- Original Guild Bank frame remains invisible but functional during use
- Frame is properly closed when you finish using the Personal Bank

### ⚙️ Configuration
- **Enable/Disable**: Personal Bank can be enabled/disabled in AdiBags settings under "Bags"
- **Default Position**: Left side of screen (configurable)
- **Background Color**: Green tint (0, 0.5, 0, 1) to distinguish from bank
- **Filters**: All existing filters work on guild bank items

## Technical Details

### Architecture

#### Virtual Bag IDs
```lua
Guild Bank Tab 1 = Bag ID 101
Guild Bank Tab 2 = Bag ID 102
...
Guild Bank Tab 8 = Bag ID 108
```

#### Key Files Modified
1. **AdiBags.lua**
   - Added `BAG_IDS.GUILD_BANK` with virtual bag IDs
   - Added helper functions for Guild Bank API
   - Added GuildBank bag registration (order 30)
   - Added default configuration for Guild Bank

2. **modules/GuildBank.lua** (NEW)
   - Handles GUILDBANKFRAME_OPENED/CLOSED events
   - Tracks current tab
   - Queries tab data when needed
   - Sends update messages to AdiBags core

3. **widgets/ContainerFrame.lua**
   - Modified `UpdateContent()` to detect guild bank bags
   - Uses `GetGuildBankItemInfo()` instead of `GetContainerItemInfo()` for guild bank
   - Uses `GetGuildBankItemLink()` instead of `GetContainerItemLink()` for guild bank

4. **Localization.lua**
   - Added "Guild Bank" translation key
   - Added description text

5. **AdiBags.toc**
   - Added modules/GuildBank.lua to load order

### API Functions

#### Helper Functions (AdiBags.lua)
```lua
addon:IsGuildBankBag(bag)           -- Returns true if bag ID is 101-108
addon:GetGuildBankTab(bag)          -- Returns tab number (1-8) from bag ID
addon:GetGuildBankNumSlots(bag)     -- Returns 98 slots if tab is viewable
addon:GetGuildBankItemInfo(bag, slot)   -- Wrapper for GetGuildBankItemInfo()
addon:GetGuildBankItemLink(bag, slot)   -- Wrapper for GetGuildBankItemLink()
addon:GetGuildBankItemID(bag, slot)     -- Extracts itemID from link
```

## Known Limitations

1. **Single Tab View**: Only the currently selected tab is shown (WoW API limitation)
2. **Read-Only Display**: Items can't be moved via drag-drop from AdiBags interface (use right-click from inventory or the original frame)
3. **Query Delay**: First time opening a tab may have a slight delay while data loads
4. **Visual Only**: This is by design - prevents accidental reorganization while providing AdiBags filtering benefits

## Ascension Personal Bank Compatibility

This implementation is specifically designed and tested for Personal Bank systems on private servers like Ascension WoW:
- ✅ Full support for Personal Banks that use Guild Bank API
- ✅ Works without being in a guild
- ✅ Handles nil or invalid tab parameters gracefully
- ✅ Defaults to tab 1 when tab information is unavailable
- ✅ DataStore_Containers compatibility built-in (no more errors!)
- ✅ Original frame automatically hidden
- ✅ Proper cleanup when closing

## Future Enhancements (Optional)

- [ ] Multi-tab view (show all viewable tabs at once)
- [ ] Tab selector in AdiBags UI
- [ ] Guild bank deposit/withdraw from AdiBags
- [ ] Guild bank log integration
- [ ] Permission indicator per tab
- [ ] Money display from guild bank

## Design Philosophy

The original author of AdiBags explicitly avoided guild bank support because:
> "AdiBags presents a nice view of your bags but actually they are in a complete mess. Guilds usually try to keep their bank tidy. What would happen if some people in a guild used AdiBags for the guild bank? They would mess up the guild bank content..."

**Our Solution**: Read-only view that filters and displays items without reorganizing the actual guild bank storage. This gives AdiBags users the filtering benefits without causing problems for non-AdiBags guild members.

## Testing Checklist

- [ ] Open guild bank - AdiBags window appears
- [ ] Close guild bank - AdiBags window disappears
- [ ] Switch tabs - Content updates to new tab
- [ ] Items are filtered correctly
- [ ] Quest items show quest indicator
- [ ] Quality highlighting works
- [ ] Virtual stacks work (if enabled)
- [ ] Search works on guild bank items
- [ ] No Lua errors in /console scriptErrors 1

## Credits

- Original AdiBags by Adirelle
- WotLK 3.3.5 backport by Sattva#7238
- Guild Bank feature by [Your Name]
