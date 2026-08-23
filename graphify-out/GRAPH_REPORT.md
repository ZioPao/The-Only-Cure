# Graph Report - The-Only-Cure  (2026-08-23)

## Corpus Check
- Large corpus: 275 files · ~507,394 words. Semantic extraction will be expensive (many Claude tokens). Consider running on a subfolder.

## Summary
- 485 nodes · 917 edges · 32 communities (25 shown, 7 thin omitted)
- Extraction: 72% EXTRACTED · 28% INFERRED · 0% AMBIGUOUS · INFERRED: 253 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Test Suite & Menu Hooks
- Client Relay & Amputation Flow
- Client APIs & Compat Layer
- Local Player Limb State
- Shared DataController Abstraction
- Perks, Sandbox & Prosthetics Data
- Cut Limb UI Interaction
- Wound Cleaning Action
- Prosthesis Equip/Unequip Logic
- Cut Limb Timed Action
- Mod Compatibility Patches
- Action Limit & Feasibility Checks
- Tourniquet Validation Logic
- Equip Block Tests & Items
- TOC Experience Actions
- Ignored/Overridden Actions
- Hook Prosthetic Recipe & Items
- Body Location Registry
- Multiplayer Data Sync Flow
- Build Version Script
- Left ForeArm Stump Item
- Left Hand Stump Item
- Left UpperArm Stump Item
- Right UpperArm Stump Item

## God Nodes (most connected - your core abstractions)
1. `TOC_DEBUG.print()` - 71 edges
2. `DataController.GetInstance()` - 39 edges
3. `getDC()` - 36 edges
4. `requestReset()` - 18 edges
5. `getUsername()` - 16 edges
6. `CommonMethods.GetSide()` - 16 edges
7. `asyncAmpMP()` - 13 edges
8. `CachedDataHandler.GetAmputatedLimbs()` - 11 edges
9. `TourniquetController.CheckTourniquetOnLimb()` - 10 edges
10. `CachedDataHandler.CalculateCacheableValues()` - 10 edges

## Surprising Connections (you probably didn't know these)
- `Steam Workshop Description` --semantically_similar_to--> `The Only Cure README`  [INFERRED] [semantically similar]
  dev_stuff/steam_desc.txt → README.md
- `Steam Workshop Listing (B42)` --semantically_similar_to--> `The Only Cure README`  [INFERRED] [semantically similar]
  workshop_files/workshop.txt → README.md
- `Bug Report Template` --conceptually_related_to--> `The Only Cure README`  [INFERRED]
  .github/ISSUE_TEMPLATE/bug_report.md → README.md
- `Sound: Amputation` --conceptually_related_to--> `Amputation Mechanic`  [INFERRED]
  42/media/scripts/TOC_sounds.txt → README.md
- `Sound: Cauterization` --conceptually_related_to--> `Amputation Mechanic`  [INFERRED]
  42/media/scripts/TOC_sounds.txt → README.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Prosthetic Arm System (Recipes, Items, Models, Perk)** — 42_media_scripts_toc_recipes_craft_prosthetic_arm, 42_media_scripts_toc_recipes_craft_prosthetic_hook, 42_media_scripts_toc_prosthesis_items_prost_normalarm_l, 42_media_scripts_toc_prosthesis_items_prost_hookarm_l, 42_media_scripts_toc_models_prostheticarm, 42_media_scripts_toc_models_prostheticarmhook, 42_media_perks_prostfamiliarity [INFERRED 0.85]
- **Amputation Workflow (Stumps, Tourniquet, Traits, Sounds)** — 42_media_scripts_toc_amputation_items_amputation_hand_r, 42_media_scripts_toc_amputation_items_amputation_upperarm_r, 42_media_scripts_toc_surgery_items_surg_arm_tourniquet_l, 42_media_scripts_toc_traits_amputee_hand, 42_media_scripts_toc_sounds_amputation_sound [INFERRED 0.80]
- **Multiplayer ModData Sync (DataController, CachedDataHandler)** — temp_flow_42_datacontroller, temp_flow_42_cacheddatahandler, temp_flow_42_moddata_sync_flow [EXTRACTED 0.90]

## Communities (32 total, 7 thin omitted)

### Community 0 - "Test Suite & Menu Hooks"
Cohesion: 0.06
Nodes (61): ISWorldObjectContextMenu.createMenu(), asyncAmpMP(), asyncResetAndWait(), getDC(), getUsername(), mockPlayerNoItems(), queueCauterize(), queueCut() (+53 more)

### Community 1 - "Client Relay & Amputation Flow"
Cohesion: 0.06
Nodes (47): ClientRelayCommands.FinalizeAmputationAction(), ClientRelayCommands.ReceiveApplyFromServer(), ClientRelayCommands.ReceiveCache(), ClientRelayCommands.ReceiveDamageDuringAmputation(), ClientRelayCommands.ReceiveExecuteAmputationAction(), ClientRelayCommands.ReceiveWearAmputation(), InitAmputationHandler(), OnServerRelayCommand() (+39 more)

### Community 2 - "Client APIs & Compat Layer"
Cohesion: 0.06
Nodes (25): AddAdminTocOptions(), ISHealthPanel.onCheatCurrentPlayer(), TOC_Compat.getHands(), TOC_Compat.hasBothHands(), TOC_Compat.hasHand(), TOC_Compat.hasPart(), ClientRelayCommands.ReceiveExecuteInitialization(), ClientDataController.OnDataReceived() (+17 more)

### Community 3 - "Local Player Limb State"
Cohesion: 0.08
Nodes (26): LocalPlayerController.HandleDamage(), LocalPlayerController.HandleSetCicatrization(), LocalPlayerController.HealArea(), LocalPlayerController.HealZombieInfection(), LocalPlayerController.InitializePlayer(), LocalPlayerController.ManageTraits(), LocalPlayerController.OnGetDamage(), LocalPlayerController.ToggleUpdateAmputations() (+18 more)

### Community 5 - "Perks, Sandbox & Prosthetics Data"
Cohesion: 0.08
Nodes (30): Amputations (Parent Perk), ProstFamiliarity (Prosthesis Familiarity) Perk, Side_L Perk (Left Side Amputation), Side_R Perk (Right Side Amputation), Sandbox Option TOC.CicatrizationSpeed, Sandbox Option TOC.SurgeonAbilityImportance, Sandbox Option TOC.WoundDirtynessMultiplier, Amputation_ForeArm_R (Stump Clothing) (+22 more)

### Community 6 - "Cut Limb UI Interaction"
Cohesion: 0.16
Nodes (13): ConfirmationPanel.Open(), AddInvAmputationOptions(), AddInventoryAmputationMenu(), CheckIfSaw(), CutLimbInteractionHandler:addToMenu(), CutLimbInteractionHandler:checkItem(), CutLimbInteractionHandler:dropItems(), CutLimbInteractionHandler:isValid() (+5 more)

### Community 7 - "Wound Cleaning Action"
Cohesion: 0.12
Nodes (5): CleanWoundAction:perform(), WoundCleaningInteractionHandler:addToMenu(), WoundCleaningInteractionHandler:isActionValid(), WoundCleaningInteractionHandler:new(), CommonMethods.GetLimbNameFromBodyPart()

### Community 8 - "Prosthesis Equip/Unequip Logic"
Cohesion: 0.20
Nodes (17): Tests.GetSide_Left(), Tests.GetSide_Right(), ISHealthPanel:render(), ServerRelayCommands.RelayProsthesisState(), CommonMethods.GetSide(), CachedDataHandler.CalculateHandFeasibility(), CachedDataHandler.GetHighestAmputatedLimbs(), ISClothingExtraAction:complete() (+9 more)

### Community 9 - "Cut Limb Timed Action"
Cohesion: 0.12
Nodes (5): CutLimbAction:getDuration(), CutLimbAction:start(), AmputationHandler:damageAfterAmputation(), AmputationHandler.PrepareBandagesAction(), AmputationHandler.PrepareStitchesAction()

### Community 10 - "Mod Compatibility Patches"
Cohesion: 0.13
Nodes (8): Compat.RunModCompatibility(), GetColorFromCicatrizationTime(), ISHealthBodyPartListBox:doDrawItem(), ISHealthPanel:dropItemsOnBodyPart(), ISHealthPanel:getDamagedParts(), ISHealthPanel:tryDrawAmputation(), ISHealthPanel:tryDrawProsthesis(), ISUIElement:wrapInCollapsableWindow()

### Community 11 - "Action Limit & Feasibility Checks"
Cohesion: 0.18
Nodes (11): CheckHandFeasibility(), ISClothingExtraAction:isValid(), ISEquipWeaponAction:isValid(), ISEquipWeaponAction:perform(), ISEquipWeaponAction:performWithAmputation(), ISInventoryPaneContextMenu.doEquipOption(), ISWearClothing:isValid(), LimitActionsController.CheckLimbFeasibility() (+3 more)

### Community 14 - "Tourniquet Validation Logic"
Cohesion: 0.23
Nodes (11): mockPlayerWithTourniquet(), Tests.CheckTourniquetOnLimb_CorrectSide_True(), Tests.CheckTourniquetOnLimb_NonTourniquetItem_False(), Tests.CheckTourniquetOnLimb_RightSide_True(), Tests.CheckTourniquetOnLimb_WrongSide_False(), Tests.IsItemTourniquet_Left_True(), Tests.IsItemTourniquet_Right_True(), Tests.IsItemTourniquet_Unrelated_False() (+3 more)

### Community 15 - "Equip Block Tests & Items"
Cohesion: 0.25
Nodes (11): LocalPlayerController.CanItemBeEquipped(), mockItem(), Tests.GetSideFull_Invalid(), Tests.GetSideFull_Valid(), Tests.MiddleFingerItem_Blocked_WhenHandCut(), Tests.RightWrist_Blocked_WhenForeArmR_Cut(), Tests.RingFingerItem_Blocked_WhenHandCut(), Tests.UnrelatedBodyLoc_AlwaysEquippable() (+3 more)

### Community 16 - "TOC Experience Actions"
Cohesion: 0.27
Nodes (9): AddTOCXpRelay(), ISGrabItemAction:update(), ISInventoryTransferAction:update(), AddTOCXp(), FlushTOCXp(), ISBaseTimedAction:perform(), ISBaseTimedAction:stop(), IterateTOCXp() (+1 more)

### Community 17 - "Ignored/Overridden Actions"
Cohesion: 0.28
Nodes (3): ISAttachItemHotbar:new(), ISEquipWeaponAction:new(), OverrideAction()

### Community 18 - "Hook Prosthetic Recipe & Items"
Cohesion: 0.67
Nodes (4): prostheticArmHook Model, Prost_HookArm_L (Left Hook Prosthesis), Prost_HookArm_R (Right Hook Prosthesis), Recipe: Craft Prosthetic Hook

### Community 20 - "Multiplayer Data Sync Flow"
Cohesion: 0.67
Nodes (3): CachedDataHandler, DataController, Multiplayer ModData Sync Flow

## Knowledge Gaps
- **20 isolated node(s):** `bump_minor_version.sh script`, `Bug Report Template`, `Steam Workshop Description`, `Steam Workshop Test Listing`, `CachedDataHandler` (+15 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `TOC_DEBUG.print()` connect `Client Relay & Amputation Flow` to `Test Suite & Menu Hooks`, `Client APIs & Compat Layer`, `Local Player Limb State`, `Shared DataController Abstraction`, `Cut Limb UI Interaction`, `Wound Cleaning Action`, `Prosthesis Equip/Unequip Logic`, `Cut Limb Timed Action`, `Mod Compatibility Patches`, `Action Limit & Feasibility Checks`, `Tourniquet Validation Logic`, `Equip Block Tests & Items`, `TOC Experience Actions`?**
  _High betweenness centrality (0.134) - this node is a cross-community bridge._
- **Why does `DataController.GetInstance()` connect `Local Player Limb State` to `Test Suite & Menu Hooks`, `Client Relay & Amputation Flow`, `Client APIs & Compat Layer`, `Shared DataController Abstraction`, `Cut Limb UI Interaction`, `Wound Cleaning Action`, `Prosthesis Equip/Unequip Logic`, `Mod Compatibility Patches`, `Action Limit & Feasibility Checks`, `TOC Experience Actions`, `Ignored/Overridden Actions`?**
  _High betweenness centrality (0.101) - this node is a cross-community bridge._
- **Why does `ISEquipWeaponAction:new()` connect `Ignored/Overridden Actions` to `Local Player Limb State`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Are the 67 inferred relationships involving `TOC_DEBUG.print()` (e.g. with `ClientRelayCommands.ReceiveApplyFromServer()` and `ClientRelayCommands.ReceiveWearAmputation()`) actually correct?**
  _`TOC_DEBUG.print()` has 67 INFERRED edges - model-reasoned connections that need verification._
- **Are the 38 inferred relationships involving `DataController.GetInstance()` (e.g. with `TOC_Compat.hasPart()` and `ClientRelayCommands.ReceiveExecuteAmputationAction()`) actually correct?**
  _`DataController.GetInstance()` has 38 INFERRED edges - model-reasoned connections that need verification._
- **Are the 2 inferred relationships involving `requestReset()` (e.g. with `ClientDataController.Request()` and `CachedDataHandler.Setup()`) actually correct?**
  _`requestReset()` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `bump_minor_version.sh script`, `Bug Report Template`, `Steam Workshop Description` to the rest of the system?**
  _20 weakly-connected nodes found - possible documentation gaps or missing edges._