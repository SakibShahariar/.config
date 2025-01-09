# ✨ Alias Customization - for smooth workflow
alias nano='micro'    
# Make nano open in micro to avoid conflicts

# 🛠️ Sudo Function Override - nano to micro with sudo
function sudo
    # Check if the first argument is nano
    if test $argv[1] = 'nano'
        # Replace nano with micro
        command sudo micro $argv[2..-1]
    else
        # Otherwise, call sudo normally
        command sudo $argv
    end
end

# ⌨️ Typewriter Function for a Cool Greeting
function typewrite
    for arg in $argv
        for i in (seq (string length $arg))
            echo -n (string sub -s $i -l 1 $arg)
            sleep 0.01
        end
    end
    echo ""
end

# 🌟 Personalized Greeting Message
function fish_greeting
    typewrite "" 
    typewrite " 🌞 Hello, " (whoami) "!"
    typewrite " Welcome back! Today is " (date '+%A, %B %d, %Y') "."
    typewrite " Remember, every day is a new opportunity to shine! 🚀"
    typewrite ""
end

# 🌱 Yazi with Custom CWD
function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end

# 🎨 Oh-My-Posh Theme Initialization
oh-my-posh init fish --config $HOME/.poshthemes/1_shell.omp.json | source

# 🚀 Aliases for Quick Actions
alias weather='curl wttr.in'   
alias dotgit="git --git-dir=$HOME/.dotfiles_repo/ --work-tree=$HOME"  
alias in="sudo dnf install"    
alias update="sudo dnf update; flatpak update; sudo fwupdmgr update"  
alias grub_refresh="sudo grub2-mkconfig -o /boot/grub2/grub.cfg"  
alias fish_edit="micro .config/fish/config.fish"  
alias fish_refresh="source ~/.config/fish/config.fish"  
alias anime="fastanime --icons --fzf --preview anilist"  
alias starwars="telnet towel.blinkenlights.nl"
alias clock="tty-clock -c -C 2"

# 🖥️ Interactive Session Configuration
if status is-interactive
    # Commands to run in interactive sessions can go here
end

# 🌈 Terminal Color Configuration for Micro
export MICRO_TRUECOLOR=1  
# Enable true color support in Micro

# 🧩 Custom Path Modification for Smooth Workflow
set -x PATH /usr/bin:/usr/local/bin $PATH

# 🚀 Zoxide Setup for Fast Directory Navigation
zoxide init fish | source

source $HOME/.cargo/env
