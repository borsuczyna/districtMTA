# districtMTA Resources Documentation

This document provides a comprehensive overview of all resources in the districtMTA server and their functionalities, along with system interconnections.

## Core Systems

### m-core
**Description:** Core server functionality providing essential utilities and base functions
**Connections:** Used by all other resources for basic server operations
**Features:**
- Player management utilities
- Money management system
- Database connection handling
- Partial name search for players
- Central event handlers

### m-mysql
**Description:** MySQL database connector and query handler
**Connections:** Used by all resources that need database access
**Features:**
- Database connection management
- Query execution and prepared statements
- Async query handling

### m-ui
**Description:** Main user interface system using CEF (Chromium Embedded Framework)
**Connections:** Provides UI for all interactive systems
**Features:**
- Request/response system for UI interactions
- CEF-based interface rendering
- UI element management

### m-boilerplate
**Description:** Template/boilerplate resource for creating new resources
**Features:**
- Standard resource structure
- Common patterns and utilities

## Inventory & Trading System

### m-inventory
**Description:** Advanced inventory management system
**Connections:** 
- **Shops:** All shop types access inventory system
- **Trading:** Player-to-player trading uses inventory
- **Crafting:** Crafting system consumes/produces inventory items
- **Jobs:** Jobs reward items to inventory
- **Paint:** Car spray uses inventory items
- **Tuning:** Vehicle tuning parts stored in inventory
- **Fishing:** Fish and fishing rods stored in inventory
- **Houses:** Furniture items stored in inventory

**Features:**
- Player inventory management
- Item usage system
- Item equipment system
- Stack management
- Weight/capacity limits
- Item metadata storage

**Shop Types:**
- **ammu-nation:** Weapons shop
- **foodcart:** Food vendor
- **fish:** Fish market
- **blank-card:** Blank card shop
- **furniture:** Furniture store
- **station:** Gas station shop

**Crafting System:**
- Fishing rod upgrades (7 tiers: Common → Uncommon → Rare → Epic → Legendary → Mythic → Exotic → Divine)
- Progressive wire requirements: 2, 4, 7, 10, 18, 31, 40 wire for each upgrade tier
- Each upgrade improves fishing rod quality and effectiveness

**Items Include:**
- Weapons (M4, etc.)
- Food (hotdog, nukacola)
- Utilities (canister, fishingRod, spray)
- Cosmetics (cosmetic items, clothing)
- Tuning parts
- Furniture items
- Potions and consumables
- Wire, bait, trace items
- Blank cards
- Fish (various types)
- Reefer (drugs)
- Liquid regret

### m-furniture-shop
**Description:** Dedicated furniture shopping interface
**Connections:** Works with m-inventory for furniture items
**Features:**
- Browse furniture catalog
- Purchase furniture for houses

## Vehicle Systems

### m-vehicle-shops
**Description:** Vehicle dealership system
**Connections:** Works with m-core for money, generates vehicles with random properties
**Features:**
- Multiple vehicle models per shop
- Random vehicle properties (fuel, mileage, color, damage)
- Quality system (affects vehicle condition - higher quality means less damage to wheels, panels, doors, and lights)
- Vehicle rotation system with time-based inventory refresh
- Dynamic pricing based on model and quality
- Exit positions for test drives
- Random spawn counts per rotation

### m-tuning
**Description:** Vehicle customization garage
**Connections:** 
- **m-inventory:** Tuning parts stored in inventory
- **Vehicles:** Applies upgrades to owned vehicles

**Features:**
- Visual tuning (spoilers, bumpers, etc.)
- Performance upgrades
- Custom tuning system for all vehicles
- Compatible upgrade checking
- Installation/uninstallation of parts
- Garage teleportation system

### m-custom-tuning-editor
**Description:** Tool for creating custom tuning parts
**Features:**
- Design custom vehicle modifications
- Test tuning configurations

### m-paint
**Description:** Vehicle paint shop
**Connections:** 
- **m-inventory:** Paint sprays stored in inventory
- **Vehicles:** Applies paint to owned vehicles

**Features:**
- Purchase paint sprays (different types: basic, additional, wheels, rims)
- Apply custom colors to vehicles
- Color selection system
- Paint type system (4 types)
- Costs 500 per spray

### m-parking
**Description:** Vehicle parking system
**Features:**
- Park owned vehicles
- Retrieve parked vehicles
- Parking spot management

### m-handlings
**Description:** Vehicle handling configuration
**Features:**
- Custom vehicle physics
- Handling modifications

### m-carexchange
**Description:** Vehicle marketplace/trading system
**Features:**
- List vehicles for sale
- Browse vehicle listings
- Player-to-player vehicle sales

### m-mechanic
**Description:** Vehicle repair system
**Features:**
- Repair damaged vehicles
- Repair shop locations
- Gate system for repair bays
- Damage assessment
- Repair cost calculation

### m-speedo
**Description:** Speedometer and vehicle information display
**Features:**
- Speed display
- Fuel gauge
- Vehicle status indicators

### m-speedcam
**Description:** Speed camera system
**Features:**
- Automatic speed detection
- Fine system for speeding

## Jobs System

### m-jobs
**Description:** Job management system
**Connections:** Manages all job resources

### Job Resources:

#### m-job-burger
**Description:** Burger restaurant job
**Connections:** Rewards items/money to inventory
**Features:**
- Cooperative job (up to 8 players)
- Food preparation tasks
- Customer service

#### m-job-courier
**Description:** Delivery/courier job
**Features:**
- Package delivery
- Route system
- Time-based deliveries

#### m-job-dodo
**Description:** Dodo delivery service job
**Features:**
- Fast food delivery
- Vehicle-based job

#### m-job-photograph
**Description:** Photography job
**Features:**
- Take photographs at specific locations
- Photo submissions

#### m-job-trash
**Description:** Garbage collection job
**Features:**
- Trash pickup routes
- Cooperative gameplay
- Vehicle-based collection

#### m-job-warehouse
**Description:** Warehouse worker job
**Features:**
- Cargo handling
- Loading/unloading tasks
- Cooperative mechanics

### m-fishing
**Description:** Advanced fishing system
**Connections:**
- **m-inventory:** Fish and fishing rods stored
- **Crafting:** Fishing rods can be upgraded
- **Shops:** Fish can be sold at fish shop

**Features:**
- Multiple fish types
- Fishing rod quality system (7 tiers)
- Bait system
- Fishing skill progression
- Fish market integration

## Housing System

### m-houses
**Description:** Player housing system
**Connections:**
- **m-inventory:** Furniture items
- **Interiors:** Custom house interiors

**Features:**
- Buy/sell houses
- House customization
- Furniture placement
- Interior system
- House ownership
- Access control

### m-house-create
**Description:** Admin tool for creating houses
**Features:**
- Place new houses
- Configure house properties

### m-enter
**Description:** Building entrance/exit system
**Features:**
- Interior transitions
- Marker-based entry points

## Faction & Organization Systems

### m-factions
**Description:** Main faction management system
**Features:**
- Faction creation
- Rank system (Discord-like permissions)
- Permission editing
- Member management

### Faction Resources:

#### m-faction-sapd
**Description:** San Andreas Police Department faction
**Features:**
- Police-specific features
- Law enforcement tools
- Arrest system

#### m-faction-ers
**Description:** Emergency Response Services faction
**Features:**
- Medical/emergency services
- Rescue operations

#### m-els
**Description:** Emergency Lighting System
**Features:**
- Emergency vehicle lights
- Siren system

### m-office
**Description:** Organization system
**Features:**
- Organization management
- Rank creation (Discord-like)
- Permission system
- Similar to factions but for businesses

## Missions & Story

### m-missions
**Description:** Mission system
**Connections:** Rewards through inventory/money systems
**Features:**
- Story-driven missions
- Easy mission creation system

**Available Missions:**
- **investigation:** Investigation-based mission
- **long-road:** Long journey mission
- **package:** Package delivery mission
- **prolog:** Introductory mission

### Story Resources:

#### story-1
**Description:** First story chapter
**Features:**
- Narrative content
- Story progression

#### story-1-map
**Description:** Map for story chapter 1
**Features:**
- Custom map objects
- Story locations

#### story-countdown
**Description:** Countdown/timer system for story events
**Features:**
- Event timing
- Countdown displays

## Player Systems

### m-login
**Description:** Authentication system
**Features:**
- Account login
- Account creation
- Session management

### m-loading
**Description:** Loading screen
**Features:**
- Custom loading interface
- Progress indicators

### m-intro
**Description:** Introduction/tutorial system
**Features:**
- New player tutorial
- Introduction sequence

### m-avatars
**Description:** Player avatar system
**Features:**
- Avatar customization
- Profile pictures

### m-clothing
**Description:** Clothing/outfit system
**Connections:** Works with cosmetics in inventory
**Features:**
- Outfit selection
- Clothing store
- Wardrobe management

### m-anim
**Description:** Animation system
**Features:**
- Player animations
- Animation library

### m-animpanel
**Description:** Animation panel UI
**Features:**
- Animation selection interface
- Quick animation access

### m-hud
**Description:** Heads-up display
**Features:**
- Health/armor display
- Money display
- Status indicators

### m-nametags
**Description:** Player name tags
**Features:**
- Custom name displays
- Distance-based visibility
- Rank/status indicators

### m-collectibles
**Description:** Collectible items system
**Features:**
- Hidden collectibles
- Collection tracking
- Rewards

### m-status
**Description:** Player status system
**Features:**
- Hunger/thirst
- Health management
- Status effects

## Seasonal & Events

### m-updates
**Description:** Seasonal pass system (Fortnite-like)
**Features:**
- Season progression
- Exclusive rewards
- Custom cosmetics
- Time-limited content

### m-upgrades
**Description:** Player upgrade system
**Features:**
- Skill upgrades
- Character progression
- Unlock system

### m-unwrap
**Description:** Gift/reward unwrapping system
**Features:**
- Open rewards
- Gift boxes
- Surprise mechanics

### m-wh
**Description:** Wallhack/X-ray vision debugging tool for admins
**Features:**
- Display object information through walls
- Show resource names, model IDs, alpha values
- Display colshape locations
- Debug tool for map/object placement
- Admin/developer utility

## Transportation

### m-scooter
**Description:** Electric scooter rental system
**Features:**
- Scooter spawning
- Rental system
- Payment integration

### m-scooter-traces
**Description:** Visual effects for scooters
**Features:**
- Trail effects behind scooters
- Visual customization

### m-cablecar
**Description:** Cable car transportation
**Features:**
- Automated cable car system
- Public transportation

### m-stations
**Description:** Transportation station system
**Features:**
- Bus/train stations
- Route management

### m-driving-license
**Description:** Driving license system
**Features:**
- License acquisition
- Driving tests
- License verification

## Interface & HUD

### m-f11
**Description:** F11 menu system
**Features:**
- Main menu interface
- Server information
- Settings

### m-scoreboard
**Description:** Player list/scoreboard
**Features:**
- Online players display
- Player statistics
- Ping display

### m-dashboard
**Description:** Player dashboard
**Features:**
- Statistics overview
- Player information
- Quick access menu

### m-interaction
**Description:** Interaction menu
**Features:**
- Context-based actions
- Quick actions menu
- Interaction prompts

### m-notis
**Description:** Notification system
**Features:**
- Toast notifications
- Alert system
- Error/success messages

### m-screen-effects
**Description:** Visual screen effects
**Features:**
- Camera effects
- Screen shaders
- Visual filters

### m-markers
**Description:** Map marker system
**Features:**
- Location markers
- Waypoint system
- Custom markers

### m-playerblips
**Description:** Player blips on map
**Features:**
- Show players on radar
- Team/faction indicators

## Admin & Moderation

### m-admins
**Description:** Admin panel and tools
**Features:**
- Player management
- Server administration
- Moderator tools
- Ban/kick system
- Teleportation
- Vehicle spawning

### m-anticheat
**Description:** Advanced anti-cheat system
**Features:**
- Cheat detection
- Security validation
- Server-side verification
- No client-trust architecture
- Protection against exploits

### m-antyafk
**Description:** Anti-AFK (Away From Keyboard) system
**Features:**
- AFK detection
- Auto-kick for inactive players
- AFK timer

### m-logs
**Description:** Server logging system
**Features:**
- Action logging
- Admin logs
- Player activity tracking

### m-helper
**Description:** Helper/support system
**Features:**
- Help tickets
- Player assistance
- Report system

## Financial Systems

### m-atm
**Description:** ATM/banking system
**Connections:** Works with m-core money system
**Features:**
- Cash withdrawal
- Deposits
- Balance checking
- Money transfers

### m-carding
**Description:** Card/payment system
**Connections:** Works with blank-card items from inventory
**Features:**
- Card creation
- Payment processing
- Card management

## World & Environment

### m-weather
**Description:** Weather system
**Features:**
- Dynamic weather
- Weather transitions
- Climate control

### m-water
**Description:** Water-related features
**Features:**
- Water physics
- Swimming mechanics

### m-maps
**Description:** Map management
**Features:**
- Custom map loading
- Map objects

### m-maps-manager
**Description:** Map editor/manager
**Features:**
- Map editing tools
- Object placement

### [maps]
**Description:** Collection of custom maps
**Features:**
- 52 different map resources
- Custom locations
- Building interiors

### [models]
**Description:** Custom 3D models
**Features:**
- 300+ custom building models
- San Andreas style models
- Exclusive custom content

## Communication & Social

### m-discord
**Description:** Discord integration
**Connections:** External Discord bot (C# based)
**Features:**
- Server status in Discord
- Daily reward reminders
- Player notifications

### m-sockets
**Description:** WebSocket/external communication
**Features:**
- Bot communication
- External API connections
- Real-time data sync

### m-voice
**Description:** Voice chat system
**Features:**
- Proximity voice
- Voice channels

## Utilities & Tools

### compiler
**Description:** Code compilation tool
**Features:**
- Resource compilation
- Code optimization

### cockpits
**Description:** Vehicle cockpit system
**Features:**
- First-person vehicle views
- Cockpit models

### fpp
**Description:** First-person perspective system
**Features:**
- FPP mode
- Camera controls

### m-bw
**Description:** Black and white effect (possibly for death/unconscious)
**Features:**
- Visual effects
- Death screen

### m-ghostmode
**Description:** Ghost/spectator mode
**Features:**
- Invisible mode
- Admin spectating

### m-record
**Description:** Recording/replay system
**Features:**
- Action recording
- Replay functionality

### m-start
**Description:** Server startup resource
**Features:**
- Initial server setup
- Resource loading order

## Community Resources

### [community]
**Description:** Community-contributed resources

#### m-pattach
**Description:** Particle attachment system
**Features:**
- Attach particles to objects
- Visual effects

#### m-timecyc
**Description:** Time and color cycle
**Features:**
- Day/night cycle
- Color timing

### [dm]
**Description:** Deathmatch/PvP resources
**Features:**
- PvP arenas
- Combat systems

## System Interconnections Summary

### Primary Integration Points:

1. **Inventory Hub:**
   - All shops → Inventory (purchases/sales)
   - Trading → Inventory (item exchange)
   - Crafting → Inventory (consume/produce items)
   - Jobs → Inventory (job rewards)
   - Paint → Inventory (spray items)
   - Tuning → Inventory (tuning parts)
   - Fishing → Inventory (fish and rods)
   - Houses → Inventory (furniture)
   - Missions → Inventory (quest rewards)

2. **Money Flow:**
   - Core → All systems (money management)
   - ATM → Core (banking)
   - Jobs → Core (salary)
   - Shops → Core (purchases)
   - Vehicle shops → Core (vehicle sales)
   - Paint → Core (spray purchases)

3. **Vehicle Integration:**
   - Vehicle shops → Vehicles (purchase)
   - Tuning → Vehicles (modifications)
   - Paint → Vehicles (appearance)
   - Mechanic → Vehicles (repairs)
   - Parking → Vehicles (storage)

4. **UI System:**
   - All interactive systems → m-ui (interface rendering)
   - CEF-based unified interface across all systems

5. **Database Layer:**
   - All persistent systems → m-mysql (data storage)
   - Player data, vehicles, houses, factions, inventory, etc.

## Performance & Optimization

The server is optimized to maintain 100 FPS even on low-end computers through:
- Efficient CEF rendering
- Optimized Lua code
- Asynchronous function usage
- Smart resource loading
- Minimal client-side processing

## Security Features

The anti-cheat system ensures "impossible to cheat" gameplay through:
- Server-side validation of all actions
- No client-trust architecture
- Secure event handling
- Protected server-side logic
- Marker-based verification system (e.g., jobs verify actual marker entry, not just money requests)
