# AdiBags-WoTLK-3.3.5
**AdiBags** backport with improved UI and functions for 3.3.5 WoTLK client.

![wow_CNgtiMLTXH](https://user-images.githubusercontent.com/74269253/229909788-3782f7b8-a995-4095-b997-37bf895675b6.png)

## 🚀 Latest Improvements (October 2025)
<details open> <summary> Click to see recent enhancements: </summary>

### Integrated Addon Features 🆕
All previously separate addons are now built into AdiBags core - no need for multiple addons!

**Ascension WoW Support:**
- **Built-in Ascension filters**: Native support for Ascension-specific items
- **Mythic+ categorization**: Automatically groups Mythic+ items in dedicated section
- **Tier Token detection**: Separates tier tokens for easy identification
- **Mystic Enchants by class**: Auto-categorizes Mystic Enchants by class (Hunter, Warrior, Mage, etc.)
- **Tools and Vanity items**: Dedicated sections for Ascension tools and vanity items
- **Transmog indicators**: Visual overlay system for uncollected transmog items
  - **Three display modes**: Choose between spinning star overlay, letter "T", or both
  - **Bold letter indicator**: White "T" with thick outline in top-right corner
  - **Customizable colors**: Configure overlay color for personal preference
  - **Own category option**: Group transmog items in separate category or keep in normal categories
- **Smart detection**: Uses Ascension's `C_Appearance` API for accurate transmog collection status

**Item Binding Filter:**
- **BoE categorization**: Separate section for Bind on Equip items
- **BoP/Soulbound filter**: Optional section for Bind on Pickup items
- **Equipable-only option**: Filter only equipable soulbound items (excludes consumables)
- **Poor/Common BoE filter**: Option to include gray and white quality BoE items
- **Fully configurable**: Enable/disable each binding type independently

**Unusable Item Overlay:**
- **Red overlay indicator**: Visual red tint on items you cannot use
- **Smart detection**: Scans tooltips for red text (level, class, race, profession requirements)
- **Performance optimized**: Debounced updates and efficient tooltip scanning
- **One-click toggle**: Easy enable/disable through AdiBags options
- **Works with everything**: Detects any restriction shown in red on tooltips

### Item Count Across Characters 🆕
- **Cross-character item tracking**: See how many of each item you have across all your characters on the same realm
- **Tooltip integration**: Item counts automatically appear in tooltips when hovering over items
- **Multiple locations tracked**: Shows separate counts for Bags, Bank, Equipped items, and Guild Bank
- **Current character highlighted**: Easily identify which counts belong to your current character
- **Total count display**: When you have items on multiple characters, see a grand total at the bottom
- **Fully configurable**: Choose which locations to display (bags, bank, equipped, guild bank)
- **Character visibility options**: Show only current character, show all characters, or customize per-character
- **Color-coded display**: Different colors for each location type for quick visual recognition
- **Automatic scanning**: Updates automatically when you open bags, visit bank, or change equipment
- **Performance optimized**: Minimal performance impact with smart caching and delayed scanning
- **Complete documentation**: See [ITEM_COUNT_README.md](ITEM_COUNT_README.md) for detailed information

### Guild Bank Support 🆕
- **Full Guild Bank integration**: View and manage your Guild Bank contents directly within AdiBags
- **8 virtual tabs**: All 8 Guild Bank tabs accessible through AdiBags interface (bags 101-108)
- **Hidden original frame**: Original WoW Guild Bank frame remains invisible while using AdiBags
- **Personal Bank compatible**: Works with Ascension WoW Personal Bank system
- **DataStore_Containers compatible**: Includes compatibility module to prevent errors
- **Complete item support**: Full functionality for tooltips, item counts, and item levels
- **Proper closure handling**: Correctly closes connection to server when done
- **ESC key support**: ESC key works normally for game menu while Guild Bank is open
- **Read-only items**: Items displayed in read-only mode to prevent reorganization issues
- **Seamless experience**: Open Guild Bank and use it just like your regular bags
- **Full documentation**: See [GUILD_BANK_README.md](GUILD_BANK_README.md) for detailed information

### New Trade Goods by Profession Filter 🆕
- **Automatic profession organization**: New filter that separates trade goods into dedicated sections by profession
- **8 professions supported**: Blacksmithing, Tailoring, Leatherworking, Alchemy, Engineering, Enchanting, Cooking, First Aid
- **500+ Items database**: Comprehensive database covering all major trade goods in WoW 3.3.5
- **Name-based matching**: Uses item names instead of IDs for better compatibility with custom servers
- **Custom server friendly**: Works reliably on servers with modified item IDs (like Ascension WoW)
- **Lightning-fast performance**: Uses static name lookups for instant classification with zero performance impact
- **Configurable options**: Choose whether to group unclassified trade goods in a separate section
- **Smart classification**: Materials automatically sorted by profession type (bars, ores, cloth, leather, herbs, etc.)
- **No Jewelcrafting/Inscription**: Optimized for servers without these professions
- **Complete documentation**: Includes user guide and developer guide for adding custom items
- **Easy to extend**: Simple to add new items to any profession category

### New Manual Refresh Button
- **Quick refresh control**: Added new "R" button to the top-left corner of bags (before the "T" button)
- **Force layout update**: Manually trigger a complete refresh of bag layout and item reorganization
- **Use cases**: Perfect for when items don't organize correctly, after changing filters, or when layout seems out of sync
- **One-click solution**: Simply click "R" to force a complete bag reorganization without closing/reopening bags

### Enhanced Item Stack Display
- **Compact number formatting**: Item stacks of 1000+ now display in compact format (1k, 1.2k, 15k, 1.5M, etc.)
- **Smart formatting rules**:
  - 1000-9999: Shows decimals when needed (1.2k, 2.5k)
  - 10000+: Shows whole numbers (15k, 250k)
  - 1M+: Shows millions with decimals when needed (1.2M, 15M)
- **Improved readability**: Much cleaner bag interface when dealing with high-stack items on private servers

### Enhanced Item Level Display
- **Improved positioning**: Item level text repositioned to bottom-left corner with 1px margin for better visibility
- **Quality-based coloring**: Changed default color scheme from complex level-based to intuitive quality-based colors:
  - Gray text for Poor quality items
  - White text for Common quality items
  - Green text for Uncommon quality items
  - Blue text for Rare quality items
  - Purple text for Epic quality items
  - Orange text for Legendary quality items
- **Better positioning**: Item count and item level now positioned at opposite corners (bottom-right and bottom-left respectively) for optimal space usage

### UI Positioning Improvements
- **Item count repositioning**: Stack count text moved to bottom-right corner with 1px margin for consistent spacing
- **Non-overlapping text**: Item level and item count now positioned at opposite corners to prevent text overlap
- **Cleaner visual layout**: Better spacing and alignment throughout the bag interface

### Enhanced Junk Filter
- **Improved "Low quality items" detection**: Now includes both gray (Poor) AND white (Common) equipment items when the "Low quality items" option is enabled
- **Smart equipment detection**: Only white equipment is considered junk, not consumables or other white items
- **Maintains backward compatibility**: Gray items still work exactly as before

### New Ammunition Filter
- **Dedicated Ammunition section**: Added a new high-priority filter that automatically separates arrows, bullets, and other projectiles
- **Precise detection**: Uses `INVTYPE_AMMO` equipment slot for accurate identification
- **Clean organization**: Ammunition no longer appears in the Junk section, keeping your projectiles easily accessible
- **Highest priority**: Runs before all other filters to ensure proper categorization

### Technical Improvements
- **Filter priority optimization**: Ammunition filter runs at priority 95 (highest) to prevent conflicts
- **Code quality**: Added proper constants and clear documentation
- **Localization ready**: Added localization strings for new features (English and Spanish)
- **Number formatting utility**: Added robust `FormatLargeNumber` function for consistent display formatting
- **Modular design**: New features implemented as separate modules for easy maintenance

These improvements make bag management more intuitive, prevent accidental disposal of useful items, and provide much better readability for high-stack items!

**📚 Full Documentation:**
- [Item Count Across Characters - Complete Guide](ITEM_COUNT_README.md)
- [Guild Bank Support - Complete Guide](GUILD_BANK_README.md)
- [Trade Goods by Profession - User Guide](PROFESSION_FILTER_README.md)
- [Adding Items to Profession Filter - Developer Guide](ADDING_ITEMS_GUIDE.md)
</details>

## 📦 Download & Installation

1. Click the green `Code` button at the top of this page, then select
   **[Download ZIP](https://github.com/Sattva-108/AdiBags/archive/refs/heads/main.zip)**

2. Extract the downloaded `.zip` file. You’ll get a folder named:
   **`AdiBags-main`**

3. Move the `AdiBags-main` folder into your WoW AddOns directory:
   `World of Warcraft\Interface\AddOns\`

4. Rename the folder to exactly:
   **`AdiBags`** ← (⚠️ Must match this name exactly — no `-main`, no extra spaces!)

✅ Done! The addon should now appear in your in-game addon list.

- _**(Optional)**_ - Download supported extra-modules for AdiBags - [AdiBags-WoTLK-3.3.5-Mods](https://github.com/Sattva-108/AdiBags-WoTLK-3.3.5-Mods)


## Usage
`/adibags` or `/ab` - chat command to open **CONFIGURATION panel** for AdiBags.
<details> <summary> More usage: </summary>
1. Enable / Change modules by selecting them in the AdibBags menu ( /ab command).
<br>
2. `Left-Click` bag icon in top-left corner to manage your current bags.
<br>
3. `Right-click` on any of your current bags to automatically sort bag space out of it (to another bags), so you can replace it by new one.
<br>
4. `Left-Click` an item in your bag and drag to desired catergory title within a bag, to assign it to another category.
</details>

## What's new with backport?
<details> <summary> Click to see the What's New: </summary>
1. Bag replacing module. There was none on 3.3.5.

![previewBagSort](https://github.com/Sattva-108/AdiBags/assets/74269253/425420ca-e3aa-4749-b293-fb3185ac142a)

2. Bag Menu to access different functions in more easy and faster way.

![previewBagMenu](https://github.com/Sattva-108/AdiBags/assets/74269253/e25eca88-0074-405c-973b-ef878fe4ef66)


3. Working on interesting extra-modules for AdiBags, you can download them here - [AdiBags-WoTLK-3.3.5-Mods](https://github.com/Sattva-108/AdiBags-WoTLK-3.3.5-Mods)
4. Item level display.
5. Bag categories are less jumpy.
6. Fixed the database bug, mentioned by addon Author in his README file, that was causing ALL Items to be tagged as `new` for some users.
7. And some minor bug fixes.
8. There is still much to do, hope you stay with me and enjoy addon!
</details>

## Conclusion
Interesting extra-modules for AdiBags, you can download them here - [AdiBags-WoTLK-3.3.5-Mods](https://github.com/Sattva-108/AdiBags-WoTLK-3.3.5-Mods)

#### `Changelog`, `To Do List` and `known bugs` can be viewed in [Changelog and Notes.txt](https://github.com/Sattva-108/AdiBags/blob/main/AdiBags/Changelog%20and%20Notes.txt) inside addon folder.

## Support
- Show **Love and Support** my goals **[Boosty](https://boosty.to/sattva108)**

## Credit
- Credit to [AdiAddons](https://github.com/AdiAddons)
- Code from [AdiBags](https://github.com/AdiAddons/AdiBags)
