PROMPT='%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )'
PROMPT+=' %{$fg_bold[cyan]%}%n%{$reset_color%} '
PROMPT+='%F{141}%c%{$reset_color%} $(git_prompt_info)'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}%{$fg_bold[blue]%}) %{$reset_color%}"
