local layout26 = import './Pinyin/Pinyin26.libsonnet';

{
  new(isDark, isPortrait):
    layout26.new(isDark, isPortrait, layout26.KeyboardType.English),
}
