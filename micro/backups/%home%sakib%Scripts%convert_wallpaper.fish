#!/usr/bin/env fish

# Configuration
set -q XDG_CACHE_HOME; or set XDG_CACHE_HOME $HOME/.cache
set -g log_file $XDG_CACHE_HOME/gowall-process.log
set -g valid_extensions png jpg jpeg gif bmp webp
set -g base_dirs \
    "/mnt/data/Wallpaper" \
    "/mnt/sda4/Wallpaper" \
    "/home/sakib/Pictures"

function show_error -a message
    zenity --error --width=400 --text="$message" --title="Error"
    exit 1
end

function check_dependencies
    if not command -q zenity
        show_error "Zenity is required but not installed.\nPlease install zenity first."
    end

    if not command -q gowall
        show_error "gowall is required but not installed.\nPlease install gowall first."
    end
end

function select_theme
    set -l themes \
        "arcdark" \
        "atomdark" \
        "catppuccin" \
        "cyberpunk" \
        "dracula" \
        "everforest" \
        "github-light" \
        "gruvbox" \
        "material" \
        "monokai" \
        "night-owl" \
        "nord" \
        "oceanic-next" \
        "onedark" \
        "rose-pine" \
        "shades-of-purple" \
        "solarized" \
        "srcery" \
        "sunset-aurant" \
        "sunset-saffron" \
        "sunset-tangerine" \
        "synthwave-84" \
        "tokyo-dark" \
        "tokyo-moon" \
        "tokyo-storm"

    set -l theme (zenity --list \
        --title="Select Theme" \
        --width=400 \
        --height=600 \
        --text="Select a theme from the list:" \
        --column="Available Themes" \
        $themes
    )

    if test -z "$theme"
        zenity --info --width=300 --text="No theme selected. Exiting."
        exit 0
    end

    echo $theme
end

function find_base_dir
    for dir in $base_dirs
        if test -d $dir
            echo $dir
            return 0
        end
    end
    show_error "No valid wallpaper directory found!\nChecked locations:\n"(string join "\n" $base_dirs)
end

function process_images -a theme
    set -l base_dir (find_base_dir)
    zenity --info --width=400 --text="Using wallpaper directory:\n<b>$base_dir</b>" --title="Directory Selected"

    set -l image_files (find $base_dir -type f \( \
        -iname "*.png" -o \
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.gif" -o \
        -iname "*.bmp" -o \
        -iname "*.webp" \
    \))

    if test (count $image_files) -eq 0
        show_error "No image files found in:\n$base_dir"
    end

    set -l total (count $image_files)
    set -l current 0
    set -l error_occurred 0

    for file in $image_files
        set current (math $current + 1)
        set percentage (math "floor(100 * $current / $total)")
        echo "$percentage"
        echo "# Processing [$current/$total] - "(basename "$file")
        
        if not gowall convert "$file" -t "$theme" >> $log_file 2>&1
            set error_occurred 1
            break
        end
    end | zenity --progress \
        --title="Processing Images" \
        --text="Starting image processing..." \
        --percentage=0 \
        --auto-close \
        --width=600

    if test $error_occurred -eq 1
        show_error "Failed to process file:\n$file\nCheck $log_file for details"
    end

    if test $status -ne 0
        show_error "Image processing canceled!\nOperation aborted by user."
    end
end

function main
    check_dependencies
    set -l theme (select_theme)
    process_images $theme
    zenity --info --width=400 \
        --text="✅ All images processed successfully!\n\nTheme: <b>$theme</b>\nDirectory: <b>$base_dir</b>" \
        --title="Processing Complete"
end

main