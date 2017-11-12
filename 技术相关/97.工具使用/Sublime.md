#### 列模式
```
鼠标左键＋Option
或者鼠标中键
增加选择：Command，减少选择：Command+Shift
```

#### CTAGS跳转
ctrl+shift+鼠标左键

#### package control
Preference


#### 我的配置（Sublime2）
##### keyboard user
```
[
    //搜索相关 在所有文件中搜索
	{ "keys": ["ctrl+shift+f"], "command": "show_panel", "args": {"panel": "find_in_files"} },
    //查找文件
	{ "keys": ["super+e"], "command": "show_overlay", "args": {"overlay": "goto", "show_files": true} },
    //查找函数
	{ "keys": ["f7"], "command": "goto_symbol_in_project" },
	// 书签相关
    { "keys": ["f2"], "command": "next_bookmark" },
	{ "keys": ["shift+f2"], "command": "prev_bookmark" },
	{ "keys": ["ctrl+w"], "command": "toggle_bookmark" }
]
```

###### user
```
{
	"color_scheme": "Packages/Color Scheme - Default/Solarized (Light).tmTheme",
	"draw_white_space": "all",
    //"font_face": "Courier New",
    "font_face": "Monaco",
	"font_size": 17.0,
	"ignored_packages":
	[
		"Vintage"
	]
}
```