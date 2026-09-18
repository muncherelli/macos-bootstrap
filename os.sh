#!/bin/bash
# macOS 27 Golden Gate system defaults. Applied from playbook.yml via ./update.sh.

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Appearance (macOS Golden Gate 27): Liquid Glass → fully tinted.
# System Settings → Appearance → Liquid Glass is a slider (ultra-clear → tinted).
# NSGlassTintAmount is 0.0 (clear) … 1.0 (fully tinted). NSGlassDiffusionSetting is
# the older Tahoe boolean (true = Tinted); keep it so both code paths agree.
defaults write NSGlobalDomain NSGlassTintAmount -float 1
defaults write NSGlobalDomain NSGlassEverEditedInSettings -bool true
defaults write NSGlobalDomain NSGlassDiffusionSetting -bool true

# Appearance (macOS Tahoe+ / Golden Gate): Icon & widget style → Dark (Always).
# Values: RegularAutomatic, RegularLight, RegularDark, Clear*, Tinted*.
defaults write NSGlobalDomain AppleIconAppearanceTheme -string RegularDark

# Notify running UI that icon / glass appearance changed (Dock picks this up after killall too).
osascript -l JavaScript -e '
ObjC.import("Foundation");
var nc = $.NSDistributedNotificationCenter.defaultCenter;
nc.postNotificationNameObjectUserInfoDeliverImmediately(
  $("AppleIconAppearanceThemeChangedNotification"), null, null, true);
nc.postNotificationNameObjectUserInfoDeliverImmediately(
  $("AppleInterfaceThemeChangedNotification"), null, null, true);
nc.postNotificationNameObjectUserInfoDeliverImmediately(
  $("NSGlassEffectDiffusionDidChangeNotification"), null, null, true);
' >/dev/null 2>&1 || true

# expand save panel by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# save to disk (not to iCloud) by default
# defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# automatically quit printer app once the print jobs complete
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# Menu bar clock: time only (no weekday, no date). ShowDate 2 = Never (macOS 12.4+).
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool false
defaults write com.apple.menuextra.clock ShowDate -int 2

# # ###############################################################################
# # # Screen                                                                      #
# # ###############################################################################

# # Save screenshots to Downloads folder.
# defaults write com.apple.screencapture location -string "${HOME}/Downloads"

# # # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
# defaults write com.apple.screencapture type -string "png"

# TO-DO: change the lock screen timeout to 180 minutes (max)

# # ###############################################################################
# # # Finder                                                                      #
# # ###############################################################################

# Finder writes its in-memory prefs back on quit, which can clobber `defaults write`.
# Stop it first so the keys below actually stick on Golden Gate.
osascript -e 'tell application "Finder" to quit' 2>/dev/null || killall Finder 2>/dev/null || true
sleep 1

# Finder: new windows open in your home directory (General → "New Finder windows show").
defaults write com.apple.finder NewWindowTarget -string PfLo
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}"

# Finder: show hidden files by default (Finder Settings → Advanced).
defaults write com.apple.finder AppleShowAllFiles -bool true

# finder: show all filename extensions
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# finder: show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# finder: do not show external disks on the desktop (Finder Settings → General)
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false

# # Avoid creating .DS_Store files on network volumes
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Finder: default view for folders without a saved per-folder style (List = Nlsv).
# Other codes: icnv icon, clmv column, glyv gallery, Flwv (legacy cover flow).
# FXPreferredSearchViewStyle covers Spotlight-in-Finder / search windows.
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder FXPreferredSearchViewStyle -string Nlsv

# show the ~/Library folder because we aren't nubs
chflags nohidden ~/Library

# disable single click desktop to hide all windows and show desktop only in Stage Manager.
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

# disable desktop widgets (System Settings → Desktop & Dock → Show Widgets → On Desktop).
# WindowManager is the Sonoma+ key; Dock's show-desktop-widgets is what Desktop Settings writes.
defaults write com.apple.WindowManager StandardHideWidgets -bool true
defaults write com.apple.dock show-desktop-widgets -bool false

# # ###############################################################################
# # # Mouse, Keyboard, Trackpad, and Input                                        #
# # ###############################################################################

# Enable three-finger drag (Accessibility-style dragging; built-in + Magic Trackpad).
# Same toggles as System Settings → Accessibility → Pointer Control → Trackpad Options.
# May require logging out and back in for the trackpad to pick it up.
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Tap to click (built-in + Magic Trackpad; matches Trackpad settings).
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Spelling and grammar (Edit → Spelling and Grammar): disable all three toggles for new documents / default text views.
# - Check Spelling While Typing
# - Check Grammar With Spelling
# - Correct Spelling Automatically (also mirrored in System Settings → Keyboard → Text Input)
defaults write NSGlobalDomain NSAllowContinuousSpellChecking -bool false
defaults write NSGlobalDomain NSGrammarCheckingEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Keyboard text substitution: capitalization (separate from the Spelling and Grammar menu).
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# # ###############################################################################
# # # Spotlight                                                                   #
# # ###############################################################################

# Spotlight → Apps only (System Settings → Spotlight).
# Golden Gate still stores disabled result sources in EnabledPreferenceRules (a
# denylist despite the name). Items absent from the list stay on — so Apps is
# left out on purpose.
# Custom.relatedContents = "Show Related Content". System.* = Results from System
# (except Apps). Golden Gate adds clipboard history, documents, and oneness
# (iPhone / Continuity) apps. Bundle IDs = Results from Apps toggles.
defaults write com.apple.Spotlight EnabledPreferenceRules -array \
  "Custom.relatedContents" \
  "System.files" \
  "System.folders" \
  "System.documents" \
  "System.clipboardHistory" \
  "System.onenessApps" \
  "System.iphoneApps" \
  "System.menuItems" \
  "com.apple.AppStore" \
  "com.apple.iBooksX" \
  "com.apple.calculator" \
  "com.apple.iCal" \
  "com.apple.AddressBook" \
  "com.apple.Dictionary" \
  "com.apple.mail" \
  "com.apple.MobileSMS" \
  "com.apple.Notes" \
  "com.apple.mobilephone" \
  "com.apple.Photos" \
  "com.apple.podcasts" \
  "com.apple.reminders" \
  "com.apple.Safari" \
  "com.apple.shortcuts" \
  "com.apple.systempreferences" \
  "com.apple.tips" \
  "com.apple.VoiceMemos"

# Classic orderedItems API (legacy Spotlight plumbing): APPLICATIONS only.
defaults write com.apple.Spotlight orderedItems -array \
  '{"enabled" = 1;"name" = "APPLICATIONS";}' \
  '{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
  '{"enabled" = 0;"name" = "CONTACT";}' \
  '{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
  '{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
  '{"enabled" = 0;"name" = "DOCUMENTS";}' \
  '{"enabled" = 0;"name" = "EVENT_TODO";}' \
  '{"enabled" = 0;"name" = "DIRECTORIES";}' \
  '{"enabled" = 0;"name" = "FONTS";}' \
  '{"enabled" = 0;"name" = "IMAGES";}' \
  '{"enabled" = 0;"name" = "MESSAGES";}' \
  '{"enabled" = 0;"name" = "EMAIL";}' \
  '{"enabled" = 0;"name" = "MOVIES";}' \
  '{"enabled" = 0;"name" = "MUSIC";}' \
  '{"enabled" = 0;"name" = "MENU_OTHER";}' \
  '{"enabled" = 0;"name" = "PDF";}' \
  '{"enabled" = 0;"name" = "PRESENTATIONS";}' \
  '{"enabled" = 0;"name" = "SPREADSHEETS";}' \
  '{"enabled" = 0;"name" = "SYSTEM_PREFS";}' \
  '{"enabled" = 0;"name" = "BOOKMARKS";}' \
  '{"enabled" = 0;"name" = "SOURCE";}' \
  '{"enabled" = 0;"name" = "TIPS";}' \
  '{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
  '{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'

# # ###############################################################################
# # # Dock, Menu, Dashboard, and hot corners                                      #
# # ###############################################################################

# disable Recently Used Applications in Dock
defaults write com.apple.dock "show-recents" -bool "false"

# Hot corners: disable all (0 = no action; bottom-right defaults to Quick Note otherwise).
for corner in tl tr bl br; do
  defaults write com.apple.dock "wvous-${corner}-corner" -int 0
  defaults write com.apple.dock "wvous-${corner}-modifier" -int 0
done

# # ###############################################################################
# # # Safari                                                                      #
# # ###############################################################################

# Safari is sandboxed: it reads prefs from the container plist. A bare `defaults write`
# often updates ~/Library/Preferences only (ignored by Safari) unless Terminal has
# Full Disk Access. We mirror into the container file when it exists, and do a one-time
# launch if Safari has never run (so that plist exists).
safari_container_plist="${HOME}/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari.plist"

osascript -e 'quit app "Safari"' 2>/dev/null || true
sleep 1

# -e (exists) not -f: without Full Disk Access, -f / PlistBuddy can miss the
# container file and PlistBuddy will create an empty decoy plist.
if [[ ! -e "$safari_container_plist" ]]; then
  open -gj -a Safari 2>/dev/null || true
  sleep 3
  osascript -e 'quit app "Safari"' 2>/dev/null || true
  sleep 1
fi

# POSIX -r/-w can pass while TCC still blocks the open(2). Probe with a real write.
safari_container_writable=false
if defaults write "$safari_container_plist" IncludeDevelopMenu -bool true 2>/dev/null; then
  safari_container_writable=true
else
  echo "Safari container prefs are not writable. Grant Terminal Full Disk Access and re-run to apply Safari settings." >&2
fi

safari_set_bool() {
  local key=$1 val=$2
  if [[ "$safari_container_writable" == true ]]; then
    # Golden Gate routes the com.apple.Safari domain into this container file.
    defaults write "$safari_container_plist" "$key" -bool "$val"
  else
    # Host-domain write is redirected to the container too, and fails without FDA.
    defaults write com.apple.Safari "$key" -bool "$val" 2>/dev/null || true
  fi
}

# General → disable "Open safe files after downloading".
safari_set_bool AutoOpenSafeDownloads false

# AutoFill → turn off all automatic fill categories.
safari_set_bool AutoFillFromAddressBook false
safari_set_bool AutoFillPasswords false
safari_set_bool AutoFillCreditCardData false
safari_set_bool AutoFillMiscellaneousForms false

# Advanced → "Show features for web developers" (Develop menu in the menu bar).
# Safari 15+ needs both the main domain and SandboxBroker; see Apple Stack Exchange #429814.
safari_set_bool IncludeDevelopMenu true
defaults write com.apple.Safari.SandboxBroker ShowDevelopMenu -bool true

# Advanced → Smart Search Field → "Show full website address".
safari_set_bool ShowFullURLInSmartSearchField true

unset -f safari_set_bool

# # ###############################################################################
# # # Login Items                                                                 #
# # ###############################################################################

# Open Displaperture at login (System Settings → General → Login Items).
# Idempotent: skip if the app is missing or already listed.
if [[ -d "/Applications/Displaperture.app" ]]; then
  osascript <<'EOF' 2>/dev/null || true
tell application "System Events"
  if not (exists login item "Displaperture") then
    make login item at end with properties {path:"/Applications/Displaperture.app", hidden:false}
  end if
end tell
EOF
fi

# Flush cached prefs so UI processes relaunch against the values we just wrote.
killall cfprefsd 2>/dev/null || true

# SIGKILL so Finder cannot flush stale in-memory view settings over our writes.
killall -9 Finder 2>/dev/null || true

# reload dock
killall Dock 2>/dev/null || true

# apply menu bar clock prefs (Ventura+)
killall ControlCenter 2>/dev/null || true

# apply desktop widget prefs (Sonoma+)
killall WindowManager 2>/dev/null || true

# apply Spotlight search-result category prefs (mds + Golden Gate Spotlight UI)
killall mds 2>/dev/null || true
killall Spotlight 2>/dev/null || true
