# Banana Split
A SM64 and Rom Hack autosplitter for LiveSplit.

Version 1.1.1.

# 1. Introduction
Original concept and base work by [Bored Banana](https://twitch.tv/bored_banana).

Currently maintained by:
 - [ColinT](https://github.com/ColinT)

# 2. Features
 - Automatically start timer when emulator starts, or on file selection.
 - Optionally disable starting on file D.
 - Split on total number of stars or split on number of stars collected per split.
 - Split on grand star dance (vanilla).
 - Split on next level transition after defeating bowser 3 (e.g.: Super Mario Star Road, Another Mario Adventure).
 - Split on boss stages that do not have separate boss areas (e.g.: Cursed Castles).
 - Split on next level transition after a cap switch press.
 - Stage RTA timer (starts on star select or level entry, last split ends on star grab).
 - Split on star grab instead of level transition for non-stop splits (e.g.: Star Revenge 0 Stage RTA).
 - Disable timer reset on splits containing the word 'reset'.

# 3. Usage

1. Open LiveSplit and right click to open the context menu
2. Go to: "Edit Layout" > "+" > "Control" > "Scriptable Auto Splitter"
3. Click "Layout Settings"
4. Go to the "Scriptable Auto Splitter" tab
5. Under "Script Path", put the path of the script file, or use "Browse" to find it
6. Click the options you want ("Start", "Split", "Reset", and the other customizations below)
7. Done!
