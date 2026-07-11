// 此精簡版皮膚僅保留 T9 注音九宮格佈局。
// 其餘佈局（26/9/14/17/18/注音/西戈）的框架檔已移除，
// 需要時可從上游 kongshan-suying 取回並還原此處的分派邏輯。
local layoutT9Zhuyin = import './Pinyin/PinyinT9Zhuyin.libsonnet';

{
  new(isDark, isPortrait):
    layoutT9Zhuyin.new(isDark, isPortrait),
}
