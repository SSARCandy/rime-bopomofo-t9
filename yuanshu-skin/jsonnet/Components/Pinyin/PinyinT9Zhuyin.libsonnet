local fonts = import '../../Constants/Fonts.libsonnet';
local t9Buttons = import '../../Buttons/LayoutT9Zhuyin.libsonnet';
local commonButtons = import '../../Buttons/Common.libsonnet';
local settings = import '../../Settings.libsonnet';
local basicStyle = import '../../Styles/BasicStyle.libsonnet';
local preedit = import '../Preedit.libsonnet';
local toolbar = import '../Toolbar.libsonnet';
local utils = import '../../Utils/Utils.libsonnet';

// 鍵位寬度：左右欄 0.16，中間三鍵各 0.226
// （與 Hamster v2 版 t9bopomo.yaml 完全相同）
local sideKeySize = { size: { width: { percentage: 0.16 } } };
local mainKeySize = { size: { width: { percentage: 0.226 } } };

// T9 注音佈局：4 列 × 5 行
// ˉ | ㄅㄉㄚ | ㄍㄐㄞ  | ㄓㄗㄢㄦ | =
// ˊ | ㄆㄊㄛ | ㄎㄑㄟ  | ㄔㄘㄣㄧ | 123
// ˇ | ㄇㄋㄜ | ㄏㄒㄠㄡ | ㄕㄙㄤㄨ | ⌫
// ˋ | ㄈㄌㄝ | 空格    | ㄖㄥㄩ  | ⏎
local t9KeyboardLayout = {
  keyboardLayout: [
    {
      HStack: {
        subviews: [
          { Cell: t9Buttons.toneFlatButton.name },
          { Cell: t9Buttons.t9OneButton.name },
          { Cell: t9Buttons.t9TwoButton.name },
          { Cell: t9Buttons.t9ThreeButton.name },
          { Cell: t9Buttons.equalButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: t9Buttons.toneRiseButton.name },
          { Cell: t9Buttons.t9FourButton.name },
          { Cell: t9Buttons.t9FiveButton.name },
          { Cell: t9Buttons.t9SixButton.name },
          { Cell: t9Buttons.numericSwitchButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: t9Buttons.toneDipButton.name },
          { Cell: t9Buttons.t9SevenButton.name },
          { Cell: t9Buttons.t9EightButton.name },
          { Cell: t9Buttons.t9NineButton.name },
          { Cell: t9Buttons.t9BackspaceButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: t9Buttons.toneFallButton.name },
          { Cell: t9Buttons.t9ZeroButton.name },
          { Cell: t9Buttons.t9SpaceButton.name },
          { Cell: t9Buttons.t9VButton.name },
          { Cell: commonButtons.enterButton.name },
        ],
      },
    },
  ],
};

local newKeyLayout(isDark=false, isPortrait=false, extraParams={}) =
  {
    keyboardHeight: if isPortrait then commonButtons.keyboardHeight.portrait else commonButtons.keyboardHeight.landscape,
    keyboardStyle: utils.newBackgroundStyle(style=basicStyle.keyboardBackgroundStyleName),
  }

  + t9KeyboardLayout

  // 聲調鍵（左側欄）
  + std.foldl(
    function(acc, button) acc +
      basicStyle.newAlphabeticButton(
        button.name,
        isDark,
        sideKeySize + {
          fontSize: fonts.standardButtonTextFontSize,
        } + button.params,
        needHint=false,
      ),
    t9Buttons.toneButtons,
    {})

  // 注音鍵（中間九宮格 + v 鍵）
  + std.foldl(
    function(acc, button) acc +
      basicStyle.newAlphabeticButton(
        button.name,
        isDark,
        mainKeySize + {
          fontSize: fonts.t9ButtonTextFontSize,
        } + button.params,
        needHint=false,
      ),
    t9Buttons.t9Buttons,
    {})

  // 空格鍵
  + basicStyle.newAlphabeticButton(
    t9Buttons.t9SpaceButton.name,
    isDark,
    mainKeySize + t9Buttons.t9SpaceButton.params,
    needHint=false,
  )

  // 右側欄功能鍵
  + basicStyle.newSystemButton(
    t9Buttons.equalButton.name,
    isDark,
    sideKeySize + t9Buttons.equalButton.params,
  )

  + basicStyle.newSystemButton(
    t9Buttons.numericSwitchButton.name,
    isDark,
    sideKeySize + t9Buttons.numericSwitchButton.params,
  )

  + basicStyle.newSystemButton(
    t9Buttons.t9BackspaceButton.name,
    isDark,
    sideKeySize + t9Buttons.t9BackspaceButton.params,
  )

  + basicStyle.newColorButton(
    commonButtons.enterButton.name,
    isDark,
    sideKeySize + commonButtons.enterButton.params,
  );

local backgroundInsets = if !settings.iPad then
{
  portrait: { top: 3, left: 4, bottom: 3, right: 4 },
  landscape: { top: 3, left: 3, bottom: 3, right: 3 },
}
else
{
  portrait: { top: 3, left: 3, bottom: 3, right: 3 },
  landscape: { top: 4, left: 6, bottom: 4, right: 6 },
};

{
  new(isDark, isPortrait):
    local insets = if isPortrait then backgroundInsets.portrait else backgroundInsets.landscape;

    local extraParams = {
      insets: insets,
    };

    preedit.new(isDark)
    + toolbar.new(isDark, isPortrait, 'pinyin')
    + basicStyle.newKeyboardBackgroundStyle(isDark)
    + basicStyle.newAlphabeticButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newSystemButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newColorButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newAlphabeticHintBackgroundStyle(isDark, { cornerRadius: 10 })
    + basicStyle.newLongPressSymbolsBackgroundStyle(isDark, extraParams)
    + basicStyle.newLongPressSymbolsSelectedBackgroundStyle(isDark, extraParams)
    + basicStyle.newButtonAnimation()
    + newKeyLayout(isDark, isPortrait, extraParams)
    // Notifications
    + basicStyle.rimeSchemaChangedNotification
}
