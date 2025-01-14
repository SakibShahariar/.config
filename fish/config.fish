# ✨ General Setup
# ---------------------
alias nano='micro'       # Make nano open in micro
export MICRO_TRUECOLOR=1 # Enable true color support in Micro
set -gx EDITOR micro     # Set default editor to micro

# 🧩 Custom Path Modification
set -x PATH /usr/bin /usr/local/bin $PATH

# 🎨 Oh-My-Posh Theme Initialization
oh-my-posh init fish --config $HOME/.poshthemes/1_shell.omp.json | source

# 🚀 Zoxide Setup for Fast Directory Navigation
zoxide init fish | source

# 🔧 Cargo Environment
source $HOME/.cargo/env

# 🌟 Greeting Message
# ---------------------
function fish_greeting
    typewrite " 🌞 Hello, " (whoami) "!"
    typewrite " Welcome back! Today is " (date '+%A, %B %d, %Y') "."
    typewrite " Remember, every day is a new opportunity to shine! 🚀"
    typewrite ""
end

# ⌨️ Helper Functions
# ---------------------
# Sudo override to use micro instead of nano
function sudo
    if test $argv[1] = 'nano'
        command sudo micro $argv[2..-1]
    else
        command sudo $argv
    end
end

# Typewriter effect for text output
function typewrite
    for arg in $argv
        for i in (seq (string length $arg))
            echo -n (string sub -s $i -l 1 $arg)
            sleep 0.01
        end
    end
    echo ""
end

# Yazi with custom current working directory
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# FZF-based file search
function fzf_files
    set file (fzf)
    if test -n "$file"
        micro $file
    end
end
bind \cf 'fzf_files'  # Bind Ctrl+F to trigger fzf_files

# 🛠️ Aliases
# ---------------------
alias weather='curl wttr.in'
alias dotgit="git --git-dir=$HOME/.dotfiles_repo/ --work-tree=$HOME"
alias in="sudo dnf install"
alias update="sudo dnf update; flatpak update; sudo fwupdmgr update"
alias grub_refresh="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"
alias fish_edit="micro ~/.config/fish/config.fish"
alias fish_refresh="source ~/.config/fish/config.fish"
alias anime="fastanime --icons --fzf --preview anilist"
alias starwars="telnet towel.blinkenlights.nl"
alias clock="tty-clock -c -C 2"
alias kitty_edit="nano ~/.config/kitty/kitty.conf"
alias ff="fastfetch"
alias cp='rsync -a --progress'
alias re='sudo dnf remove'
alias pipes="pipes.sh -t 3"

# 🖥️ Interactive Session
# ---------------------
if status is-interactive
    # Commands for interactive sessions go here
end
