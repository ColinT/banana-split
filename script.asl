// Version 1.1.0

// #region states
state("project64", "v1.6") {
  int offset: "Project64.exe", 0xD6A1C;
  int numObjects: "Project64.exe", 0xD6A1C, 0x33D270;

  byte stars: "Project64.exe", 0xD6A1C, 0x33B218;
  byte level: "Project64.exe", 0xD6A1C, 0x32DDFA;
  byte music: "Project64.exe", 0xD6A1C, 0x22261E;
  byte file: "Project64.exe", 0xD6A1C, 0x32DDF6;
  int marioAction: "Project64.exe", 0xD6A1C, 0x33B17C;
  int time: "Project64.exe", 0xD6A1C, 0x32D580;

  // tracks cap buttons and key grabs
  byte flags: "Project64.exe", 0xD6A1C, 0x207708;

  ushort button: "Project64.exe", 0xD6A1C, 0x33AFA0;

  // position of the hand cursor during File Select
  ushort handPosX: "Project64.exe", 0xD6A1C, 0x213892;
  ushort handPosY: "Project64.exe", 0xD6A1C, 0x213890;
}

state("project64", "v2.2") {
  int offset: "RSP.dll", 0x394A8;
  int numObjects: "RSP.dll", 0x394A8, 0x33D270;

  byte stars: "RSP.dll", 0x394A8, 0x33B218;
  byte level: "RSP.dll", 0x394A8, 0x32DDFA;
  byte music: "RSP.dll", 0x394A8, 0x22261E;
  byte file: "RSP.dll", 0x394A8, 0x32DDF6;
  int marioAction: "RSP.dll", 0x394A8, 0x33B17C;
  int time: "RSP.dll", 0x394A8, 0x32D580;

  // tracks cap buttons and key grabs
  byte flags: "RSP.dll", 0x394A8, 0x207708;

  ushort button: "RSP.dll", 0x394A8, 0x33AFA0;

  // position of the hand cursor during File Select
  ushort handPosX: "RSP.dll", 0x394A8, 0x213812;
  ushort handPosY: "RSP.dll", 0x394A8, 0x213810;
}

state("project64", "v2.3") {
  int offset: "RSP 1.7.dll", 0x44B5C;
  int numObjects: "RSP 1.7.dll", 0x44B5C, 0x33D270;

  byte stars: "RSP 1.7.dll", 0x44B5C, 0x33B218;
  byte level: "RSP 1.7.dll", 0x44B5C, 0x32DDFA;
  byte music: "RSP 1.7.dll", 0x44B5C, 0x22261E;
  byte file: "RSP 1.7.dll", 0x44B5C, 0x32DDF6;
  int marioAction: "RSP 1.7.dll", 0x44B5C, 0x33B17C;
  int time: "RSP 1.7.dll", 0x44B5C, 0x32D580;

  // tracks cap buttons and key grabs
  byte flags: "RSP 1.7.dll", 0x44B5C, 0x207708;

  ushort button: "RSP 1.7.dll", 0x44B5C, 0x33AFA0;

  // position of the hand cursor during File Select
  ushort handPosX: "RSP 1.7.dll", 0x44B5C, 0x213812;
  ushort handPosY: "RSP 1.7.dll", 0x44B5C, 0x213810;
}
// #endregion states

// #region init
init {
  refreshRate = 30;
  int baseOffset = 0;
  switch(modules.First().ModuleMemorySize) {
    case 1392640:
      version = "v1.6";
      baseOffset = current.offset;
      break;
    case 1425408:
      version = "v2.2";
      baseOffset = 0x52B40000;
      break;
    case 1417216:
      version = "v2.3";
      baseOffset = 0;
      break;
  }

  // #region functions
  vars.functions = new ExpandoObject();

  Func<int, uint> segmentedToVirtual = (segmentedAddress) => {
    int segmentedTableAddress = baseOffset + 0x33B400;
    byte segment = (byte)(segmentedAddress >> 24);
    int offset = segmentedAddress & 0x00FFFFFF;
    int segmentBaseAddress = memory.ReadValue<int>((IntPtr)(segmentedTableAddress + (4 * segment))); // 4 bytes per segment address
    return ((uint)(segmentBaseAddress + offset) | (uint)0x80000000);
  };
  vars.functions.segmentedToVirtual = segmentedToVirtual;

  Func<int, int, int> findObjectWithBehavior = (behaviorSegmentedAddress, numMaxObjects) => {
    uint behaviorVirtualAddress = vars.functions.segmentedToVirtual(behaviorSegmentedAddress);

    int OBJECT_TABLE_ADDRESS = 0x33D488;
    int firstObjectAddress = baseOffset + OBJECT_TABLE_ADDRESS;
    int numScannedObjects = 1;
    int currentObjectAddress = firstObjectAddress;
    int nextObjectAddress = memory.ReadValue<int>((IntPtr)(currentObjectAddress + 0x060));

    while (numScannedObjects < numMaxObjects) {
      uint oBehavior = memory.ReadValue<uint>((IntPtr)currentObjectAddress + 0x20C);
      if (oBehavior == behaviorVirtualAddress) {
        return currentObjectAddress;
      }

      currentObjectAddress = baseOffset + (int)((uint)nextObjectAddress - 0x80000000);
      nextObjectAddress = memory.ReadValue<int>((IntPtr)(currentObjectAddress + 0x060));
      numScannedObjects++;
    }
    return 0;
  };
  vars.functions.findObjectWithBehavior = findObjectWithBehavior;
  // #endregion functions
}
// #endregion init

// #region startup
startup {
  Action<string, bool, string, string> addSettingWithTooltip = (key, defaultValue, name, tooltip) => {
    settings.Add(key, defaultValue, name);
    settings.SetToolTip(key, tooltip);
  };

  Action<string, bool, string, string, string> addChildSettingWithTooltip = (key, defaultValue, name, tooltip, parentKey) => {
    settings.Add(key, defaultValue, name, parentKey);
    settings.SetToolTip(key, tooltip);
  };

  // #region settings
  vars.settings = new ExpandoObject();

  vars.settings.SPLIT_ON_TOTAL_STARS = "SplitOnTotalStars";
  addSettingWithTooltip(vars.settings.SPLIT_ON_TOTAL_STARS, false, "Specify total stars in each split", "Not recommended for co-op");

  vars.settings.SPLIT_ON_BUTTON_PRESSES = "SplitOnButtonPresses";
  addSettingWithTooltip(vars.settings.SPLIT_ON_BUTTON_PRESSES, false, "Cap Stage Buttons will force a split", "Splits on next area transition after a button press");
  
  vars.settings.SPLIT_ON_GRAND_STAR = "SplitOnGrandStar";
  addSettingWithTooltip(vars.settings.SPLIT_ON_GRAND_STAR, false, "Split on Grand Star dance", "Not recommended for co-op");

  vars.settings.SPLIT_ON_BOWSER_3_DEFEATED = "SplitOnBowser3Defeated";
  addSettingWithTooltip(vars.settings.SPLIT_ON_BOWSER_3_DEFEATED, false, "Split on final Bowser defeated", "For use in rom hacks that warp out of the final fight after Bowser");

  vars.settings.SPLIT_WITHOUT_FIGHTING_BOWSER = "SplitWithoutFightingBowser";
  addSettingWithTooltip(vars.settings.SPLIT_WITHOUT_FIGHTING_BOWSER, false, "Split without fighting bowser", "For use in rom hacks that do not have a separate Bowser fight area in Bowser stages");

  vars.settings.DISABLE_START_ON_RESET = "DisableStartOnReset";
  addSettingWithTooltip(vars.settings.DISABLE_START_ON_RESET, false, "Disable starting the timer when the emulator starts", "For use in rom hacks that start timing on File Select");

  vars.settings.DISABLE_START_ON_FILE_D = "DisableStartOnFileD";
  addChildSettingWithTooltip(vars.settings.DISABLE_START_ON_FILE_D, false, "Disable starting the timer when selecting File D", "Enable this to practice on File D", vars.settings.DISABLE_START_ON_RESET);

  vars.settings.ENABLE_STAGE_RTA_MODE = "EnableStageRtaMode";
  addSettingWithTooltip(vars.settings.ENABLE_STAGE_RTA_MODE, false, "Enable stage RTA mode", "Starts timer on star select and splits on star touch for the last split");

  vars.settings.START_SPLITS_ON_LEVEL_TRANSITION = "StartSplitsOnLevelTransition";
  addChildSettingWithTooltip(vars.settings.START_SPLITS_ON_LEVEL_TRANSITION, false, "Start timer on level transition instead of star select", "For use in stages without a star select screen", vars.settings.ENABLE_STAGE_RTA_MODE);

  vars.settings.ENABLE_SPLIT_ON_STAR_GRAB = "EnableSplitOnStarGrab";
  addSettingWithTooltip(vars.settings.ENABLE_SPLIT_ON_STAR_GRAB, false, "Enable split on star grab", "Split on star grab instead of level transition");

  vars.settings.DISABLE_RESET_ON_MARKED_SPLITS = "DisableResetOnMarkedSplits";
  addSettingWithTooltip(vars.settings.DISABLE_RESET_ON_MARKED_SPLITS, false, "Disable timer reset on splits that contain the word 'reset'", "Case insensitive");
  // #endregion settings

  // #region regexes
  vars.regexes = new ExpandoObject();

  vars.regexes.REGEX_RESET = new System.Text.RegularExpressions.Regex(@"\breset\b");
  // #endregion regexes

  vars.isSplittingOnLevelChange = false;
  vars.starsCollectedInSplit = 0;
  vars.numberInSplit = -1;
  vars.lastSplitIndex = 0;
  vars.finalBowserAddress = 0;
  vars.starSelectorAddress = 0;
}
// #endregion startup

// #region update
update {
  if (timer.CurrentPhase == TimerPhase.NotRunning) {
    vars.isSplittingOnLevelChange = false; 
    vars.starsCollectedInSplit = 0;
    vars.numberInSplit = -1;
    vars.lastSplitIndex = 0;
    vars.finalBowserAddress = 0;
  }
}
// #endregion update

// #region start
start {
  if (settings[vars.settings.ENABLE_STAGE_RTA_MODE]) {
    if (settings[vars.settings.START_SPLITS_ON_LEVEL_TRANSITION]) {
      return current.level != old.level;
    } else if (current.music == 13) { // star select screen music
      // search for star selector object to be completely sure we are on the star select screen
      if (vars.starSelectorAddress == 0) {
        int STAR_SELECTOR_BEHAVIOR_SEGMENTED_ADDRESS = 0x1300302C;
        vars.starSelectorAddress = vars.functions.findObjectWithBehavior(STAR_SELECTOR_BEHAVIOR_SEGMENTED_ADDRESS, current.numObjects);
      } else {
        if (current.level != old.level) { // player loaded a state or reset the emulator
          vars.starSelectorAddress = 0;
          return false;
        }
        bool isSelectButtonPressed = (current.button & 0xD000) - (old.button & 0xD000) > 0;
        if (isSelectButtonPressed) {
          vars.starSelectorAddress = 0;
          return true;
        } else {
          return false;
        }
      }
    }
  } else if (settings[vars.settings.DISABLE_START_ON_RESET]) {
    // look for a button press of A, B or Start while the file select music is playing with the select hand over Files
    bool isSelectButtonPressed = (current.button & 0xD000) - (old.button & 0xD000) > 0;
    bool isFileSelectMusicPlaying = current.music == 33;

    if (isSelectButtonPressed && isFileSelectMusicPlaying) {
      int LEFT_LOWER_BOUND = 34;
      int LEFT_UPPER_BOUND = 82;

      int RIGHT_LOWER_BOUND = 153;
      int RIGHT_UPPER_BOUND = 201;

      int TOP_LOWER_BOUND = 117;
      int TOP_UPPER_BOUND = 157;

      int BOTTOM_LOWER_BOUND = 75;
      int BOTTOM_UPPER_BOUND = 115;

      bool isCursorOnFileA =
        current.handPosX >= LEFT_LOWER_BOUND && 
        current.handPosX <= LEFT_UPPER_BOUND &&
        current.handPosY >= TOP_LOWER_BOUND &&
        current.handPosY <= TOP_UPPER_BOUND;

      bool isCursorOnFileB =
        current.handPosX >= RIGHT_LOWER_BOUND && 
        current.handPosX <= RIGHT_UPPER_BOUND &&
        current.handPosY >= TOP_LOWER_BOUND &&
        current.handPosY <= TOP_UPPER_BOUND;

      bool isCursorOnFileC =
        current.handPosX >= LEFT_LOWER_BOUND && 
        current.handPosX <= LEFT_UPPER_BOUND &&
        current.handPosY >= BOTTOM_LOWER_BOUND &&
        current.handPosY <= BOTTOM_UPPER_BOUND;

      bool isCursorOnFileD =
        current.handPosX >= RIGHT_LOWER_BOUND && 
        current.handPosX <= RIGHT_UPPER_BOUND &&
        current.handPosY >= BOTTOM_LOWER_BOUND &&
        current.handPosY <= BOTTOM_UPPER_BOUND;

      return (
        isCursorOnFileA ||
        isCursorOnFileB ||
        isCursorOnFileC ||
        (isCursorOnFileD && !settings[vars.settings.DISABLE_START_ON_FILE_D])
      );
    } else {
      return false;
    }
  } else {
    return current.level == 1 && old.time > current.time;
  }
}
// #endregion start

// #region reset
reset {
  // only way to decrease time is load state or reset emulator
  if (current.time < old.time) {
    if (settings[vars.settings.DISABLE_RESET_ON_MARKED_SPLITS]) {
      // Check if the current split has the word 'reset'
      System.Text.RegularExpressions.MatchCollection matches = vars.regexes.REGEX_RESET.Matches(timer.CurrentSplit.Name);
      return matches.Count == 0;
    } else {
      return true;
    }
  }
}
// #endregion reset

// #region split
split {
  // check for a skipped split
  if (vars.lastSplitIndex != timer.CurrentSplitIndex) {
    // reset all split variables
    vars.isSplittingOnLevelChange = false;
    vars.starsCollectedInSplit = 0;
    vars.numberInSplit = -1;
    vars.lastSplitIndex = timer.CurrentSplitIndex;
    return false;
  }

  Action<bool> addSplitCondition = (condition) => {
    if (!vars.isSplittingOnLevelChange) {
      vars.isSplittingOnLevelChange = condition;
    }
  };

  // if final bowser is defeated, split on next level transition
  if (settings[vars.settings.SPLIT_ON_BOWSER_3_DEFEATED]) {
    int LEVEL_BOWSER_3_FIGHT = 34;
    if (current.level == LEVEL_BOWSER_3_FIGHT && !vars.isSplittingOnLevelChange) {

      // search for bowser
      if (vars.finalBowserAddress == 0) { // final bowser has not been found yet
        int BOWSER_BEHAVIOR_SEGMENTED_ADDRESS = 0x13001850;
        vars.finalBowserAddress = vars.functions.findObjectWithBehavior(BOWSER_BEHAVIOR_SEGMENTED_ADDRESS, current.numObjects);
      } else { // final bowser has been found, check his actions to determine when he is defeated
        int oAction = memory.ReadValue<int>((IntPtr)(vars.finalBowserAddress + 0x14C));
        int oSubAction = memory.ReadValue<int>((IntPtr)(vars.finalBowserAddress + 0x150));
        addSplitCondition(oAction == 4 && oSubAction == 11); // final bowser was defeated
      }
    } else {
      vars.finalBowserAddress = 0;
    }
  }

  // obtain the number in the split name reading from left to right
  if (vars.numberInSplit < 0) {
    char[] separators = {'(', ')', '[', ']', ':', ' '};
    String[] splitNameArray = timer.CurrentSplit.Name.Split(separators, StringSplitOptions.RemoveEmptyEntries);

    int tempStarCount = -1;
    foreach(String word in splitNameArray) {
      if (Int32.TryParse(word, out tempStarCount)) {
        vars.numberInSplit = tempStarCount;
        break;
      }
    }
  }

  // check if the player is in a star dance action
  int ACTION_STAR_DANCE_EXIT = 0x1302;
  int ACTION_STAR_DANCE_UNDERWATER = 0x1303;
  int ACTION_STAR_DANCE_NO_EXIT = 0x1307;
  int ACTION_FALL_AFTER_STAR_GRAB = 0x1904;
  int[] starGrabActions = { ACTION_STAR_DANCE_EXIT, ACTION_STAR_DANCE_UNDERWATER, ACTION_STAR_DANCE_NO_EXIT, ACTION_FALL_AFTER_STAR_GRAB };
  bool isInStarDanceAction = Array.Exists(starGrabActions, (action) => action == current.marioAction && current.marioAction != old.marioAction && old.marioAction != ACTION_FALL_AFTER_STAR_GRAB);

  // check splitting on star grab conditions
  if (vars.numberInSplit >= 0) { // there is a number in the current split
    if (settings[vars.settings.SPLIT_ON_TOTAL_STARS] && !settings[vars.settings.ENABLE_STAGE_RTA_MODE]) { // splitting on total stars
      if (current.stars != old.stars) {
        addSplitCondition(current.stars >= vars.numberInSplit);
      }
    } else { // not splitting on total stars
      if (isInStarDanceAction) {
        vars.starsCollectedInSplit++;
        addSplitCondition(vars.starsCollectedInSplit >= vars.numberInSplit);
      }
    }
  }
  
  if (isInStarDanceAction) { // star grab occured
    if (settings[vars.settings.ENABLE_STAGE_RTA_MODE] && timer.Run.Count - 1 == timer.CurrentSplitIndex && vars.isSplittingOnLevelChange) { // on the last split of stage RTA mode, split
      return true;
    } else if (settings[vars.settings.ENABLE_SPLIT_ON_STAR_GRAB] && vars.isSplittingOnLevelChange) { // split on star grab is enabled, skip waiting for level transition
      vars.isSplittingOnLevelChange = false;
      vars.starsCollectedInSplit = 0;
      vars.numberInSplit = -1;
      vars.lastSplitIndex++;
      return true;
    }
  }
  
  // check if the player is in a bowser stage
  int LEVEL_DARK_WORLD = 17;
  int LEVEL_FIRE_SEA = 19;
  int LEVEL_BITS = 21;
  int[] bowserStages = { LEVEL_DARK_WORLD, LEVEL_FIRE_SEA, LEVEL_BITS };
  bool isInBowserStage = Array.Exists(bowserStages, (stage) => stage == old.level || stage == current.level);

  // check splitting on flags being activated
  int FLAG_WING_CAP_SWITCH = 2;
  int FLAG_METAL_CAP_SWITCH = 4;
  int FLAG_VANISH_CAP_SWITCH = 8;
  int FLAG_KEY_1 = 16;
  int FLAG_KEY_2 = 32;
  int LEVEL_WING_CAP = 29;
  int LEVEL_METAL_CAP = 28;
  int LEVEL_VANISH_CAP = 18;
  int LEVEL_BOWSER_1_FIGHT = 30;
  int LEVEL_BOWSER_2_FIGHT = 33;
  int changedFlag = current.flags - old.flags;
  bool isButtonOrKeyFlagged =
    current.flags != old.flags &&
    changedFlag >= FLAG_WING_CAP_SWITCH &&
    changedFlag <= FLAG_KEY_2;

  if (isButtonOrKeyFlagged) {
    if (settings[vars.settings.SPLIT_ON_BUTTON_PRESSES]) {
      addSplitCondition(changedFlag == FLAG_WING_CAP_SWITCH && current.level == LEVEL_WING_CAP);
      addSplitCondition(changedFlag == FLAG_METAL_CAP_SWITCH && current.level == LEVEL_METAL_CAP);
      addSplitCondition(changedFlag == FLAG_VANISH_CAP_SWITCH && current.level == LEVEL_VANISH_CAP);
    }
    addSplitCondition(changedFlag == FLAG_KEY_1 && current.level == LEVEL_BOWSER_1_FIGHT);
    addSplitCondition(changedFlag == FLAG_KEY_2 && current.level == LEVEL_BOWSER_2_FIGHT);
  }

  if (current.level != old.level || isButtonOrKeyFlagged) {
    print("will split: " + vars.isSplittingOnLevelChange.ToString() + "\nStar Dances Counted: " + vars.starsCollectedInSplit.ToString() + "\nNumber of stars: " + current.stars.ToString() + "\nNumber in split: " + vars.numberInSplit.ToString() + "\nLast split index: " + vars.lastSplitIndex.ToString() + "\nFlags Value: " + (current.flags - old.flags).ToString());
  }

  if (
    vars.isSplittingOnLevelChange && // if split conditions have been made
    current.level != old.level &&    // a level transistion has been made
    !(!settings[vars.settings.SPLIT_WITHOUT_FIGHTING_BOWSER] && isInBowserStage) // the player is not in a bowser stage (or has explicitly allowed splitting when in bowser stages)
  ) {
    // set up a split and reset counters for the next split
    vars.isSplittingOnLevelChange = false;
    vars.starsCollectedInSplit = 0;
    vars.numberInSplit = -1;
    vars.lastSplitIndex++;
    return true;
  }

  // split on explicit level entry split
  if (timer.CurrentSplit.Name.ToLower().IndexOf("enter") != -1) {
    return current.level != old.level && current.level == vars.numberInSplit;
  }

  // split on Grand Star dance if enabled
  int ACTION_GRAND_STAR_DANCE = 0x1909;
  if (settings[vars.settings.SPLIT_ON_GRAND_STAR]) {
    return current.marioAction == ACTION_GRAND_STAR_DANCE;
  }
}
// #endregion split
