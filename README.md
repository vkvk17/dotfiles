## 自动安装chezmoi、拉取仓库、同步所有配置到家目录
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply https://github.com/vkvk17/dotfiles.git
