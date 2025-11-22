
# Simple Flutter App with Bottom Navigation

## Overview

This document outlines the plan for creating a simple Flutter application with a bottom navigation bar.

## Features

*   **Bottom Navigation Bar:** A bottom tab bar with five buttons: Home, Chats, Search, Community, and Lens.
*   **Organized Screens:** Each tab has its own dedicated file for better organization.
*   **Custom AppBar:** A customized app bar on the home screen with a menu button, centered title, and search and add buttons.
*   **Top Navigation Bar:** A horizontal, swipeable top navigation bar on the home screen with sections for shorts, feature, videos, following, photos, music, forum, app, and files.

## Plan

1.  **Dependencies:** Use the default Flutter dependencies.
2.  **Screens:** Create a separate file for each screen:
    *   `lib/home_screen.dart`
    *   `lib/chats_screen.dart`
    *   `lib/search_screen.dart`
    *   `lib/community_screen.dart`
    *   `lib/lens_screen.dart`
3.  **Main Screen:** Create a `lib/main.dart` that will contain the bottom navigation logic and display the appropriate screen.
