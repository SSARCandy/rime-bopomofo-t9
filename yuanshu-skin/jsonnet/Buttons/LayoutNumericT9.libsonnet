# =====================================
# 此文件用於自定義鍵盤按鍵功能。
# 可根據需要修改下方內容，調整各類按鍵的行為
# 修改完成後，保存本文件，然後回到皮膚界面，
# 長按皮膚，選擇「運行 main.jsonnet」生效。
#
# 包含 T9 數字九宮格佈局的按鍵
# （所有數字與符號均直接上屏，不經過 RIME）
# =====================================

local commonButtons = import './Common.libsonnet';

{
  local root = self,

  // ===== 數字鍵 =====
  numOneButton:   { name: 'numOneButton',   params: { action: { symbol: '1' } } },
  numTwoButton:   { name: 'numTwoButton',   params: { action: { symbol: '2' } } },
  numThreeButton: { name: 'numThreeButton', params: { action: { symbol: '3' } } },
  numFourButton:  { name: 'numFourButton',  params: { action: { symbol: '4' } } },
  numFiveButton:  { name: 'numFiveButton',  params: { action: { symbol: '5' } } },
  numSixButton:   { name: 'numSixButton',   params: { action: { symbol: '6' } } },
  numSevenButton: { name: 'numSevenButton', params: { action: { symbol: '7' } } },
  numEightButton: { name: 'numEightButton', params: { action: { symbol: '8' } } },
  numNineButton:  { name: 'numNineButton',  params: { action: { symbol: '9' } } },
  numZeroButton:  { name: 'numZeroButton',  params: { action: { symbol: '0' } } },
  numCommaButton: { name: 'numCommaButton', params: { action: { symbol: ',' } } },
  numDotButton:   { name: 'numDotButton',   params: { action: { symbol: '.' } } },

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
  numPlusButton:     { name: 'numPlusButton',     params: { action: { symbol: '+' } } },
  numMinusButton:    { name: 'numMinusButton',    params: { action: { symbol: '-' } } },
  numMultiplyButton: { name: 'numMultiplyButton', params: { action: { symbol: '*' } } },
  numSlashButton:    { name: 'numSlashButton',    params: { action: { symbol: '/' } } },

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
      action: { symbol: '=' },
      # 右緣按鍵：依 v2 視覺順序（> < % ~ $），預設選最右的 $
      longPress: [
        { text: '>', action: { symbol: '>' } },
        { text: '<', action: { symbol: '<' } },
        { text: '%', action: { symbol: '%' } },
        { text: '~', action: { symbol: '~' } },
        { text: '$', action: { symbol: '$' }, selected: true },
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
