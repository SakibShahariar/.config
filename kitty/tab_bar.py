from kitty.tabs import TabBar

# Gruvbox Color Palette
GRUVBOX_COLORS = {
    "bg": (40, 40, 40),       # Dark background
    "fg": (220, 220, 220),     # Light foreground text
    "active_bg": (180, 90, 40),  # Active tab background
    "inactive_bg": (60, 60, 60),  # Inactive tab background
    "active_fg": (220, 220, 220),  # Active tab text
    "inactive_fg": (130, 130, 130),  # Inactive tab text
    "border": (100, 100, 100),     # Border color for tabs
}

def draw_tab(tab, width, height, bg_color, fg_color, is_active, margin):
    """Draw a Gruvbox-themed tab with active/inactive colors."""
    if is_active:
        bg_color = GRUVBOX_COLORS["active_bg"]
        fg_color = GRUVBOX_COLORS["active_fg"]
    else:
        bg_color = GRUVBOX_COLORS["inactive_bg"]
        fg_color = GRUVBOX_COLORS["inactive_fg"]

    tab.draw_background(0, 0, width, height, bg_color)
    tab.draw_text(tab.get_title(), 10, 5, fg_color, 20)

def draw_tab_bar(tabs, width, height):
    """Draw the custom tab bar with Gruvbox theme."""
    num_tabs = len(tabs)
    if num_tabs == 0:
        return

    tab_width = width // num_tabs
    for index, tab in enumerate(tabs):
        x_position = tab_width * index
        draw_tab(tab, tab_width, height, GRUVBOX_COLORS["bg"], GRUVBOX_COLORS["fg"], tab.is_active, 10)
