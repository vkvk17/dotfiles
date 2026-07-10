## 快速部署

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/vkvk17/dotfiles.git
```

## 一、Chezmoi 核心逻辑

### 1. 两个关键目录
1. **源目录（仓库目录）**
   - `~/.local/share/chezmoi`
   - 这里是 Git 仓库，保存所有配置文件的原始副本和模板。
   - 这个目录一般会推送到 GitHub。
   - 文件命名规则：
     - `dot_bashrc` → 对应家目录隐藏文件 `~/.bashrc`
     - `dot_config/doom` → 对应 `~/.config/doom`

2. **目标目录**
   - `$HOME`（你的用户根目录）
   - `chezmoi apply` 会将源目录的文件同步到这里。

### 2. 核心工作流
1. `chezmoi add <文件>`：把本机现有配置复制到源目录进行托管。
2. 修改源目录文件（推荐使用 `chezmoi edit`）。
3. `chezmoi diff`：对比源目录文件和 HOME 目录真实文件的差异。
4. `chezmoi apply`：将源目录改动同步到系统家目录。
5. `chezmoi cd`：进入 chezmoi 仓库，执行 git 提交和推送。

## 二、安装与初始化

### 1. 一键安装（Linux / WSL / macOS）
```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```
验证安装：
```bash
chezmoi --version
```

### 2. 两种初始化方式

#### 方式 1：全新本地初始化（当前机器从零开始）
```bash
chezmoi init
```
该命令会在 `~/.local/share/chezmoi` 创建一个空的 Git 仓库。

#### 方式 2：从已有 GitHub 仓库拉取（换电脑 / 重装系统）
```bash
# 拉取仓库，但不自动应用到 HOME
chezmoi init git@github.com:你的用户名/dotfiles.git

# 拉取仓库并直接应用所有配置
chezmoi init --apply git@github.com:你的用户名/dotfiles.git
```

## 三、最常用核心命令详解

### 1. 托管文件：`chezmoi add`
作用：将本机已存在的配置复制到 chezmoi 源目录，加入版本管理。

```bash
chezmoi add ~/.bashrc
chezmoi add ~/.config/doom
chezmoi add --template ~/.config/doom/config.el
chezmoi add --force ~/.config/doom
```

执行后，源目录会自动生成对应结构，例如：
`~/.config/doom` → `~/.local/share/chezmoi/dot_config/doom`

### 2. 编辑托管文件：`chezmoi edit`
建议用内置命令编辑，避免直接修改源目录造成不同步问题。

```bash
chezmoi edit ~/.config/doom/config.el
chezmoi edit ~/.config/doom
```

修改后，源目录文件会更新；然后运行 `chezmoi apply` 同步到系统。

### 3. 预览变更：`chezmoi diff`
查看源目录文件与 HOME 目录真实文件的差异，防止误覆盖。

```bash
chezmoi diff
chezmoi diff ~/.config/doom
```

如果没有输出，说明两边文件一致。

### 4. 同步配置到系统：`chezmoi apply`
将源目录的改动应用到 HOME 目录。

```bash
chezmoi apply
chezmoi apply ~/.config/doom
chezmoi apply --dry-run
```

`--dry-run` 只预览变更，不会实际写入。

### 5. 拉取远程更新：`chezmoi update`
等价于 `git pull && chezmoi apply`。

```bash
chezmoi update
```

适合另一个设备推送更新后，本机执行一键同步。

### 6. 进入仓库：`chezmoi cd`
进入 `~/.local/share/chezmoi` 目录并执行 Git 操作。

```bash
chezmoi cd
git add .
git commit -m "更新 Doom Emacs 配置"
git push
```

### 7. 查看托管文件：`chezmoi managed`
列出所有由 chezmoi 托管的文件。

```bash
chezmoi managed
chezmoi managed | grep doom
```

### 8. 查看未托管文件：`chezmoi unmanaged`
列出源目录下尚未被托管的文件。

### 9. 打开源目录：`chezmoi open`
快速打开源目录中的文件或目录。

```bash
chezmoi open ~/.config/doom
```

### 10. 移除托管：`chezmoi remove`
仅从 chezmoi 管理中移除，不删除 HOME 目录的真实文件。

```bash
chezmoi remove ~/.config/doom
```

## 四、标准工作流示例（Doom Emacs）
1. 修改本地配置：`~/.config/doom/config.el`
2. 将改动同步到 chezmoi 源目录：
```bash
chezmoi add ~/.config/doom
```
3. 检查差异：
```bash
chezmoi diff
```
4. 同步到系统（可选）：
```bash
chezmoi apply
```
5. 提交并推送到 GitHub：
```bash
chezmoi cd
git add .
git commit -m "feat: 优化 posframe 弹窗大小，修复 WSL 中文输入"
git push
```

## 五、模板系统（多机器差异化配置）

### 1. 模板简介
模板文件后缀为 `.tmpl`，使用 `{{ }}` 语法，`chezmoi apply` 时会自动渲染变量。

### 2. 将普通文件转为模板
```bash
chezmoi add --template ~/.config/doom/config.el
```
源目录会生成：`dot_config/doom/config.el.tmpl`

### 3. 内置常用变量
- `.chezmoi.hostname`：主机名（用于区分不同机器）。
- `.chezmoi.os`：系统类型，可能值为 `linux` / `windows` / `darwin`。
- `.chezmoi.username`：用户名。
- `.chezmoi.arch`：架构，`amd64` / `arm64`。

### 4. 示例：根据环境切换配置
```elisp
;; WSL2 专属修复中文输入
{{ if eq .chezmoi.os "linux" }}
(setq pgtk-use-im-context-on-new-connection nil)
{{ else }}
;; macOS 配置
(setq doom-font (font-spec :size 15))
{{ end }}

;; 根据主机名切换字体大小
{{ if eq .chezmoi.hostname "wsl-ubuntu" }}
(setq doom-font (font-spec :family "WenQuanYi Micro Hei" :size 12))
{{ else }}
(setq doom-font (font-spec :family "WenQuanYi Micro Hei" :size 16))
{{ end }}
```

执行 `chezmoi apply` 时会自动渲染当前机器对应内容。

### 5. 自定义变量
在 `~/.config/chezmoi/chezmoi.toml` 中定义自有变量：

```toml
[data]
editor = "emacs"
email = "你的邮箱@xxx.com"
```

模板中引用：
```gotemplate
{{ .email }}
```

## 六、.chezmoiignore（忽略规则）

在源目录创建 `.chezmoiignore`，语法与 `.gitignore` 类似，用于排除不希望托管的文件。

示例：
```gitignore
# Doom 插件缓存，不上传
dot_config/doom/.local/
# 编译产物
**/*.elc
# 临时缓存
**/.cache
# Rime 词库缓存
dot_config/rime/userdb.txt
```

区别：
- `.chezmoiignore`：Chezmoi 不纳入版本管理。
- `.gitignore`：Git 不提交这些文件。

## 七、符号链接管理

### 1. 使用 `symlink_` 前缀创建软链接
在源目录中使用 `symlink_` 前缀，Chezmoi 会生成软链接而不是复制文件。

示例：
`symlink_dot_bashrc` 会生成 `~/.bashrc`，并指向源文件。

### 2. 命令方式创建软链接托管
```bash
chezmoi add --symlink ~/.bashrc
```

## 八、加密敏感配置

对于公开仓库，避免明文存放 Git Token、邮箱密码、API Key 等敏感信息。

Chezmoi 支持 Age 和 GPG 加密文件。

### 加密流程
1. 加密文件：
```bash
chezmoi encrypt ~/.config/doom/private.el
```
2. 该命令会生成 `private.el.age`，并删除明文文件。
3. 使用时执行：
```bash
chezmoi apply
```
4. 编辑加密文件：
```bash
chezmoi edit ~/.config/doom/private.el
```

## 九、一键部署新机器

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:你的用户名/dotfiles.git
```

部署完成后，可执行 Doom 初始化：
```bash
~/.config/emacs/bin/doom sync
```

## 十、高频问题与排查

1. **修改本地配置后仓库未更新**
   - 必须执行 `chezmoi add ~/.config/doom`。
   - Chezmoi 不会自动将本地改动同步到源目录。

2. **`chezmoi apply` 覆盖了本地修改**
   - 先运行 `chezmoi diff`，确认差异后再执行 `apply`。
   - 对重要文件进行备份。

3. **模板变量不生效**
   - 文件必须有 `.tmpl` 后缀。
   - 使用 `chezmoi add --template` 添加模板文件。

4. **推送 GitHub 时权限不足**
   - 使用 SSH 地址作为远程仓库。
   - 确保本机已配置 GitHub SSH key。

5. **仓库体积过大、上传缓慢**
   - 在 `.chezmoiignore` 中过滤缓存和编译文件。
   - 不要托管插件缓存目录。

6. **`chezmoi cd` 找不到 git**
   - 确认已执行 `chezmoi init`。

## 十一、常用命令速查表

```bash
chezmoi add FILE                # 托管文件
chezmoi edit FILE               # 编辑托管文件
chezmoi diff                    # 查看差异
chezmoi apply                   # 同步配置到系统
```

chezmoi update                  # 拉取远程并同步
chezmoi managed                 # 列出所有托管文件
chezmoi cd                      # 进入git仓库
```
### 初始化/部署
```bash
chezmoi init                    # 本地新建仓库
chezmoi init --apply repo       # 拉取并部署远程仓库
```
### 模板/加密
```bash
chezmoi add --template FILE     # 添加模板文件
chezmoi encrypt FILE            # 加密敏感文件
chezmoi remove FILE             # 取消托管
```
