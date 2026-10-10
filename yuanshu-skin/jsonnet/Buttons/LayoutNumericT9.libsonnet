# =====================================
# 此文件用於自定義鍵盤按鍵功能。
# 可根據需要修改下方內容，調整各類按鍵的行為
# 修改完成後，保存本文件，然後回到皮膚界面，
# 長按皮膚，選擇「運行 main.jsonnet」生效。
#
# 包含 T9 數字九宮格佈局的按鍵
# （數字與運算符以 sendKeys 送出 keypad 按鍵進 RIME，由
#   user_predict.lua 的 NUMPAD_MAP 上屏：組字/聯想中按下時
#   只會丟棄候選、絕不連帶上屏。KP 鍵不在方案字母表，
#   不會被當成注音碼。）
# =====================================

local commonButtons = import './Common.libsonnet';

{
  local root = self,

  // ===== 數字鍵 =====
  numOneButton:   { name: 'numOneButton',   params: { action: { sendKeys: 'KP_1' }, text: '1' } },
  numTwoButton:   { name: 'numTwoButton',   params: { action: { sendKeys: 'KP_2' }, text: '2' } },
  numThreeButton: { name: 'numThreeButton', params: { action: { sendKeys: 'KP_3' }, text: '3' } },
  numFourButton:  { name: 'numFourButton',  params: { action: { sendKeys: 'KP_4' }, text: '4' } },
  numFiveButton:  { name: 'numFiveButton',  params: { action: { sendKeys: 'KP_5' }, text: '5' } },
  numSixButton:   { name: 'numSixButton',   params: { action: { sendKeys: 'KP_6' }, text: '6' } },
  numSevenButton: { name: 'numSevenButton', params: { action: { sendKeys: 'KP_7' }, text: '7' } },
  numEightButton: { name: 'numEightButton', params: { action: { sendKeys: 'KP_8' }, text: '8' } },
  numNineButton:  { name: 'numNineButton',  params: { action: { sendKeys: 'KP_9' }, text: '9' } },
  numZeroButton:  { name: 'numZeroButton',  params: { action: { sendKeys: 'KP_0' }, text: '0' } },
  numCommaButton: { name: 'numCommaButton', params: { action: { sendKeys: 'KP_Separator' }, text: ',' } },
  numDotButton:   { name: 'numDotButton',   params: { action: { sendKeys: 'KP_Decimal' }, text: '.' } },

  numberButtons: [
    self.numOneButton,
    self.numTwoButton,
    self.numThreeButton,
    self.numFourButton,
    self.numFiveButton,
    self.numSixButton,
    self.numSevenButton,
    self.numEightButton,
    self.numNineButton,
    self.numZeroButton,
    self.numCommaButton,
    self.numDotButton,
  ],

  // ===== 左側欄運算符 =====
  numPlusButton:     { name: 'numPlusButton',     params: { action: { sendKeys: 'KP_Add' },      text: '+' } },
  numMinusButton:    { name: 'numMinusButton',    params: { action: { sendKeys: 'KP_Subtract' }, text: '-' } },
  numMultiplyButton: { name: 'numMultiplyButton', params: { action: { sendKeys: 'KP_Multiply' }, text: '*' } },
  numSlashButton:    { name: 'numSlashButton',    params: { action: { sendKeys: 'KP_Divide' },   text: '/' } },

  operatorButtons: [
    self.numPlusButton,
    self.numMinusButton,
    self.numMultiplyButton,
    self.numSlashButton,
  ],

  // ===== 右側欄功能鍵 =====

  // 等號鍵：長按選其他符號（與注音鍵盤上的等號鍵相同）
  numEqualButton: {
    name: 'numEqualButton',
    params: {
      action: { sendKeys: 'KP_Equal' },
      text: '=',
      # 右緣按鍵：依 v2 視覺順序（> < % ~ $），預設選最右的 $
      # （character 進 RIME，user_predict.lua 的 RAW_SYMBOL_KEYS 攔截上屏）
      longPress: [
        { text: '>', action: { character: '>' } },
        { text: '<', action: { character: '<' } },
        { text: '%', action: { character: '%' } },
        { text: '~', action: { character: '~' } },
        { text: '$', action: { character: '$' }, selected: true },
      ],
    },
  },

  // 返回注音鍵盤
  zhuyinSwitchButton: {
    name: 'zhuyinSwitchButton',
    params: {
      action: { keyboardType: 'pinyin' },
      text: '中',
    },
  },
}
