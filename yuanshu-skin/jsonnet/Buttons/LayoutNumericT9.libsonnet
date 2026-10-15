# =====================================
# 此文件用於自定義鍵盤按鍵功能。
# 可根據需要修改下方內容，調整各類按鍵的行為
# 修改完成後，保存本文件，然後回到皮膚界面，
# 長按皮膚，選擇「運行 main.jsonnet」生效。
#
# 包含 T9 數字九宮格佈局的按鍵
# （各鍵以 character 送出「方案沒用到的字元鍵」進 RIME，由
#   user_predict.lua 的 NUMPAD_MAP 映射回數字上屏：組字/聯想中
#   按下時只會丟棄候選、絕不連帶上屏。
#   不用 symbol——前端插字前會把組字上屏（搶候選）；
#   不用 sendKeys KP_*——元書實測不認 keypad 鍵名。）
# =====================================

local commonButtons = import './Common.libsonnet';

{
  local root = self,

  // ===== 數字鍵（text 顯示數字，character 為 lua 映射用的替身鍵） =====
  numOneButton:   { name: 'numOneButton',   params: { action: { character: '(' }, text: '1' } },
  numTwoButton:   { name: 'numTwoButton',   params: { action: { character: ')' }, text: '2' } },
  numThreeButton: { name: 'numThreeButton', params: { action: { character: '[' }, text: '3' } },
  numFourButton:  { name: 'numFourButton',  params: { action: { character: ']' }, text: '4' } },
  numFiveButton:  { name: 'numFiveButton',  params: { action: { character: '{' }, text: '5' } },
  numSixButton:   { name: 'numSixButton',   params: { action: { character: '}' }, text: '6' } },
  numSevenButton: { name: 'numSevenButton', params: { action: { character: ';' }, text: '7' } },
  numEightButton: { name: 'numEightButton', params: { action: { character: ':' }, text: '8' } },
  numNineButton:  { name: 'numNineButton',  params: { action: { character: '"' }, text: '9' } },
  numZeroButton:  { name: 'numZeroButton',  params: { action: { character: '|' }, text: '0' } },
  numCommaButton: { name: 'numCommaButton', params: { action: { character: '&' }, text: ',' } },
  numDotButton:   { name: 'numDotButton',   params: { action: { character: '_' }, text: '.' } },

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

  // ===== 左側欄運算符（字元不是注音碼，直接送本尊） =====
  numPlusButton:     { name: 'numPlusButton',     params: { action: { character: '+' }, text: '+' } },
  numMinusButton:    { name: 'numMinusButton',    params: { action: { character: '-' }, text: '-' } },
  numMultiplyButton: { name: 'numMultiplyButton', params: { action: { character: '*' }, text: '*' } },
  numSlashButton:    { name: 'numSlashButton',    params: { action: { character: '/' }, text: '/' } },

  operatorButtons: [
    self.numPlusButton,
    self.numMinusButton,
    self.numMultiplyButton,
    self.numSlashButton,
  ],

  // ===== 右側欄功能鍵 =====

  // 等號鍵：長按選其他符號（與注音鍵盤上的等號鍵相同，
  // character 進 RIME，user_predict.lua 的 RAW_SYMBOL_KEYS 攔截上屏）。
  // 半形冒號例外：「:」字元是 8 鍵的替身（NUMPAD_MAP 會轉成 8），
  // 所以送方案字母表沒用到的大寫 H 當替身鍵，由 SYMBOL_MAP 轉回「:」。
  numEqualButton: {
    name: 'numEqualButton',
    params: {
      action: { character: '=' },
      text: '=',
      # 右緣按鍵：氣泡往左展開，依 v2 視覺順序（> < % ~ $）、
      # 新增的 : 排最左，預設仍選最右的 $
      longPress: [
        { text: ':', action: { character: 'H' } },
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
