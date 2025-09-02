alias dns_flush="sudo dscacheutil -flushcache;sudo killall -HUP mDNSResponder"
alias vi="nvim"

fish_vi_key_bindings

function close
    osascript -e "quit app \"$argv\""
end

zoxide init fish --cmd cd | source

function starship_transient_prompt_func
  starship module character
end

function starship_transient_rprompt_func
  starship module time
end

function fish_greeting
    # Do nothing — disables startup greeting
end

starship init fish | source
enable_transience

