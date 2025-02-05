# ✨ General Setup
# --------------------------------------------------------
# Aliases and Editor Setup
alias nano='micro'       # Make nano open in micro
export MICRO_TRUECOLOR=1 # Enable true color support in Micro
set -gx EDITOR micro     # Set default editor to micro

# 🧩 Custom Path Modification
# --------------------------------------------------------
# Clear the previous PATH (if any)
set -e PATH

# Set the correct PATH including ~/Scripts first, followed by system directories
set -Ux PATH $PATH ~/Scripts /usr/bin /usr/local/bin /home/sakib/.local/bin /home/sakib/.cargo/bin /usr/local/sbin ~/sbin
set -Ux PATH /sbin /usr/sbin $PATH

# Starship Initialization (Prompt)
starship init fish | source

# 🎨 Oh-My-Posh Theme Initialization (optional)
# --------------------------------------------------------
# oh-my-posh init fish --config $HOME/.poshthemes/night-owl.omp.json | source
# night-owl
# 1_shell

# 🚀 Zoxide Setup for Fast Directory Navigation
# --------------------------------------------------------
zoxide init fish | source

# 🔧 Cargo Environment
# --------------------------------------------------------
source $HOME/.cargo/env

# 🌟 Greeting Message
# --------------------------------------------------------
function fish_greeting
    typewrite " 🌞 Hello, " (whoami) "!"
    typewrite " Welcome back! Today is " (date '+%A, %B %d, %Y') "."
    typewrite " Remember, every day is a new opportunity to shine! 🚀"
    typewrite ""
end

# ⌨️ Helper Functions
# --------------------------------------------------------

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
# --------------------------------------------------------
alias weather='curl wttr.in'
alias dotgit="git --git-dir=$HOME/.dotfiles_repo/ --work-tree=$HOME"
alias in="sudo dnf install"
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
alias grub_edit="sudo nano /etc/default/grub"
alias yy="yazi"
alias yys="sudo yazi"


# 🖥️ Interactive Session
# --------------------------------------------------------
if status is-interactive
    # Commands for interactive sessions go here
end
