# Graph Report - The-Only-Cure  (2026-08-17)

## Corpus Check
- Large corpus: 277 files · ~506,622 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 487 nodes · 906 edges · 37 communities (29 shown, 8 thin omitted)
- Extraction: 73% EXTRACTED · 27% INFERRED · 0% AMBIGUOUS · INFERRED: 249 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Amputation Test Suite
- Compatibility & Wound Care
- Data Controller & XP
- Perks & Sandbox Options
- Limb Cutting & Confirmation UI
- Item Equip Restrictions
- Admin & Relay Commands
- Public API & Zombie Amputation
- Player Controller & Cauterization
- Server Item Management
- Server Data & Initialization
- Limb Action Restrictions
- Amputation Damage Handler
- Tourniquet System
- Debug Utilities
- Server-Client Data Sync
- Server Relay Commands
- Ignored Action Overrides
- Player Initialization
- Tooling Config
- Body Location Mapping
- Graphify Plugin Config
- Data Flow Design Notes
- CI Build Scripts
- Amputation Left Forearm
- Amputation Right Forearm
- Amputation Left Upper Arm
- Amputation Right Upper Arm
- Issue Templates

## God Nodes (most connected - your core abstractions)
1. `TOC_DEBUG.print()` - 69 edges
2. `DataController.GetInstance()` - 38 edges
3. `getDC()` - 36 edges
4. `requestReset()` - 18 edges
5. `getUsername()` - 16 edges
6. `CommonMethods.GetSide()` - 15 edges
7. `asyncAmpMP()` - 13 edges
8. `CachedDataHandler.GetAmputatedLimbs()` - 11 edges
9. `TourniquetController.CheckTourniquetOnLimb()` - 10 edges
10. `CachedDataHandler.CalculateCacheableValues()` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Steam Workshop Description` --semantically_similar_to--> `README (The Only Cure)`  [INFERRED] [semantically similar]
  dev_stuff/steam_desc.txt → README.md
- `Workshop Listing (B42.15)` --semantically_similar_to--> `README (The Only Cure)`  [INFERRED] [semantically similar]
  workshop_files/workshop.txt → README.md
- `Sandbox option: SurgeonAbilityImportance` --conceptually_related_to--> `Amputation (core mechanic)`  [INFERRED]
  42/media/sandbox-options.txt → README.md
- `Amputation (core mechanic)` --references--> `Perk: Side_R (right-side amputation skill)`  [INFERRED]
  README.md → 42/media/perks.txt
- `Amputation (core mechanic)` --references--> `Item: Amputation Clothing (Hand R)`  [INFERRED]
  README.md → 42/media/scripts/TOC_amputation_items.txt

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Prosthesis crafting and display system** — 42_media_scripts_toc_recipes_craft_prosthetic_arm, 42_media_scripts_toc_recipes_craft_prosthetic_hook, 42_media_scripts_toc_prosthesis_items_prost_normalarm_l, 42_media_scripts_toc_prosthesis_items_prost_hookarm_l, 42_media_scripts_toc_models_prostheticarm, 42_media_scripts_toc_models_prostheticarmhook [INFERRED 0.85]
- **Amputation gameplay system (mechanic, sounds, traits, side perks)** — readme_amputation, 42_media_scripts_toc_sounds_amputation, 42_media_scripts_toc_traits_amputee_hand, 42_media_scripts_toc_traits_amputee_forearm, 42_media_scripts_toc_traits_amputee_upperarm, 42_media_perks_side_l, 42_media_perks_side_r, 42_media_scripts_toc_amputation_items_amputation_hand_r [INFERRED 0.80]
- **Cicatrization wound-care tuning and feedback** — readme_cicatrization, 42_media_sandbox_options_cicatrizationspeed, 42_media_sandbox_options_wounddirtynessmultiplier, 42_media_scripts_toc_sounds_cauterization [INFERRED 0.75]

## Communities (37 total, 8 thin omitted)

### Community 0 - "Amputation Test Suite"
Cohesion: 0.07
Nodes (61): asyncAmpMP(), asyncResetAndWait(), getDC(), getUsername(), mockPlayerNoItems(), queueCauterize(), queueCut(), requestReset() (+53 more)

### Community 1 - "Compatibility & Wound Care"
Cohesion: 0.06
Nodes (22): Compat.RunModCompatibility(), LocalPlayerController.TryRandomBleed(), Tests.Normalize_Standard(), Tests.Normalize_ZeroRange(), CleanWoundAction:perform(), GetColorFromCicatrizationTime(), ISHealthBodyPartListBox:doDrawItem(), ISHealthPanel:dropItemsOnBodyPart() (+14 more)

### Community 2 - "Data Controller & XP"
Cohesion: 0.05
Nodes (6): AddTOCXpRelay(), ISInventoryTransferAction:update(), DataController:apply(), DataController:new(), AddTOCXp(), IterateTOCXp()

### Community 3 - "Perks & Sandbox Options"
Cohesion: 0.07
Nodes (33): Perk Tree: Amputations (parent), Perk: Prosthesis Familiarity, Perk: Side_L (left-side amputation skill), Perk: Side_R (right-side amputation skill), Sandbox option: CicatrizationSpeed, Sandbox option: SurgeonAbilityImportance, Sandbox option: WoundDirtynessMultiplier, Item: Amputation Clothing (Hand L) (+25 more)

### Community 4 - "Limb Cutting & Confirmation UI"
Cohesion: 0.10
Nodes (14): CutLimbAction:getDuration(), ConfirmationPanel.Open(), AddInvAmputationOptions(), AddInventoryAmputationMenu(), CheckIfSaw(), CutLimbInteractionHandler:addToMenu(), CutLimbInteractionHandler:checkItem(), CutLimbInteractionHandler:dropItems() (+6 more)

### Community 5 - "Item Equip Restrictions"
Cohesion: 0.13
Nodes (25): LocalPlayerController.CanItemBeEquipped(), mockItem(), Tests.GetSide_Left(), Tests.GetSide_Right(), Tests.GetSideFull_Invalid(), Tests.GetSideFull_Valid(), Tests.MiddleFingerItem_Blocked_WhenHandCut(), Tests.RightWrist_Blocked_WhenForeArmR_Cut() (+17 more)

### Community 6 - "Admin & Relay Commands"
Cohesion: 0.12
Nodes (19): AddAdminTocOptions(), ISHealthPanel.onCheatCurrentPlayer(), ClientRelayCommands.FinalizeAmputationAction(), ClientRelayCommands.ReceiveCache(), ClientRelayCommands.ReceiveExecuteAmputationAction(), ClientRelayCommands.ReceiveExecuteInitialization(), InitAmputationHandler(), OnServerRelayCommand() (+11 more)

### Community 7 - "Public API & Zombie Amputation"
Cohesion: 0.12
Nodes (12): TOC_Compat.getHands(), TOC_Compat.hasBothHands(), TOC_Compat.hasHand(), TOC_Compat.hasPart(), ISDetachItemHotbar:new(), OverrideAction(), GetZombieID(), HandleZombiesAmputations() (+4 more)

### Community 8 - "Player Controller & Cauterization"
Cohesion: 0.12
Nodes (10): LocalPlayerController.HandleDamage(), LocalPlayerController.HandleSetCicatrization(), LocalPlayerController.HealArea(), LocalPlayerController.HealZombieInfection(), LocalPlayerController.OnGetDamage(), LocalPlayerController.UpdateAmputations(), Tests.RunCicatrizationLoop(), CauterizeAction:perform() (+2 more)

### Community 9 - "Server Item Management"
Cohesion: 0.18
Nodes (15): ClientRelayCommands.ReceiveWearAmputation(), ItemsController.Player.DeleteAllOldAmputationItems(), ItemsController.Player.DeleteOldAmputationItem(), ItemsController.Player.GetAmputationTexturesIndex(), ItemsController.Player.OverrideAmputationItemVisuals(), ItemsController.Player.RemoveClothingItem(), ItemsController.Player.SpawnAmputationItem(), ItemsController.Zombie.GetAmputationTexturesIndex() (+7 more)

### Community 10 - "Server Data & Initialization"
Cohesion: 0.14
Nodes (8): ClientRelayCommands.ReceiveApplyFromServer(), Main.Start(), Main.WipeData(), DebugCommands.PrintTocData(), ServerDataHandler.AddTable(), ServerRelayCommands.RelayExecuteInitialization(), CommandsData.GetKey(), DataController:save()

### Community 12 - "Limb Action Restrictions"
Cohesion: 0.20
Nodes (10): CheckHandFeasibility(), ISClothingExtraAction:isValid(), ISEquipWeaponAction:isValid(), ISEquipWeaponAction:perform(), ISEquipWeaponAction:performWithAmputation(), ISInventoryPaneContextMenu.doEquipOption(), ISWearClothing:isValid(), LimitActionsController.CheckLimbFeasibility() (+2 more)

### Community 14 - "Amputation Damage Handler"
Cohesion: 0.20
Nodes (7): ClientRelayCommands.ReceiveDamageDuringAmputation(), CutLimbAction:start(), ServerRelayCommands.RelayDamageDuringAmputation(), AmputationHandler.ApplyDamageDuringAmputation(), AmputationHandler:damageAfterAmputation(), AmputationHandler.PrepareBandagesAction(), AmputationHandler.PrepareStitchesAction()

### Community 15 - "Tourniquet System"
Cohesion: 0.23
Nodes (11): mockPlayerWithTourniquet(), Tests.CheckTourniquetOnLimb_CorrectSide_True(), Tests.CheckTourniquetOnLimb_NonTourniquetItem_False(), Tests.CheckTourniquetOnLimb_RightSide_True(), Tests.CheckTourniquetOnLimb_WrongSide_False(), Tests.IsItemTourniquet_Left_True(), Tests.IsItemTourniquet_Right_True(), Tests.IsItemTourniquet_Unrelated_False() (+3 more)

### Community 16 - "Debug Utilities"
Cohesion: 0.21
Nodes (4): TOC_DEBUG.getRunningFile(), TOC_DEBUG.print(), TOC_DEBUG.testAddXp(), TOC_DEBUG.TestBodyDamage()

### Community 17 - "Server-Client Data Sync"
Cohesion: 0.24
Nodes (8): ClientDataController.OnDataReceived(), ClientDataController.Request(), ISMedicalCheckAction:perform(), SetHealthPanelTOC(), createDefaultData(), ServerDataController.GetOrCreate(), ServerDataController.Initialize(), ServerRelayCommands.RelayRequestDataController()

### Community 18 - "Server Relay Commands"
Cohesion: 0.28
Nodes (6): ServerRelayCommands.RelayApplyTraitAmputation(), ServerRelayCommands.RelayExecuteAmputationAction(), ServerRelayCommands.RelayForcedAmputation(), ServerRelayCommands.RelayTriggerBleed(), ServerRelayCommands.UpdateDataControllerFromClient(), CommonMethods.GetPatientForServer()

### Community 19 - "Ignored Action Overrides"
Cohesion: 0.28
Nodes (3): ISAttachItemHotbar:new(), ISEquipWeaponAction:new(), OverrideAction()

### Community 20 - "Player Initialization"
Cohesion: 0.29
Nodes (7): LocalPlayerController.InitializePlayer(), LocalPlayerController.ManageTraits(), LocalPlayerController.ToggleUpdateAmputations(), Main.InitializePlayer(), Tests.InitializePlayer(), CommonMethods.SafeStartEvent(), DataController.WhenReady()

### Community 21 - "Tooling Config"
Cohesion: 0.50
Nodes (3): plugin, $schema, .opencode/plugins/graphify.js

### Community 24 - "Data Flow Design Notes"
Cohesion: 1.00
Nodes (3): Multiplayer Data Sync Flow Notes, CachedDataHandler, DataController

## Knowledge Gaps
- **22 isolated node(s):** `$schema`, `.opencode/plugins/graphify.js`, `bump_minor_version.sh script`, `Workshop Test Listing`, `GitHub Bug Report Template` (+17 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **8 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TOC_DEBUG.print()` connect `Debug Utilities` to `Amputation Test Suite`, `Compatibility & Wound Care`, `Data Controller & XP`, `Limb Cutting & Confirmation UI`, `Item Equip Restrictions`, `Admin & Relay Commands`, `Public API & Zombie Amputation`, `Player Controller & Cauterization`, `Server Item Management`, `Server Data & Initialization`, `Limb Action Restrictions`, `Amputation Damage Handler`, `Tourniquet System`, `Server-Client Data Sync`, `Server Relay Commands`, `Player Initialization`?**
  _High betweenness centrality (0.130) - this node is a cross-community bridge._
- **Why does `DataController.GetInstance()` connect `Compatibility & Wound Care` to `Amputation Test Suite`, `Data Controller & XP`, `Limb Cutting & Confirmation UI`, `Item Equip Restrictions`, `Admin & Relay Commands`, `Public API & Zombie Amputation`, `Player Controller & Cauterization`, `Server Item Management`, `Limb Action Restrictions`, `Server-Client Data Sync`, `Server Relay Commands`, `Ignored Action Overrides`, `Player Initialization`?**
  _High betweenness centrality (0.098) - this node is a cross-community bridge._
- **Why does `ISEquipWeaponAction:new()` connect `Ignored Action Overrides` to `Compatibility & Wound Care`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Are the 65 inferred relationships involving `TOC_DEBUG.print()` (e.g. with `ClientRelayCommands.ReceiveApplyFromServer()` and `ClientRelayCommands.ReceiveWearAmputation()`) actually correct?**
  _`TOC_DEBUG.print()` has 65 INFERRED edges - model-reasoned connections that need verification._
- **Are the 37 inferred relationships involving `DataController.GetInstance()` (e.g. with `TOC_Compat.hasPart()` and `ClientRelayCommands.ReceiveExecuteAmputationAction()`) actually correct?**
  _`DataController.GetInstance()` has 37 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `requestReset()` (e.g. with `ClientDataController.Request()` and `CachedDataHandler.Setup()`) actually correct?**
  _`requestReset()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `$schema`, `.opencode/plugins/graphify.js`, `bump_minor_version.sh script` to the rest of the system?**
  _22 weakly-connected nodes found - possible documentation gaps or missing edges._