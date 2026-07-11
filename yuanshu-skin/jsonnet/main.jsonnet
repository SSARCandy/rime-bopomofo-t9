local pinyinComponent = import 'Components/Pinyin.libsonnet';
local temp26Component = import 'Components/Pinyin/PinyinTemp26.libsonnet';
local alphabeticComponent = import 'Components/Alphabetic.libsonnet';
local numericComponent = import 'Components/Numeric.libsonnet';
local panelComponent = import 'Components/Panel.libsonnet';
local settings = import 'Settings.libsonnet';

// 精簡版：主鍵盤為 T9 注音、T9 數字，符號鍵盤使用元書內建
// （symbolicLayout: 'default'）。
// 注意：alphabetic（英文26鍵）必須保留——密碼/Email 等欄位會強制
// 切換到英文鍵盤類型，皮膚缺少該定義時鍵盤會顯示為空白。
// 日常英文輸入仍建議用 iOS 系統英文鍵盤（地球鍵切換）。
local nameToComponent = {
  pinyin: pinyinComponent,
  alphabetic: alphabeticComponent,
  numeric: numericComponent,
  panel: panelComponent,
  temp26Key: temp26Component,
};

local getFileName(componentName, isPortrait) =
  componentName + (if isPortrait then 'Portrait' else 'Landscape');

local config = {
  [name]: {
    iPhone: {
      portrait: getFileName(name, isPortrait=true),
      landscape: getFileName(name, isPortrait=false),
    },
    iPad: {
      portrait: getFileName(name, isPortrait=true),
      landscape: getFileName(name, isPortrait=false),
      floating: getFileName(name, isPortrait=true),
    },
  } for name in std.objectFields(nameToComponent)
};

// std.toString 生成的内容紧凑，生成速度快，但不易阅读，适合发布时使用
// std.manifestYamlDoc 生成的内容格式化良好，易于阅读，但生成速度慢，也更占用内存，适合在电脑上调试时使用
// 如果想让 debug=true，需要在命令行中使用 --tla-code debug=true 参数传入
function(debug=false)
  local toString =
    if debug then
      function(x) std.manifestYamlDoc(x, indent_array_in_object=false, quote_keys=false)
    else
      function(x) std.toString(x);
{
  'config.yaml': std.manifestYamlDoc(config, indent_array_in_object=true, quote_keys=false),
}
// 键盘布局文件: light/dark × portrait/landscape
+ std.foldl(function(acc, x) acc + x, [
  {
    [theme + '/' + getFileName(name, isPortrait=isPortrait) + '.yaml']:
      toString(nameToComponent[name].new(isDark=(theme == 'dark'), isPortrait=isPortrait))
    for name in std.objectFields(nameToComponent)
  }
  for theme in ['light', 'dark']
  for isPortrait in [true, false]
], {})
