# AdiBags-WoTLK-3.3.5
**AdiBags** backport with improved UI and functions for 3.3.5 WoTLK client.

![wow_CNgtiMLTXH](https://user-images.githubusercontent.com/74269253/229909788-3782f7b8-a995-4095-b997-37bf895675b6.png)


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

## 🚀 Latest Improvements (October 2025)
<details> <summary> Click to see recent enhancements: </summary>

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
- **Localization ready**: Added localization strings for new features
- **Number formatting utility**: Added robust `FormatLargeNumber` function for consistent display formatting

These improvements make bag management more intuitive, prevent accidental disposal of useful items, and provide much better readability for high-stack items!
</details>

## Conclusion
Interesting extra-modules for AdiBags, you can download them here - [AdiBags-WoTLK-3.3.5-Mods](https://github.com/Sattva-108/AdiBags-WoTLK-3.3.5-Mods)

#### `Changelog`, `To Do List` and `known bugs` can be viewed in [Changelog and Notes.txt](https://github.com/Sattva-108/AdiBags/blob/main/AdiBags/Changelog%20and%20Notes.txt) inside addon folder.

## Support
- Show **Love and Support** my goals **[Boosty](https://boosty.to/sattva108)**

## Credit
- Credit to [AdiAddons](https://github.com/AdiAddons)
- Code from [AdiBags](https://github.com/AdiAddons/AdiBags)
