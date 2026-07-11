local fonts = import '../../Constants/Fonts.libsonnet';
local numT9Buttons = import '../../Buttons/LayoutNumericT9.libsonnet';
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

// T9 數字佈局：4 列 × 5 行
// + | 1 2 3 | =
// - | 4 5 6 | 中
// * | 7 8 9 | ⌫
// / | , 0 . | ⏎
local numericT9KeyboardLayout = {
  keyboardLayout: [
    {
      HStack: {
        subviews: [
          { Cell: numT9Buttons.numPlusButton.name },
          { Cell: numT9Buttons.numOneButton.name },
          { Cell: numT9Buttons.numTwoButton.name },
          { Cell: numT9Buttons.numThreeButton.name },
          { Cell: numT9Buttons.numEqualButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: numT9Buttons.numMinusButton.name },
          { Cell: numT9Buttons.numFourButton.name },
          { Cell: numT9Buttons.numFiveButton.name },
          { Cell: numT9Buttons.numSixButton.name },
          { Cell: numT9Buttons.zhuyinSwitchButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: numT9Buttons.numMultiplyButton.name },
          { Cell: numT9Buttons.numSevenButton.name },
          { Cell: numT9Buttons.numEightButton.name },
          { Cell: numT9Buttons.numNineButton.name },
          { Cell: commonButtons.backspaceButton.name },
        ],
      },
    },
    {
      HStack: {
        subviews: [
          { Cell: numT9Buttons.numSlashButton.name },
          { Cell: numT9Buttons.numCommaButton.name },
          { Cell: numT9Buttons.numZeroButton.name },
          { Cell: numT9Buttons.numDotButton.name },
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

  + numericT9KeyboardLayout

  // 數字鍵（中間九宮格）
  + std.foldl(
    function(acc, button) acc +
      basicStyle.newAlphabeticButton(
        button.name,
        isDark,
        mainKeySize + {
          fontSize: fonts.numericButtonTextFontSize,
        } + button.params,
        needHint=false,
      ),
    numT9Buttons.numberButtons,
    {})

  // 左側欄運算符
  + std.foldl(
    function(acc, button) acc +
      basicStyle.newSystemButton(
        button.name,
        isDark,
        sideKeySize + {
          fontSize: fonts.numericButtonTextFontSize,
        } + button.params,
      ),
    numT9Buttons.operatorButtons,
    {})

  // 右側欄功能鍵
  + basicStyle.newSystemButton(
    numT9Buttons.numEqualButton.name,
    isDark,
    sideKeySize + numT9Buttons.numEqualButton.params,
  )

  + basicStyle.newSystemButton(
    numT9Buttons.zhuyinSwitchButton.name,
    isDark,
    sideKeySize + numT9Buttons.zhuyinSwitchButton.params,
  )

  + basicStyle.newSystemButton(
    commonButtons.backspaceButton.name,
    isDark,
    sideKeySize + commonButtons.backspaceButton.params,
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
    + toolbar.new(isDark, isPortrait, 'numeric')
    + basicStyle.newKeyboardBackgroundStyle(isDark)
    + basicStyle.newAlphabeticButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newSystemButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newColorButtonBackgroundStyle(isDark, extraParams)
    + basicStyle.newAlphabeticHintBackgroundStyle(isDark, { cornerRadius: 10 })
    + basicStyle.newLongPressSymbolsBackgroundStyle(isDark, extraParams)
    + basicStyle.newLongPressSymbolsSelectedBackgroundStyle(isDark, extraParams)
    + basicStyle.newButtonAnimation()
    + newKeyLayout(isDark, isPortrait, extraParams)
}
